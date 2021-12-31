const std = @import("std");
const platform = @import("platform.zig");

pub const Point = struct {
    x: i32,
    y: i32,
    pub fn init(x: i32, y: i32) Point {
        return Point{ .x = x, .y = y };
    }
    fn draw(self: *const Point) void {
        platform.rect(self.x * 8, self.y * 8, 8, 8);
    }
    fn plus(self: *const Point, other: Point) Point {
        return Point{ .x = @mod(self.x + other.x, 20), .y = @mod(self.y + other.y, 20) };
    }
};

pub const Snake = struct {
    // Body segments, with head at body[0].  Preallocate the maximum number of
    // body segments, which is enough to fill the play field.
    body: [20 * 20]Point,
    body_len: usize = 3,
    direction: Point,

    pub fn init() Snake {
        var s = Snake{
            .body = undefined,
            .body_len = 3,
            .direction = Point.init(1, 0),
        };
        s.body[0] = Point.init(2, 0);
        s.body[1] = Point.init(1, 0);
        s.body[2] = Point.init(0, 0);
        return s;
    }

    pub fn draw(self: *const Snake) void {
        platform.DRAW_COLORS.* = 0x0004;
        self.body[0].draw();

        platform.DRAW_COLORS.* = 0x0043;
        for (self.body[1..self.body_len]) |part| {
            part.draw();
        }
    }

    pub fn down(self: *Snake) void {
        self.direction = Point.init(0, 1);
    }

    pub fn up(self: *Snake) void {
        self.direction = Point.init(0, -1);
    }

    pub fn left(self: *Snake) void {
        self.direction = Point.init(-1, 0);
    }

    pub fn right(self: *Snake) void {
        self.direction = Point.init(1, 0);
    }

    pub fn grow(self: *Snake) void {
        self.body_len += 1;
        self.body[self.body_len - 1] = self.body[self.body_len - 2];
    }

    pub fn head_collides_with(self: *const Snake, pt: Point) bool {
        return std.meta.eql(self.body[0], pt);
    }

    pub fn body_collides_with(self: *const Snake, pt: Point) bool {
        for (self.body[1..self.body_len]) |part| {
            if (std.meta.eql(part, pt)) {
                return true;
            }
        }
        return false;
    }

    pub fn head_collides_with_body(self: *const Snake) bool {
        return self.body_collides_with(self.body[0]);
    }

    pub fn update(self: *Snake) void {
        var i: usize = self.body.len - 1;
        while (i >= 1) : (i -= 1) {
            self.body[i] = self.body[i - 1];
        }
        self.body[0] = self.body[0].plus(self.direction);

        //util.trace("After: {?}", .{self});
    }
};
