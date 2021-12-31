const Point = @import("snake.zig").Point;
const platform = @import("platform.zig");

pub const Fruit = struct {
    position: Point,

    pub fn init(position: Point) Fruit {
        return Fruit{ .position = position };
    }

    pub fn move(self: *Fruit, position: Point) void {
        self.position = position;
    }

    pub fn draw(self: *const Fruit) void {
        // From `w4 png2src --zig fruit.png`
        const fruitWidth = 8;
        const fruitHeight = 8;
        const fruitFlags = 1; // BLIT_2BPP
        const fruitSprite = [16]u8{ 0x00, 0xa0, 0x02, 0x00, 0x0e, 0xf0, 0x36, 0x5c, 0xd6, 0x57, 0xd5, 0x57, 0x35, 0x5c, 0x0f, 0xf0 };

        platform.DRAW_COLORS.* = 0x4320;
        platform.blit(&fruitSprite, self.position.x * 8, self.position.y * 8, fruitWidth, fruitHeight, fruitFlags);
    }
};
