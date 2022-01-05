const std = @import("std");
const platform = @import("platform.zig");
const main = @import("main.zig");
const util = @import("util.zig");

const abs = util.abs;
const add_velocity = util.add_velocity;

const slog = std.log.scoped(.main_level);

const Bullets = Particles(10);

pub const MainLevel = struct {
    const n_players = 2;

    players: [n_players]?Player,
    bullets: [n_players]?Bullets,

    pub fn init(self: *MainLevel) void {
        const middle = (platform.CANVAS_SIZE / 2) << 8;
        self.players[0] = Player.create((platform.CANVAS_SIZE / 3) << 8, middle, 3, platform.GAMEPAD1, &self.bullets[0]);
        self.players[1] = Player.create((platform.CANVAS_SIZE * 2 / 3) << 8, middle, 2, platform.GAMEPAD2, &self.bullets[1]);

        platform.PALETTE.* = [_]u32{ 0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d };
    }

    pub fn update(self: *MainLevel) ?main.LevelId {
        for (self.players) |*mp| {
            if (mp.*) |*p| {
                p.update();
                p.draw();
            }
        }

        for (self.bullets) |*mb| {
            if (mb.*) |*b| {
                b.update_and_draw();
            }
        }

        // Collision checking reads the frame buffer - must be *after* we draw
        // collidables!
        for (self.players) |*mp| {
            if (mp.*) |*p| {
                if (p.check_collisions()) {
                    platform.tone(500, (16 << 24) | 38, 15, platform.TONE_TRIANGLE);
                }
            }
        }

        return null;
    }
};

const Direction = enum {
    LEFT,
    RIGHT,
    UP,
    DOWN,
};

const Player = struct {
    x: u16,
    y: u16,
    vx: i16,
    vy: i16,
    draw_color: u8,
    gamepad: *const u8,
    bullets: *?Bullets,

    prev_gamepad: u8 = 0,

    const width = 3;
    const height = 3;
    const accel = 30;

    pub fn check_collisions(self: Player) bool {
        const startx = @intCast(u8, self.x >> 8);
        const starty = @intCast(u8, self.y >> 8);
        var x = startx;
        var y = starty;
        // Hanging out at the right and bottom edges gives a
        // smaller hit box. Bug or feature?
        while (x < (startx + Player.width) and x < platform.CANVAS_SIZE) : (x += 1) {
            while (y < (starty + Player.height) and y < platform.CANVAS_SIZE) : (y += 1) {
                const fb_color = util.get_pixel(x, y);
                // Background is color 1. Check for any color other than self or bg.
                if (fb_color != 1 and fb_color != self.draw_color) {
                    slog.debug("collision pixel-color:{} draw-color:{}", .{ fb_color, self.draw_color });
                    return true;
                }
            }
        }
        return false;
    }

    pub fn create(x: u16, y: u16, draw_color: u8, gamepad: *const u8, bullets: *?Bullets) Player {
        return Player{ .x = x, .y = y, .vx = 0, .vy = 0, .draw_color = draw_color, .gamepad = gamepad, .bullets = bullets };
    }

    fn fire(self: *Player, direction: Direction) void {
        const bullet_velocity = 200;
        const bullet_spread = 20;
        const recoil = 1 << 6;
        var bullet_vx = self.vx;
        var bullet_vy = self.vy;
        switch (direction) {
            .LEFT => {
                bullet_vx -= bullet_velocity;
                self.vx += recoil;
            },
            .RIGHT => {
                bullet_vx += bullet_velocity;
                self.vx -= recoil;
            },
            .UP => {
                bullet_vy -= bullet_velocity;
                self.vy += recoil;
            },
            .DOWN => {
                bullet_vy += bullet_velocity;
                self.vy -= recoil;
            },
        }
        const bullet_x = self.x + ((Player.width / 2) << 8);
        const bullet_y = self.y + ((Player.height / 2) << 8);
        self.bullets.* = Bullets.create(.{ .x = bullet_x, .y = bullet_y, .vx = bullet_vx, .vy = bullet_vy, .spread = bullet_spread, .draw_color = self.draw_color });
        platform.tone(370 | (160 << 16), (16 << 24) | 38, 15, platform.TONE_NOISE);
    }

    pub fn update(self: *Player) void {
        const gamepad = self.gamepad.*;
        const just_pressed = gamepad & (gamepad ^ self.prev_gamepad);

        if (just_pressed & platform.BUTTON_LEFT != 0) {
            self.fire(.LEFT);
        }
        if (just_pressed & platform.BUTTON_RIGHT != 0) {
            self.fire(.RIGHT);
        }
        if (just_pressed & platform.BUTTON_UP != 0) {
            self.fire(.UP);
        }
        if (just_pressed & platform.BUTTON_DOWN != 0) {
            self.fire(.DOWN);
        }
        self.x = add_velocity(self.x, self.vx);
        self.y = add_velocity(self.y, self.vy);
        self.prev_gamepad = gamepad;
    }

    fn draw(self: Player) void {
        platform.DRAW_COLORS.* = self.draw_color;
        platform.rect(self.x >> 8, self.y >> 8, Player.width, Player.height);
    }
};

test "fire" {
    // Regression test for overflow
    var bullets: Bullets = undefined;
    const middle = (platform.CANVAS_SIZE / 2) << 8;
    var player = Player.create((platform.CANVAS_SIZE / 3) << 8, middle, 3, platform.GAMEPAD1, &bullets);
    player.fire(.LEFT);
}

const ParticleOptions = struct {
    x: u16,
    y: u16,
    vx: i16,
    vy: i16,
    spread: u15,
    draw_color: u8,
};

fn Particles(comptime n: u32) type {
    return struct {
        const Self = @This();
        const n = n;

        xs: [n]u16,
        ys: [n]u16,
        vxs: [n]i16,
        vys: [n]i16,
        draw_color: u8,

        pub fn create(options: ParticleOptions) Self {
            var p: Self = undefined;
            const rand_most = @intCast(i16, options.spread);
            const rand_min = -rand_most;
            p.init_xs(options.x, rand_min, rand_most);
            p.init_ys(options.y, rand_min, rand_most);
            p.init_vxs(options.vx, rand_min, rand_most);
            p.init_vys(options.vy, rand_min, rand_most);
            p.draw_color = options.draw_color;

            return p;
        }

        pub fn init_xs(self: *Self, x: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                const err = main.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
                // XXX: rename
                self.xs[i] = util.add_velocity(x, err);
            }
        }

        pub fn init_ys(self: *Self, y: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                const err = main.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
                // XXX: rename
                self.ys[i] = util.add_velocity(y, err);
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
            platform.DRAW_COLORS.* = self.draw_color;
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
