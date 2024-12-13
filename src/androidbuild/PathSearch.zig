/// Searches your PATH environment variable directories for adb, jarsigner, etc
const std = @import("std");

const PathSearch = @This();

pub const Error = error{
    NoAndroidSdk,
};

allocator: std.mem.Allocator,
path_env: []const u8,
path_it: std.mem.SplitIterator(u8, .scalar),

/// "adb" or "adb.exe"
adb: []const u8,
/// "jarsigner" or "jarsigner.exe"
jarsigner: []const u8,

android_sdk_path: ?[]const u8 = null,
jdk_path: ?[]const u8 = null,

pub fn init(allocator: std.mem.Allocator, host_os_tag: std.Target.Os.Tag) error{ EnvironmentVariableNotFound, OutOfMemory }!PathSearch {
    const path_env = std.process.getEnvVarOwned(allocator, "PATH") catch |err| switch (err) {
        error.OutOfMemory => return error.OutOfMemory,
        error.EnvironmentVariableNotFound => return error.EnvironmentVariableNotFound,
        // Windows-only
        error.InvalidWtf8 => @panic("PATH environment variable is invalid UTF-8"),
    };
    if (path_env.len == 0) {
        return error.EnvironmentVariableNotFound;
    }

    // setup binaries to search for
    const exe_suffix = if (host_os_tag == .windows) ".exe" else "";
    const adb = std.mem.concat(allocator, u8, &.{ "adb", exe_suffix }) catch |err| return err;
    const jarsigner = std.mem.concat(allocator, u8, &.{ "jarsigner", exe_suffix }) catch |err| return err;

    const path_it = std.mem.splitScalar(u8, path_env, ';');
    return .{
        .allocator = allocator,
        .path_env = path_env,
        .path_it = path_it,
        .adb = adb,
        .jarsigner = jarsigner,
    };
}

pub fn deinit(self: *PathSearch) void {
    const allocator = self.allocator;
    allocator.free(self.path_env);
}

/// Get the Android SDK Path, the caller owns the memory
pub fn findAndroidSDK(self: *PathSearch, allocator: std.mem.Allocator) ![]const u8 {
    if (self.android_sdk_path == null) {
        // Iterate over PATH environment folders until we either hit the end or the Android SDK folder
        try self.getNext(.androidsdk);
    }
    // Get the Android SDK path
    const android_sdk_path = self.android_sdk_path orelse {
        return Error.NoAndroidSdk;
    };
    if (android_sdk_path.len == 0) {
        return Error.NoAndroidSdk;
    }
    return allocator.dupe(u8, android_sdk_path);
}

/// Get the JDK Path, the caller owns the memory
pub fn findJDK(self: *PathSearch, allocator: std.mem.Allocator) error{OutOfMemory}![]const u8 {
    if (self.jdk_path == null) {
        // Iterate over PATH environment folders until we either hit the end or the Android SDK folder
        try self.getNext(.jdk);
    }
    // Get the Java Home path
    const jdk_path = self.jdk_path orelse unreachable;
    if (jdk_path.len == 0) return &[0]u8{};
    return allocator.dupe(u8, jdk_path);
}

const PathType = enum {
    androidsdk,
    jdk,
};

fn getNext(self: *PathSearch, path: PathType) error{OutOfMemory}!void {
    const allocator = self.allocator;
    while (self.path_it.next()) |path_item| {
        if (path_item.len == 0) continue;

        // If we haven't found Android SDK Path yet, check
        blk: {
            if (self.android_sdk_path == null) {
                // Check $PATH/adb.exe
                {
                    const adb_binary_path = std.fs.path.join(allocator, &.{ path_item, self.adb }) catch |err| return err;
                    defer allocator.free(adb_binary_path);
                    std.fs.accessAbsolute(adb_binary_path, .{}) catch {
                        break :blk;
                    };
                }
                // Transform: "Sdk\platform-tools" into "Sdk"
                const sdk_path = std.fs.path.dirname(path_item) orelse {
                    // If found adb.exe in a root directory, it can't be the Android SDK, skip
                    break :blk;
                };
                self.android_sdk_path = sdk_path;
                if (path == .androidsdk) {
                    // If specifically just wanting the Android SDK path right now, stop here
                    return;
                }
                continue;
            }
        }
        // If we haven't found JDK Path yet, check
        blk: {
            if (self.jdk_path == null) {
                // Check $PATH/jarsigner.exe
                {
                    const jarsigner_binary_path = std.fs.path.join(allocator, &.{ path_item, self.jarsigner }) catch |err| return err;
                    defer allocator.free(jarsigner_binary_path);

                    std.fs.accessAbsolute(jarsigner_binary_path, .{}) catch {
                        break :blk;
                    };
                }
                // Transform: "jdk-21.0.3.9-hotspot/bin" into "jdk-21.0.3.9-hotspot"
                const jdk_path = std.fs.path.dirname(path_item) orelse {
                    // If found adb.exe in a root directory, it can't be the Android SDK, skip
                    break :blk;
                };
                self.jdk_path = jdk_path;
                if (path == .jdk) {
                    // If specifically just wanting the JDK path right now, stop here
                    return;
                }
                continue;
            }
        }
    }
    // If we didn't discover the paths, set to empty slice
    if (self.android_sdk_path == null) {
        self.android_sdk_path = &[0]u8{};
    }
    if (self.jdk_path == null) {
        self.jdk_path = &[0]u8{};
    }
}
