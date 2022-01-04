const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");

const MainLevel = @import("main_level.zig").MainLevel;
const SplashLevel = @import("splash_level.zig").SplashLevel;

// TODO: seed
pub var rnd = std.rand.DefaultPrng.init(0);
pub var frame_count: u64 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
//pub const log_level: std.log.Level = .warn;
pub const log = util.log;

pub var prev_gamepad: u8 = undefined;

const LevelUnion = union(enum) {
    splash_level: SplashLevel,
    main_level: MainLevel,

    fn init(self: *LevelUnion, id: LevelId) void {
        // Initialize new tag
        switch (id) {
            .splash_level => {
                self.* = LevelUnion{ .splash_level = undefined };
                self.splash_level.init();
            },
            .main_level => {
                self.* = LevelUnion{ .main_level = undefined };
                self.main_level.init();
            },
        }
    }

    fn update(self: *LevelUnion) ?LevelId {
        return switch (self.*) {
            LevelUnion.main_level => |*l| l.update(),
            LevelUnion.splash_level => |*l| l.update(),
        };
    }
};
pub const LevelId = std.meta.Tag(LevelUnion);

test "level switch" {
    level.init(.splash_level);
    level.init(.main_level);
}

var level: LevelUnion = undefined;

export fn start() void {
    frame_count = 0;
    level.init(.splash_level);
}

export fn update() void {
    frame_count += 1;

    if (level.update()) |next| {
        platform.trace("Switching level");
        rnd = std.rand.DefaultPrng.init(frame_count);
        level.init(next);
    }

    prev_gamepad = platform.GAMEPAD1.*;
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
