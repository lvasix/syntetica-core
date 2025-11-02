const std = @import("std");
const sdl = @import("SDL2");

fn addSyntetica(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, exe: *std.Build.Step.Compile) void {
    const syntetica_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
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

    const syntetica_mod = b.addModule("syntetica", .{
        .root_source_file = b.path("src/root.zig"),
        .optimize = optimize,
        .target = target,
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C addLibrary

    syntetica_mod.linkLibrary(raylib_artifact);
    syntetica_mod.addImport("raylib", raylib);
    syntetica_mod.addImport("raygui", raygui);

    // EXAMPLES ///////////////////////////
    const examples = [_][]const u8{
        "full",
        "actorstyle",
    };
    for (examples) |example_name| {
        const example_path = b.fmt("examples/{s}", .{example_name}); 
        const example = b.addExecutable(.{
            .name = example_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(b.fmt("{s}/main.zig", .{example_path})),
                .target = target,
                .optimize = optimize,
            }),
        });
        example.root_module.addImport("syntetica", syntetica_mod);

        b.installArtifact(example);
        const inst_dir = b.addInstallDirectory(.{ .source_dir = b.path(b.fmt("{s}/res", .{example_path})), .install_dir = .prefix, .install_subdir = "res" });

        const install_example = b.addRunArtifact(example);

        const example_step = b.step(b.fmt("runeg_{s}", .{example_name}), b.fmt("Run the {s} example", .{example_name}));
        example_step.dependOn(&inst_dir.step);
        example_step.dependOn(&example.step);
        example_step.dependOn(&install_example.step);
    }
}
