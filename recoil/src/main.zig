const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");

const main_level = @import("main_level.zig");
const MainLevel = main_level.MainLevel;
const MainLevelOptions = main_level.MainLevelOptions;

const splash_level = @import("splash_level.zig");
const SplashLevel = splash_level.SplashLevel;
const SplashLevelOptions = splash_level.SplashLevelOptions;

const slog = std.log.scoped(.main);

// TODO: seed
pub var rnd = std.rand.DefaultPrng.init(0);
pub var frame_count: u32 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
pub const log_level: std.log.Level = .warn;
pub const log = util.log;

pub var prev_gamepad: u8 = undefined;

pub const LevelInitializer = union(enum) {
    splash_level: void,
    main_level: MainLevelOptions,
};

const LevelUnion = union(enum) {
    splash_level: SplashLevel,
    main_level: MainLevel,

    fn init(self: *LevelUnion, initializer: LevelInitializer) void {
        // Initialize new tag
        switch (initializer) {
            .splash_level => {
                self.* = LevelUnion{ .splash_level = undefined };
                self.splash_level.init();
            },
            .main_level => |o| {
                self.* = LevelUnion{ .main_level = undefined };
                self.main_level.init(o);
            },
        }
    }

    fn update(self: *LevelUnion) ?LevelInitializer {
        return switch (self.*) {
            LevelUnion.main_level => |*l| l.update(),
            LevelUnion.splash_level => |*l| l.update(),
        };
    }
};

test "level switch" {
    level.init(.splash_level);
    level.init(.main_level);
}

var level: LevelUnion = undefined;

export fn start() void {
    frame_count = 0;
    level.init(LevelInitializer.splash_level);
}

export fn update() void {
    frame_count += 1;

    if (level.update()) |next| {
        slog.debug("Switching level", .{});
        rnd = std.rand.DefaultPrng.init(frame_count);
        level.init(next);
    }

    prev_gamepad = platform.GAMEPAD1.*;
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
