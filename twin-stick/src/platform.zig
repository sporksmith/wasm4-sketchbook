const std = @import("std");
const w4 = @import("wasm4.zig");
const tag = @import("builtin").os.tag;

const slog = std.log.scoped(.platform);

pub const CANVAS_SIZE = w4.CANVAS_SIZE;
pub const BUTTON_1: u8 = w4.BUTTON_1;
pub const BUTTON_2: u8 = w4.BUTTON_2;
pub const BUTTON_LEFT: u8 = w4.BUTTON_LEFT;
pub const BUTTON_RIGHT: u8 = w4.BUTTON_RIGHT;
pub const BUTTON_UP: u8 = w4.BUTTON_UP;
pub const BUTTON_DOWN: u8 = w4.BUTTON_DOWN;

var _DRAW_COLORS: u16 = undefined;
pub const DRAW_COLORS: *u16 = if (tag == .freestanding) w4.DRAW_COLORS else &_DRAW_COLORS;

var _PALETTE: [4]u32 = undefined;
pub const PALETTE: *[4]u32 = if (tag == .freestanding) w4.PALETTE else &_PALETTE;

var _FRAMEBUFFER: [CANVAS_SIZE * CANVAS_SIZE * 2 / 8]u8 = undefined;
pub const FRAMEBUFFER: *[6400]u8 = if (tag == .freestanding) w4.FRAMEBUFFER else &_FRAMEBUFFER;

var _GAMEPAD1: u8 = undefined;
pub const GAMEPAD1 = if (tag == .freestanding) w4.GAMEPAD1 else &_GAMEPAD1;

var _GAMEPAD2: u8 = undefined;
pub const GAMEPAD2 = if (tag == .freestanding) w4.GAMEPAD2 else &_GAMEPAD2;

pub const MOUSE_X = w4.MOUSE_X;
pub const MOUSE_Y = w4.MOUSE_Y;
pub const MOUSE_BUTTONS = w4.MOUSE_BUTTONS;

pub const MOUSE_LEFT = w4.MOUSE_LEFT;
pub const MOUSE_RIGHT = w4.MOUSE_RIGHT;
pub const MOUSE_MIDDLE = w4.MOUSE_MIDDLE;

fn _trace(x: [*:0]const u8) void {
    slog.debug("{s}\n", .{x});
}
pub const trace = if (tag == .freestanding) w4.trace else _trace;

fn _rect(x: i32, y: i32, width: u32, height: u32) void {
    slog.debug("rect(x:{} y:{} width:{} height:{}", .{ x, y, width, height });
}
pub const rect = if (tag == .freestanding) w4.rect else _rect;

fn _blit(sprite: [*]const u8, x: i32, y: i32, width: i32, height: i32, flags: u32) void {
    slog.debug("blit(sprite:{*} x:{} y:{} width:{} height:{} flags:{x}", .{ sprite, x, y, width, height, flags });
}
pub const blit = if (tag == .freestanding) w4.blit else _blit;

fn _line(x1: i32, y1: i32, x2: i32, y2: i32) void {
    slog.debug("line(x1:{} y1:{} x2:{} y2:{}", .{ x1, y1, x2, y2 });
}
pub const line = if (tag == .freestanding) w4.line else _line;

fn _tone(frequency: u32, duration: u32, volume: u32, flags: u32) void {
    slog.debug("tone(frequency:{} duration:{} volume:{} flags:{}", .{ frequency, duration, volume, flags });
}
pub const tone = if (tag == .freestanding) w4.tone else _tone;

pub const TONE_PULSE1 = w4.TONE_PULSE1;
pub const TONE_PULSE2 = w4.TONE_PULSE2;
pub const TONE_TRIANGLE = w4.TONE_TRIANGLE;
pub const TONE_NOISE = w4.TONE_NOISE;
pub const TONE_MODE1 = w4.TONE_MODE1;
pub const TONE_MODE2 = w4.TONE_MODE2;
pub const TONE_MODE3 = w4.TONE_MODE3;
pub const TONE_MODE4 = w4.TONE_MODE4;
