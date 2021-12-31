const snakemod = @import("snake.zig");
const fruitmod = @import("fruit.zig");
const platform = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");
const Snake = snakemod.Snake;
const Point = snakemod.Point;
const Fruit = fruitmod.Fruit;

// TODO: seed
var rnd = std.rand.DefaultPrng.init(0);
var snake: Snake = undefined;
var fruit = Fruit.init(Point.init(0, 0));
var frame_count: u64 = undefined;

// Override default panic handler.
pub const panic = util.panic;

// Configure logging.
pub const log_level: std.log.Level = .warn;
pub const log = util.log;
export fn start() void {
    platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    frame_count = 0;
    snake = Snake.init();
    moveFruit();
}

const slog = std.log.scoped(.snek);

export fn update() void {
    frame_count += 1;

    input();

    if (snake.head_collides_with(fruit.position)) {
        slog.info("nom", .{});
        snake.grow();
        moveFruit();
    }

    if (snake.head_collides_with_body()) {
        slog.info("blargh", .{});
        start();
        return;
    }

    if (frame_count % 10 == 0) {
        snake.update();
    }
    if (frame_count % 250 == 0) {
        slog.info("yoink", .{});
        moveFruit();
    }
    snake.draw();
    fruit.draw();
}

fn moveFruit() void {
    var pt = Point.init(rnd.random().intRangeLessThan(i32, 0, 20), rnd.random().intRangeLessThan(i32, 0, 20));
    while (snake.head_collides_with(pt) or snake.body_collides_with(pt)) {
        pt = Point.init(rnd.random().intRangeLessThan(i32, 0, 20), rnd.random().intRangeLessThan(i32, 0, 20));
    }
    fruit.move(pt);
}

var prev_gamepad: u8 = 0;

fn input() void {
    const just_pressed = platform.GAMEPAD1.* ^ prev_gamepad;

    prev_gamepad = platform.GAMEPAD1.*;
    if (just_pressed != 0) {
        slog.debug("pressed: {d}", .{just_pressed});
    }

    if (just_pressed & platform.BUTTON_LEFT != 0) {
        snake.left();
    }
    if (just_pressed & platform.BUTTON_RIGHT != 0) {
        snake.right();
    }
    if (just_pressed & platform.BUTTON_UP != 0) {
        snake.up();
    }
    if (just_pressed & platform.BUTTON_DOWN != 0) {
        snake.down();
    }
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
