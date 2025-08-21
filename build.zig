const std = @import("std");
const sdl = @import("SDL2");

fn addSDL(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const sdk = sdl.init(b, .{.dep_name = "SDL2"});
    sdl.link(sdk, exe, .dynamic, sdl.Library.SDL2);

    // request the wrapper module for sdl2 instead of native
    exe.root_module.addImport("sdl2", sdk.getWrapperModule());
}

fn addSyntetica(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, exe: *std.Build.Step.Compile) void {
    const syntetica_mod = b.createModule(.{
        .root_source_file = b.path("src/eng/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("syntetica", syntetica_mod);

    const syntetica = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "syntetica",
        .root_module = syntetica_mod,
    });
    b.installArtifact(syntetica);

    syntetica.addIncludePath(b.path("src/"));

    addSDL(b, syntetica);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const example_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "test",
        .root_module = example_mod,
    });

    b.installArtifact(exe);

    addSyntetica(b, target, optimize, exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = example_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
