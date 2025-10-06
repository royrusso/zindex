const std = @import("std");

pub const InvertedIndex = struct {
    /// The main map of terms to documents
    terms: std.StringHashMap(*Documents),
    /// The allocator used for memory management
    allocator: std.mem.Allocator,

    /// Documents holds a set of document IDs
    pub const Documents = struct {
        /// Set of document IDs
        docs: std.StringHashMap(void),
        /// The allocator used for memory management
        allocator: std.mem.Allocator,

        /// Initialize a new Documents set
        pub fn init(allocator: std.mem.Allocator) !*Documents {
            const self = try allocator.create(Documents);
            self.* = .{
                .docs = std.StringHashMap(void).init(allocator),
                .allocator = allocator,
            };
            return self;
        }

        /// Clean up resources
        pub fn deinit(self: *Documents) void {
            self.docs.deinit();
            self.allocator.destroy(self);
        }

        /// Add a document ID to the set
        pub fn add(self: *Documents, doc_id: []const u8) !void {
            const owned_id = try self.allocator.dupe(u8, doc_id);
            try self.docs.put(owned_id, {});
        }

        /// Check if the set contains a document ID
        pub fn contains(self: *Documents, doc_id: []const u8) bool {
            return self.docs.contains(doc_id);
        }

        /// Get the number of documents in the set
        pub fn count(self: *Documents) usize {
            return self.docs.count();
        }
    };

    /// Initialize a new InvertedIndex
    pub fn init(allocator: std.mem.Allocator) !InvertedIndex {
        return InvertedIndex{
            .terms = std.StringHashMap(*Documents).init(allocator),
            .allocator = allocator,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *InvertedIndex) void {
        var it = self.terms.iterator();
        while (it.next()) |entry| {
            const term_key = entry.key_ptr.*;
            const docs = entry.value_ptr.*;

            self.allocator.free(term_key);
            docs.deinit();
        }
        self.terms.deinit();
    }

    /// Add a document to the index with the given content
    pub fn addDocument(self: *InvertedIndex, doc_id: []const u8, content: []const u8) !void {
        var terms_iter = std.mem.tokenizeScalar(u8, content, ' ');

        while (terms_iter.next()) |term| {
            const gop = try self.getOrPutTerm(term);
            try gop.docs.add(doc_id);
        }
    }

    /// Search the index for documents containing the term
    pub fn search(self: *InvertedIndex, term: []const u8) !*Documents {
        const docs = self.terms.get(term) orelse {
            return error.TermNotFound;
        };
        return docs;
    }

    /// Helper method to get or create a Documents set for a term
    fn getOrPutTerm(self: *InvertedIndex, term: []const u8) !*Documents {
        const result = try self.terms.getOrPut(term);

        if (!result.found_existing) {
            // Create a new term entry
            const owned_term = try self.allocator.dupe(u8, term);
            result.key_ptr.* = owned_term;

            // Create a new document set for this term
            result.value_ptr.* = try Documents.init(self.allocator);
        }

        return result.value_ptr.*;
    }
};
