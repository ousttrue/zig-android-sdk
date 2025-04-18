const std = @import("std");
const zcc = @import("compile_commands");

pub fn build(b: *std.Build) void {
    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "hello_xr",
        .target = target,
        .optimize = optimize,
    });
    targets.append(exe) catch @panic("OOM");

    const root = b.path("src");
    exe.linkLibCpp();
    exe.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "main.cpp",
            "openxr_program.cpp",
            "logger.cpp",
            //
            "platformplugin_factory.cpp",
            "platformplugin_win32.cpp",
            //
            "graphicsplugin_factory.cpp",
            // "graphicsplugin_opengles.cpp",
            "graphicsplugin_opengl.cpp",
            "common/gfxwrapper_opengl.c",
            // "graphicsplugin_d3d11.cpp",
            // "d3d_common.cpp",
        },
        .flags = &.{
            "-DWIN32",
            "-DXR_USE_PLATFORM_WIN32",
            // "-DXR_USE_GRAPHICS_API_OPENGL_ES",
            "-DXR_USE_GRAPHICS_API_OPENGL",
            // "-DXR_USE_GRAPHICS_API_D3D11",
        },
    });
    exe.addIncludePath(root);
    exe.addIncludePath(root.path(b, "external/include"));

    const openxr_dep = b.dependency("openxr", .{});
    exe.addIncludePath(openxr_dep.path("include"));

    exe.linkSystemLibrary("Ole32");
    exe.linkSystemLibrary("OpenGL32");
    exe.linkSystemLibrary("Gdi32");

    // prebuilt
    const openxr_loader_dep = b.dependency("openxr_loader", .{});
    exe.addLibraryPath(openxr_loader_dep.path("native/x64/release/lib"));
    exe.linkSystemLibrary("openxr_loader");
    const dll = b.addInstallBinFile(
        openxr_loader_dep.path("native/x64/release/bin/openxr_loader.dll"),
        "openxr_loader.dll",
    );
    b.getInstallStep().dependOn(&dll.step);

    // d3d
    const dxmath_dep = b.dependency("directxmath", .{});
    exe.addIncludePath(dxmath_dep.path("Inc"));

    b.installArtifact(exe);

    zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}
