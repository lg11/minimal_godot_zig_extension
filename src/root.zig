const std = @import("std");

const c = @cImport({
    @cInclude("gdextension_interface.h");
});

fn initialize(userdata: ?*anyopaque, level: c_uint) callconv(.c) void {
    _ = userdata;

    switch (level) {
        c.GDEXTENSION_INITIALIZATION_SERVERS => {
            std.log.debug("initialize servers", .{});
        },
        c.GDEXTENSION_INITIALIZATION_EDITOR => {
            std.log.debug("initialize editor", .{});
        },
        else => {
            std.log.debug("initialize else", .{});
        },
    }
}

fn deinitialize(userdata: ?*anyopaque, level: c_uint) callconv(.c) void {
    _ = userdata;

    switch (level) {
        c.GDEXTENSION_INITIALIZATION_SERVERS => {
            std.log.debug("deinitialize servers", .{});
        },
        c.GDEXTENSION_INITIALIZATION_EDITOR => {
            std.log.debug("deinitialize editor", .{});
        },
        else => {
            std.log.debug("initialize else", .{});
        },
    }
}
export fn zig_init(
    ptrGetProcAddress: c.GDExtensionInterfaceGetProcAddress,
    ptrLibrary: c.GDExtensionClassLibraryPtr,
    ptrInitialization: *c.GDExtensionInitialization,
) callconv(.c) c.GDExtensionBool {
    _ = ptrGetProcAddress;
    _ = ptrLibrary;

    ptrInitialization.initialize = initialize;
    ptrInitialization.deinitialize = deinitialize;
    ptrInitialization.userdata = null;
    ptrInitialization.minimum_initialization_level = c.GDEXTENSION_INITIALIZATION_SERVERS;

    std.log.debug("zig_init", .{});

    return 1;
}
