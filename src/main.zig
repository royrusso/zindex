const std = @import("std");

pub const InvertedIndex = @import("core/inverted_index.zig").InvertedIndex;

/// Public API for the zindex library
pub fn main() !void {
    std.debug.print("zindex - A Zig inverted index library\n", .{});
}

// test "basic functionality" {
//     // Basic tests can go here, but more extensive tests should be in separate files
//     const allocator = std.testing.allocator;

//     var index = try InvertedIndex.init(allocator);
//     defer index.deinit();

//     try index.addDocument("doc1", "hello world");
//     try index.addDocument("doc2", "hello zig");

//     var results = try index.search("hello");
//     defer results.deinit();

//     try std.testing.expectEqual(@as(usize, 2), results.count());
//     try std.testing.expect(results.contains("doc1"));
//     try std.testing.expect(results.contains("doc2"));
// }
