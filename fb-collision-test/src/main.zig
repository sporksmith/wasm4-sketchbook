const w4 = @import("wasm4.zig");

export fn update() void {
    w4.tracef("before: %x", @as(u32, w4.FRAMEBUFFER[0]));

    var color: u8 = 0;
    while (color <= 4) : (color += 1) {
        w4.DRAW_COLORS.* = color;
        w4.rect(0, 0, 1, 1);
        // Turns out that the color written to the framebuffer is (DRAW_COLOR&0xf)-1, not (DRAW_COLOR & 0xf).
        w4.tracef("after rect with DRAW_COLORS=%d, FRAMEBUFFER[0]=%d", @as(u32, w4.DRAW_COLORS.*), @as(u32, w4.FRAMEBUFFER[0]));
    }
}
