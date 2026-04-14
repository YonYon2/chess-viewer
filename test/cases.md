# Objectives and Test Cases for `PgnReader`

Main goal: Read file downloaded from chess.com website of a game's PGN, with timestamps included and convert into a list of screen updates to playback in the terminal.

## During tokenization of move text

- [ ] Check piece by looking at the first character
    - [ ] 'O', castling is handled
- [ ] Find *from*/*to* squares
    - [ ] regular move gives the *to* square
    - [ ] disambiguated moves give part/whole *from* square, followed by *to* square
    - [ ]

## Cases for successful PGN read

- [ ] Short and Long Castle
- [ ] Difference between pawn capture and enpassant
- [ ] Disambiguating moves
    - [ ] Type 1: originating file
    - [ ] Type 2: originating rank
    - [ ] Type 3: originating square
    - [ ] Pinned piece is not treated as disambiguated
- [ ] Highlight piece that moved and where it landed
- [ ] Highlight king square
    - [ ] Check
    - [ ] Checkmate
    - [ ] Game terminated
- [ ] Clock updates
    - [ ] Clock increases at end of move
    - [ ] Clock ticks down per second
        - [ ] Clock ticks down by 0.1 seconds when below 20s
- [ ] Print each player's name
- [ ] Print game result when last move is reached
