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

pub fn FixedPoint(comptime signed: bool, comptime whole_bits: u32, comptime frac_bits: u32) type {
    return struct {
        pub const Base = @Type(.{
            .Int = .{
                .signedness = if (signed) .signed else .unsigned,
                .bits = whole_bits + frac_bits,
            },
        });

        pub const Whole = @Type(.{
            .Int = .{
                .signedness = if (signed) .signed else .unsigned,
                .bits = whole_bits,
            },
        });

        val: Base,

        pub fn create(val: anytype) @This() {
            return @This(){ .val = @as(Base, @as(Whole, val)) << frac_bits };
        }

        pub fn fromFloat(val: anytype) @This() {
            return @This(){ .val = @floatToInt(Base, @intToFloat(@TypeOf(val), 1 << frac_bits) * val) };
        }

        pub fn toFloat(self: @This(), comptime T: type) T {
            return @intToFloat(T, self.val) / @intToFloat(T, 1 << frac_bits);
        }

        pub fn add(self: @This(), other: @This()) @This() {
            return @This(){ .val = self.val + other.val };
        }

        pub fn neg(self: @This()) @This() {
            return @This(){ .val = -self.val };
        }

        pub fn mod(self: @This(), other: @This()) @This() {
            return @This(){ .val = @mod(self.val, other.val) };
        }

        pub fn whole(self: @This()) Whole {
            return @intCast(Whole, self.val >> frac_bits);
        }

        pub fn idivTrunc(self: @This(), other: anytype) @This() {
            return @This(){ .val = @divTrunc(self.val, @as(Base, other)) };
        }
    };
}

test "fixed point floating point round trip" {
    const expectEqual = std.testing.expectEqual;
    const expectApproxEqAbs = std.testing.expectApproxEqAbs;
    const FP = FixedPoint(true, 8, 8);

    try expectEqual(@as(f32, 1.5), FP.fromFloat(1.5).toFloat(f32));
    try expectEqual(@as(f32, 1.75), FP.fromFloat(1.75).toFloat(f32));

    try expectApproxEqAbs(@as(f32, 1.1), FP.fromFloat(1.1).toFloat(f32), 1.0 / 256.0);
}

test {
    std.testing.refAllDecls(@This());
}

pub fn abs(x: anytype) @TypeOf(x) {
    return if (x >= 0) x else -x;
}
