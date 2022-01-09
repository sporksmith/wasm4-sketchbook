const std = @import("std");
const builtin = @import("builtin");

const engine = @import("engine");
const platform_mod = engine.platform;
const platform = &platform_mod.platform;

const game_mod = @import("game.zig");
const Game = game_mod.Game;
const game = &game_mod.game;

pub const log_level: std.log.Level = .debug;

usingnamespace engine.Prelude(platform);

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
