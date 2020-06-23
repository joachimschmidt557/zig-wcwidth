const std = @import("std");
const process = std.process;
const Allocator = std.mem.Allocator;

const Output = @import("out.zig").Output;

fn parseEastAsian(alloc: *Allocator, in_stream: var) !void {
    const version_line = try in_stream.readUntilDelimiterAlloc(alloc, '\n', 1024 * 40);
    const date_line = try in_stream.readUntilDelimiterAlloc(alloc, '\n', 1024 * 40);

    while (in_stream.readUntilDelimiterAlloc(alloc, '\n', 1024 * 40)) |line| {
        if (line[0] == '#') continue;

        var iter = std.mem.tokenize(line, ";");
        const addrs = iter.next() orelse continue;
        const details = iter.next() orelse continue;
    } else |e| switch (e) {
        error.EndOfStream => {},
        else => return e,
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    var args_it = process.args();
    if (!args_it.skip()) @panic("expected self arg");
    
    const in_file_name = try (args_it.next(allocator) orelse @panic("expected input arg"));
    defer allocator.free(in_file_name);
    const out_file_name = try (args_it.next(allocator) orelse @panic("expected output arg"));
    defer allocator.free(out_file_name);

    var in_file = try std.fs.cwd().openFile(in_file_name, .{ .read = true });
    defer in_file.close();
    var out_file = try std.fs.cwd().createFile(out_file_name, .{});
    defer out_file.close();

    var in_stream = in_file.inStream();

    var output = Output{ .file = out_file, .table_name = "wide_eastasian" };
    try output.start();


    try output.finish();
}
