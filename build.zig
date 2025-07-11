const Build = @import("std").Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("wcwidth", .{
        .root_source_file = b.path("src/main.zig"),
    });

    const generate_module = b.createModule(.{
        .root_source_file = b.path("tools/generate.zig"),
        .target = target,
        .optimize = optimize,
    });

    const generate = b.addExecutable(.{
        .name = "generate",
        .root_module = generate_module,
    });

    const generate_run = b.addRunArtifact(generate);

    const generate_step = b.step("generate", "Generate tables");
    generate_step.dependOn(&generate_run.step);

    const test_module = b.createModule(.{
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const main_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
