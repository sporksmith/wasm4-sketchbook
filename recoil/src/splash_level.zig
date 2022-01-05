const platform = @import("platform.zig");
const main = @import("main.zig");

pub const SplashLevel = struct {
    const Self = @This();

    p1_ready: bool = false,
    p2_ready: bool = false,

    pub fn init(self: *Self) void {
        self.* = Self{ .p1_ready = false, .p2_ready = false };
    }

    pub fn update(self: *Self) ?main.LevelId {
        _ = self;

        var y: i32 = 0;
        const lines = .{
            "Gamepad 1:", //
            "Arrow Keys", //
            "\n", //
            "Gamepad 2:", //
            "ESDF", //
        };
        inline for (lines) |s| {
            platform.text(s, 0, y);
            y += 10;
        }

        if ((platform.GAMEPAD1.* & platform.BUTTON_UP) != 0) {
            self.p1_ready = true;
        }
        if ((platform.GAMEPAD2.* & platform.BUTTON_UP) != 0) {
            self.p2_ready = true;
        }

        if (!self.p1_ready) {
            platform.text("P1: Press \"up\"...", 0, 100);
        } else {
            platform.text("P1: Ready!", 0, 100);
        }

        if (!self.p2_ready) {
            platform.text("P2: Press \"up\"...", 0, 110);
        } else {
            platform.text("P2: Ready!", 0, 110);
        }

        if (self.p1_ready and self.p2_ready) {
            return .main_level;
        }

        return null;
    }
};
