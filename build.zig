const std = @import("std");
const sdl = @import("SDL2");

fn addSyntetica(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, exe: *std.Build.Step.Compile) void {
    const syntetica_mod = b.createModule(.{
        .root_source_file = b.path("src/eng/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("syntetica", syntetica_mod);
//    syntetica_mod.addIncludePath(b.path("./src/eng/"));

    const syntetica = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "syntetica",
        .root_module = syntetica_mod,
    });
    syntetica.root_module.addIncludePath(b.path("./src/eng/"));
    b.installArtifact(syntetica);
//    syntetica.addIncludePath(b.path("src/"));
    
    const sdl3 = b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,

    // Lib options.
    // .callbacks = false,
    .ext_image = true,

    // Options passed directly to https://github.com/castholm/SDL (SDL3 C Bindings):
    // .c_sdl_preferred_linkage = .static,
    // .c_sdl_strip = false,
    // .c_sdl_sanitize_c = .off,
    // .c_sdl_lto = .none,
    // .c_sdl_emscripten_pthreads = false,
    // .c_sdl_install_build_config_h = false,

    // Options if `ext_image` is enabled:
    // .image_enable_bmp = true,
    // .image_enable_gif = true,
    // .image_enable_jpg = true,
    // .image_enable_lbm = true,
    // .image_enable_pcx = true,
    .image_enable_png = true,
    // .image_enable_pnm = true,
    // .image_enable_qoi = true,
    // .image_enable_svg = true,
    // .image_enable_tga = true,
    // .image_enable_xcf = true,
    // .image_enable_xpm = true,
    // .image_enable_xv = true,
    });

    syntetica.root_module.addImport("sdl3", sdl3.module("sdl3"));
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

    // add syntetica module to main executable
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
