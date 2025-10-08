const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Timer = struct {
    const Self = @This();
    start: f64,
    life: f64, // duration; constant
    fn makeTimer() Timer {
        return .{ .start = 0, .life = 0 };
    }
    fn startTimer(self: *Self, life: f64) void {
        self.start = ray.GetTime();
        self.life = life;
    }
    fn resetTimer(self: *Self) void {
        self.start = ray.GetTime();
    }
    fn timerDone(self: Self) bool {
        return ray.GetTime() - self.start >= self.life;
    }
    fn getElapsed(self: Self) f64 {
        return ray.GetTime() - self.start;
    }
};

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

const Square = struct { file: u8 = 'a', rank: u8 = '1' };

const Piece = struct {
    alive: bool,
    square: Square,
    const default: Piece = .{ .alive = false, .square = .{} };
    fn init() Piece {
        return default;
    }
    fn make(square: Square) Piece {
        return .{ .alive = true, .square = square };
    }
    fn makeS(square: [2]u8) Piece {
        return .{ .alive = true, .square = .{ .file = square[0], .rank = square[1] } };
    }
    fn take(self: *Piece) Square {
        self.alive = false;
        return self.square;
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
        const pawn_rank = if (first) '2' else '7';
        const main_rank = if (first) '1' else '8';
        return .{
            .pawn = blk: {
                var p_arr: [8]Piece = undefined;
                inline for (0..8) |i| p_arr[i] = .{ .alive = true, .square = .{ .file = @as(u8, i) + 'a', .rank = pawn_rank } };
                break :blk p_arr;
            },
            .knight = [2]Piece{ Piece.makeS(.{ 'b', main_rank }), Piece.makeS(.{ 'g', main_rank }) } ++
                [1]Piece{Piece.init()} ** 8,
            .bishop = [2]Piece{ Piece.makeS(.{ 'c', main_rank }), Piece.makeS(.{ 'f', main_rank }) } ++
                [1]Piece{Piece.init()} ** 8,
            .rook = [2]Piece{ Piece.makeS(.{ 'a', main_rank }), Piece.makeS(.{ 'h', main_rank }) } ++
                [1]Piece{Piece.init()} ** 8,
            .queen = [1]Piece{Piece.makeS(.{ 'd', main_rank })} ++ [1]Piece{Piece.init()} ** 8,
            .king = Piece.makeS(.{ 'e', main_rank }),
        };
    }
    // give the pawn index
    fn promote(self: *Player, pindex: usize) void {
        _ = self.pawn[pindex].take();
    }
};

test "player" {
    const p = Player.init(true);
    std.debug.print("{any}\n", .{p.knight});
}

const Game = struct {
    time: u8, // seconds
    increment: u8, // seconds
};

const pgnReader = struct {
    const Self = @This();
    const Modes = enum { meta, move };
    iterator: std.mem.SplitIterator(u8, u8),
    mode: Modes,
    fn init(game: []const u8) pgnReader {
        return .{ .iterator = std.mem.splitScalar(u8, game, '\n'), .mode = Modes.meta };
    }
    fn next(self: *Self) bool {
        if (self.iterator.next()) |token| {
            if (token.len > 0) {
                switch (self.mode) {
                    pgnReader.Modes.meta => "",
                    else => "",
                }
            }
        } else return false;
        return true;
    }
};

test "PGN tokenize" {
    std.debug.print("in the works\n", .{});
    // use split somehow (maybe splitAny for " ,")
    // std.mem.tokenizeScalar(comptime T: type, buffer: []const T, delimiter: T)
    // std.mem.splitScalar(comptime T: type, buffer: []const T, delimiter: T)
    // example chess game PGN with timestamps
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
    //_ = ex_pgn;
    // const readMeta = fn (str: []const u8) void{};
    // const readMove = fn (comptime first: bool, str: []const u8) void{};
    // const readTime = fn () void{};
    var it = std.mem.splitSequence(u8, ex_pgn[0..], "\n");
    // var read_meta = true;
    token_loop: while (it.next()) |token| {
        std.debug.print("tkn: {s}", .{if (token.len > 0) switch (token[0]) {
            '[' => std.mem.trim(u8, token, "[]"),
            else => "()",
        } else { // empty line indicates moves are to now be read
            // read_meta = false;
            break :token_loop;
        }});
    }

    var move_it = std.mem.tokenizeSequence(u8, it.rest(), ". ");

    // var is_move = false;
    while (move_it.next()) |token| {
        var replace_slice = std.mem.zeroes([1024]u8);
        _ = try std.fmt.bufPrintZ(&replace_slice, "{s}", .{token});
        std.mem.replaceScalar(u8, &replace_slice, '\n', ' ');
        std.debug.print("REPLACE: {s}\n", .{&replace_slice});
        // const trimmed = std.mem.trimEnd(u8, &replace_slice, "0123456789. ");
        // std.debug.print("\"{s}\"\n", .{replace_slice});

        var two_move = std.mem.tokenizeSequence(u8, &replace_slice, ". ");
        // _ = two_move.next();
        var second = false;
        while (two_move.next()) |two_token| {
            if (second) std.debug.print("\t", .{});
            std.debug.print("\"{s}\"\n", .{two_token});
            std.debug.print("\"{s}\"\n", .{std.mem.trim(u8, two_token, ". ")});
            second = !second;
        }
    }
}

// PGN reader
// <piece letter><coordinate>
// Captures (Bxe6)
// Disambiguating moves
// Pawn promotion (e8=Q)
// Castling 'O-O' or 'O-O-O'
// Check '+'
// Checkmate '#'
//

pub fn main() !void {
    ray.InitWindow(800, 450, "basic window");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    // init
    var alarm: [2]Timer = .{ Timer.makeTimer(), Timer.makeTimer() }; // every 0.5s and 0.1s
    alarm[0].startTimer(0.5);
    alarm[1].startTimer(0.1);
    var buf = std.mem.zeroes([1024]u8);
    var flash: [2]bool = .{ true, true };
    while (!ray.WindowShouldClose()) {
        // logic and calc
        const dt = alarm[0].getElapsed();

        for (&alarm, 0..) |*a, i| {
            if (a.timerDone()) {
                a.resetTimer();
                flash[i] = true;
            } else flash[i] = false;
        }
        const flash_c1: u21 = if (flash[0]) '@' else ' ';
        const flash_c2: u21 = if (flash[1]) '@' else ' ';
        _ = try std.fmt.bufPrintZ(&buf, "{d:x<8.6}\n{d:x<8.6}\n[{u}]\n[{u}]", .{ 3.14, dt, flash_c1, flash_c2 });

        // everything drawing
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText(&buf, 190, 200, 20, ray.LIGHTGRAY);
    }
}
