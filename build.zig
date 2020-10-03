const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zig-wcwidth", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    var generate = b.addExecutable("generate", "tools/generate.zig");
    generate.setBuildMode(mode);

    const generate_step = b.step("generate", "Generate tables");
    generate_step.dependOn(&b.addInstallArtifact(generate).step);

    var main_tests = b.addTest("src/test.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
