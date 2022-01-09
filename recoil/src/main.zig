const std = @import("std");
const builtin = @import("builtin");

const platform_mod = @import("platform.zig");
const platform = &platform_mod.platform;

// Configure logging.
pub const log_level: std.log.Level = .warn;
pub fn log(comptime llevel: std.log.Level, comptime scope: @TypeOf(.EnumLiteral), comptime fmt: []const u8, args: anytype) void {
    platform.log(llevel, scope, fmt, args);
}

// Override default panic handler.
pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
    platform.panic(msg, error_return_trace);
}

const game_mod = @import("game.zig");
const Game = game_mod.Game;
const game = &game_mod.game;

export fn start() void {
    game.init();
}

export fn update() void {
    game.update();
}

test {
    // TODO: Make
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
