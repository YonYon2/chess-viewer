const std = @import("std");
const Allocator = std.mem.Allocator;

const ex_pgn =
    \\[White "Guest7527675399"]
    \\[Black "Guest4401176224"]
    \\[Result "1-0"]
    \\[TimeControl "180"]
    \\[WhiteElo "400"]
    \\[BlackElo "400"]
    \\[Termination "Guest7527675399 won by checkmate"]
    \\[Link "https://www.chess.com/game/143827314072"]
    \\
    \\1. Nh3 {[%clk 0:02:59.1][%timestamp 9]} 1... d5 {[%clk 0:02:56.5][%timestamp
    \\35]} 2. d3 {[%clk 0:02:58.6][%timestamp 5]} 2... Bxh3 {[%clk
    \\0:02:54.4][%timestamp 21]} 3. gxh3 {[%clk 0:02:57.7][%timestamp 9]} 3... Qc8
    \\{[%clk 0:02:53.4][%timestamp 10]} 4. Bg2 {[%clk 0:02:57.2][%timestamp 5]} 4...
    \\c6 {[%clk 0:02:51.3][%timestamp 21]} 5. c4 {[%clk 0:02:56.5][%timestamp 7]} 5...
    \\Nf6 {[%clk 0:02:48.7][%timestamp 26]} 6. cxd5 {[%clk 0:02:55.6][%timestamp 9]}
    \\6... Nxd5 {[%clk 0:02:48.6][%timestamp 1]} 7. Bxd5 {[%clk 0:02:54.9][%timestamp
    \\7]} 7... c5 {[%clk 0:02:47.9][%timestamp 7]} 8. Qa4+ {[%clk
    \\0:02:53.6][%timestamp 13]} 8... Nc6 {[%clk 0:02:45.9][%timestamp 20]} 9. Bxc6+
    \\{[%clk 0:02:52.5][%timestamp 11]} 9... bxc6 {[%clk 0:02:44.9][%timestamp 10]}
    \\10. Nc3 {[%clk 0:02:47.6][%timestamp 49]} 10... Kd7 {[%clk 0:02:41.3][%timestamp
    \\36]} 11. Ne4 {[%clk 0:02:46.4][%timestamp 12]} 11... e6 {[%clk
    \\0:02:38.7][%timestamp 26]} 12. Nxc5+ {[%clk 0:02:45.4][%timestamp 10]} 12...
    \\Bxc5 {[%clk 0:02:37.3][%timestamp 14]} 13. d4 {[%clk 0:02:42.8][%timestamp 26]}
    \\13... Bd6 {[%clk 0:02:34.6][%timestamp 27]} 14. e4 {[%clk 0:02:41][%timestamp
    \\18]} 14... Kc7 {[%clk 0:02:31.6][%timestamp 30]} 15. e5 {[%clk
    \\0:02:39.7][%timestamp 13]} 15... Be7 {[%clk 0:02:30.2][%timestamp 14]} 16. Qa5+
    \\{[%clk 0:02:36.4][%timestamp 33]} 16... Kd7 {[%clk 0:02:28.6][%timestamp 16]}
    \\17. Bd2 {[%clk 0:02:32.8][%timestamp 36]} 17... Qb7 {[%clk 0:02:23.4][%timestamp
    \\52]} 18. b3 {[%clk 0:02:27.6][%timestamp 52]} 18... Rab8 {[%clk
    \\0:02:18.1][%timestamp 53]} 19. Rb1 {[%clk 0:02:20.7][%timestamp 69]} 19... Bb4
    \\{[%clk 0:02:17.6][%timestamp 5]} 20. Bxb4 {[%clk 0:02:18.8][%timestamp 19]}
    \\20... Qxb4+ {[%clk 0:02:16.7][%timestamp 9]} 21. Qxb4 {[%clk
    \\0:02:16.8][%timestamp 20]} 21... Rxb4 {[%clk 0:02:16.4][%timestamp 3]} 22. Ke2
    \\{[%clk 0:02:13.5][%timestamp 33]} 22... Rxd4 {[%clk 0:02:15][%timestamp 14]} 23.
    \\Rhc1 {[%clk 0:02:11][%timestamp 25]} 23... Re4+ {[%clk 0:02:13.3][%timestamp
    \\17]} 24. Kf3 {[%clk 0:02:09.1][%timestamp 19]} 24... Rxe5 {[%clk
    \\0:02:12.5][%timestamp 8]} 25. b4 {[%clk 0:02:07.6][%timestamp 15]} 25... Rb8
    \\{[%clk 0:02:10.6][%timestamp 19]} 26. a3 {[%clk 0:02:06.3][%timestamp 13]} 26...
    \\Rbb5 {[%clk 0:02:09.6][%timestamp 10]} 27. a4 {[%clk 0:02:04.4][%timestamp 19]}
    \\27... Rf5+ {[%clk 0:02:08.9][%timestamp 7]} 28. Kg3 {[%clk 0:02:02.8][%timestamp
    \\16]} 28... Rbd5 {[%clk 0:02:06.7][%timestamp 22]} 29. f3 {[%clk
    \\0:02:00.7][%timestamp 21]} 29... h5 {[%clk 0:02:04.5][%timestamp 22]} 30. Rc3
    \\{[%clk 0:01:58.9][%timestamp 18]} 30... Rf6 {[%clk 0:02:03.5][%timestamp 10]}
    \\31. Rbb3 {[%clk 0:01:57.5][%timestamp 14]} 31... Rg6+ {[%clk
    \\0:02:02.6][%timestamp 9]} 32. Kf2 {[%clk 0:01:55][%timestamp 25]} 32... h4
    \\{[%clk 0:02:01.4][%timestamp 12]} 33. b5 {[%clk 0:01:52.6][%timestamp 24]} 33...
    \\Rd6 {[%clk 0:01:58.5][%timestamp 29]} 34. b6 {[%clk 0:01:50.8][%timestamp 18]}
    \\34... a6 {[%clk 0:01:56.5][%timestamp 20]} 35. b7 {[%clk 0:01:49.7][%timestamp
    \\11]} 35... Rd2+ {[%clk 0:01:53.3][%timestamp 32]} 36. Ke3 {[%clk
    \\0:01:47][%timestamp 27]} 36... Rb2 {[%clk 0:01:45.7][%timestamp 76]} 37. Rxb2
    \\{[%clk 0:01:44.7][%timestamp 23]} 37... Kc7 {[%clk 0:01:45][%timestamp 7]} 38.
    \\b8=Q+ {[%clk 0:01:42.7][%timestamp 20]} 38... Kd7 {[%clk 0:01:43.5][%timestamp
    \\15]} 39. Qb7+ {[%clk 0:01:39.4][%timestamp 33]} 39... Kd6 {[%clk
    \\0:01:41.2][%timestamp 23]} 40. Qxc6+ {[%clk 0:01:38.7][%timestamp 7]} 40... Ke5
    \\{[%clk 0:01:40.1][%timestamp 11]} 41. Rc5+ {[%clk 0:01:37][%timestamp 17]} 41...
    \\Kf6 {[%clk 0:01:39.1][%timestamp 10]} 42. Qe4 {[%clk 0:01:28.3][%timestamp 87]}
    \\42... Rg5 {[%clk 0:01:36.8][%timestamp 23]} 43. Rxg5 {[%clk
    \\0:01:26.5][%timestamp 18]} 43... Kxg5 {[%clk 0:01:35.3][%timestamp 15]} 44. Qe5+
    \\{[%clk 0:01:24.8][%timestamp 17]} 44... f5 {[%clk 0:01:33.1][%timestamp 22]} 45.
    \\Qxe6 {[%clk 0:01:23.4][%timestamp 14]} 45... g6 {[%clk 0:01:32.4][%timestamp 7]}
    \\46. Rb6 {[%clk 0:01:21.9][%timestamp 15]} 46... f4+ {[%clk 0:01:29.6][%timestamp
    \\28]} 47. Kf2 {[%clk 0:01:19.8][%timestamp 21]} 47... Kh5 {[%clk
    \\0:01:28.2][%timestamp 14]} 48. Qxg6# {[%clk 0:01:18.7][%timestamp 11]} 1-0
;

const Pieces = enum { nada, P, N, B, R, Q, K, p, n, b, r, q, k };

test "print piece letters" {
    std.debug.print("\nbegin\n", .{});
    inline for (@typeInfo(Pieces).@"enum".fields) |e| {
        // if (std.mem.eql(@TypeOf(e.name), e.name, "nada"))
        //     continue;
        std.debug.print("{s} ", .{e.name});
    }
    std.debug.print("end\n", .{});
}

// invariants:
// active piece { alive, file rank are valid values from 1 to 8 or a to h}
// dead piece { !alive, file rank are either a1 or some previous value but are not to be used}
// init: always dead piece unless you provide a file and rank

const Square = struct {
    file: u3,
    rank: u3,
    const default: Square = .{ .file = 0, .rank = 0 };
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
    // give the pawn index and what to transfer it into
    // fn promote(self: *Player, pindex: usize) void {
    //     _ = self.pawn[pindex].take();
    // }
};

// meep
const Move = struct {
    piece: Pieces,
    prev: Square,
    next: Square,
};

const ChessUnicode = enum(u21) { K = 0x2654, Q, R, B, N, P, k, q, r, b, n, p };

test "print chess" {
    std.debug.print("\nKing {u}\n", .{@intFromEnum(ChessUnicode.K)});
    inline for (@typeInfo(ChessUnicode).@"enum".fields) |e| {
        std.debug.print("{s} = {u}\n", .{ e.name, e.value });
    }
}

// reference for understanding how to read PGN moves
// https://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm
const Game = struct {
    const Self = @This();
    white: []const u8 = "Player 1",
    black: []const u8 = "Player 2",
    result: []const u8 = "Draw",
    time: u32 = 60, // seconds
    increment: u32 = 0, // seconds
    clock: [2]u32 = .{ 600, 600 }, // 10ths of a second
    board: [64]u8 = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr".*,
    flip: bool = false,
};

// for the purposes of updating the screen
const Change = struct {
    from: Square = .default,
    to: Square = .default,
    mover: Pieces = .nada,
    replace: ?Pieces = null,
    promote: ?Pieces = null,
    delay: u32 = 1, // tenths of a second
};

// object that holds the info for what was read from a PGN file
const pgnReader = struct {
    const Self = @This();
    allocator: Allocator,
    game_info: Game,
    move_list: std.ArrayList(Change),
    fn init(allocator: Allocator, contents: []const u8) !pgnReader {
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
        var is_white = true;
        var start_index: usize = 0;
        var start_read = false;
        const Modes = enum { move_number, move, clock, timestamp };
        var mode = Modes.move_number;
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
                            const move_text = remaining_file[start_index..i];
                            const move_piece = switch (move_text[0]) {
                                'K' => if (is_white) Pieces.K else Pieces.k,
                                'Q' => if (is_white) Pieces.Q else Pieces.q,
                                'R' => if (is_white) Pieces.R else Pieces.r,
                                'B' => if (is_white) Pieces.B else Pieces.b,
                                'N' => if (is_white) Pieces.N else Pieces.n,
                                else => if (is_white) Pieces.P else Pieces.p,
                            };
                            try move_list.append(allocator, .{ .mover = move_piece });
                            std.debug.print("{s} ", .{move_text});
                            start_read = false;
                            mode = .clock;
                        }
                    }
                },
                .clock => {
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
                            start_read = false;
                            is_white = !is_white;
                            mode = .move_number;
                        }
                    }
                },
            }
        }
        // // make copy of the rest of contents and remove newlines (helps to have "1. " and not "1.\r\n" before a move)
        // // const cr_len = std.mem.replacementSize(u8, it.rest(), "\r", "");
        // const new_len = std.mem.replacementSize(u8, remaining_file, "\r", "");
        // const move_txt = try allocator.alloc(u8, new_len);
        // defer allocator.free(move_txt);
        // _ = std.mem.replace(u8, remaining_file, "\r", "", move_txt);
        // const in_tmp: []const u8 = move_txt;
        // _ = std.mem.replace(u8, in_tmp, "\n", " ", move_txt);

        // // go ply by ply
        // var move_it = std.mem.tokenizeSequence(u8, move_txt, ". ");
        // // idk
        // var erm = std.once(declare);
        // while (move_it.next()) |tkn| {
        //     erm.call();
        //     var move_parts_it = std.mem.tokenizeScalar(u8, tkn, ' ');
        //     var count: usize = 0;
        //     std.debug.print("\"", .{});
        //     while (move_parts_it.next()) |tkn_part| : (count += 1) {
        //         switch (count) {
        //             0 => {
        //                 // const move = std.mem.trimEnd(u8, tkn_part, "0123456789. ");
        //                 std.debug.print("{s}", .{tkn_part});
        //             },
        //             2 => {
        //                 var clock = std.mem.zeroes([1024]u8);
        //                 const cutOff = std.mem.indexOfNone(u8, tkn_part, "0123456789:.").?;
        //                 _ = try std.fmt.bufPrint(&clock, "{s}", .{tkn_part[0..cutOff]});
        //                 std.debug.print(" {s}", .{clock});
        //             },
        //             3 => {
        //                 const wait = std.fmt.parseUnsigned(usize, std.mem.trim(u8, tkn_part, "]} "), 10) catch blk: {
        //                     std.debug.print(" Invalid timestamp!", .{});
        //                     break :blk 1;
        //                 };
        //                 std.debug.print(" {}", .{wait});
        //             },
        //             else => {
        //                 // show = false;
        //             },
        //         }
        //     }
        //     std.debug.print("\"\n", .{});
        // }
        std.debug.print("{} plies! {} moves!\n", .{ move_list.items.len, move_list.items.len / 2 });
        return .{
            .allocator = allocator,
            .game_info = game,
            .move_list = move_list, //move_list,
        };
    }
    fn deinit(self: *Self) void {
        self.move_list.deinit(self.allocator);
    }
};

test "new" {
    // grab file and open
    const file = try std.fs.cwd().openFile("test-pgn/ex_game.txt", .{});
    var buf: [1024]u8 = undefined;
    var file_reader = file.reader(&buf); // var because you are editing the contents through file_out
    const file_out = &file_reader.interface; // const because you aren't changing readers

    const Meta = struct {
        const Self = @This();
        tag: []const u8,
        value: []const u8,
        end: bool,
        const empty: Self = .{
            .tag = &.{},
            .value = &.{},
            .end = false,
        };
        fn read_tag(self: *Self, reader: *std.Io.Reader) ![]const u8 {
            const erm: []const u8 = try reader.peekDelimiterExclusive(' ');
            self.tag = erm;
            return erm;
        }
        fn read_value(self: *Self, reader: *std.Io.Reader) ![]const u8 {
            const tmp: []const u8 = try reader.peekDelimiterExclusive('"');
            self.value = tmp;
            return tmp;
        }
    };

    // read tags and values
    var data = Meta.empty;
    std.debug.print("\nReading file...\n", .{});
    while (true) {
        _ = try file_out.discardDelimiterInclusive('[');
        std.debug.print("{s} ", .{try data.read_tag(file_out)});
        _ = try file_out.discardDelimiterInclusive('"');
        std.debug.print("{s} ", .{try data.read_value(file_out)});
        _ = try file_out.discardDelimiterInclusive('\n');
        const next_line = try file_out.peekDelimiterExclusive('\n');
        std.debug.print("\n(next has {} characters)\n", .{next_line.len});
        if (next_line.len <= 1) {
            break;
        }
    }
    std.debug.print("what is left in buffer:{s}\n", .{file_out.buffered()});
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

test "PGN tokenize" {
    std.debug.print("in the works\n", .{});
    // use split somehow (maybe splitAny for " ,")
    // std.mem.tokenizeScalar(comptime T: type, buffer: []const T, delimiter: T)
    // std.mem.splitScalar(comptime T: type, buffer: []const T, delimiter: T)
    // example chess game PGN with timestamps

    // reads the meta data
    var it = std.mem.splitSequence(u8, ex_pgn[0..], "\n");
    // var read_meta = true;
    token_loop: while (it.next()) |token| {
        std.debug.print("tkn: {s}{any}\n", .{
            if (token.len > 0) switch (token[0]) {
                '[' => std.mem.trim(u8, token, "[]"),
                else => "()",
            } else { // empty line indicates moves are to now be read
                // read_meta = false;
                break :token_loop;
            },
            token,
        });
    }
    // read move data
    const move_txt = try std.mem.Allocator.dupe(std.testing.allocator, u8, it.rest());
    defer std.testing.allocator.free(move_txt);

    // replace newlines so tokens can be done by ". " and not ".\n" mess it up
    std.mem.replaceScalar(u8, move_txt, '\n', ' ');
    var move_it = std.mem.tokenizeSequence(u8, move_txt, ". ");
    while (move_it.next()) |tkn| {
        var move_parts_it = std.mem.tokenizeAny(u8, tkn, " \n");
        var count: usize = 0;
        std.debug.print("\"", .{});
        while (move_parts_it.next()) |tkn_part| : (count += 1) {
            switch (count) {
                0 => {
                    // const move = std.mem.trimEnd(u8, tkn_part, "0123456789. ");
                    std.debug.print("{s}", .{tkn_part});
                },
                2 => {
                    var clock = std.mem.zeroes([1024]u8);
                    const cutOff = std.mem.indexOfNone(u8, tkn_part, "0123456789:.").?;
                    _ = try std.fmt.bufPrint(&clock, "{s}", .{tkn_part[0..cutOff]});
                    std.debug.print(" {s}", .{clock});
                },
                3 => {
                    const wait = std.fmt.parseUnsigned(usize, std.mem.trim(u8, tkn_part, "]} "), 10) catch blk: {
                        std.debug.print("Invalid timestamp!\n", .{});
                        break :blk 1;
                    };
                    std.debug.print(" {}", .{wait});
                },
                else => {
                    // show = false;
                },
            }
        }
        std.debug.print("\"\n", .{});
    }
}

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

    var my_pgn = try pgnReader.init(allocator, fname);
    defer my_pgn.deinit();
}
