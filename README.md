用zig写的，最小化的godot扩展。
先用
```bash
godot --dump-gdextension-interface
```
导出`gdextension_interface.h`头文件，放到`include`目录下。
然后写`build.zig`：
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "zig",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    lib.linkLibC();
    lib.addIncludePath(b.path("include"));

    b.installArtifact(lib);
}
```
然后写`src/root.zig`：
```zig
const std = @import("std");

const c = @cImport({
    @cInclude("gdextension_interface.h");
});

fn initialize(userdata: ?*anyopaque, level: c_uint) callconv(.c) void {
    _ = userdata;

    switch (level) {
        c.GDEXTENSION_INITIALIZATION_SCENE => {
            std.log.debug("initialize scene", .{});
        },
        c.GDEXTENSION_INITIALIZATION_EDITOR => {
            std.log.debug("initialize editor", .{});
        },
        else => {},
    }
}

fn deinitialize(userdata: ?*anyopaque, level: c_uint) callconv(.c) void {
    _ = userdata;

    switch (level) {
        c.GDEXTENSION_INITIALIZATION_SCENE => {
            std.log.debug("deinitialize scene", .{});
        },
        c.GDEXTENSION_INITIALIZATION_EDITOR => {
            std.log.debug("deinitialize editor", .{});
        },
        else => {},
    }
}
export fn zig_init(
    ptrGetProcAddress: *c.GDExtensionInterfaceGetProcAddress,
    ptrLibrary: *c.GDExtensionClassLibraryPtr,
    ptrInitialization: *c.GDExtensionInitialization,
) callconv(.c) c.GDExtensionBool {
    _ = ptrGetProcAddress;
    _ = ptrLibrary;

    ptrInitialization.initialize = initialize;
    ptrInitialization.deinitialize = deinitialize;
    ptrInitialization.userdata = null;
    ptrInitialization.minimum_initialization_level = c.GDEXTENSION_INITIALIZATION_SCENE;

    std.log.debug("zig_init", .{});

    return 1;
}
```
这里要说明下`GDEXTENSION_INITIALIZATION_SCENE`，godot有四个初始化阶段（level），core、server、scene、editor。
一般导出的游戏会初始化到scene阶段，编辑器里则会初始化到editor阶段。
然后运行：
```bash
zig build
```
编译出`libzig.so`，把so放到godot项目的`lib`路径下，然后在godot项目的根目录下创建`zig.gdextension`文件：
```
[configuration]
entry_symbol = "zig_init"
compatibility_minimum = "4.6"

[libraries]
linux.debug = "res://lib/libzig.so"
```
这样打开项目时，就会加载libzig.so了。
不过现在std.log的信息不会显示到godot的output里，而是会出现在终端的stdout里，这个以后再说了。
