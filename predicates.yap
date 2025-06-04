% O has only no rotation
rotate('O', RotatedPolygon, Angle) :-
    no_rotation('O', RotatedPolygon),
    Angle = 0.

% I rotations
rotate('I', RotatedPolygon, Angle) :-
    no_rotation('I', RotatedPolygon),
    Angle = 0.
rotate('I', RotatedPolygon, Angle) :-
    Angle = 90,
    dbrotate('I', Angle, RotatedPolygon).

% T rotations
rotate('T', RotatedPolygon, Angle) :-
    no_rotation('T', RotatedPolygon),
    Angle = 0.
rotate('T', RotatedPolygon, Angle) :-
    Angle = 90,
    dbrotate('T', Angle, RotatedPolygon).
rotate('T', RotatedPolygon, Angle) :-
    Angle = 180,
    dbrotate('T', Angle, RotatedPolygon).
rotate('T', RotatedPolygon, Angle) :-
    Angle = 270,
    dbrotate('T', Angle, RotatedPolygon).

% S rotations
rotate('S', RotatedPolygon, Angle) :-
    no_rotation('S', RotatedPolygon),
    Angle = 0.
rotate('S', RotatedPolygon, Angle) :-
    Angle = 90,
    dbrotate('S', Angle, RotatedPolygon).

% Z rotations
rotate('Z', RotatedPolygon, Angle) :-
    no_rotation('Z', RotatedPolygon),
    Angle = 0.
rotate('Z', RotatedPolygon, Angle) :-
    Angle = 90,
    dbrotate('Z', Angle, RotatedPolygon).

% L rotations
rotate('L', RotatedPolygon, Angle) :-
    no_rotation('L', RotatedPolygon),
    Angle = 0.
rotate('L', RotatedPolygon, Angle) :-
    Angle = 90,
    dbrotate('L', Angle, RotatedPolygon).
rotate('L', RotatedPolygon, Angle) :-
    Angle = 180,
    dbrotate('L', Angle, RotatedPolygon).
rotate('L', RotatedPolygon, Angle) :-
    Angle = 270,
    dbrotate('L', Angle, RotatedPolygon).

% J rotations
rotate('J', RotatedPolygon, Angle) :-
    no_rotation('J', RotatedPolygon),
    Angle = 0.
rotate('J', RotatedPolygon, Angle) :-
    Angle = 90,
    dbrotate('J', Angle, RotatedPolygon).
rotate('J', RotatedPolygon, Angle) :-
    Angle = 180,
    dbrotate('J', Angle, RotatedPolygon).
rotate('J', RotatedPolygon, Angle) :-
    Angle = 270,
    dbrotate('J', Angle, RotatedPolygon).

no_rotation(Letter, Polygon) :-
    format(atom(SQL),
           "SELECT ST_AsText(ST_SnapToGrid(shape, 1e-6)) FROM tetrominoes WHERE letter = '~w'",
           [Letter]),
    db_call(SQL, Polygon).

dbrotate(Letter, Angle, RotatedPolygon) :-
    format(atom(SQL),
           "SELECT ST_AsText(ST_SnapToGrid(ST_Rotate(shape, radians(~d)), 1e-6)) FROM tetrominoes WHERE letter = '~w'",
           [Angle, Letter]),
    db_call(SQL, RotatedPolygon).

translate(RotatedPolygon, point(X, Y), TranslatedPolygon) :-
    format(atom(SQL),
        "SELECT ST_AsText(ST_SnapToGrid(ST_Translate(ST_GeomFromText('~w'), ~d, ~d), 1e-6))",
        [RotatedPolygon, X, Y]),
    db_call(SQL, TranslatedPolygon).

difference(Puzzle, Tetromino, NewPuzzle) :-
    format(atom(SQL),
        "SELECT ST_AsText(ST_SnapToGrid(ST_Difference(ST_GeomFromText('~w'), ST_GeomFromText('~w')), 1e-6))",
        [Puzzle, Tetromino]),
    db_call(SQL, NewPuzzle).

fits(Puzzle, TetGeom) :-
    format(atom(SQL),
           "SELECT ST_Contains(ST_GeomFromText('~w'), ST_GeomFromText('~w'))",
           [Puzzle, TetGeom]),
    db_call(SQL, 't').

coord_in(PuzzleWKT, X, Y) :-
    bounding_box(PuzzleWKT, bbox(Xmin, Ymin, Xmax, Ymax)),
    XStart is floor(Xmin),
    XEnd is ceiling(Xmax),
    YStart is floor(Ymin),
    YEnd is ceiling(Ymax),
    between(XStart, XEnd, X),
    between(YStart, YEnd, Y).


area_mod_4_zero(PolygonWKT) :-
    format(atom(SQL),
        "SELECT NOT EXISTS (SELECT NULL FROM ST_Dump(ST_Multi(ST_GeomFromText('~w'))) AS dumped WHERE MOD(ROUND(ST_Area(dumped.geom))::int, 4) != 0 LIMIT 1)",
        [PolygonWKT]),
    db_call(SQL, 't').

% SOLVING

solve_puzzle('POLYGON EMPTY', [], _).
solve_puzzle('MULTIPOLYGON EMPTY', [], _).
solve_puzzle('GEOMETRYCOLLECTION EMPTY', [], _).

solve_puzzle(Puzzle, [Tetromino | Rest], [(Tetromino, Angle, X, Y) | Solution]) :-
    place(Tetromino, Puzzle, Angle, X, Y, NewPuzzle),
    solve_puzzle(NewPuzzle, Rest, Solution).

place(Tetromino, Puzzle, Angle, X, Y, NewPuzzle) :-
    rotate(Tetromino, RotatedGeom, Angle),
    coord_in(Puzzle, X, Y),
    translate(RotatedGeom, point(X, Y), TranslatedGeom),
    fits(Puzzle, TranslatedGeom),
    difference(Puzzle, TranslatedGeom, NewPuzzle),
    area_mod_4_zero(NewPuzzle).

% PRINT SOLUTION

print_solution([]).
print_solution([(Tet, Angle, X, Y) | Rest]) :-
    format("~w, ~d, ~d, ~d~n", [Tet, Angle, X, Y]),
    print_solution(Rest).

% START SOLVING

start_solve(ID) :-
    puzzle(ID, PuzzleWKT),
    findall(T, tetromino(T), TetrominoList),
    solve_puzzle(PuzzleWKT, TetrominoList, Solution),
    print_solution(Solution).