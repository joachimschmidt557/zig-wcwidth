const std = @import("std");
const testing = std.testing;

const main = @import("main.zig");
const wcwidth = main.wcwidth;
const wcswidth = main.wcswidth;
const sliceWidth = main.sliceWidth;

test "null character" {
    testing.expectEqual(@as(isize, 0), wcwidth(0));
}

test "simple ascii characters" {
    testing.expectEqual(@as(isize, 1), wcwidth('a'));
    testing.expectEqual(@as(isize, 1), wcwidth('1'));
    testing.expectEqual(@as(isize, 1), wcwidth('-'));
}

test "hello jp" {
    const phrase = "コンニチハ, セカイ!";
    const expect_length_each = [_]isize{ 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 1 };
    const expect_length_phrase = comptime blk: {
        var sum: isize = 0;
        for (expect_length_each) |x| sum += x;
        break :blk sum;
    };

    // Check individual widths
    var utf8 = (try std.unicode.Utf8View.init(phrase)).iterator();
    var i: usize = 0;
    while (utf8.nextCodepoint()) |codepoint| : (i += 1) {
        testing.expectEqual(expect_length_each[i], wcwidth(codepoint));
    }

    // Check phrase width
    testing.expectEqual(expect_length_phrase, try sliceWidth(phrase));
}

test "csi width -1" {
    const phrase = "\x1B[0m";
    const expect_length_each = [_]isize{ -1, 1, 1, 1 };
    const expect_length_phrase: isize = -1;

    // Check individual widths
    var utf8 = (try std.unicode.Utf8View.init(phrase)).iterator();
    var i: usize = 0;
    while (utf8.nextCodepoint()) |codepoint| : (i += 1) {
        testing.expectEqual(expect_length_each[i], wcwidth(codepoint));
    }

    // Check phrase width
    testing.expectEqual(expect_length_phrase, try sliceWidth(phrase));
}

test "combining total 4" {
    const phrase = "--\u{05BF}--";
    const expect_length_each = [_]isize{ 1, 1, 0, 1, 1 };
    const expect_length_phrase: isize = 4;

    // Check individual widths
    var utf8 = (try std.unicode.Utf8View.init(phrase)).iterator();
    var i: usize = 0;
    while (utf8.nextCodepoint()) |codepoint| : (i += 1) {
        testing.expectEqual(expect_length_each[i], wcwidth(codepoint));
    }

    // Check phrase width
    testing.expectEqual(expect_length_phrase, try sliceWidth(phrase));
}

test "combining cafe" {
    const phrase = "cafe\u{0301}";
    const expect_length_each = [_]isize{ 1, 1, 1, 1, 0 };
    const expect_length_phrase: isize = 4;

    // Check individual widths
    var utf8 = (try std.unicode.Utf8View.init(phrase)).iterator();
    var i: usize = 0;
    while (utf8.nextCodepoint()) |codepoint| : (i += 1) {
        testing.expectEqual(expect_length_each[i], wcwidth(codepoint));
    }

    // Check phrase width
    testing.expectEqual(expect_length_phrase, try sliceWidth(phrase));
}

test "combining enclosing" {
    const phrase = "\u{0401}\u{0488}";
    const expect_length_each = [_]isize{ 1, 0 };
    const expect_length_phrase: isize = 1;

    // Check individual widths
    var utf8 = (try std.unicode.Utf8View.init(phrase)).iterator();
    var i: usize = 0;
    while (utf8.nextCodepoint()) |codepoint| : (i += 1) {
        testing.expectEqual(expect_length_each[i], wcwidth(codepoint));
    }

    // Check phrase width
    testing.expectEqual(expect_length_phrase, try sliceWidth(phrase));
}

test "combining spacing" {
    const phrase = "\u{1B13}\u{1B28}\u{1B2E}\u{1B44}";
    const expect_length_each = [_]isize{ 1, 1, 1, 1 };
    const expect_length_phrase: isize = 4;

    // Check individual widths
    var utf8 = (try std.unicode.Utf8View.init(phrase)).iterator();
    var i: usize = 0;
    while (utf8.nextCodepoint()) |codepoint| : (i += 1) {
        testing.expectEqual(expect_length_each[i], wcwidth(codepoint));
    }

    // Check phrase width
    testing.expectEqual(expect_length_phrase, try sliceWidth(phrase));
}
