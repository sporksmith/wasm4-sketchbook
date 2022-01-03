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

var particles: Particles(200) = undefined;

export fn start() void {
    platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    frame_count = 0;
    particles.init();
}

export fn update() void {
    frame_count += 1;
    particles.update_and_draw();
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

fn abs(x: anytype) @TypeOf(x) {
    return if (x >= 0) x else -x;
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
                self.vxs[i] = rnd.random().intRangeAtMost(i16, -100, 200);
                self.vys[i] = rnd.random().intRangeAtMost(i16, -3000, 400);
            }
        }

        fn update_and_draw(self: *Self) void {
            var i: usize = 0;
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
