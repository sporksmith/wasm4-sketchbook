const std = @import("std");

pub const platform = @import("engine/platform.zig");
pub const util = @import("engine/util.zig");

/// To use: `usingnamespace @import("engine").prelude;`
pub fn Prelude(pplatform: anytype) type {
    return struct {
        // Configure logging.
        pub fn log(comptime llevel: std.log.Level, comptime scope: @TypeOf(.EnumLiteral), comptime fmt: []const u8, args: anytype) void {
            pplatform.log(llevel, scope, fmt, args);
        }

        // Override default panic handler.
        pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
            pplatform.panic(msg, error_return_trace);
        }
    };
}

//pub fn Engine(comptime PlatformParam: type, comptime GameParam: type) type {
//    return struct {
//        const Self = @This();
//        pub const Platform = PlatformParam;
//        pub const Game = GameParam;
//
//        platform: Platform,
//        game: Game,
//        rnd: std.rand.DefaultPrng = std.rand.DefaultPrng.init(0),
//        frame_count: u32 = 0,
//
//        // XXX: An Engine could easily be designed to fill all of memory on
//        // wasm4. How confident are we about RVO? Alternatively take an
//        // uninit'd pointer to self and init in place, but lots more room for
//        // error that way.
//        pub fn create(platform: Platform, game: Game) Engine {
//            return Self{
//                .platform = platform,
//                .game = game,
//            };
//        }
//
//        pub fn start(self: *Self) void {
//            self.game.start(self);
//        }
//
//        pub fn update(self: *Self) void {
//            self.game.update();
//            self.frame_count += 1;
//        }
//    };
//}
