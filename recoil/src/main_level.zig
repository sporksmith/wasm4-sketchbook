const std = @import("std");
const util = @import("engine").util;

const engine = @import("engine");
const platform_mod = engine.platform;
const Platform = platform_mod.Platform;
const platform = &platform_mod.platform;

const game_mod = @import("game.zig");
const Game = game_mod.Game;
const game = &game_mod.game;

const abs = util.abs;
const add_velocity = util.add_velocity;

const slog = std.log.scoped(.main_level);

const Bullets = Particles(10);
const Explosion = Particles(100);

pub const MainLevelOptions = struct {
    p1_behavior: PlayerBehavior,
    p2_behavior: PlayerBehavior,
};

pub const MainLevel = struct {
    const Self = @This();
    const n_players = 2;
    const bullets_per_player = 3;

    players: [n_players]?Player,
    bullets: [n_players][bullets_per_player]?Bullets,
    explosions: [n_players]?Explosion,

    first_stayalive_frame: ?u32,
    gameover: bool,

    pub fn init(self: *Self, options: MainLevelOptions) void {
        const middle = (Platform.CANVAS_SIZE / 2) << 8;
        self.players[0] = Player.create((Platform.CANVAS_SIZE / 3) << 8, middle, 3, options.p1_behavior, &self.bullets[0]);
        self.players[1] = Player.create((Platform.CANVAS_SIZE * 2 / 3) << 8, middle, 2, options.p2_behavior, &self.bullets[1]);
        self.bullets = .{.{null} ** bullets_per_player} ** n_players;
        self.explosions = .{null} ** @typeInfo(@TypeOf(self.explosions)).Array.len;
        self.first_stayalive_frame = null;
        self.gameover = false;
    }

    pub fn update(self: *Self) ?game_mod.LevelInitializer {
        if (self.gameover and (platform.get_gamepad(.gamepad1) & (Platform.BUTTON_1 | Platform.BUTTON_2)) != 0) {
            return .splash_level;
        }

        for (self.players) |*mp| {
            if (mp.*) |*p| {
                p.update();
                p.draw();
            }
        }

        for (self.bullets) |*array| {
            for (array.*) |*mb| {
                if (mb.*) |*b| {
                    b.update_and_draw();
                }
            }
        }

        for (self.explosions) |*me| {
            if (me.*) |*e| {
                e.update_and_draw();
            }
        }

        // Collision checking reads the frame buffer - must be *after* we draw
        // collidables!
        var live_player_count: u8 = 0;
        var live_player_idx: ?usize = null;
        for (self.players) |*mp, i| {
            if (mp.*) |*p| {
                if (!self.gameover and p.check_collisions()) {
                    platform.tone(.{ .freq1 = 500, .attack = 16, .sustain = 38, .volume = 15, .channel = .triangle });
                    self.explosions[i] = Explosion.create(.{ .x = p.x, .y = p.y, .vx = p.vx, .vy = p.vy, .spread = 0x20, .draw_color = p.draw_color });
                    mp.* = null;
                } else {
                    live_player_count += 1;
                    live_player_idx = i;
                }
            }
        }

        // Is only 1 player alive?
        if (live_player_count == 1) {
            if (!(self.players[live_player_idx orelse unreachable] orelse unreachable).is_human()) {
                // Last player is AI
                platform.text("Death!", 50, 80);
                platform.text("X to restart", 30, 90);
                self.gameover = true;
            } else {
                if (self.first_stayalive_frame) |_| {} else {
                    self.first_stayalive_frame = game.frame_count;
                }
                const first_stayalive_frame = self.first_stayalive_frame orelse unreachable;
                const stayalive_frames_elapsed = game.frame_count - first_stayalive_frame;
                const stayalive_frames_remaining = 3 * Platform.TARGET_FPS - @bitCast(i32, stayalive_frames_elapsed);
                if (stayalive_frames_remaining > 0 and stayalive_frames_elapsed > 0) {
                    const seconds_remaining = @divTrunc(stayalive_frames_remaining, Platform.TARGET_FPS) + 1;
                    var buf: [20:0]u8 = undefined;
                    _ = std.fmt.bufPrintZ(&buf, "Stay Alive! {}", .{seconds_remaining}) catch unreachable;
                    platform.text(&buf, 20, 80);
                } else if (stayalive_frames_remaining <= 0) {
                    platform.text("Victory!", 50, 80);
                    platform.text("X to restart", 30, 90);
                    self.gameover = true;
                }
            }
        } else if (live_player_count == 0) {
            platform.text("Draw!", 50, 80);
            platform.text("X to restart", 30, 90);
            self.gameover = true;
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

pub const HumanPlayerBehavior = struct {
    const Self = @This();
    gamepad_id: Platform.GamepadId,

    fn get_gamepad(self: *Self) u8 {
        return platform.get_gamepad(self.gamepad_id);
    }
};

pub const RandomPlayerBehavior = struct {
    frame: u32 = 0,

    fn get_gamepad(self: *RandomPlayerBehavior) u8 {
        self.frame += 1;
        if (self.frame == 1) {
            // Always do nothing on first frame to clear gamepad state.
            return 0;
        }

        // Always pick *some* direction, (other than right) on the 2nd frame.
        // On subsequent frames most likely result will be idle.
        const max: i16 = if (self.frame == 2) 2 else 100;
        const r = game.rnd.random().intRangeAtMost(i16, 0, max);
        if (r == 0) {
            return Platform.BUTTON_LEFT;
        }
        if (r == 1) {
            return Platform.BUTTON_UP;
        }
        if (r == 2) {
            return Platform.BUTTON_DOWN;
        }
        if (r == 3) {
            return Platform.BUTTON_RIGHT;
        }
        return 0;
    }
};

pub const PlayerBehavior = union(enum) {
    Human: HumanPlayerBehavior,
    Random: RandomPlayerBehavior,

    fn get_gamepad(self: *PlayerBehavior) u8 {
        return switch (self.*) {
            .Human => |*b| b.get_gamepad(),
            .Random => |*b| b.get_gamepad(),
        };
    }
};

pub const Player = struct {
    const Self = @This();

    x: u16,
    y: u16,
    vx: i16,
    vy: i16,
    draw_color: u4,
    behavior: PlayerBehavior,
    bullets: *[MainLevel.bullets_per_player]?Bullets,
    bulleti: usize = 0,

    prev_gamepad: u8 = 0xff,

    const width = 3;
    const height = 3;
    const accel = 30;

    pub fn is_human(self: Self) bool {
        return switch (self.behavior) {
            .Human => true,
            else => false,
        };
    }

    pub fn check_collisions(self: Self) bool {
        const startx = @intCast(u8, self.x >> 8);
        const starty = @intCast(u8, self.y >> 8);
        var x = startx;
        var y = starty;
        // Hanging out at the right and bottom edges gives a
        // smaller hit box. Bug or feature?
        while (x < (startx + Self.width) and x < Platform.CANVAS_SIZE) : (x += 1) {
            while (y < (starty + Self.height) and y < Platform.CANVAS_SIZE) : (y += 1) {
                const fb_color = platform.get_pixel(x, y);
                // Background is color 1. Check for any color other than self or bg.
                if (fb_color != 1 and fb_color != self.draw_color) {
                    slog.debug("collision pixel-color:{} draw-color:{}", .{ fb_color, self.draw_color });
                    return true;
                }
            }
        }
        return false;
    }

    pub fn create(x: u16, y: u16, draw_color: u4, behavior: PlayerBehavior, bullets: *[MainLevel.bullets_per_player]?Bullets) Self {
        return Self{ .x = x, .y = y, .vx = 0, .vy = 0, .draw_color = draw_color, .behavior = behavior, .bullets = bullets };
    }

    fn fire(self: *Self, direction: Direction) void {
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
        const bullet_x = self.x + (Self.width << 8) / 2;
        const bullet_y = self.y + (Self.height << 8) / 2;
        self.bullets[self.bulleti] = Bullets.create(.{ .x = bullet_x, .y = bullet_y, .vx = bullet_vx, .vy = bullet_vy, .spread = bullet_spread, .draw_color = self.draw_color });
        self.bulleti = (self.bulleti + 1) % self.bullets.len;
        platform.tone(.{ .freq1 = 370, .freq2 = 160, .attack = 0, .decay = 0, .sustain = 38, .release = 16, .volume = 80, .channel = .triangle });
    }

    pub fn update(self: *Self) void {
        const gamepad = self.behavior.get_gamepad();
        const just_pressed = gamepad & (gamepad ^ self.prev_gamepad);

        if (just_pressed & Platform.BUTTON_LEFT != 0) {
            self.fire(.LEFT);
        }
        if (just_pressed & Platform.BUTTON_RIGHT != 0) {
            self.fire(.RIGHT);
        }
        if (just_pressed & Platform.BUTTON_UP != 0) {
            self.fire(.UP);
        }
        if (just_pressed & Platform.BUTTON_DOWN != 0) {
            self.fire(.DOWN);
        }
        self.x = add_velocity(self.x, self.vx);
        self.y = add_velocity(self.y, self.vy);
        self.prev_gamepad = gamepad;
    }

    fn draw(self: Self) void {
        platform.set_draw_colors(.{ .dc1 = self.draw_color });
        platform.rect(self.x >> 8, self.y >> 8, Self.width, Self.height);
    }
};

const ParticleOptions = struct {
    x: u16,
    y: u16,
    vx: i16,
    vy: i16,
    spread: u15,
    draw_color: u4,
};

fn Particles(comptime n: u32) type {
    return struct {
        const Self = @This();
        const n = n;

        xs: [n]u16,
        ys: [n]u16,
        vxs: [n]i16,
        vys: [n]i16,
        draw_colors: Platform.DrawColors,

        pub fn create(options: ParticleOptions) Self {
            var p: Self = undefined;
            const rand_most = @intCast(i16, options.spread);
            const rand_min = -rand_most;
            p.init_xs(options.x, rand_min, rand_most);
            p.init_ys(options.y, rand_min, rand_most);
            p.init_vxs(options.vx, rand_min, rand_most);
            p.init_vys(options.vy, rand_min, rand_most);
            p.draw_colors = .{ .dc1 = options.draw_color };

            return p;
        }

        pub fn init_xs(self: *Self, x: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                const err = game.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
                // XXX: rename
                self.xs[i] = util.add_velocity(x, err);
            }
        }

        pub fn init_ys(self: *Self, y: u16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                const err = game.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
                // XXX: rename
                self.ys[i] = util.add_velocity(y, err);
            }
        }

        pub fn init_vxs(self: *Self, vx: i16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.vxs[i] = vx + game.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
            }
        }

        pub fn init_vys(self: *Self, vy: i16, rand_min: i16, rand_most: i16) void {
            var i: usize = 0;
            while (i < Self.n) : (i += 1) {
                self.vys[i] = vy + game.rnd.random().intRangeAtMost(i16, rand_min, rand_most);
            }
        }

        fn update_and_draw(self: *Self) void {
            var i: usize = 0;
            platform.set_draw_colors(self.draw_colors);
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

test "fire" {
    // Regression test for overflow
    var bullets: [MainLevel.bullets_per_player]?Bullets = undefined;
    const middle = (Platform.CANVAS_SIZE / 2) << 8;
    var player = Player.create((Platform.CANVAS_SIZE / 3) << 8, middle, 3, .{ .Human = .{ .gamepad_id = .gamepad1 } }, &bullets);
    player.fire(.LEFT);
}
