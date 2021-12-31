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

var particles: Particles(50) = undefined;

export fn start() void {
    platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    frame_count = 0;
    particles.init();
}

export fn update() void {
    frame_count += 1;
    particles.draw();
}

fn Particles(comptime n: u32) type {
    return struct {
        const Self = @This();
        const n = n;

        xs: [n]u8,
        ys: [n]u8,

        fn create() Self {
            var p = Self{
                .xs = undefined,
                .ys = undefined,
            };
            var i: u8 = 0;
            while (i < Self.n) : (i += 1) {
                p.xs[i] = i * 2;
            }
            i = 0;
            while (i < Self.n) : (i += 1) {
                p.ys[i] = i * 3;
            }
            return p;
        }

        fn init(self: *Self) void {
            var i: u8 = 0;
            while (i < Self.n) : (i += 1) {
                self.xs[i] = i * 2;
            }
            i = 0;
            while (i < Self.n) : (i += 1) {
                self.ys[i] = i * 3;
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
