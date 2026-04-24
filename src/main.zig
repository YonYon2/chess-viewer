const std = @import("std");
const Allocator = std.mem.Allocator;

const CSI = "\x1b[";
const CLS = CSI ++ "2J";
const SAVE_POS = CSI ++ "s";
const LOAD_POS = CSI ++ "u";
const RESET_POS = CSI ++ "H";
const RESET_COL = CSI ++ "m";
const FG_RGB = CSI ++ "38;2;{};{};{}m";
const BG_RGB = CSI ++ "48;2;{};{};{}m";
// use this for runtime version and just pass the arguments
const GOTO_FMT = CSI ++ "{};{}H";

// colors used to draw pieces, squares, etc.
const bg1: [3]u8 = .{ 0x69, 0x92, 0x3E }; // #69923E
const bg2: [3]u8 = .{ 0xe9, 0xea, 0xce }; // #e9eace
const highlight1: [3]u8 = .{ 0xb9, 0xca, 0x43 }; // #b9ca43
const highlight2: [3]u8 = .{ 0xf5, 0xf6, 0x82 }; // #f5f682
const white: [3]u8 = .{ 0, 0, 0 }; // unicode is mostly blank so a dark outline would help it #f9f9f9
const black: [3]u8 = .{ 0x57, 0x54, 0x52 }; // #575452
const defeat: [3]u8 = .{ 0xff, 0, 0 };
const victory: [3]u8 = .{ 0, 0xff, 0 };

// meant for the below wrapper
const FG_FMT = CSI ++ "38;2;{}m";
const BG_FMT = CSI ++ "48;2;{}m";
/// A wrapper so that with any tuple of RGB values you can print its values to `Writer`
fn Color(comptime RGB: [3]u8) type {
    return struct {
        const Self = @This();
        /// exists so you intialize with `Color(bg1).c` instead of `Color(bg1){}` so less visual clutter
        const c: Color(RGB) = .{};
        pick: [3]u8 = RGB,
        /// all this just so I dont have to write out all three elements of the array 
        pub fn format(
            self: Self,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{};{};{}", .{self.pick[0], self.pick[1], self.pick[2]});
        }
    };
}

// need to figure out how to output the text version everytime so it doesnt stick the emoji one and spoil the style
test "pawn as emoji and text" {
    // const p_u21 = @intFromEnum(ChessUnicode.p);
    const pawn_base = "♟";
    const pawn_base_v15 = "♟︎";
    const pawn_base_emoji = "♟️";
    std.debug.print("\nBase {s}\nBase+V15 {s}\nEmoji {s}\n", .{pawn_base, pawn_base_v15, pawn_base_emoji});
}

test "color format showcase" {
    // const col: Color(bg1) = .{};
    std.debug.print( "\n\x1b[48;2;{f}m!\n", .{Color(bg1).c});
    std.debug.print( "\n\x1b[48;2;{f}m?\n", .{Color(.{101, 25, 135}).c});
    std.debug.print( RESET_COL, .{});
}

const ChessUnicode = enum(u21) { K = 0x2654, Q, R, B, N, P, k, q, r, b, n, p };

const Pieces = enum(u8) {
    nada = '.',
    K = 'K',
    Q = 'Q',
    R = 'R',
    B = 'B',
    N = 'N',
    P = 'P',
    k = 'k',
    q = 'q',
    r = 'r',
    b = 'b',
    n = 'n',
    p = 'p',
    fn getUnicode(self: Pieces) u21 {
        return switch (self) {
            .K => @intFromEnum(ChessUnicode.K),
            .Q => @intFromEnum(ChessUnicode.Q),
            .R => @intFromEnum(ChessUnicode.R),
            .B => @intFromEnum(ChessUnicode.B),
            .N => @intFromEnum(ChessUnicode.N),
            .P => @intFromEnum(ChessUnicode.P),
            .k => @intFromEnum(ChessUnicode.k),
            .q => @intFromEnum(ChessUnicode.q),
            .r => @intFromEnum(ChessUnicode.r),
            .b => @intFromEnum(ChessUnicode.b),
            .n => @intFromEnum(ChessUnicode.n),
            .p => @intFromEnum(ChessUnicode.p),
            else => ' ',
        };
    }
};

const Square = struct {
    const Self = @This();
    file: u3,
    rank: u3,
    const default: Square = .{ .file = 0, .rank = 0 };
    /// algebraic notation of square as a 2-byte string
    fn str(self: Self) [2]u8 {
        return .{ 'a' + @as(u8, self.file), '1' + @as(u8, self.rank) };
    }
    /// number between 0-64 to index a Game board
    fn boardIndex(self: Self) usize {
        return @as(usize, self.rank) * 8 + self.file;
    }
};

const Piece = struct {
    const Self = @This();
    alive: bool, // draw the piece
    square: Square, // where it resides
    const default: Piece = .{ .alive = false, .square = .default };
    fn activate(file: u3, rank: u3) Piece {
        return .{
            .alive = true,
            .square = .{ .file = file, .rank = rank },
        };
    }
};

const Player = struct {
    // used for position reference to quickly figure out what is being replaced
    pawn: [8]Piece,
    knight: [10]Piece,
    bishop: [10]Piece,
    rook: [10]Piece,
    queen: [9]Piece,
    king: Piece,
    fn init(comptime first: bool) Player {
        const pawn_rank: u3 = if (first) 1 else 6;
        const main_rank: u3 = if (first) 0 else 7;
        return .{
            .pawn = blk: {
                var p_arr: [8]Piece = undefined;
                inline for (0..8) |i| p_arr[i] = .{ .alive = true, .square = .{ .file = @truncate(i), .rank = pawn_rank } };
                break :blk p_arr;
            },
            .knight = [2]Piece{ Piece.activate(1, main_rank), Piece.activate(6, main_rank) } ++
                [1]Piece{Piece.default} ** 8,
            .bishop = [2]Piece{ Piece.activate(2, main_rank), Piece.activate(5, main_rank) } ++
                [1]Piece{Piece.default} ** 8,
            .rook = [2]Piece{ Piece.activate(0, main_rank), Piece.activate(7, main_rank) } ++
                [1]Piece{Piece.default} ** 8,
            .queen = [1]Piece{Piece.activate(3, main_rank)} ++ [1]Piece{Piece.default} ** 8,
            .king = Piece.activate(4, main_rank),
        };
    }
};

// reference for understanding how to read PGN moves
// https://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm
const Game = struct {
    const Self = @This();
    const initial_board = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr";
    white: []const u8 = "Player 1",
    black: []const u8 = "Player 2",
    result: []const u8 = "Draw",
    time: u32 = 60, // seconds
    increment: u32 = 0, // seconds
    clock: [2]u32 = .{ 600, 600 }, // 10ths of a second
    // ranks 1-8 goes top to bottom, and files a-h goes left to right
    board: [64]Pieces = blk: {
        var result = [1]Pieces{.nada} ** 64;
        for (initial_board, 0..) |c, i| {
            result[i] = @enumFromInt(c);
        }
        break :blk result;
    },
    flip: bool = false,
    fn printBoard(self: Self) void {
        for (self.board, 0..) |P, i| {
            if (i % 8 == 0)
                std.debug.print("\n", .{});
            std.debug.print("{c}", .{@intFromEnum(P)});
        }
    }
};

// convert tenths of a second amount into the format: mm:ss OR ss.t When less than 20 seconds
// only needs 6 u8s to fit clock
fn clockStr(buf: *[6]u8, time: u32) []const u8 {
    const s = (time / 10) % 60;
    const m = time / 10 / 60;
    if (time >= 200)
        return std.fmt.bufPrint(&buf.*, "{:>2}:{:0>2} ", .{ m, s }) catch unreachable;
    const t = time % 10;
    return std.fmt.bufPrint(&buf.*, "0:{:0>2}.{:1}", .{ s, t }) catch unreachable;
}

// for the purposes of updating the screen
const Change = struct {
    const Self = @This();
    flip: bool = false,
    from: Square = .default,
    to: Square = .default,
    mover: Pieces = .nada,
    replace: Pieces = .nada,
    promote: Pieces = .nada,
    castle: ?struct { from: Square = .default, to: Square = .default } = null,
    // clock: []const u8 = &.{},
    check: bool = false, // will be used to highlight the opposing king
    enpassant: bool = false, // replace will redo the piece to the left/right of the pawn
    delay: u32 = 1, // tenths of a second
    /// blanks the from square with the correct background color and at the correct cursor position, accounting for flip
    fn printBlank(self: Self) void {
        { // did this so row in the next block is not shadowed
            const sqr_c = if ((self.from.rank -% self.from.file) % 2 == 0) bg1 else bg2;
            const row: u32, const col: u32 = self.from;
            std.debug.print(BG_FMT ++ GOTO_FMT ++ "  ", .{ sqr_c, row + 2, 2 * col + 1 });
        }
        if (self.enpassant) {
            // take the file of `to` and the rank of `from`  
            const enpass_c = if ((self.from.rank -% self.to.file) % 2 == 0) bg1 else bg2;
            const row: u32, const col: u32 = .{ self.from.rank, self.to.file };
            std.debug.print( BG_FMT ++ GOTO_FMT ++ "  ", .{ enpass_c, row + 2, 2 * col + 1});
        }
    }
    /// establish the piece with its background color, foreground color, and cursor position from its square and flip's value
    fn printPiece(self: Self) void {
        const piece_c = if (std.ascii.isUpper(@intFromEnum(self.mover))) white else black;
        const sqr_c = if ((self.to.rank -% self.to.file) % 2 == 0) bg1 else bg2;
        std.debug.print(BG_FMT ++ FG_FMT ++ GOTO_FMT ++ "{u} ", .{ sqr_c, piece_c, @as(u32, self.from.rank) + 2, 2 * @as(u32, self.from.file) + 1, self.mover.getUnicode() });
    }
};

// order of iterating through changes:
// 1. read `delay`
// 2. wait for `delay` time elapsed
// 3. update clock each 1s or each 0.1s if less than 20s
// 4. update from/to pieces
// 5. update from/to bg colors
// 5. update check bg highlight
// 6. advance to next change

// piece that moves always leaves behind a blank tile

// object that holds the info for what was read from a PGN file
const PgnReader = struct {
    const Self = @This();
    allocator: Allocator,
    game_info: Game,
    current_move: usize = 0,
    move_list: std.ArrayList(Change),
    fn init(allocator: Allocator, contents: []const u8) !PgnReader {
        var move_list = try std.ArrayList(Change).initCapacity(allocator, 50);
        var game = Game{};
        game.flip = true;

        var file = try std.fs.cwd().openFile(contents, .{});
        defer file.close();
        // hold entire file
        const data = try allocator.alloc(u8, (try file.stat()).size);
        defer allocator.free(data);
        var file_reader = file.reader(data);
        const file_out = &file_reader.interface;

        var tag_name: []const u8 = &.{};
        var value: []const u8 = &.{};
        const tags = [_][]const u8{ "White", "Black", "Result", "TimeControl", "WhiteElo", "BlackElo", "Termination" };
        while (true) {
            _ = try file_out.discardDelimiterInclusive('[');
            tag_name = try file_out.peekDelimiterExclusive(' ');
            _ = try file_out.discardDelimiterInclusive('"');
            value = try file_out.peekDelimiterExclusive('"');
            _ = try file_out.discardDelimiterInclusive('\n');
            for (tags, 0..) |tag, i| {
                if (std.mem.eql(u8, tag, tag_name)) {
                    switch (i) {
                        0 => game.white = value,
                        1 => game.black = value,
                        2 => game.result = value,
                        3 => {
                            var time_it = std.mem.tokenizeScalar(u8, value, '+');
                            if (time_it.next()) |clock| {
                                game.time = try std.fmt.parseUnsigned(u32, clock, 10);
                                game.clock = [1]u32{game.time * 10} ** 2;
                            }
                            if (time_it.next()) |inc| {
                                game.increment = try std.fmt.parseUnsigned(u32, inc, 10);
                            }
                        },
                        else => {},
                    }
                }
            }
            const next_line = try file_out.peekDelimiterExclusive('\n');
            std.debug.print("\n(next has {} characters)\n", .{next_line.len});
            if (next_line.len <= 1) {
                break;
            }
        }
        const remaining_file = file_out.buffered();
        // view by character and piece together Change item to add to the move list
        var is_white, var start_index: usize, var start_read = .{ true, 0, false };
        const Modes = enum { move_number, move, clock, timestamp };
        var mode = Modes.move_number;
        // here for the purpose of finding a player's pieces without looking through
        // TODO potentially don't need this
        var players = [_]Player{ .init(false), .init(true) };
        for (remaining_file, 0..) |c, i| {
            switch (mode) {
                .move_number => {
                    if (std.ascii.isWhitespace(c))
                        continue;
                    if (c == '.')
                        mode = .move;
                },
                .move => {
                    if (!start_read) {
                        if (c == '.' or std.ascii.isWhitespace(c))
                            continue;
                        start_index = i;
                        start_read = true;
                    } else {
                        if (std.ascii.isWhitespace(c)) {
                            const player_i: usize = @intFromBool(is_white);
                            const move_text = remaining_file[start_index..i];
                            var castling = false;
                            // push to movelist
                            var hold_change: Change = .{};
                            // check which piece is moving
                            hold_change.mover = switch (move_text[0]) {
                                'K' => if (is_white) .K else .k,
                                'Q' => if (is_white) .Q else .q,
                                'R' => if (is_white) .R else .r,
                                'B' => if (is_white) .B else .b,
                                'N' => if (is_white) .N else .n,
                                'O' => lbo: {
                                    // handle all castling logic since its fixed (except for check and checkmate)
                                    castling = true;
                                    const is_castle_long = move_text.len >= 5; //O-O >=3, O-O-O >=5
                                    const back_rank: u3 = if (is_white) 0 else 7;
                                    hold_change.from = players[player_i].king.square;
                                    hold_change.to = .{ .file = if (is_castle_long) 6 else 2, .rank = back_rank };
                                    // update player king
                                    players[player_i].king.square = hold_change.to;
                                    const rook_from_file: u3 = if (is_castle_long) 0 else 7;
                                    const rook_to_file: u3 = if (is_castle_long) 3 else 5;
                                    hold_change.castle = .{
                                        .from = .{ .file = rook_from_file, .rank = back_rank },
                                        .to = .{ .file = rook_to_file, .rank = back_rank },
                                    };
                                    // TODO update player rook (need to loop through all bc there COULD be more than 2 active rooks)
                                    for (&players[player_i].rook) |*rook| {
                                        if (rook.alive and rook.square.file == rook_from_file and rook.square.rank == back_rank) {
                                            rook.square = hold_change.castle.?.to;
                                            break;
                                        }
                                    }
                                    break :lbo if (is_white) .K else .k;
                                },
                                else => if (is_white) .P else .p,
                            };
                            // read square and attack portion of the text
                            const sqr_sec_end = std.mem.indexOfNone(u8, move_text, "KQRNBabcdefgh12345678x");
                            const sqr_sec = if (sqr_sec_end) |end| move_text[0..end] else move_text[0..];
                            // have room to potentially read 1-2 squares
                            var is_attack = false;
                            var file_count: u2, var rank_count: u2 = .{ 0, 0 };
                            var sqr1, var sqr2 = .{ Square.default, Square.default };
                            // bxc5: b5, c5
                            for (sqr_sec) |ch| {
                                if (ch >= 'a' and ch <= 'h') {
                                    if (file_count == 0) {
                                        sqr1.file = @truncate(ch - 'a');
                                        sqr2.file = sqr1.file;
                                    } else {
                                        sqr2.file = @truncate(ch - 'a');
                                    }
                                    file_count += 1;
                                } else if (ch >= '1' and ch <= '8') {
                                    if (rank_count == 0) {
                                        sqr1.rank = @truncate(ch - '1');
                                        sqr2.rank = sqr1.rank;
                                    } else {
                                        sqr2.rank = @truncate(ch - '1');
                                    }
                                    rank_count += 1;
                                } else if (ch == 'x') {
                                    is_attack = true;
                                }
                            }
                            // file_count, rank_count
                            // 1,1 (ex. Ke6)            from: <find>,                to: sqr1
                            // 2,1 or 1,2 (ex. bxc5)    from: sqr1.file | sqr1.rank, to: sqr1
                            // 2,2 (ex. Qa1xh8#)        from: sqr1,                  to: sqr2

                            // fill in `from`, `to`, `replace` based on the mover (for pawns, depends on attack)
                            if (!castling) {
                                switch (hold_change.mover) {
                                    .K, .k => {
                                        hold_change.from = players[player_i].king.square;
                                        hold_change.to = sqr1;
                                        // update player's pieces
                                        players[player_i].king.square = sqr1;
                                        game.board[hold_change.from.boardIndex()] = .nada;
                                        game.board[sqr1.boardIndex()] = hold_change.mover;
                                    },
                                    .P, .p => {
                                        // pawn movement always 1,1
                                        for (&players[player_i].pawn) |*p| {
                                            if (p.alive and p.square.file == sqr1.file) {
                                                const sqr_o = p.square.boardIndex();
                                                if (!is_attack) {
                                                    const sqr_check = if (is_white) sqr_o + 8 else sqr_o - 8;
                                                    // ONLY thing that matters is if 1 space in front of pawn is empty, for both 1 hop and 2 hop pawns
                                                    if (game.board[sqr_check] == .nada) {
                                                        hold_change.from = p.square;
                                                        hold_change.to = sqr1;
                                                        p.square = sqr1;
                                                        game.board[sqr_o] = .nada;
                                                        game.board[sqr1.boardIndex()] = hold_change.mover;
                                                        break;
                                                    }
                                                } else {
                                                    // file2 > file1 = +1 else -1
                                                    // check 1 square diagonal towards the `to` square
                                                    // hm integer overflow
                                                    const file_dir = sqr2.file > sqr1.file;
                                                    var sqr_i = if (is_white) sqr_o + 8 else sqr_o - 8;
                                                    if (file_dir) {
                                                        sqr_i += 1;
                                                    } else sqr_i -= 1;
                                                    // std.debug.print(", {} {c} 8 {c} 1>", .{ if (is_white) sqr_i - 8 else sqr_i + 8, if (is_white) @as(u8, '+') else @as(u8, '-'), if (file_dir) @as(u8, '+') else @as(u8, '-') });

                                                    // also check for en passant
                                                    const enpass_index = if (file_dir) sqr_o + 1 else sqr_o - 1;
                                                    std.debug.print("<({c}) @ enpass>", .{@intFromEnum(game.board[enpass_index])});
                                                    std.debug.print("<({c}) @ capture>", .{@intFromEnum(game.board[sqr_i])});
                                                    hold_change.enpassant = if (is_white) game.board[enpass_index] == .p else game.board[enpass_index] == .P;
                                                    // std.debug.print("enpass? {s}, ", .{if (hold_change.enpassant) "YES" else "NO"});
                                                    if (game.board[sqr_i] != .nada or hold_change.enpassant) {
                                                        std.debug.print("<from {} to {}, en?{}>", .{ sqr_o, if (is_white) sqr_i - 8 else sqr_i + 8, hold_change.enpassant });
                                                        hold_change.from = p.square;
                                                        hold_change.to = sqr2;
                                                        p.square = sqr2;
                                                        hold_change.replace = if (hold_change.enpassant) game.board[enpass_index] else game.board[sqr2.boardIndex()];
                                                        game.board[sqr_o] = .nada;
                                                        game.board[sqr2.boardIndex()] = hold_change.mover;
                                                        if (hold_change.enpassant)
                                                            game.board[enpass_index] = .nada;
                                                        break;
                                                    }
                                                    // game.board[sqr_i] = .K;
                                                }
                                            }
                                        }
                                    },
                                    else => unreachable,
                                }
                            }
                            // TODO handle any check, checkmate, or promotion here

                            // add move
                            try move_list.append(allocator, hold_change);
                            // std.debug.print("{any} ", .{hold_change});
                            game.printBoard();
                            // std.debug.print("{s} ", .{move_text});
                            start_read = false;
                            mode = .clock;
                        }
                    }
                },
                .clock => { // for now can be ignored
                    if (!start_read) {
                        if (std.ascii.isDigit(c)) {
                            start_index = i;
                            start_read = true;
                        }
                    } else {
                        if (c == ']') {
                            const clock_text = remaining_file[start_index..i];
                            std.debug.print("{s} ", .{clock_text});
                            start_read = false;
                            mode = .timestamp;
                        }
                    }
                },
                .timestamp => {
                    if (!start_read) {
                        if (std.ascii.isDigit(c)) {
                            start_index = i;
                            start_read = true;
                        }
                    } else {
                        if (c == ']') {
                            const timestamp_number = try std.fmt.parseUnsigned(u32, remaining_file[start_index..i], 10);
                            std.debug.print("{}\n", .{timestamp_number});
                            move_list.items[move_list.items.len - 1].delay = timestamp_number;
                            start_read = false;
                            is_white = !is_white;
                            mode = .move_number;
                        }
                    }
                },
            }
        }
        std.debug.print("{} plies! {} moves!\n", .{ move_list.items.len, move_list.items.len / 2 });
        for (move_list.items) |change| {
            std.debug.print("{c} from {s} to {s},", .{ @intFromEnum(change.mover), change.from.str(), change.to.str() });
            if (change.replace != .nada) {
                std.debug.print("x {c}", .{@intFromEnum(change.replace)});
            }
            // if (change.castle) |c| {
            //     std.debug.print("{any}", .{c});
            // }
            std.debug.print("\n", .{});
        }
        return .{
            .allocator = allocator,
            .game_info = game,
            .move_list = move_list, //move_list,
        };
    }
    fn drawPlayback(self: Self) void {
        _ = self;
    }
    fn drawInit(self: Self) void {
        std.debug.print(CLS ++ GOTO_FMT, .{ 1, 1 });
        for (Game.initial_board, 0..) |P, i| {
            if (i % 8 == 0)
                std.debug.print("\n", .{});
            const r = i / 8;
            const f = i % 8;
            const tile_c = if ((r -% f) % 2 == 0) bg1 else bg2;
            const piece_c = if (std.ascii.isUpper(P)) white else black;
            const piece_e: Pieces = @enumFromInt(P);
            std.debug.print(BG_RGB ++ FG_RGB ++ "{u} " ++ RESET_COL, .{
                tile_c[0],            tile_c[1],  tile_c[2],
                piece_c[0],           piece_c[1], piece_c[2],
                piece_e.getUnicode(),
            });
        }
        // save the input line position
        std.debug.print("\n\n" ++ SAVE_POS ++ "Input:", .{});
        // go back and print player names and clocks
        if (self.game_info.flip) {
            // const top_pname = if (self.game_info.flip) self.game_info.white else self.game_info.black;
            // // const top_clock = self.game_info.clock;
            // const bottom_pname = if (self.game_info.flip) self.game_info.black else self.game_info.white;
            // _ = bottom_pname;
            // std.debug.print(cursorGoto(1, 11) ++ "{s}" ++ cursorGoto(2, 11), .{
            //     top_pname,
            // });
        } else {
            // std.debug.print(cursorGoto(1, 11) ++ self.game_info.white, .{});
        }
    }
    fn drawNext(self: *Self) void {
        if (self.current_move >= self.move_list.items.len)
            return;
        // reverse effects of previous updates
        // if (self.current_move > 0) {
        //     const prev = self.move_list.items[self.current_move - 1];
        // }
        const curr = self.move_list.items[self.current_move];
        // move mover
        const piece_c = if (self.current_move % 2 == 0) white else black;
        // highlight to and from squares
        const left_c = if ((curr.from.rank -% curr.from.file) % 2 == 0) bg1 else bg2;
        std.debug.print(BG_RGB ++ GOTO_FMT ++ "  ", .{
            left_c[0], left_c[1], left_c[2],
            @as(u32, curr.from.rank) + 2, 2 * @as(u32, curr.from.file) + 1,
        });
        const replace_c = if ((curr.to.rank -% curr.to.file) % 2 == 0) bg1 else bg2;
        std.debug.print(BG_RGB ++ FG_RGB ++ GOTO_FMT ++ "{u} ", .{
            replace_c[0], replace_c[1], replace_c[2],
            piece_c[0], piece_c[1], piece_c[2],
            @as(u32, curr.to.rank) + 2,   2 * @as(u32, curr.to.file) + 1,
            curr.mover.getUnicode(),
        });
        // enpassant
        if (curr.enpassant) {
            // std.debug.print(BG_RGB ++ GOTO_FMT ++ "  ", .{
            //     @as(u32, curr.from.rank) + 2,
            //     2 * @as(u32, curr.to.file) + 1,
            // });
        }
        std.debug.print(LOAD_POS, .{});
        self.current_move += 1;
    }
    fn drawPrev(self: *Self) void {
        if (self.current_move > 0)
            self.current_move -= 1;
    }
    fn deinit(self: *Self) void {
        self.move_list.deinit(self.allocator);
    }
};

// so I can view the colors
const RGBWheel = struct {
    const Self = @This();
    rgb: [3]u8 = .{ 255, 0, 0 },
    climb: bool = false,
    phase: usize = 0,
    fn scroll(self: *Self) void {
        if (!self.climb) {
            const next_c = (self.phase + 1) % 3;
            self.rgb[next_c] += 1;
            if (self.rgb[next_c] == 255) {
                self.climb = true;
            }
        } else {
            self.rgb[self.phase] -= 1;
            if (self.rgb[self.phase] == 0) {
                self.climb = false;
                self.phase = (self.phase + 1) % 3;
            }
        }
    }
};

// PGN reader
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // going to use this to provide a chess PGN file to replay
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip(); // skip executable's name

    var fname: []const u8 = &.{};
    if (args.next()) |argv| {
        std.debug.print("args was {s}!\n", .{argv});
        fname = argv;
    } else {
        std.debug.print("Usage: chess-viewer fname", .{});
        return;
    }

    // enable unicode code page
    const original_cp = std.os.windows.kernel32.GetConsoleOutputCP();
    _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);
    defer _ = std.os.windows.kernel32.SetConsoleOutputCP(original_cp);

    var my_pgn = try PgnReader.init(allocator, fname);
    defer my_pgn.deinit();
    my_pgn.drawInit();
    defer std.debug.print(RESET_COL ++ "\n", .{});
    // for (0..8) |row| {
    //     for (0..8) |col| {
    //         const replace_c = if ((row -% col) % 2 == 0) PgnReader.bg1 else PgnReader.bg2;
    //         std.debug.print(GOTO_FMT ++ BG_RGB ++ "  ", .{
    //             row + 2,
    //             2 * col + 1,
    //             replace_c[0],
    //             replace_c[1],
    //             replace_c[2],
    //         });
    //     }
    // }
    // std.debug.print("\n", .{});

    // var times_up: u32 = 1200;
    // var clock_buf = [1]u8{0} ** 6;
    // var delay = std.time.milliTimestamp();

    // while (true) {
    //     const new_delay = std.time.milliTimestamp();
    //     if (new_delay - delay >= 100) {
    //         times_up -= 1;
    //         std.debug.print("\r{s}", .{clockStr(&clock_buf, times_up)});
    //         delay = new_delay;
    //     }
    //     if (times_up == 0)
    //         break;
    // }

    // probably not needed
    // disable line input mode so newline does not keep scrolling the screen down
    // const handle = try std.os.windows.GetStdHandle(std.os.windows.STD_INPUT_HANDLE);
    // var mode: u32 = undefined;
    // _ = std.os.windows.kernel32.GetConsoleMode(handle, &mode);
    // const LINE_INPUT: std.os.windows.DWORD, const ECHO_INPUT: std.os.windows.DWORD = .{2, 4};
    // _ = std.os.windows.kernel32.SetConsoleMode(handle, mode | ~(LINE_INPUT | ECHO_INPUT));

    // terminal keyboard input
    var input_b: [1]u8 = undefined; //"q".*;
    var stdin_reader = std.fs.File.stdin().reader(&input_b);
    const stdin = &stdin_reader.interface;

    // only accept 'L' for previous, 'R' or ' ' for next
    while (input_b[0] != 'q') {
        // std.debug.print("{}\r", .{try stdin.takeByte()});
        const char = try stdin.takeByte();
        if (char == 'R' or char == ' ') {
            my_pgn.drawNext();
        } else if (char == 'L') {
            my_pgn.drawPrev();
        }
    }
    std.debug.print("\n", .{});
}

// tests
test "print two seperate color squares?" {
    std.debug.print("\n" ++ GOTO_FMT ++ FG_RGB ++ BG_RGB ++ "GG" ++ GOTO_FMT ++ BG_RGB ++ FG_RGB ++ "PP\n" ++ RESET_COL, .{ 2, 2, 0, 0, 255, 255, 0, 0, 3, 3, 0, 255, 0, 255, 255, 255 });
}

test "ansi rgb color" {
    std.debug.print("\n" ++ CSI ++ "38;2;255;0;0m", .{});
}

test "parse seven character move" {
    const move_text = "Qa6xb7#";
    const str: []const u8 = &[_]u8{ 'A', 'L' };
    std.debug.print("\n{s}\n{s}\n", .{ move_text, str });
}

test "print clock" {
    var clock_buf = [1]u8{33} ** 6;
    std.debug.print("\n{s}\n", .{clockStr(&clock_buf, 611)});
    std.debug.print("{s}\n", .{clockStr(&clock_buf, 35_999)});
    std.debug.print("{s}\n", .{clockStr(&clock_buf, 257)});
}

test "find piece squares" {
    std.debug.print("\n", .{});
    const game: Game = .{};
    const p1 = Player.init(false);
    const moves = [2]Square{
        .default,
        .{ .file = 4, .rank = 3 },
    };
    const move_piece = [2]Pieces{ .K, .P };
    const move_atk = [2]bool{ false, false };
    for (0..2) |i| {
        const res = p1.findPiece(&game.board, move_piece[i], moves[i], move_atk[i]);
        std.debug.print("{c} {s}\n", .{ @intFromEnum(move_piece[i]), if (res) |r| &r.str() else "none" });
    }
}

fn test_find_squares(move_text: []const u8) void {
    // use string before checks, checkmate, or promotion symbols appear
    const sqr_sec_end = std.mem.indexOfNone(u8, move_text, "KQRNBabcdefgh12345678x");
    const sqr_sec = if (sqr_sec_end) |end| move_text[0..end] else move_text[0..];
    std.debug.print("reading from \"{s}\" - ", .{sqr_sec});
    // have room to potentially read 1-2 squares
    var is_attack = false;
    var file_count: u2, var rank_count: u2 = .{ 0, 0 };
    var sqr1, var sqr2 = .{ Square.default, Square.default };
    // bxc5: b5, c5
    for (sqr_sec) |ch| {
        if (ch >= 'a' and ch <= 'h') {
            if (file_count == 0) {
                sqr1.file = @truncate(ch - 'a');
                sqr2.file = sqr1.file;
            } else {
                sqr2.file = @truncate(ch - 'a');
            }
            file_count += 1;
        } else if (ch >= '1' and ch <= '8') {
            if (rank_count == 0) {
                sqr1.rank = @truncate(ch - '1');
                sqr2.rank = sqr1.rank;
            } else {
                sqr2.rank = @truncate(ch - '1');
            }
            rank_count += 1;
        } else if (ch == 'x') {
            is_attack = true;
        }
    }
    std.debug.print("{s} to {s}\n", .{ sqr1.str(), sqr2.str() });
}

test "detect disambiguating moves" {
    std.debug.print("\n", .{});
    const moves = [_][]const u8{ "Kb6", "Bgxh7", "Qb2f6" };
    for (moves) |m| {
        test_find_squares(m);
    }
}

test "read file into slice" {
    // open file
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("ugh", .{
        .mode = .read_only,
    });
    defer file.close();
    // find out the size in bytes
    const stats = try file.stat();
    std.debug.print("file is {} bytes?\n", .{stats.size});
    // read after knowing the size
    const content = try std.testing.allocator.alloc(u8, stats.size);
    defer std.testing.allocator.free(content);
    _ = try std.fs.cwd().readFile("test.txt", content);
    std.debug.print("{s}\nWow! Incredible!\n", .{content});
}
