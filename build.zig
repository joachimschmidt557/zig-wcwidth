const Build = @import("std").Build;
const FileSource = Build.FileSource;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    _ = b.addModule(.{
        .source_file = .{ .path = "src/main.zig" },
    });
    
    const lib = b.addStaticLibrary(.{
        .name = "zig-wcwidth",
        .root_source_file = FileSource.relative("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.install();

    var generate = b.addExecutable(.{
        .name = "generate", 
        .root_source_file = FileSource.relative("tools/generate.zig"),
        .target = target,
        .optimize = optimize,
    });

    var generate_run = generate.run();

    const generate_step = b.step("generate", "Generate tables");
    generate_step.dependOn(&generate_run.step);

    var main_tests = b.addTest(.{
        .root_source_file = FileSource.relative("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
