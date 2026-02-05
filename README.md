# chess-viewer

Replays a chess.com game on Windows Terminal when given a PGN (with timestamps!) as a text file.

## Features
- prints the chess board with pieces, name of players, increment, and clocks in ASCII with colors
- flip board depending on perspective
- toggle to use unicode chess pieces or just letters
- playback game in real-time, rewind, or scroll move-by-move forwards and backwards

## How to run
Build with Zig 0.15.2, then run in terminal and pass PGN text file by `PS > ./chess-viewer my_game.txt`.
