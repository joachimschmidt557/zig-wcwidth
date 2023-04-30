const Build = @import("std").Build;
const FileSource = Build.FileSource;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("wcwidth", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    var generate = b.addExecutable(.{
        .name = "generate",
        .root_source_file = FileSource.relative("tools/generate.zig"),
        .target = target,
        .optimize = optimize,
    });

    var generate_run = b.addRunArtifact(generate);

    const generate_step = b.step("generate", "Generate tables");
    generate_step.dependOn(&generate_run.step);

    var main_tests = b.addTest(.{
        .root_source_file = FileSource.relative("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
