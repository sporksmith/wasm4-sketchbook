const platform = @import("platform.zig");
const main = @import("main.zig");

pub const SplashLevel = struct {
    const Self = @This();

    pub fn init(self: *Self) void {
        _ = self;
    }

    pub fn update(self: *Self) ?main.LevelId {
        _ = self;

        var y: i32 = 0;
        const lines = .{
            "Controls:", //
            "\n", //
            "Arrow   : accelerate", //
            "Hold X", //
            " + Arrow: fire", //
            "Z       : brake", //
            "\n", //
            "WIP: Not much to", //
            "do here yet!", //
            "\n",
            "X to begin",
        };
        inline for (lines) |s| {
            platform.text(s, 0, y);
            y += 10;
        }

        if (platform.GAMEPAD1.* & platform.BUTTON_1 != 0) {
            return .main_level;
        }
        return null;
    }
};
