const platform = @import("platform.zig");
const main = @import("main.zig");
const util = @import("util.zig");

const abs = util.abs;
const add_velocity = util.add_velocity;

pub const MainLevel = struct {
    const n_players = 1;

    players: [n_players]Player,
    bullets: Particles(10),

    pub fn init(self: *MainLevel) void {
        const middle = (platform.CANVAS_SIZE / 2) << 8;
        self.players[0] = Player.create(middle, middle, 3);

        self.bullets.live = false;
        platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    }

    pub fn update(self: *MainLevel) ?main.LevelId {
        for (self.players) |*p| {
            p.update(self);
        }
        for (self.players) |p| {
            p.draw();
        }

        if (self.bullets.live) {
            self.bullets.update_and_draw();
        }

        return null;
    }
};

const Player = struct {
    x: u16,
    y: u16,
    vx: i16,
    vy: i16,
    draw_color: u8,

    const width = 3;
    const height = 3;
    const accel = 30;

    pub fn create(x: u16, y: u16, draw_color: u8) Player {
        return Player{ .x = x, .y = y, .vx = 0, .vy = 0, .draw_color = draw_color };
    }

    pub fn update(self: *Player, level: *MainLevel) void {
        const gamepad = platform.GAMEPAD1.*;

        if (gamepad & platform.BUTTON_1 != 0) {
            // Directions fire on tap.
            const just_pressed = gamepad & (gamepad ^ main.prev_gamepad);
            const bullet_velocity = 1000;
            const bullet_spread = 20;
            const recoil = 1 << 8;
            const bullet_x = self.x + ((Player.width / 2) << 8);
            const bullet_y = self.y + ((Player.height / 2) << 8);
            if (just_pressed & platform.BUTTON_LEFT != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(bullet_x, -bullet_spread, bullet_spread);
                level.bullets.init_ys(bullet_y, -bullet_spread, bullet_spread);
                level.bullets.init_vxs(self.vx - bullet_velocity, -bullet_spread, bullet_spread);
                level.bullets.init_vys(self.vy, -bullet_spread, bullet_spread);
                self.vx += recoil;
                fire_sound();
            }
            if (just_pressed & platform.BUTTON_RIGHT != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(bullet_x, -bullet_spread, bullet_spread);
                level.bullets.init_ys(bullet_y, -bullet_spread, bullet_spread);
                level.bullets.init_vxs(self.vx + bullet_velocity, -bullet_spread, bullet_spread);
                level.bullets.init_vys(self.vy, -bullet_spread, bullet_spread);
                self.vx -= recoil;
                fire_sound();
            }
            if (just_pressed & platform.BUTTON_DOWN != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(bullet_x, -bullet_spread, bullet_spread);
                level.bullets.init_ys(bullet_y, -bullet_spread, bullet_spread);
                level.bullets.init_vxs(self.vx, -bullet_spread, bullet_spread);
                level.bullets.init_vys(self.vy + bullet_velocity, -bullet_spread, bullet_spread);
                self.vy -= recoil;
                fire_sound();
            }
            if (just_pressed & platform.BUTTON_UP != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(bullet_x, -bullet_spread, bullet_spread);
                level.bullets.init_ys(bullet_y, -bullet_spread, bullet_spread);
                level.bullets.init_vxs(self.vx, -bullet_spread, bullet_spread);
                level.bullets.init_vys(self.vy - bullet_velocity, -bullet_spread, bullet_spread);
                self.vy += recoil;
                fire_sound();
            }
        } else if (gamepad & platform.BUTTON_2 != 0) {
            // Brake
            if (self.vx != 0 or self.vy != 0) {
                platform.tone(550, 2, 15, platform.TONE_NOISE);
            }

            const brake_power: i16 = 8;
            if (abs(self.vx) < brake_power) {
                self.vx = 0;
            } else if (self.vx < 0) {
                self.vx += brake_power;
            } else {
                self.vx -= brake_power;
            }
            if (abs(self.vy) < brake_power) {
                self.vy = 0;
            } else if (self.vy < 0) {
                self.vy += brake_power;
            } else {
                self.vy -= brake_power;
            }
        } else {
            // Directions accelerate continuously.
            if (gamepad & platform.BUTTON_LEFT != 0) {
                self.vx = self.vx - accel;
            } else if (gamepad & platform.BUTTON_RIGHT != 0) {
                self.vx = self.vx + accel;
            } else {
                // FIXME: this is way too fast to be noticeable
                //self.vx = @divTrunc(self.vx, 2);
            }

            if (gamepad & platform.BUTTON_UP != 0) {
                self.vy = self.vy - accel;
            } else if (gamepad & platform.BUTTON_DOWN != 0) {
                self.vy = self.vy + accel;
            } else {
                //self.vy = @divTrunc(self.vy, 2);
            }
        }

        self.x = add_velocity(self.x, self.vx);
        self.y = add_velocity(self.y, self.vy);

        // Shoot left or right with button 1 and button 2.
        // Ok-ish, but was hoping for 4 direction firing.
        if (false) {
            if (gamepad & platform.BUTTON_1 != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(self.x + ((Player.width / 2) << 8), -10, 10);
                level.bullets.init_ys(self.y + ((Player.height / 2) << 8), -10, 10);
                level.bullets.init_vxs(self.vx - 1000, -10, 10);
                level.bullets.init_vys(self.vy, -10, 10);
            }

            if (gamepad & platform.BUTTON_2 != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(self.x + ((Player.width / 2) << 8), -100, 100);
                level.bullets.init_ys(self.y + ((Player.height / 2) << 8), -100, 100);
                level.bullets.init_vxs(self.vx + 1000, -10, 10);
                level.bullets.init_vys(self.vy, -10, 10);
            }
        }

        // Shoot with mouse. Kind of interesting, but awkward.
        if (false) {
            if (platform.MOUSE_BUTTONS.* & platform.MOUSE_LEFT != 0) {
                level.bullets.live = true;
                level.bullets.init_xs(self.x + ((Player.width / 2) << 8), -100, 100);
                level.bullets.init_ys(self.y + ((Player.height / 2) << 8), -100, 100);
                const mouse_x = @intCast(i16, platform.MOUSE_X.*) << 8;
                const mouse_y = @intCast(i16, platform.MOUSE_Y.*) << 8;
                level.bullets.init_vxs(self.vx + @divTrunc(mouse_x - @intCast(i16, self.x), 32), -10, 10);
                level.bullets.init_vys(self.vy + @divTrunc(mouse_y - @intCast(i16, self.y), 32), -10, 10);
            }
        }
    }

    fn draw(self: Player) void {
        platform.DRAW_COLORS.* = self.draw_color;
        platform.rect(self.x >> 8, self.y >> 8, Player.width, Player.height);
    }
};

fn Particles(comptime n: u32) type {
    return struct {
        const Self = @This();
        const n = n;

        xs: [n]u16,
        ys: [n]u16,
        vxs: [n]i16,
        vys: [n]i16,
        live: bool,

        pub fn init_xs(self: *Self, x: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.xs[i] = x + @bitCast(u16, main.rnd.random().intRangeAtMost(i16, rand_min, rand_most));
            }
        }

        pub fn init_ys(self: *Self, y: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.ys[i] = y + @bitCast(u16, main.rnd.random().intRangeAtMost(i16, rand_min, rand_most));
            }
        }

        pub fn init_vxs(self: *Self, vx: i16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.vxs[i] = vx + main.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
            }
        }

        pub fn init_vys(self: *Self, vy: i16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.vys[i] = vy + main.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
            }
        }

        fn update_and_draw(self: *Self) void {
            var i: usize = 0;
            platform.DRAW_COLORS.* = 2;
            while (i < Self.n) : (i += 1) {
                const old_x = self.xs[i];
                const old_y = self.ys[i];
                const new_x = add_velocity(old_x, self.vxs[i]);
                const new_y = add_velocity(old_y, self.vys[i]);
                const abs_dx = abs(@intCast(i32, new_x) - @intCast(i32, old_x));
                const abs_dy = abs(@intCast(i32, new_y) - @intCast(i32, old_y));

                // Draw a line between old and new positions *if* it didn't wrap around the screen on this frame.
                if (abs_dx <= abs(self.vxs[i]) and abs_dy <= abs(self.vys[i])) {
                    platform.line(old_x >> 8, old_y >> 8, new_x >> 8, new_y >> 8);
                }

                self.xs[i] = new_x;
                self.ys[i] = new_y;
            }
        }
    };
}

fn fire_sound() void {
    platform.tone(370 | (160 << 16), (16 << 24) | 38, 15, platform.TONE_NOISE);
}
