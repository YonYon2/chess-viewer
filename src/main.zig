const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Timer = struct {
    const Self = @This();
    start: f64,
    life: f64,
    pub fn makeTimer() Timer {
        return .{ .start = 0, .life = 0 };
    }
    pub fn startTimer(self: *Self, life: f64) void {
        self.start = ray.GetTime();
        self.life = life;
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

    var timer = Timer.makeTimer();
    var alarm: f64 = 0;
    var buf = std.mem.zeroes([1024]u8);
    var flash = true;
    while (!ray.WindowShouldClose()) {
        timer.startTimer(0);
        if (alarm >= 1000) {
            flash = !flash;
            alarm -= 1000;
        }
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        const flash_c: u8 = if (flash) '*' else ' ';
        const frame_time = timer.getElapsed();
        _ = try std.fmt.bufPrint(&buf, "{d}\n{d}\n[{c}]", .{ frame_time, alarm, flash_c });
        ray.DrawText(&buf, 190, 200, 20, ray.LIGHTGRAY);
        alarm += frame_time;
    }
}
