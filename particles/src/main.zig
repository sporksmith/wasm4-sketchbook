const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");

// TODO: seed
var rnd = std.rand.DefaultPrng.init(0);
var frame_count: u64 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
//pub const log_level: std.log.Level = .debug;
pub const log = util.log;

var particles: Particles(1000) = undefined;

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
                self.xs[i] = @mod(self.xs[i] +% @bitCast(u16, self.vxs[i]), platform.CANVAS_SIZE << 8);
                self.ys[i] = @mod(self.ys[i] +% @bitCast(u16, self.vys[i]), @as(u16, platform.CANVAS_SIZE << 8));
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
