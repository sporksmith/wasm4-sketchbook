const std = @import("std");
const w4 = @import("wasm4.zig");
const builtin = @import("builtin");
const slog = std.log.scoped(.platform);

// Packages up constants we want to expose through Platform.
const Constants = struct {
    pub const CANVAS_SIZE = w4.CANVAS_SIZE;
    pub const TARGET_FPS = 60;

    pub const BUTTON_1: u8 = w4.BUTTON_1;
    pub const BUTTON_2: u8 = w4.BUTTON_2;
    pub const BUTTON_LEFT: u8 = w4.BUTTON_LEFT;
    pub const BUTTON_RIGHT: u8 = w4.BUTTON_RIGHT;
    pub const BUTTON_UP: u8 = w4.BUTTON_UP;
    pub const BUTTON_DOWN: u8 = w4.BUTTON_DOWN;
};

const MOUSE_LEFT: u8 = w4.MOUSE_LEFT;
const MOUSE_RIGHT: u8 = w4.MOUSE_RIGHT;
const MOUSE_MIDDLE: u8 = w4.MOUSE_MIDDLE;

const SYSTEM_PRESERVE_FRAMEBUFFER: u8 = w4.SYSTEM_PRESERVE_FRAMEBUFFER;
const SYSTEM_HIDE_GAMEPAD_OVERLAY: u8 = w4.SYSTEM_HIDE_GAMEPAD_OVERLAY;

const BLIT_2BPP: u32 = w4.BLIT_2BPP;
const BLIT_1BPP: u32 = w4.BLIT_1BPP;
const BLIT_FLIP_X: u32 = w4.BLIT_FLIP_X;
const BLIT_FLIP_Y: u32 = w4.BLIT_FLIP_Y;
const BLIT_ROTATE: u32 = w4.BLIT_ROTATE;

const TONE_PULSE1 = w4.TONE_PULSE1;
const TONE_PULSE2 = w4.TONE_PULSE2;
const TONE_TRIANGLE = w4.TONE_TRIANGLE;
const TONE_NOISE = w4.TONE_NOISE;
const TONE_MODE1 = w4.TONE_MODE1;
const TONE_MODE2 = w4.TONE_MODE2;
const TONE_MODE3 = w4.TONE_MODE3;
const TONE_MODE4 = w4.TONE_MODE4;

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
    _FRAMEBUFFER: [6400]u8 = .{0} ** (6400),
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
        self._DRAW_COLORS = draw_colors;
    }

    pub fn get_mouse_x(self: Self) i16 {
        return self._MOUSE_X;
    }

    pub fn get_mouse_y(self: Self) i16 {
        return self._MOUSE_Y;
    }

    pub fn get_mouse_buttons(self: Self) u8 {
        return self._MOUSE_BUTTONS;
    }

    pub fn get_system_flags(self: Self) u8 {
        return self._SYSTEM_FLAGS;
    }
    pub fn set_system_flags(self: *Self, flags: u8) void {
        self._SYSTEM_FLAGS = flags;
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
        std.debug.print("{s}\n", .{x});
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
        slog.debug("tone(frequency:{} duration:{} volume:{} flags:{}", .{ frequency, duration, volume, flags });
    }

    pub fn text(self: *Self, str: [*:0]const u8, x: i32, y: i32) void {
        _ = self;
        slog.debug("text(str:{s} x:{} y:{}", .{ str, x, y });
    }

    pub fn diskr(self: Self, dest: [*]u8, size: u32) u32 {
        _ = self;
        slog.debug("diskr(dest:{x} size:{}", .{ &dest[0], size });
        return size;
    }

    pub fn diskw(self: *Self, src: [*]const u8, size: u32) u32 {
        _ = self;
        slog.debug("diskw(src:{x} size:{}", .{ &src[0], size });
        return size;
    }

    pub fn get_gamepad1(self: Self) u8 {
        return self._GAMEPAD1;
    }

    pub fn get_gamepad2(self: Self) u8 {
        return self._GAMEPAD2;
    }
};

fn PlatformTemplate(Backend: anytype) type {
    return struct {
        const Self = @This();
        usingnamespace Constants;

        pub const DrawColor = u4;
        pub const DrawColors = struct {
            dc1: DrawColor = 0,
            dc2: DrawColor = 0,
            dc3: DrawColor = 0,
            dc4: DrawColor = 0,
        };

        pub const ToneChannel = enum(u32) {
            pulse1 = TONE_PULSE1,
            pulse2 = TONE_PULSE2,
            triangle = TONE_TRIANGLE,
            noise = TONE_NOISE,
        };

        pub const ToneDutyCycle = enum(u32) {
            c_12_5 = TONE_MODE1,
            c_25 = TONE_MODE2,
            c_50 = TONE_MODE3,
            c_75 = TONE_MODE4,
        };

        pub const ToneParams = struct {
            freq1: u16,
            freq2: u16 = 0,
            attack: u8 = 0,
            decay: u8 = 0,
            sustain: u8,
            release: u8 = 0,
            channel: ToneChannel,
            duty_cycle: ToneDutyCycle = .c_12_5,
            volume: u8 = 100,
        };

        pub const GamepadId = enum {
            gamepad1,
            gamepad2,
        };

        _backend: Backend,

        pub fn create(backend: Backend) Self {
            return Self{ ._backend = backend };
        }

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
            return self._backend.get_framebuffer();
        }
        pub fn get_framebuffer_mut(self: *Self) *[6400]u8 {
            return self._backend.get_framebuffer_mut();
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

        pub fn text(self: *Self, str: [*:0]const u8, x: i32, y: i32) void {
            self._backend.text(str, x, y);
        }

        pub fn diskr(self: Self, dest: [*]u8, size: u32) u32 {
            return self._backend.diskr(dest, size);
        }

        pub fn diskw(self: *Self, src: [*]const u8, size: u32) u32 {
            return self._backend.diskw(src, size);
        }

        pub fn get_gamepad(self: Self, gamepad_id: GamepadId) u8 {
            return switch (gamepad_id) {
                .gamepad1 => self._backend.get_gamepad1(),
                .gamepad2 => self._backend.get_gamepad2(),
            };
        }

        pub fn get_pixel(self: Self, x: u8, y: u8) DrawColor {
            const pixel_idx = @intCast(usize, y) * Self.CANVAS_SIZE + @intCast(usize, x);
            const byte_idx = pixel_idx / 4; // 4 pixels per byte
            const shift = @intCast(u3, pixel_idx & 0b11) * 2;
            const byte = self.get_framebuffer()[byte_idx];
            const rv = ((byte >> shift) & 0b11) + 1;
            //std.log.debug("get_pixel x:{} y:{} pixel_idx:{} byte_idx:{} shift:{} byte:{} rv:{}", .{ x, y, pixel_idx, byte_idx, shift, byte, rv });
            return @intCast(DrawColor, rv);
        }

        pub fn tone(self: *Self, params: ToneParams) void {
            const freq = @as(u32, params.freq1) | (@as(u32, params.freq2) << 16);
            const duration = (@as(u32, params.attack) << 24) | (@as(u32, params.decay) << 16) | @as(u32, params.sustain) | (@as(u32, params.release) << 8);
            const flags = @enumToInt(params.channel) | @enumToInt(params.duty_cycle);
            self._backend.tone(freq, duration, params.volume, flags);
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

pub const Wasm4Platform = PlatformTemplate(Wasm4Backend);
pub const TestPlatform = PlatformTemplate(TestBackend);

pub const Platform = if (!builtin.is_test) Wasm4Platform else TestPlatform;
pub var platform = Platform.create(.{});
