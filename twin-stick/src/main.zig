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

var player = Player.create();

export fn start() void {
    platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    frame_count = 0;
}

export fn update() void {
    frame_count += 1;

    player.update();
    player.draw();
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}

const Player = struct {
    x: u16,
    y: u16,
    vx: i16,
    vy: i16,

    const accel = 30;

    fn add_velocity(pos: u16, vel: i16) u16 {
        const pos32 = @as(i32, pos);
        const vel32 = @as(i32, vel);
        const sum = pos32 + vel32;
        const max = @as(i32, platform.CANVAS_SIZE) << 8;
        return @intCast(u16, if (sum > 0) @mod(sum, max) else max + sum);
    }

    pub fn create() Player {
        const middle = (platform.CANVAS_SIZE / 2) << 8;
        return Player{ .x = middle, .y = middle, .vx = 0, .vy = 0 };
    }

    pub fn update(self: *Player) void {
        const gamepad = platform.GAMEPAD1.*;
        if (gamepad & platform.BUTTON_LEFT != 0) {
            self.vx = self.vx - accel;
        } else if (gamepad & platform.BUTTON_RIGHT != 0) {
            self.vx = self.vx + accel;
        } else {
            // FIXME: this is way too fast to be noticeable
            //self.vx = @divTrunc(self.vx, 2);
        }

        if (gamepad & platform.BUTTON_UP != 0) {
            self.vy = self.vy - accel;
        } else if (gamepad & platform.BUTTON_DOWN != 0) {
            self.vy = self.vy + accel;
        } else {
            //self.vy = @divTrunc(self.vy, 2);
        }

        self.x = add_velocity(self.x, self.vx);
        self.y = add_velocity(self.y, self.vy);
    }

    fn draw(self: Player) void {
        platform.rect(self.x >> 8, self.y >> 8, 10, 10);
    }
};
