const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("cart", "src/main.zig", .unversioned);
    lib.addPackagePath("engine", "src/engine.zig");
    lib.export_symbol_names = &[_][]const u8{ "start", "update" };
    lib.setBuildMode(mode);
    lib.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    lib.import_memory = true;
    lib.initial_memory = 65536;
    lib.max_memory = 65536;
    lib.global_base = 6560;
    lib.stack_size = 8192;
    lib.install();

    const test_step = b.step("test", "Run the tests");

    var main_test = b.addTest("src/main.zig");
    test_step.dependOn(&main_test.step);
    main_test.setBuildMode(mode);
    main_test.addPackagePath("engine", "src/engine.zig");
    //test_stage2.single_threaded = single_threaded;
}
