const std = @import("std");
const w4 = @import("wasm4.zig");
const tag = @import("builtin").os.tag;
const slog = std.log.scoped(.platform);

pub const TARGET_FPS = 60;
pub const CANVAS_SIZE = w4.CANVAS_SIZE;

pub const BUTTON_1: u8 = w4.BUTTON_1;
pub const BUTTON_2: u8 = w4.BUTTON_2;
pub const BUTTON_LEFT: u8 = w4.BUTTON_LEFT;
pub const BUTTON_RIGHT: u8 = w4.BUTTON_RIGHT;
pub const BUTTON_UP: u8 = w4.BUTTON_UP;
pub const BUTTON_DOWN: u8 = w4.BUTTON_DOWN;

pub const MOUSE_LEFT: u8 = w4.MOUSE_LEFT;
pub const MOUSE_RIGHT: u8 = w4.MOUSE_RIGHT;
pub const MOUSE_MIDDLE: u8 = w4.MOUSE_MIDDLE;

pub const SYSTEM_PRESERVE_FRAMEBUFFER: u8 = w4.SYSTEM_PRESERVE_FRAMEBUFFER;
pub const SYSTEM_HIDE_GAMEPAD_OVERLAY: u8 = w4.SYSTEM_HIDE_GAMEPAD_OVERLAY;

pub const BLIT_2BPP: u32 = w4.BLIT_2BPP;
pub const BLIT_1BPP: u32 = w4.BLIT_1BPP;
pub const BLIT_FLIP_X: u32 = w4.BLIT_FLIP_X;
pub const BLIT_FLIP_Y: u32 = w4.BLIT_FLIP_Y;
pub const BLIT_ROTATE: u32 = w4.BLIT_ROTATE;

pub const TONE_PULSE1 = w4.TONE_PULSE1;
pub const TONE_PULSE2 = w4.TONE_PULSE2;
pub const TONE_TRIANGLE = w4.TONE_TRIANGLE;
pub const TONE_NOISE = w4.TONE_NOISE;
pub const TONE_MODE1 = w4.TONE_MODE1;
pub const TONE_MODE2 = w4.TONE_MODE2;
pub const TONE_MODE3 = w4.TONE_MODE3;
pub const TONE_MODE4 = w4.TONE_MODE4;

const Wasm4Backend = struct {
    const Self = @This();

    pub fn get_draw_colors(self: Self) u16 {
        _ = self;
        return w4.DRAW_COLORS.*;
    }
    pub fn set_draw_colors(self: *Self, draw_colors: u16) void {
        _ = self;
        w4.DRAW_COLORS.* = draw_colors;
    }

    pub fn get_mouse_x(self: Self) i16 {
        _ = self;
        return w4.MOUSE_X.*;
    }

    pub fn get_mouse_y(self: Self) i16 {
        _ = self;
        return w4.MOUSE_Y.*;
    }

    pub fn get_mouse_buttons(self: Self) u8 {
        _ = self;
        return w4.MOUSE_BUTTONS.*;
    }

    pub fn get_system_flags(self: Self) u8 {
        _ = self;
        return w4.SYSTEM_FLAGS.*;
    }
    pub fn set_system_flags(self: *Self, flags: u8) void {
        _ = self;
        w4.SYSTEM_FLAGS.* = flags;
    }

    pub fn get_framebuffer(self: *const Self) *const [6400]u8 {
        _ = self;
        return w4.FRAMEBUFFER;
    }
    pub fn get_framebuffer_mut(self: *Self) *[6400]u8 {
        _ = self;
        return w4.FRAMEBUFFER;
    }

    pub fn rect(self: *Self, x: i32, y: i32, width: u32, height: u32) void {
        _ = self;
        w4.rect(x, y, width, height);
    }

    pub fn trace(self: *Self, x: [*:0]const u8) void {
        _ = self;
        w4.trace(x);
    }

    pub fn blit(self: *Self, sprite: [*]const u8, x: i32, y: i32, width: i32, height: i32, flags: u32) void {
        _ = self;
        w4.blit(sprite, x, y, width, height, flags);
    }

    pub fn line(self: *Self, x1: i32, y1: i32, x2: i32, y2: i32) void {
        _ = self;
        w4.line(x1, y1, x2, y2);
    }

    pub fn tone(self: *Self, frequency: u32, duration: u32, volume: u32, flags: u32) void {
        _ = self;
        w4.tone(frequency, duration, volume, flags);
    }

    pub fn text(self: *Self, str: [*:0]const u8, x: i32, y: i32) void {
        _ = self;
        w4.text(str, x, y);
    }

    pub fn diskr(self: Self, dest: [*]u8, size: u32) u32 {
        _ = self;
        return w4.diskr(dest, size);
    }

    pub fn diskw(self: *Self, src: [*]const u8, size: u32) u32 {
        _ = self;
        return w4.diskw(src, size);
    }

    pub fn get_gamepad1(self: Self) u8 {
        _ = self;
        return w4.GAMEPAD1.*;
    }

    pub fn get_gamepad2(self: Self) u8 {
        _ = self;
        return w4.GAMEPAD2.*;
    }
};

const TestBackend = struct {
    const Self = @This();

    _DRAW_COLORS: u16 = 0,
    _PALETTE: [4]u32 = .{ 0, 0, 0, 0 },
    _FRAMEBUFFER: [Self.CANVAS_SIZE * Self.CANVAS_SIZE * 2 / 8]u8 = .{0} ** (Self.CANVAS_SIZE * Self.CANVAS_SIZE * 2 / 8),
    _GAMEPAD1: u8 = 0,
    _GAMEPAD2: u8 = 0,
    _MOUSE_X: i16 = 0,
    _MOUSE_Y: i16 = 0,
    _MOUSE_BUTTONS: u8 = 0,
    _SYSTEM_FLAGS: u8 = 0,

    pub fn get_draw_colors(self: Self) u16 {
        return self._DRAW_COLORS.*;
    }
    pub fn set_draw_colors(self: *Self, draw_colors: u16) void {
        self._DRAW_COLORS.* = draw_colors;
    }

    pub fn get_mouse_x(self: Self) i16 {
        return self._MOUSE_X.*;
    }

    pub fn get_mouse_y(self: Self) i16 {
        return self._MOUSE_Y.*;
    }

    pub fn get_mouse_buttons(self: Self) u8 {
        return self._MOUSE_BUTTONS.*;
    }

    pub fn get_system_flags(self: Self) u8 {
        return self._SYSTEM_FLAGS.*;
    }
    pub fn set_system_flags(self: *Self, flags: u8) void {
        self._SYSTEM_FLAGS.* = flags;
    }

    pub fn get_framebuffer(self: *const Self) *const [6400]u8 {
        return &self._FRAMEBUFFER;
    }
    pub fn get_framebuffer_mut(self: *Self) *[6400]u8 {
        return &self._FRAMEBUFFER;
    }

    pub fn rect(self: *Self, x: i32, y: i32, width: u32, height: u32) void {
        _ = self;
        slog.debug("rect(x:{} y:{} width:{} height:{}", .{ x, y, width, height });
    }

    pub fn trace(self: *Self, x: [*:0]const u8) void {
        _ = self;
        slog.debug("{s}\n", .{x});
    }

    pub fn blit(self: *Self, sprite: [*]const u8, x: i32, y: i32, width: i32, height: i32, flags: u32) void {
        _ = self;
        slog.debug("blit(sprite:{x} x:{} y:{} width:{} height:{} flags:{})", .{ sprite, x, y, width, height, flags });
    }

    pub fn line(self: *Self, x1: i32, y1: i32, x2: i32, y2: i32) void {
        _ = self;
        slog.debug("line(x1:{}, y1:{}, x2:{}, y2:{}", .{ x1, y1, x2, y2 });
    }

    pub fn tone(self: *Self, frequency: u32, duration: u32, volume: u32, flags: u32) void {
        _ = self;
        slog.tone("tone(frequency:{} duration:{} volume:{} flags:{}", .{ frequency, duration, volume, flags });
    }

    pub fn text(self: *Self, str: [*:0]const u8, x: i32, y: i32) void {
        _ = self;
        slog.debug("text(str:{s} x:{} y:{}", .{ str, x, y });
    }

    pub fn diskr(self: Self, dest: [*]u8, size: u32) u32 {
        _ = self;
        slog.debug("diskr(dest:{x} size:{}", .{ dest.ptr, size });
    }

    pub fn diskw(self: *Self, src: [*]const u8, size: u32) u32 {
        _ = self;
        slog.debug("diskw(src:{x} size:{}", .{ src.ptr, size });
        return size;
    }

    pub fn get_gamepad1(self: Self) u8 {
        return self._GAMEPAD1;
    }

    pub fn get_gamepad2(self: Self) u8 {
        return self._GAMEPAD2;
    }
};

fn Platform(Backend: anytype) type {
    return struct {
        const Self = @This();
        _backend: Backend,

        pub fn create(backend: Backend) Self {
            return Self{ ._backend = backend };
        }

        pub const DrawColors = struct {
            dc1: u4 = 0,
            dc2: u4 = 0,
            dc3: u4 = 0,
            dc4: u4 = 0,
        };
        pub fn get_draw_colors(self: Self) DrawColors {
            const raw = self._backend.draw_colors();
            return .{ .dc1 = raw & 0xf, .dc2 = (raw << 4) & 0xf, .dc3 = (raw << 8) & 0xf, .dc4 = (raw << 12) & 0xf };
        }
        pub fn set_draw_colors(self: *Self, draw_colors: DrawColors) void {
            const dc = draw_colors;
            std.debug.assert(dc.dc1 <= 4);
            std.debug.assert(dc.dc2 <= 4);
            std.debug.assert(dc.dc3 <= 4);
            std.debug.assert(dc.dc4 <= 4);
            self._backend.set_draw_colors(@as(u16, dc.dc4) << 12 | @as(u16, dc.dc3) << 8 | @as(u16, dc.dc2) << 4 | @as(u16, dc.dc1));
        }

        pub fn get_mouse_x(self: Self) i16 {
            return self._backend.mouse_x();
        }

        pub fn get_mouse_y(self: Self) i16 {
            return self._backend.mouse_y();
        }

        pub fn get_mouse_buttons(self: Self) u8 {
            return self._backend.mouse_buttons();
        }

        pub fn get_system_flags(self: Self) u8 {
            return self._backend.system_flags();
        }
        pub fn set_system_flags(self: *Self, flags: u8) void {
            return self._backend.set_system_flags(flags);
        }

        pub fn get_framebuffer(self: *const Self) *const [6400]u8 {
            return self._backend.framebuffer();
        }
        pub fn get_framebuffer_mut(self: *Self) *[6400]u8 {
            return self._backend.framebuffer_mut();
        }

        pub fn rect(self: *Self, x: i32, y: i32, width: u32, height: u32) void {
            self._backend.rect(x, y, width, height);
        }

        pub fn trace(self: *Self, x: [*:0]const u8) void {
            self._backend.trace(x);
        }

        pub fn blit(self: *Self, sprite: [*]const u8, x: i32, y: i32, width: i32, height: i32, flags: u32) void {
            self._backend.blit(sprite, x, y, width, height, flags);
        }

        pub fn line(self: *Self, x1: i32, y1: i32, x2: i32, y2: i32) void {
            self._backend.line(x1, y1, x2, y2);
        }

        pub fn tone(self: *Self, frequency: u32, duration: u32, volume: u32, flags: u32) void {
            self._backend.tone(frequency, duration, volume, flags);
        }

        pub fn diskr(self: Self, dest: [*]u8, size: u32) u32 {
            return self._backend.diskr(dest, size);
        }

        pub fn diskw(self: *Self, src: [*]const u8, size: u32) u32 {
            return self._backend.diskw(src, size);
        }

        pub fn get_gamepad1(self: Self) u8 {
            return self._backend.get_gamepad1();
        }

        pub fn get_gamepad2(self: Self) u8 {
            return self._backend.get_gamepad2();
        }

        /// Used by `std.log`, and partly cargo-culted from example in `std/log.zig`.
        /// Uses a fixed-size buffer on the stack and plumbs through w4.trace.
        const max_log_line_length = 200;
        pub fn log(self: *Self, comptime level: std.log.Level, comptime scope: @TypeOf(.EnumLiteral), comptime fmt: []const u8, args: anytype) void {
            const full_fmt = comptime "[" ++ level.asText() ++ "] (" ++ @tagName(scope) ++ ") " ++ fmt ++ "\x00";

            // This is a bit over-engineered, but notably removes the length
            // restriction for log messages that don't do any formatting.
            // This also lets us safely recurse below.
            switch (@typeInfo(@TypeOf(args))) {
                .Struct => |s| {
                    if (s.fields.len == 0) {
                        self.trace(full_fmt);
                        return;
                    }
                },
                else => {},
            }

            var buf: [max_log_line_length:0]u8 = undefined;
            _ = std.fmt.bufPrint(&buf, full_fmt, args) catch {
                std.log.warn("Failed to log: " ++ full_fmt, .{});
                return;
            };
            self.trace(&buf);
        }

        // Override panic behavior.
        pub fn panic(self: *Self, msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
            // Use raw calls to `trace` to minimize dependencies.
            self.trace("Panicking:");

            var buf: [200:0]u8 = .{0} ** 200;
            std.mem.copy(u8, &buf, msg[0..std.math.min(buf.len, msg.len)]);
            self.trace(&buf);

            // Easiest way to satisfy `noreturn`. Doesn't seem to report anything, but at least
            // returns control to the wasm engine with some kind of error.
            std.builtin.default_panic(msg, error_return_trace);
        }
    };
}

pub const Wasm4Platform = Platform(Wasm4Backend);
pub const TestPlatform = Platform(TestBackend);
