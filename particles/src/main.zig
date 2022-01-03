const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// TODO: seed
var rnd = std.rand.DefaultPrng.init(0);
var frame_count: u64 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
//pub const log_level: std.log.Level = .debug;
pub const log = util.log;

var particles: Particles(6000) = undefined;

export fn start() void {
    platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    frame_count = 0;
    particles.init();
}

export fn update() void {
    frame_count += 1;
    particles.update();
    particles.draw();
}

fn add_velocity(pos: u16, vel: i16) u16 {
    const pos32 = @as(i32, pos);
    const vel32 = @as(i32, vel);
    const sum = pos32 + vel32;
    const max = @as(i32, platform.CANVAS_SIZE) << 8;
    return @intCast(u16, if (sum > 0) @mod(sum, max) else max + sum);
}

test "add_velocity" {
    try expectEqual(@as(u16, 2), add_velocity(1, 1));

    // 0xa000 is CANVAS_SIZE shifted into the high 8 bits.
    try expectEqual(@as(u16, 0xa000), @as(u16, platform.CANVAS_SIZE) << 8);

    // 0x9fff is max position
    try expectEqual(@as(u16, 0x9fff), (@as(u16, platform.CANVAS_SIZE) << 8) - @as(u16, 1));

    // Adding 0 to max value is max value
    try expectEqual(@as(u16, 0x9fff), add_velocity(0x9fff, 0));

    // Adding 1 to max value is 0
    try expectEqual(@as(u16, 0), add_velocity(0x9fff, 1));

    // Subtracting 1 from 0 wraps around to max value
    try expectEqual(@as(u16, 0x9fff), add_velocity(0, -1));
}

fn Particles(comptime n: u32) type {
    return struct {
        const Self = @This();
        const n = n;

        xs: [n]u16,
        ys: [n]u16,
        vxs: [n]i16,
        vys: [n]i16,

        fn init(self: *Self) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.xs[i] = @as(u16, (platform.CANVAS_SIZE / 2) << 8) + @bitCast(u16, rnd.random().intRangeAtMost(i16, -10 * 256, 10 * 256));
                self.ys[i] = @as(u16, (platform.CANVAS_SIZE / 2) << 8) + @bitCast(u16, rnd.random().intRangeAtMost(i16, -10 * 256, 10 * 256));
                self.vxs[i] = rnd.random().intRangeAtMost(i16, -100, 100);
                self.vys[i] = rnd.random().intRangeAtMost(i16, -100, 100);
            }
        }

        fn update(self: *Self) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.xs[i] = add_velocity(self.xs[i], self.vxs[i]);
                self.ys[i] = add_velocity(self.ys[i], self.vys[i]);
            }
        }

        fn draw(self: Self) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                platform.rect(self.xs[i] >> 8, self.ys[i] >> 8, 1, 1);
            }
        }
    };
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
