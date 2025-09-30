const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Timer = struct {
    const Self = @This();
    start: f64,
    life: f64, // duration; constant
    pub fn makeTimer() Timer {
        return .{ .start = 0, .life = 0 };
    }
    pub fn startTimer(self: *Self, life: f64) void {
        self.start = ray.GetTime();
        self.life = life;
    }
    pub fn resetTimer(self: *Self) void {
        self.start = ray.GetTime();
    }
    pub fn timerDone(self: Self) bool {
        return ray.GetTime() - self.start >= self.life;
    }
    pub fn getElapsed(self: Self) f64 {
        return ray.GetTime() - self.start;
    }
};

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
