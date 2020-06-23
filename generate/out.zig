const std = @import("std");
const File = std.fs.File;

pub const Output = struct {
    file: File,
    table_name: []const u8,

    const Self = @This();

    pub fn start(self: *Self) !void {
        try self.file.outStream().print("pub const {} = [_][2]u8", .{ self.table_name });
        try self.file.writeAll("{\n");
    }

    pub fn finish(self: *Self) !void {
        try self.file.writeAll("};\n");
    }
};
