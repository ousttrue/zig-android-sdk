# <img src="examples/minimal/android/res/mipmap/ic_launcher.png" width="32" height="32"> Zig Android SDK

![Continuous integration](https://github.com/silbinarywolf/zig-android-sdk/actions/workflows/ci.yml/badge.svg)

⚠️ **WARNING:** This is a work-in-progress and will be updated as I improve it for my personal SDL2 / OpenXR project.

This library allows you to setup and build an APK for your Android devices. This project was mostly based off the work of [ikskuh](https://github.com/ikskuh) and wouldn't exist without the work they did on the [ZigAndroidTemplate](https://github.com/ikskuh/ZigAndroidTemplate) project.


```sh
# Target one Android architecture
zig build -Dtarget=x86_64-linux-android

# Target all Android architectures
zig build -Dandroid=true
```

env
```sh
> $env:ANDROID_HOME
D:\android_sdk
> ls D:\android_sdk
.downloadIntermediates  .temp        cmdline-tools  extras    ndk             platforms  system-images
.knownPackages          build-tools  emulator       licenses  platform-tools  sources

> $env:JAVA_HOME
D:\Program Files\Android\Android Studio\jbr
> ls $env:JAVA_HOME
bin  conf  legal  lib  release
```

```sh
cd examples/minimal
zig build -Dtarget=aarch64-linux-android --summary all
Build Summary: 19/19 steps succeeded
install success
└─ install generated to minimal.apk success
   └─ zig-android-sdk apksigner success 724ms MaxRSS:5M
      ├─ zig-android-sdk keytool success 2s MaxRSS:88M
      └─ zig-android-sdk zipalign success 27ms MaxRSS:4M
         └─ zig-android-sdk jar (zip compress apk) success 249ms MaxRSS:47M
            ├─ WriteFile lib\arm64-v8a\libmain.so success
            │  ├─ zig build-lib minimal Debug aarch64-linux-android success 2s MaxRSS:187M
            │  │  ├─ options success
            │  │  ├─ WriteFile android-libc_target-aarch64-linux-android_version-34_ndk-27.1.12297006.conf success
            │  │  ├─ options success
            │  │  │  └─ zig-android-sdk builtin_options_update success
            │  │  │     └─ zig-android-sdk aapt2 dump packagename success 6ms MaxRSS:6M
            │  │  │        └─ zig-android-sdk aapt2 link success 1s MaxRSS:38M
            │  │  │           └─ zig-android-sdk aapt2 compile [dir] success 2s MaxRSS:7M
            │  │  └─ options (+1 more reused dependencies)
            │  ├─ zig-android-sdk d8 success 1s MaxRSS:5M
            │  │  ├─ zig-android-sdk d8glob success
            │  │  │  └─ zig-android-sdk javac success 2s MaxRSS:139M
            │  │  └─ zig-android-sdk javac (reused)
            │  ├─ zig-android-sdk aapt2 link (+1 more reused dependencies)
            │  └─ zig-android-sdk jar (unzip resources.apk) success 162ms MaxRSS:40M
            │     ├─ zig-android-sdk aapt2 link (+1 more reused dependencies)
            │     └─ zig-android-sdk aapt2 link (+1 more reused dependencies)
            └─ WriteFile lib\arm64-v8a\libmain.so (+4 more reused dependencies)
```

```sh
cd examples/sdl2
Build Summary: 26/26 steps succeeded
install success
└─ install generated to sdl-zig-demo.apk success
   └─ zig-android-sdk apksigner success 618ms MaxRSS:5M
      ├─ zig-android-sdk keytool success 1s MaxRSS:94M
      └─ zig-android-sdk zipalign success 12ms MaxRSS:4M
         └─ zig-android-sdk jar (zip compress apk) success 500ms MaxRSS:46M
            ├─ WriteFile lib\arm64-v8a\libmain.so success
            │  ├─ zig build-lib sdl-zig-demo Debug aarch64-linux-android success 21s MaxRSS:200M
            │  │  ├─ zig build-lib SDL2 ReleaseFast aarch64-linux-android success 8s MaxRSS:45M
            │  │  │  ├─ zig build-lib hidapi ReleaseFast aarch64-linux-android success 23s MaxRSS:154M
            │  │  │  │  ├─ WriteFile android-libc_target-aarch64-linux-android_version-34_ndk-27.1.12297006.conf cached
            │  │  │  │  └─ WriteFile android-libc_target-aarch64-linux-android_version-34_ndk-27.1.12297006.conf success
            │  │  │  ├─ WriteFile cached
            │  │  │  └─ WriteFile android-libc_target-aarch64-linux-android_version-34_ndk-27.1.12297006.conf cached
            │  │  ├─ WriteFile cached
            │  │  ├─ zig build-lib hidapi ReleaseFast aarch64-linux-android (+2 more reused dependencies)
            │  │  ├─ WriteFile (reused)
            │  │  ├─ options success
            │  │  ├─ WriteFile android-libc_target-aarch64-linux-android_version-34_ndk-27.1.12297006.conf cached
            │  │  ├─ options success
            │  │  │  └─ zig-android-sdk builtin_options_update success
            │  │  │     └─ zig-android-sdk aapt2 dump packagename success 12ms MaxRSS:6M
            │  │  │        └─ zig-android-sdk aapt2 link success 226ms MaxRSS:38M
            │  │  │           └─ zig-android-sdk aapt2 compile [dir] success 1s MaxRSS:7M
            │  │  └─ options (+1 more reused dependencies)
            │  ├─ zig build-lib SDL2 ReleaseFast aarch64-linux-android (+3 more reused dependencies)
            │  ├─ zig build-lib hidapi ReleaseFast aarch64-linux-android (+2 more reused dependencies)
            │  ├─ zig build-lib hidapi ReleaseFast aarch64-linux-android (+2 more reused dependencies)
            │  ├─ zig-android-sdk d8 success 2s MaxRSS:5M
            │  │  ├─ zig-android-sdk d8glob success
            │  │  │  └─ zig-android-sdk javac success 1s MaxRSS:223M
            │  │  └─ zig-android-sdk javac (reused)
            │  ├─ zig-android-sdk aapt2 link (+1 more reused dependencies)
            │  └─ zig-android-sdk jar (unzip resources.apk) success 241ms MaxRSS:40M
            │     ├─ zig-android-sdk aapt2 link (+1 more reused dependencies)
            │     └─ zig-android-sdk aapt2 link (+1 more reused dependencies)
            └─ WriteFile lib\arm64-v8a\libmain.so (+7 more reused dependencies)
```

```zig
// This is an overly simplified example to give you the gist
// of how this library works, see: examples/minimal/build.zig
const android = @import("zig-android-sdk");

pub fn build(b: *std.Build) !void {
    const android_tools = android.Tools.create(b, ...);
    const apk = android.APK.create(b, android_tools);
    apk.setAndroidManifest(b.path("android/AndroidManifest.xml"));
    apk.addResourceDirectory(b.path("android/res"));
    apk.addJavaSourceFile(.{ .file = b.path("android/src/NativeInvocationHandler.java") });
    for (android.standardTargets(b, b.standardTargetOptions(.{}))) |target| {
        apk.addArtifact(b.addSharedLibrary(.{
            .name = exe_name,
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }))
    }
}
```

## core function: doInstallApk

```zig
// src/androidbuild/apk.zig:150-580
fn doInstallApk(apk: *@This()) std.mem.Allocator.Error!*Step.InstallFile;
```

## Requirements

* [Zig](https://ziglang.org/download)
* Android Tools
    * Option A: [Android Studio](https://developer.android.com/studio)
    * Option B: [Android Command Line Tools](https://developer.android.com/studio#command-line-tools-only)
* [Java Development Kit](https://www.oracle.com/au/java/technologies/downloads/)

## Installation

Add the following to your build.zig.zon file and run `zig build`.

```zig
.{
    .dependencies = .{
        .@"zig-android-sdk" = .{
            .path = "https://github.com/silbinarywolf/zig-android-sdk/archive/REPLACE_WITH_WANTED_COMMIT.tar.gz",
            // .hash = REPLACE_WITH_HASH_FROM_BUILD_ERROR
        },
    },
}
```

## Examples

* [minimal](examples/minimal): This is based off ZigAndroidTemplate's minimal example.
* [SDL2](examples/sdl2): This is based off Andrew Kelly's SDL Zig Demo but modified to run on Android, Windows, Mac and Linux.

## Credits

- [ikskuh](https://github.com/ikskuh) This would not exist without their [ZigAndroidTemplate](https://github.com/ikskuh/ZigAndroidTemplate) repository to use as a baseline for figuring this all out and also being able to use their logic for the custom panic / logging functions.
  - ikskuh gave a huge thanks to [@cnlohr](https://github.com/cnlohr) for [rawdrawandroid](https://github.com/cnlohr/rawdrawandroid)
