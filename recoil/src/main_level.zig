const platform = @import("platform.zig");
const main = @import("main.zig");
const util = @import("util.zig");

const abs = util.abs;
const add_velocity = util.add_velocity;

pub const MainLevel = struct {
    const n_players = 2;

    players: [n_players]Player,
    bullets: Particles(10),

    pub fn init(self: *MainLevel) void {
        const middle = (platform.CANVAS_SIZE / 2) << 8;
        self.players[0] = Player.create((platform.CANVAS_SIZE / 3) << 8, middle, 3, platform.GAMEPAD1);
        self.players[1] = Player.create((platform.CANVAS_SIZE * 2 / 3) << 8, middle, 4, platform.GAMEPAD2);

        self.bullets.live = false;
        platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    }

    pub fn update(self: *MainLevel) ?main.LevelId {
        for (self.players) |*p| {
            p.update(self);
        }
        for (self.players) |p| {
            p.draw();
        }

        if (self.bullets.live) {
            self.bullets.update_and_draw();
        }

        return null;
    }
};

const Direction = enum {
    LEFT,
    RIGHT,
    UP,
    DOWN,
};

const Player = struct {
    x: u16,
    y: u16,
    vx: i16,
    vy: i16,
    draw_color: u8,
    gamepad: *const u8,
    prev_gamepad: u8 = 0,

    const width = 3;
    const height = 3;
    const accel = 30;

    pub fn create(x: u16, y: u16, draw_color: u8, gamepad: *const u8) Player {
        return Player{ .x = x, .y = y, .vx = 0, .vy = 0, .draw_color = draw_color, .gamepad = gamepad };
    }

    fn fire(self: *Player, level: *MainLevel, direction: Direction) void {
        const bullet_velocity = 1000;
        const bullet_spread = 20;
        const recoil = 1 << 8;
        const bullet_x = self.x + ((Player.width / 2) << 8);
        const bullet_y = self.y + ((Player.height / 2) << 8);
        level.bullets.live = true;
        level.bullets.init_xs(bullet_x, -bullet_spread, bullet_spread);
        level.bullets.init_ys(bullet_y, -bullet_spread, bullet_spread);

        var bullet_vx = self.vx;
        var bullet_vy = self.vy;
        switch (direction) {
            .LEFT => {
                bullet_vx -= bullet_velocity;
                self.vx += recoil;
            },
            .RIGHT => {
                bullet_vx += bullet_velocity;
                self.vx -= recoil;
            },
            .UP => {
                bullet_vy -= bullet_velocity;
                self.vy += recoil;
            },
            .DOWN => {
                bullet_vy += bullet_velocity;
                self.vy -= recoil;
            },
        }
        level.bullets.init_vxs(bullet_vx, -bullet_spread, bullet_spread);
        level.bullets.init_vys(bullet_vy, -bullet_spread, bullet_spread);

        platform.tone(370 | (160 << 16), (16 << 24) | 38, 15, platform.TONE_NOISE);
    }

    pub fn update(self: *Player, level: *MainLevel) void {
        const gamepad = self.gamepad.*;
        const just_pressed = gamepad & (gamepad ^ self.prev_gamepad);

        if (just_pressed & platform.BUTTON_LEFT != 0) {
            self.fire(level, .LEFT);
        }
        if (just_pressed & platform.BUTTON_RIGHT != 0) {
            self.fire(level, .RIGHT);
        }
        if (just_pressed & platform.BUTTON_UP != 0) {
            self.fire(level, .UP);
        }
        if (just_pressed & platform.BUTTON_DOWN != 0) {
            self.fire(level, .DOWN);
        }
        self.x = add_velocity(self.x, self.vx);
        self.y = add_velocity(self.y, self.vy);
        self.prev_gamepad = gamepad;
    }

    fn draw(self: Player) void {
        platform.DRAW_COLORS.* = self.draw_color;
        platform.rect(self.x >> 8, self.y >> 8, Player.width, Player.height);
    }
};

fn Particles(comptime n: u32) type {
    return struct {
        const Self = @This();
        const n = n;

        xs: [n]u16,
        ys: [n]u16,
        vxs: [n]i16,
        vys: [n]i16,
        live: bool,

        pub fn init_xs(self: *Self, x: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.xs[i] = x + @bitCast(u16, main.rnd.random().intRangeAtMost(i16, rand_min, rand_most));
            }
        }

        pub fn init_ys(self: *Self, y: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.ys[i] = y + @bitCast(u16, main.rnd.random().intRangeAtMost(i16, rand_min, rand_most));
            }
        }

        pub fn init_vxs(self: *Self, vx: i16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.vxs[i] = vx + main.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
            }
        }

        pub fn init_vys(self: *Self, vy: i16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.vys[i] = vy + main.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
            }
        }

        fn update_and_draw(self: *Self) void {
            var i: usize = 0;
            platform.DRAW_COLORS.* = 2;
            while (i < Self.n) : (i += 1) {
                const old_x = self.xs[i];
                const old_y = self.ys[i];
                const new_x = add_velocity(old_x, self.vxs[i]);
                const new_y = add_velocity(old_y, self.vys[i]);
                const abs_dx = abs(@intCast(i32, new_x) - @intCast(i32, old_x));
                const abs_dy = abs(@intCast(i32, new_y) - @intCast(i32, old_y));

                // Draw a line between old and new positions *if* it didn't wrap around the screen on this frame.
                if (abs_dx <= abs(self.vxs[i]) and abs_dy <= abs(self.vys[i])) {
                    platform.line(old_x >> 8, old_y >> 8, new_x >> 8, new_y >> 8);
                }

                self.xs[i] = new_x;
                self.ys[i] = new_y;
            }
        }
    };
}
