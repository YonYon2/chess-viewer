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

fn colorFmt(comptime color: [3]u8) []const u8 {
    return std.fmt.comptimePrint("{};{};{}", .{ color[0], color[1], color[2] });
}

// meant for the below wrapper
const FG_FMT = CSI ++ "38;2;{f}m";
const BG_FMT = CSI ++ "48;2;{f}m";
// scratch that, it is only comptime bc of type and we can't do switch or change the type because of runtime value
const BG_FMT2 = CSI ++ "48;2;{s}m";
const FG_FMT2 = CSI ++ "38;2;{s}m";

/// A wrapper so that with any tuple of RGB values you can print its values to `Writer`
fn Color(RGB: [3]u8) type {
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
            try writer.print("{};{};{}", .{ self.pick[0], self.pick[1], self.pick[2] });
        }
    };
}

test "color format showcase" {
    // const col: Color(bg1) = .{};
    std.debug.print("\n" ++ BG_FMT ++ "!\n", .{Color(bg1).c});
    std.debug.print("\n\x1b[48;2;{f}m?\n", .{Color(.{ 101, 25, 135 }).c});
    // simpler version
    const tim = std.time.timestamp();
    std.debug.print("\n" ++ BG_FMT2 ++ ";\n", .{if (@mod(tim, 2) == 0) colorFmt(highlight1) else colorFmt(highlight2)});
    std.debug.print(RESET_COL, .{});
}

// need to figure out how to output the text version everytime so it doesnt stick the emoji one and spoil the style
test "pawn as emoji and text" {
    // const p_u21 = @intFromEnum(ChessUnicode.p);
    const pawn_base = "♟\u{fe0e}";
    const pawn_base_v15 = "♟︎";
    const pawn_base_emoji = "♟️";
    std.debug.print("\nBase {s}\nBase+V15 {s}\nEmoji {s}\n", .{ pawn_base, pawn_base_v15, pawn_base_emoji });
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
    fn str(self: Pieces) []const u8 {
        return switch (self) {
            .K => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.K)}),
            .Q => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.Q)}),
            .R => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.R)}),
            .B => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.B)}),
            .N => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.N)}),
            .P => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.P)}),
            .k => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.k)}),
            .q => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.q)}),
            .r => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.r)}),
            .b => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.b)}),
            .n => std.fmt.comptimePrint("{u} ", .{@intFromEnum(ChessUnicode.n)}),
            .p => "♟︎ ", // has VS15 unicode block to make text and not emoji
            .nada => "  ",
        };
    }
};

test "print black pawn unicode text" {
    const p = Pieces.p;
    std.debug.print("{s}", .{p.str()});
}

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
    fn printBlank(self: Self, reverse: bool) void {
        if (reverse) {
            const p_enpass = if (self.enpassant) Pieces.nada else self.replace;
            const piece_c = if (std.ascii.isUpper(@intFromEnum(self.replace))) colorFmt(white) else colorFmt(black);
            const sqr_c = if ((self.to.rank -% self.to.file) % 2 == 0) colorFmt(bg1) else colorFmt(bg2);
            const row: u32 = self.to.rank;
            const col: u32 = self.to.file;
            std.debug.print(LOAD_POS ++ "<{c}>", .{@intFromEnum(self.replace)});
            std.debug.print(BG_FMT2 ++ FG_FMT2 ++ GOTO_FMT ++ "{s}", .{ sqr_c, piece_c, row + 2, 2 * col + 1, p_enpass.str() });
        } else {
            const sqr_c = if ((self.from.rank -% self.from.file) % 2 == 0) colorFmt(bg1) else colorFmt(bg2);
            const row: u32, const col: u32 = .{ self.from.rank, self.from.file };
            std.debug.print(BG_FMT2 ++ GOTO_FMT ++ "  ", .{ sqr_c, row + 2, 2 * col + 1 });
        }
        if (self.enpassant) {
            // take the file of `to` and the rank of `from`
            const enpass_c = if ((self.from.rank -% self.to.file) % 2 == 0) colorFmt(bg1) else colorFmt(bg2);
            const piece_c = if (std.ascii.isUpper(@intFromEnum(self.replace))) colorFmt(white) else colorFmt(black);
            const row: u32, const col: u32 = .{ self.from.rank, self.to.file };
            const p_rev = if (reverse) self.replace else Pieces.nada;
            std.debug.print(BG_FMT2 ++ FG_FMT2 ++ GOTO_FMT ++ "{s}", .{ enpass_c, piece_c, row + 2, 2 * col + 1, p_rev.str() });
        }
    }
    /// establish the piece with its background color, foreground color, and cursor position from its square and flip's value
    fn printPiece(self: Self, reverse: bool) void {
        const piece_c = if (std.ascii.isUpper(@intFromEnum(self.mover))) colorFmt(white) else colorFmt(black);
        const condition = if (reverse) (self.from.rank -% self.from.file) % 2 == 0 else (self.to.rank -% self.to.file) % 2 == 0;
        const sqr_c = if (condition) colorFmt(bg1) else colorFmt(bg2);
        const row: u32 = if (reverse) self.from.rank else self.to.rank;
        const col: u32 = if (reverse) self.from.file else self.to.file;
        const p_rev = self.mover;
        std.debug.print(BG_FMT2 ++ FG_FMT2 ++ GOTO_FMT ++ "{s}", .{ sqr_c, piece_c, row + 2, 2 * col + 1, p_rev.str() });
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
                            // TODO handle any check, checkmate, or promotion here
                            const res_change = parseMove(&game, &players, is_white, remaining_file[start_index..i]);
                            // add move
                            try move_list.append(allocator, res_change);
                            // std.debug.print("{any} ", .{hold_change});
                            // game.printBoard();
                            // std.debug.print("{s} ", .{move_text});
                            start_read = false;
                            mode = .clock;
                        }
                    }
                },
                .timestamp, .clock => {
                    if (!start_read) {
                        if (std.ascii.isDigit(c)) {
                            start_index = i;
                            start_read = true;
                        }
                    } else {
                        if (c == ']') {
                            const time_text = remaining_file[start_index..i];
                            if (mode == .timestamp) {
                                move_list.items[move_list.items.len - 1].delay = try std.fmt.parseUnsigned(u32, time_text, 10);
                                is_white = !is_white;
                                mode = .move_number;
                            } else {
                                mode = .timestamp;
                            }
                            start_read = false;
                        }
                    }
                },
            }
        }
        // debug: view what recorded
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
    fn parseMove(game: *Game, players: *[2]Player, is_white: bool, move: []const u8) Change {
        const player_i: usize = @intFromBool(is_white);
        var castling = false;
        // push to movelist
        var hold_change: Change = .{};
        // check which piece is moving
        hold_change.mover = switch (move[0]) {
            'K' => if (is_white) .K else .k,
            'Q' => if (is_white) .Q else .q,
            'R' => if (is_white) .R else .r,
            'B' => if (is_white) .B else .b,
            'N' => if (is_white) .N else .n,
            'O' => lbo: {
                // handle all castling logic since its fixed (except for check and checkmate)
                castling = true;
                const is_castle_long = move.len >= 5; //O-O >=3, O-O-O >=5
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
        const sqr_sec_end = std.mem.indexOfNone(u8, move, "KQRNBabcdefgh12345678x");
        const sqr_sec = if (sqr_sec_end) |end| move[0..end] else move[0..];
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

                                // also check for en passant
                                const enpass_index = if (file_dir) sqr_o + 1 else sqr_o - 1;
                                hold_change.enpassant = if (is_white) game.board[enpass_index] == .p else game.board[enpass_index] == .P;
                                if (game.board[sqr_i] != .nada or hold_change.enpassant) {
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
                            }
                        }
                    }
                },
                else => unreachable,
            }
        }
        return hold_change;
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
            const tile_c = if ((r -% f) % 2 == 0) colorFmt(bg1) else colorFmt(bg2);
            const piece_c = if (std.ascii.isUpper(P)) colorFmt(white) else colorFmt(black);
            const piece_e: Pieces = @enumFromInt(P);
            std.debug.print(BG_FMT2 ++ FG_FMT2 ++ "{s}" ++ RESET_COL, .{ tile_c, piece_c, piece_e.str() });
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
        // move mover
        const curr = self.move_list.items[self.current_move];
        curr.printPiece(false);
        curr.printBlank(false);
        std.debug.print(LOAD_POS, .{});
        self.current_move += 1;
    }
    fn drawPrev(self: *Self) void {
        if (self.current_move > 0) {
            self.current_move -= 1;
        } else return;
        const curr = self.move_list.items[self.current_move];
        curr.printPiece(true);
        curr.printBlank(true);
        std.debug.print(LOAD_POS, .{});
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
    const allocator = gpa.allocator();
    // dont need to do if it already handles all allocs?
    // defer {
    //     std.debug.print("gpa deinit\n", .{});
    //     _ = gpa.deinit();
    // }

    // going to use this to provide a chess PGN file to replay
    var args = try std.process.argsWithAllocator(allocator);
    defer {
        std.debug.print("args deinit\n", .{});
        args.deinit();
    }
    _ = args.skip(); // skip executable's name

    const help_msg =
        \\usage: chess_viewer [fname] [options]
        \\
        \\  -h show this message
        \\  -f frame-by-frame by pressing 'R' and 'L' to move forward/backward
        \\  -e explode
        \\
    ;
    var fname: []const u8 = &.{};
    var frame_play = false;
    // get filename first
    if (args.next()) |argv| {
        std.debug.print("args was {s}!\n", .{argv});
        fname = argv;
    } else {
        std.debug.print(help_msg, .{});
        return;
    }
    //
    while (args.next()) |arg| {
        if (arg[0] == '-') {
            for (arg[1..arg.len]) |ch| {
                switch (ch) {
                    'h' => std.debug.print(help_msg, .{}),
                    'f' => frame_play = true,
                    else => {},
                }
            }
        } else {
            std.debug.print("what?\n", .{});
            return;
        }
    }

    // enable unicode code page
    const original_cp = std.os.windows.kernel32.GetConsoleOutputCP();
    _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);
    defer _ = std.os.windows.kernel32.SetConsoleOutputCP(original_cp);

    // std.debug.print("new?", .{});
    const pawn_base = "♟";
    const pawn_base_v15 = "\u{265F}\u{fe0e}";
    const pawn_base_v16 = "\u{265F}\u{fe0f}";
    // const pawn_base_emoji = "♟️";
    std.debug.print("\nBase {s}\nDingbat (base+V16) {s}\nEmoji (base+V15) {s}\n", .{ pawn_base, pawn_base_v15, pawn_base_v16 });

    var my_pgn = PgnReader.init(allocator, fname) catch |err| {
        std.debug.print("Error: {t}\n", .{err});
        return;
    };
    defer my_pgn.deinit();
    my_pgn.drawInit();
    defer std.debug.print(RESET_COL ++ "\n", .{});

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

    // terminal keyboard input
    // TODO need to turn off line mode so the byte it taken instantly
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
