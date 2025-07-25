gpa: Allocator,
scratch_arena_state: *std.heap.ArenaAllocator,
lexer_arena_state: ?*std.heap.ArenaAllocator,
parser_arena_state: ?*std.heap.ArenaAllocator,
tacky_arena_state: ?*std.heap.ArenaAllocator,
codegen_arena_state: ?*std.heap.ArenaAllocator,
code_emission_arena_state: ?*std.heap.ArenaAllocator,

error_reporter: *ErrorReporter,
error_reporter_arena_state: *std.heap.ArenaAllocator,

const Self = @This();

pub fn init(gpa: Allocator, src: []const u8, src_path: []const u8) Self {
    const arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    arena_state.* = std.heap.ArenaAllocator.init(gpa);

    const lexer_arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    lexer_arena_state.* = std.heap.ArenaAllocator.init(gpa);

    const parser_arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    parser_arena_state.* = std.heap.ArenaAllocator.init(gpa);

    const tacky_arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    tacky_arena_state.* = std.heap.ArenaAllocator.init(gpa);

    const codegen_arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    codegen_arena_state.* = std.heap.ArenaAllocator.init(gpa);

    const code_emission_arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    code_emission_arena_state.* = std.heap.ArenaAllocator.init(gpa);

    const error_reporter_arena_state = gpa.create(std.heap.ArenaAllocator) catch unreachable;
    error_reporter_arena_state.* = std.heap.ArenaAllocator.init(gpa);
    const error_arena = error_reporter_arena_state.allocator();

    const error_reporter = error_arena.create(ErrorReporter) catch unreachable;
    error_reporter.* = ErrorReporter.init(error_arena, src, src_path);

    return .{
        .gpa = gpa,
        .scratch_arena_state = arena_state,
        .lexer_arena_state = lexer_arena_state,
        .parser_arena_state = parser_arena_state,
        .tacky_arena_state = tacky_arena_state,
        .codegen_arena_state = codegen_arena_state,
        .code_emission_arena_state = code_emission_arena_state,
        .error_reporter = error_reporter,
        .error_reporter_arena_state = error_reporter_arena_state,
    };
}

pub fn deinit(self: *Self) void {
    _ = self.scratch_arena_state.deinit();
    self.gpa.destroy(self.scratch_arena_state);

    self.deinitLexerArena();
    self.deinitParserArena();
    self.deinitTackyArena();
    self.deinitCodegenArena();
    self.deinitCodeEmissionArena();

    self.error_reporter_arena_state.deinit();
    self.gpa.destroy(self.error_reporter_arena_state);
}

pub fn scratchArena(self: *const Self) Allocator {
    return self.scratch_arena_state.allocator();
}

pub fn resetScratchArena(self: *const Self) void {
    _ = self.scratch_arena_state.reset(.retain_capacity);
}

pub fn lexerArena(self: *const Self) Allocator {
    return self.lexer_arena_state.?.allocator();
}

pub fn deinitLexerArena(self: *Self) void {
    if (self.lexer_arena_state) |arena| {
        _ = arena.deinit();
        self.gpa.destroy(arena);
        self.lexer_arena_state = null;
    }
}

pub fn parserArena(self: *const Self) Allocator {
    return self.parser_arena_state.?.allocator();
}

pub fn deinitParserArena(self: *Self) void {
    if (self.parser_arena_state) |arena| {
        _ = arena.deinit();
        self.gpa.destroy(arena);
        self.parser_arena_state = null;
    }
}

pub fn tackyArena(self: *const Self) Allocator {
    return self.tacky_arena_state.?.allocator();
}

pub fn deinitTackyArena(self: *Self) void {
    if (self.tacky_arena_state) |arena| {
        _ = arena.deinit();
        self.gpa.destroy(arena);
        self.tacky_arena_state = null;
    }
}

pub fn codegenArena(self: *const Self) Allocator {
    return self.codegen_arena_state.?.allocator();
}

pub fn deinitCodegenArena(self: *Self) void {
    if (self.codegen_arena_state) |arena| {
        _ = arena.deinit();
        self.gpa.destroy(arena);
        self.codegen_arena_state = null;
    }
}

pub fn codeEmissionArena(self: *const Self) Allocator {
    return self.code_emission_arena_state.?.allocator();
}

pub fn deinitCodeEmissionArena(self: *Self) void {
    if (self.code_emission_arena_state) |arena| {
        _ = arena.deinit();
        self.gpa.destroy(arena);
        self.code_emission_arena_state = null;
    }
}

const std = @import("std");
const ErrorReporter = @import("ErrorReporter.zig");
const Allocator = std.mem.Allocator;
