const std = @import("std");
const zcc = @import("compile_commands");
const android = @import("android");

pub fn build(b: *std.Build) void {
    var cdb_targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    const exe_name = "hello_xr";
    const root_target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root = b.path("src");

    const srcs = [_][]const u8{
        "main.cpp",
        "openxr_program.cpp",
        "logger.cpp",
        "platformplugin_factory.cpp",
        "graphicsplugin_factory.cpp",
    };

    const openxr_dep = b.dependency("openxr", .{});

    if (root_target.result.abi.isAndroid()) {
        // apk
        const android_targets = android.standardTargets(b, root_target);

        var root_target_single = [_]std.Build.ResolvedTarget{root_target};
        const targets: []std.Build.ResolvedTarget = if (android_targets.len == 0)
            root_target_single[0..]
        else
            android_targets;

        // If building with Android, initialize the tools / build
        const android_apk: ?*android.APK = blk: {
            if (android_targets.len == 0) {
                break :blk null;
            }
            const android_tools = android.Tools.create(b, .{
                .api_level = .android15,
                .build_tools_version = "35.0.1",
                .ndk_version = "29.0.13113456",
            });
            const apk = android.APK.create(b, android_tools);

            const key_store_file = android_tools.createKeyStore(android.CreateKey.example());
            apk.setKeyStore(key_store_file);
            apk.setAndroidManifest(b.path("android/AndroidManifest.xml"));
            apk.addResourceDirectory(b.path("android/res"));

            // Add Java files
            apk.addJavaSourceFile(.{ .file = b.path("android/src/NativeInvocationHandler.java") });
            break :blk apk;
        };

        for (targets) |target| {
            const app_module = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("src/minimal.zig"),
            });

            var exe: *std.Build.Step.Compile = if (target.result.abi.isAndroid()) b.addLibrary(.{
                .name = exe_name,
                .root_module = app_module,
                .linkage = .dynamic,
            }) else b.addExecutable(.{
                .name = exe_name,
                .root_module = app_module,
            });

            const apk: *android.APK = android_apk orelse @panic("Android APK should be initialized");
            const android_dep = b.dependency("android", .{
                .optimize = optimize,
                .target = target,
            });
            exe.root_module.addImport("android", android_dep.module("android"));

            apk.addArtifact(exe);

            // "-DXR_USE_GRAPHICS_API_D3D11",
            exe.addCSourceFiles(.{
                .root = root,
                .files = &(srcs ++ .{}),
                .flags = &.{
                    "-DXR_USE_PLATFORM_ANDROID",
                    "-DXR_USE_GRAPHICS_API_OPENGL_ES",
                },
            });
        }
        if (android_apk) |apk| {
            apk.installApk();
        }
    } else {
        // Windows

        const exe = b.addExecutable(.{
            .name = exe_name,
            .target = root_target,
            .optimize = optimize,
        });
        cdb_targets.append(exe) catch @panic("OOM");
        exe.linkLibCpp();
        exe.addIncludePath(root);
        b.installArtifact(exe);
        exe.addIncludePath(openxr_dep.path("include"));

        exe.addCSourceFiles(.{
            .root = root,
            .files = &(srcs ++ .{
                "platformplugin_win32.cpp",
                "graphicsplugin_opengl.cpp",
                "common/gfxwrapper_opengl.c",
            }),
            .flags = &.{
                "-DXR_USE_PLATFORM_WIN32",
                "-DXR_USE_GRAPHICS_API_OPENGL",
            },
        });
        exe.addIncludePath(root.path(b, "external/include"));

        // prebuilt openxr_loader.dll
        const openxr_loader_dep = b.dependency("openxr_loader", .{});
        exe.addLibraryPath(openxr_loader_dep.path("native/x64/release/lib"));
        exe.linkSystemLibrary("openxr_loader");
        const dll = b.addInstallBinFile(
            openxr_loader_dep.path("native/x64/release/bin/openxr_loader.dll"),
            "openxr_loader.dll",
        );
        b.getInstallStep().dependOn(&dll.step);

        exe.linkSystemLibrary("Ole32");
        exe.linkSystemLibrary("OpenGL32");
        exe.linkSystemLibrary("Gdi32");
    }

    // compile_commands.json for clangd
    zcc.createStep(b, "cdb", cdb_targets.toOwnedSlice() catch @panic("OOM"));
}
