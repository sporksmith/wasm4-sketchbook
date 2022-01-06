const platform = @import("platform.zig");
const main = @import("main.zig");
const main_level = @import("main_level.zig");

const PlayerType = enum {
    gamepad1,
    gamepad2,
    random,

    pub fn string(self: @This()) [:0]const u8 {
        return switch (self) {
            .gamepad1 => "Gamepad 1 (Arrows)",
            .gamepad2 => "Gamepad 2 (ESDF)",
            .random => "AI",
        };
    }

    pub fn behavior(self: @This()) main_level.PlayerBehavior {
        return switch (self) {
            .gamepad1 => main_level.PlayerBehavior{ .Human = .{ .gamepad = platform.GAMEPAD1 } },
            .gamepad2 => main_level.PlayerBehavior{ .Human = .{ .gamepad = platform.GAMEPAD2 } },
            .random => main_level.PlayerBehavior.Random,
        };
    }
};

const MenuSelection = enum(u2) {
    p1,
    p2,
    start,

    pub fn string(self: @This()) [:0]const u8 {
        return switch (self) {
            .p1 => "Player 1",
            .p2 => "Player 2",
            .start => "START",
        };
    }
};

// Assumes enum is numbered sequentially from 0
fn enumNext(e: anytype) @TypeOf(e) {
    const EnumT = @TypeOf(e);
    const e_as_int = @enumToInt(e);
    const next_as_int = if (e_as_int == @typeInfo(EnumT).Enum.fields.len - 1) 0 else e_as_int + 1;
    return @intToEnum(EnumT, next_as_int);
}

// Assumes enum is numbered sequentially from 0
fn enumPrev(e: anytype) @TypeOf(e) {
    const EnumT = @TypeOf(e);
    const e_as_int = @enumToInt(e);
    const prev_as_int = if (e_as_int == 0) @typeInfo(EnumT).Enum.fields.len - 1 else e_as_int - 1;
    return @intToEnum(EnumT, prev_as_int);
}

pub const SplashLevel = struct {
    const Self = @This();

    p1_type: PlayerType = .gamepad1,
    p2_type: PlayerType = .random,
    menu_selection: MenuSelection = .start,
    prev_gamepad: u8 = 0xff,

    fn save(self: Self) void {
        const sz = 2;
        var buf: [sz]u8 = undefined;
        buf[0] = @enumToInt(self.p1_type);
        buf[1] = @enumToInt(self.p2_type);
        _ = platform.diskw(&buf, sz);
    }

    fn load(self: *Self) void {
        const sz = 2;
        var buf: [sz]u8 = undefined;
        if (platform.diskr(&buf, sz) == sz) {
            self.p1_type = @intToEnum(PlayerType, buf[0]);
            self.p2_type = @intToEnum(PlayerType, buf[1]);
        }
    }

    pub fn init(self: *Self) void {
        self.* = Self{};
        self.load();
    }

    fn create_mainlevel_init(self: *Self) main.LevelInitializer {
        _ = self;
        return main.LevelInitializer{ .main_level = .{ .p1_behavior = self.p1_type.behavior(), .p2_behavior = self.p2_type.behavior() } };
    }

    pub fn update(self: *Self) ?main.LevelInitializer {
        const just_pressed = platform.GAMEPAD1.* & ~self.prev_gamepad;

        if ((just_pressed & platform.BUTTON_DOWN) != 0) {
            self.menu_selection = enumNext(self.menu_selection);
        }
        if ((just_pressed & platform.BUTTON_UP) != 0) {
            self.menu_selection = enumPrev(self.menu_selection);
        }
        if ((just_pressed & platform.BUTTON_RIGHT) != 0) {
            switch (self.menu_selection) {
                .p1 => self.p1_type = enumNext(self.p1_type),
                .p2 => self.p2_type = enumNext(self.p2_type),
                .start => {
                    self.save();
                    return self.create_mainlevel_init();
                },
            }
        }
        if ((just_pressed & platform.BUTTON_LEFT) != 0) {
            switch (self.menu_selection) {
                .p1 => self.p1_type = enumPrev(self.p1_type),
                .p2 => self.p2_type = enumPrev(self.p2_type),
                .start => {
                    self.save();
                    return self.create_mainlevel_init();
                },
            }
        }

        const menu_color = 3;
        const selection_color = 2;

        platform.DRAW_COLORS.* = menu_color;
        platform.text(MenuSelection.p1.string(), 10, 10);
        platform.DRAW_COLORS.* = selection_color;
        platform.text(self.p1_type.string(), 10, 20);

        platform.DRAW_COLORS.* = menu_color;
        platform.text(MenuSelection.p2.string(), 10, 40);
        platform.DRAW_COLORS.* = selection_color;
        platform.text(self.p2_type.string(), 10, 50);

        platform.DRAW_COLORS.* = menu_color;
        platform.text(MenuSelection.start.string(), 10, 70);

        const selection_y: i32 = switch (self.menu_selection) {
            .p1 => 10,
            .p2 => 40,
            .start => 70,
        };
        platform.text(">", 0, selection_y);
        self.prev_gamepad = platform.GAMEPAD1.*;
        return null;
    }
};
