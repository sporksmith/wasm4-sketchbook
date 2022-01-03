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

var particles: Particles(200) = undefined;

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

        xs: [n]i16,
        ys: [n]i16,
        spxs: [n]i16,
        spys: [n]i16,
        vxs: [n]i8,
        vys: [n]i8,

        fn init(self: *Self) void {
            var i: u8 = 0;
            while (i < Self.n) : (i += 1) {
                self.xs[i] = platform.CANVAS_SIZE / 2;
                self.ys[i] = platform.CANVAS_SIZE / 2;
                self.vxs[i] = rnd.random().intRangeAtMost(i8, -50, 50);
                self.vys[i] = rnd.random().intRangeAtMost(i8, -50, 50);
                self.spxs[i] = 0;
                self.spys[i] = 0;
            }
        }

        fn update(self: *Self) void {
            var i: u8 = 0;
            while (i < Self.n) : (i += 1) {
                self.spxs[i] = self.spxs[i] + self.vxs[i];
                self.xs[i] = @mod(self.xs[i] + @divTrunc(self.spxs[i], 100), platform.CANVAS_SIZE);
                self.spxs[i] = @rem(self.spxs[i], 100);

                self.spys[i] = self.spys[i] + self.vys[i];
                self.ys[i] = @mod(self.ys[i] + @divTrunc(self.spys[i], 100), platform.CANVAS_SIZE);
                self.spys[i] = @rem(self.spys[i], 100);
            }
        }

        fn draw(self: Self) void {
            var i: u8 = 0;
            while (i < Self.n) : (i += 1) {
                platform.rect(self.xs[i], self.ys[i], 1, 1);
            }
        }
    };
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
