const std = @import("std");
const process = std.process;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Version = std.builtin.Version;

const max_line_len = 1024 * 40;

const Table = struct {
    version: void,
    date: void,
    values: void,
};

fn getUnicodeVersions(allocator: *Allocator) ![]const Version {
    var result = ArrayList(Version).init(allocator);

    var file = try std.fs.cwd().openFile("DerivedAge.txt", .{});
    defer file.close();

    var reader = file.reader();
    while (reader.readUntilDelimiterAlloc(allocator, '\n', max_line_len)) |line| {
        defer allocator.free(line);

        const needle = "# Newly assigned in Unicode ";
        if (std.mem.startsWith(u8, line, needle)) {
            const version_start = line[needle.len..];
            const version_end = std.mem.indexOfScalar(u8, version_start, ' ') orelse continue;
            const version = version_start[0..version_end];

            try result.append(try Version.parse(version));
        }
    } else |e| switch (e) {
        error.EndOfStream => {},
        else => return e,
    }

    return result.toOwnedSlice();
}

fn writeUnicodeVersions(allocator: *Allocator, versions: []const Version) !void {
    const file_name = "unicode_versions.zig";
    var file = try std.fs.cwd().createFile(file_name, .{});
    defer file.close();

    const writer = file.writer();

    try writer.writeAll(
        \\/// Generated by tools/generate.zig
        \\const std = @import("std");
        \\const Version = std.builtin.Version;
        \\
    );

    try writer.writeAll("pub const unicode_versions = [_]Version{\n");

    const indent = "    ";
    for (versions) |v| {
        try writer.print(indent ++ "comptime Version.parse(\"{}\"),\n", .{v});
    }

    try writer.writeAll("}\n");
}

fn makeTable(allocator: *Allocator, values: []const u21) ![]const [2]u21 {
    var result = ArrayList([2]u21).init(allocator);

    var start = values[0];
    var end = values[0];
    for (values) |x, i| {
        if (i == 0) {
            try result.append([2]u21{ x, x });
        } else {
            const last = result.pop();
            start = last[0];
            end = last[1];

            if (end == x - 1) {
                try result.append([2]u21{ start, x });
            } else {
                try result.append([2]u21{ start, end });
                try result.append([2]u21{ x, x });
            }
        }
    }

    return result.toOwnedSlice();
}

fn writeTable(file: File, table_name: []const u8, table: Table) !void {
    const buf_writer = std.io.bufferedWriter(file.writer());
    const writer = buf_writer.writer();

    try writer.writeAll("/// Automatically generated table\n");
    try writer.print("pub const {} = [_][2]u21{\n", .{table_name});

    try writer.writeAll("};\n");

    try buf_writer.flush();
}

fn writeEastAsian(allocator: *Allocator, versions: []const Version) !void {
    var in_file = try std.fs.cwd().openFile("", .{});
    defer in_file.close();
    var out_file = try std.fs.cwd().createFile("", .{});
    defer out_file.close();

    var reader = in_file.reader();
}

fn parseEastAsian(allocator: *Allocator, reader: anytype) !Table {
    const properties = [_]u8{ 'W', 'F' };

    const version_line = try reader.readUntilDelimiterAlloc(allocator, '\n', max_line_len);
    const date_line = try reader.readUntilDelimiterAlloc(allocator, '\n', max_line_len);

    while (reader.readUntilDelimiterAlloc(allocator, '\n', max_line_len)) |line| {
        if (line.len > 0 and line[0] == '#') continue;

        var iter = std.mem.tokenize(line, ";");
        const addrs = iter.next() orelse continue;
        const details = iter.next() orelse continue;
    } else |e| switch (e) {
        error.EndOfStream => {},
        else => return e,
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = &gpa.allocator;

    const versions = try getUnicodeVersions(allocator);
    defer allocator.free(versions);

    // try writeEastAsian(allocator, versions);
    try writeUnicodeVersions(allocator, versions);
}