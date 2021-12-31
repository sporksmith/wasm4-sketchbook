const std = @import("std");
const Builder = std.build.Builder;
const Step = std.build.Step;
const LibExeObjStep = std.build.LibExeObjStep;

const print = std.debug.print;

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("cart", "src/main.zig", .unversioned);
    lib.export_symbol_names = &[_][]const u8{ "start", "update" };
    lib.setBuildMode(mode);
    lib.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    lib.import_memory = true;
    lib.initial_memory = 65536;
    lib.max_memory = 65536;
    lib.global_base = 6560;
    lib.stack_size = 8192;
    lib.install();

    if (false) {
        const strip = b.addSystemCommand(&[_][]const u8{
            "wasm-opt",
            "-Oz",
            "--strip-producers",
            //"--zero-filled-memory",
            //b.lib_dir ++ lib.out_filename,
            lib.getOutputSource().getPath(b),
            "-o",
            "stripped.wasm", //lib.out_filename,
        });
        strip.step.dependOn(&lib.step);
    }

    const opt_step = OptStep.create(b, lib);
    opt_step.step.dependOn(&lib.step);

    b.default_step = &opt_step.step;
}

const OptStep = struct {
    step: Step,
    lib_step: *LibExeObjStep,
    builder: *Builder,

    pub fn create(builder: *Builder, lib: *LibExeObjStep) *@This() {
        const self = builder.allocator.create(@This()) catch unreachable;
        self.* = .{
            .step = Step.init(.custom, "wasm-opt", builder.allocator, make),
            .lib_step = lib,
            .builder = builder,
        };
        return self;
    }

    fn make(step: *Step) anyerror!void {
        const self = @fieldParentPtr(@This(), "step", step);
        print("Going to call wasm-opt for path {s}", .{self.lib_step.getOutputSource().getPath(self.builder)});
    }
};
