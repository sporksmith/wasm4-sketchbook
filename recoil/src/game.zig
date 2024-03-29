const std = @import("std");
const engine = @import("engine");

const platform_mod = engine.platform;
const Platform = platform_mod.Platform;
const platform = &platform_mod.platform;

const slog = std.log.scoped(.game);

const main_level = @import("main_level.zig");
const MainLevel = main_level.MainLevel;
const MainLevelOptions = main_level.MainLevelOptions;

const splash_level = @import("splash_level.zig");
const SplashLevel = splash_level.SplashLevel;
const SplashLevelOptions = splash_level.SplashLevelOptions;

pub const LevelInitializer = union(enum) {
    splash_level: void,
    main_level: MainLevelOptions,
};

pub const LevelUnion = union(enum) {
    const Self = @This();
    splash_level: SplashLevel,
    main_level: MainLevel,

    fn init(self: *Self, initializer: LevelInitializer) void {
        // Initialize new tag
        switch (initializer) {
            .splash_level => {
                self.* = .{ .splash_level = undefined };
                self.splash_level.init();
            },
            .main_level => |o| {
                self.* = .{ .main_level = undefined };
                self.main_level.init(o);
            },
        }
    }

    fn update(self: *LevelUnion) ?LevelInitializer {
        return switch (self.*) {
            .main_level => |*l| l.update(),
            .splash_level => |*l| l.update(),
        };
    }
};

pub const Game = struct {
    const Self = @This();
    rnd: std.rand.DefaultPrng = std.rand.DefaultPrng.init(0),
    frame_count: u32 = 0,
    level: LevelUnion = undefined,
    prev_gamepad: u8 = 0xff,

    pub fn init(self: *Self) void {
        self.level.init(LevelInitializer.splash_level);
    }

    pub fn update(self: *Self) void {
        self.frame_count += 1;

        if (self.level.update()) |next| {
            slog.debug("Switching level", .{});
            self.rnd = std.rand.DefaultPrng.init(self.frame_count);
            self.level.init(next);
        }

        self.prev_gamepad = platform.get_gamepad(.gamepad1);
    }
};

pub var game: Game = .{};
