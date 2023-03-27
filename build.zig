const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    
    _ = b.addModule(.{
        .source_file = .{ .path = "src/main.zig" },
    });

    const lib = b.addStaticLibrary("zig-wcwidth", "src/main.zig");
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.install();

    var generate = b.addExecutable("generate", "tools/generate.zig");
    generate.setTarget(target);
    generate.setBuildMode(mode);

    var generate_run = generate.run();

    const generate_step = b.step("generate", "Generate tables");
    generate_step.dependOn(&generate_run.step);

    var main_tests = b.addTest("src/test.zig");
    main_tests.setTarget(target);
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
