const w4 = @import("wasm4.zig");

var frame: u64 = 0;
export fn update() void {
    if (frame % 15 == 0)
        // yes
        // w4.tone(370 | (160 << 16), (16 << 24) | 38, 15, w4.TONE_NOISE);
        //
        // yes
        // w4.tone(370, (16 << 24) | 38, 15, w4.TONE_NOISE);
        //
        // no
        // w4.tone(370, 38, 15, w4.TONE_NOISE);
        //
        // no
        // w4.tone(370, 38, 100, w4.TONE_NOISE);
        //
        // yes
        // w4.tone(370, (16 << 24) | 38, 100, w4.TONE_NOISE);
        //
        // yes
        w4.tone(370, (16 << 24) | 38, 100, w4.TONE_TRIANGLE);
    frame += 1;
}
