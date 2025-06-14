const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "learn_opengl_KTX_Viewer",
        .root_module = exe_mod,
    });

    // This loaded all the installed dependencies into the project defined from the
    exe.linkLibC();

    // this points to the installation of the KTX library; for my case
    // I have instead in "C:\Program Files\KTX-Software\include",
    // thus included that as lazy path.
    //
    // Your KTX location might differ from my setting where you might
    // installed it user wise instead of system wise, or in different os.
    // Please ensure the following path is pointing to your KTX header location.
    //
    // IMPORTANT: Since there is an issue about the return type between KTX and GLFW,
    // it is currently impossible to use this library. I have submitted an issue to
    // that GLFW binding library to see if a solution is provided.
    // For now, let we stick with a temporary solution.
    //
    // exe.addIncludePath(.{ .cwd_relative = "C:\\Program Files\\KTX-Software\\include" });

    exe.addIncludePath(.{ .cwd_relative = "inlucde/" });

    // build.zig.zon where the url of the dependencies
    const zm = b.dependency("zm", .{});
    exe_mod.addImport("zm", zm.module("zm"));

    const zglfw = b.dependency("zglfw", .{});
    exe_mod.addImport("zglfw", zglfw.module("root"));
    exe.linkLibrary(zglfw.artifact("glfw"));

    const gl_bindings = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.5",
        .profile = .core,
        .extensions = &.{ .ARB_clip_control, .NV_scissor_exclusive },
    });
    exe_mod.addImport("gl", gl_bindings);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
