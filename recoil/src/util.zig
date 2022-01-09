const std = @import("std");
const w4 = @import("wasm4.zig");

const platform_mod = @import("platform.zig");
const Platform = platform_mod.Platform;
const platform = &platform_mod.platform;

fn pack(dst: []u8, val: anytype) []u8 {
    const T = comptime @TypeOf(val);
    const src = @ptrCast(*const [@sizeOf(T)]u8, &val);
    if (dst.len < @sizeOf(T)) {}
    std.mem.copy(u8, dst[0..@sizeOf(T)], src);
    return dst[@sizeOf(T)..];
}

fn charType(c: u8) ?type {
    return switch (c) {
        '%' => null,
        'd', 'c' => i32,
        'x' => u32,
        'f' => f64,
        's' => u32,
        else => unreachable,
    };
}

/// Wrapper around w4.tracef. Currently doesn't support strings.
/// Probably better off using the logging framework with `log`, below,
/// but using this instead can save a little bit of cart space.
///
/// Examples:
/// {
///   util.tracef("literal terminated %s", .{"hi"});
/// }
/// {
///   var s: [10:0]u8 = undefined;
///   s[0]= 'h';
///   s[1]= 'i';
///   util.tracef("terminated type, but not terminated at runtime: %s", .{s});
/// }
/// {
///   var s: [10:0]u8 = undefined;
///   s[0]= 'h';
///   s[1]= 'i';
///   s[2]= 0;
///   util.tracef("terminated type, terminated at runtime: %s", .{s});
/// }
/// {
///   // Correctly doesn't compile
///   //var s: [10]u8 = undefined;
///   //util.tracef("unterminated %s", .{s});
/// }
pub fn tracef(comptime msg: [:0]const u8, args: anytype) void {
    comptime var space_needed = 0;
    {
        comptime var msg_idx = 0;
        inline while (msg_idx < msg.len) : (msg_idx += 1) {
            if (msg[msg_idx] != '%') {
                continue;
            }
            msg_idx += 1;
            const T = charType(msg[msg_idx]) orelse continue;
            space_needed += @sizeOf(T);
        }
    }

    if (space_needed == 0) {
        // Nothing to format - short-circuit to simpler API.  (This is mostly to
        // avoid the zero-length-buffer edge case below).
        platform.trace(msg);
        return;
    }

    var buf: [space_needed]u8 = undefined;
    var buf_slice: []u8 = buf[0..];
    comptime var arg_idx: usize = 0;
    comptime var msg_idx: usize = 0;
    inline while (msg_idx < msg.len) : (msg_idx += 1) {
        if (msg[msg_idx] != '%') {
            continue;
        }
        msg_idx += 1;
        switch (msg[msg_idx]) {
            '%' => {},
            'd', 'c', 'x', 'f' => |c| {
                const T = charType(c) orelse unreachable;
                buf_slice = pack(buf_slice, @as(T, args[arg_idx]));
                arg_idx += 1;
            },
            's' => {
                const s: [*:0]const u8 = switch (@typeInfo(@TypeOf(args[arg_idx]))) {
                    .Pointer => args[arg_idx],
                    .Array => &args[arg_idx],
                    else => unreachable,
                };
                const T = charType('s') orelse unreachable;
                buf_slice = pack(buf_slice, @as(T, @ptrToInt(s)));
                arg_idx += 1;
            },
            else => unreachable,
        }
    }
    platform.tracef(msg.ptr, &buf);
}

pub fn add_velocity(pos: u16, vel: i16) u16 {
    const pos32 = @as(i32, pos);
    const vel32 = @as(i32, vel);
    const sum = pos32 + vel32;
    const max = @as(i32, Platform.CANVAS_SIZE) << 8;
    return @intCast(u16, if (sum > 0) @mod(sum, max) else max + sum);
}

pub fn abs(x: anytype) @TypeOf(x) {
    return if (x >= 0) x else -x;
}
