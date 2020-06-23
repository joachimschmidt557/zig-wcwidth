const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("zig-wcwidth", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    var gen_wide_exe = b.addExecutable("genwide", "generate/wide.zig");
    var gen_zero_exe = b.addExecutable("genzero", "generate/zero.zig");

    var gen_wide_cmd = gen_wide_exe.run();
    var gen_zero_cmd = gen_zero_exe.run();

    gen_wide_cmd.addArgs(&[_][]const u8{
        "EastAsianWidth.txt",
        "src/table_wide.zig",
    });
    gen_zero_cmd.addArgs(&[_][]const u8{
        "DerivedGeneralCategory.txt",
        "src/table_zero.zig",
    });

    const gen_step = b.step("generate", "Generate tables");
    gen_step.dependOn(&gen_wide_cmd.step);
    gen_step.dependOn(&gen_zero_cmd.step);

    var main_tests = b.addTest("src/test.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
