const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");
const main_level = @import("main_level.zig");

const MainLevel = main_level.MainLevel;

// TODO: seed
pub var rnd = std.rand.DefaultPrng.init(0);
pub var frame_count: u64 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
pub const log_level: std.log.Level = .warn;
pub const log = util.log;

pub var prev_gamepad: u8 = undefined;

const LevelUnion = union(enum) {
    main_level: MainLevel,

    fn init(self: *LevelUnion) void {
        switch (self.*) {
            .main_level => |*l| l.init(),
        }
    }

    fn update(self: *LevelUnion) void {
        switch (self.*) {
            LevelUnion.main_level => |*l| l.update(),
        }
    }
};
pub const LevelId = std.meta.Tag(LevelUnion);

var level: LevelUnion = undefined;

export fn start() void {
    frame_count = 0;
    level.main_level = undefined;
    level.init();
}

export fn update() void {
    frame_count += 1;
    level.update();
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
