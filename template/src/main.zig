const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");

// TODO: seed
var rnd = std.rand.DefaultPrng.init(0);
var frame_count: u64 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
pub const log_level: std.log.Level = .warn;
pub const log = util.log;

export fn start() void {
    platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    frame_count = 0;
}

export fn update() void {
    frame_count += 1;
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
