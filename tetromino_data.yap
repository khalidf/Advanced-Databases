% Tetromino facts
tetromino('I').
tetromino('O').
tetromino('T').
tetromino('S').
tetromino('Z').
tetromino('J').
tetromino('L').

% Puzzle facts
puzzle(1, 'POLYGON((0 0,6 0,6 5,0 5,0 0),(2 1,2 2,3 2,3 1,2 1),(2 3,2 4,3 4,3 3,2 3))').
puzzle(2, 'POLYGON((1 0,1 5,0 5,0 6,2 6,2 5,4 5,4 6,6 6,6 5,5 5,5 2,6 2,6 3,7 3,7 0,6 0,6 1,5 1,5 0,1 0))').
puzzle(3, 'POLYGON((0 0,0 4,7 4,7 3,8 3,8 0,0 0),(1 2,1 3,3 3,3 2,1 2),(6 2,6 3,7 3,7 2,6 2))').
puzzle(4, 'POLYGON((0 4,0 5,1 5,1 7,5 7,5 3,6 3,6 4,7 4,7 1,6 1,6 0,3 0,3 1,4 1,4 2,2 2,2 4,0 4))').
puzzle(5, 'POLYGON((0 0,0 8,1 8,1 10,0 10,0 12,1 12,1 13,0 13,0 16,2 16,2 4,1 4,1 3,2 3,2 0,0 0))').
