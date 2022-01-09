const platform_module = @import("platform.zig");
const util = @import("util.zig");
const std = @import("std");

const slog = std.log.scoped(.main);

const Platform = platform_module.Wasm4Platform;
var platform = Platform.create(.{});

const game_mod = @import("game.zig").for_platform(Platform);
const Game = game_mod.Game;

// Configure logging.
pub const log_level: std.log.Level = .warn;
pub fn log(comptime llevel: std.log.Level, comptime scope: @TypeOf(.EnumLiteral), comptime fmt: []const u8, args: anytype) void {
    platform.log(llevel, scope, fmt, args);
}

// Override default panic handler.
pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
    platform.panic(msg, error_return_trace);
}

var game: Game = .{ .platform = &platform };

export fn start() void {
    game.init();
}

export fn update() void {
    game.update();
}

test {
    // Pull in referenced decls and tests.
    std.testing.refAllDecls(@This());
}
