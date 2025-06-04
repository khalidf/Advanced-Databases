solve_manual :-
    puzzle(1, Puzzle),
    writeln('Original Puzzle':Puzzle),

    no_rotation('I', RotatedI),
    translate(RotatedI, point(1, 4), TranslatedI),
    ( fits(Puzzle, TranslatedI) -> writeln('I fits in puzzle') ; writeln('I does not fit!') ),
    difference(Puzzle, TranslatedI, Puzzle1),
    writeln('After placing I':Puzzle1),

    no_rotation('O', RotatedO),
    translate(RotatedO, point(4, 0), TranslatedO),
    ( fits(Puzzle1, TranslatedO) -> writeln('O fits in puzzle') ; writeln('O does not fit!') ),
    difference(Puzzle1, TranslatedO, Puzzle2),
    writeln('After placing O':Puzzle2),

    dbrotate('T', 90, RotatedT),
    translate(RotatedT, point(2, 2), TranslatedT),
    ( fits(Puzzle2, TranslatedT) -> writeln('T fits in puzzle') ; writeln('T does not fit!') ),
    difference(Puzzle2, TranslatedT, Puzzle3),
    writeln('After placing T':Puzzle3),

    no_rotation('S', RotatedS),
    translate(RotatedS, point(2, 2), TranslatedS),
    ( fits(Puzzle3, TranslatedS) -> writeln('S fits in puzzle') ; writeln('S does not fit!') ),
    difference(Puzzle3, TranslatedS, Puzzle4),
    writeln('After placing S':Puzzle4),

    dbrotate('Z', 90, RotatedZ),
    translate(RotatedZ, point(2, 0), TranslatedZ),
    ( fits(Puzzle4, TranslatedZ) -> writeln('Z fits in puzzle') ; writeln('Z does not fit!') ),
    difference(Puzzle4, TranslatedZ, Puzzle5),
    writeln('After placing Z':Puzzle5),

    no_rotation('J', RotatedJ),
    translate(RotatedJ, point(4, 2), TranslatedJ),
    ( fits(Puzzle5, TranslatedJ) -> writeln('J fits in puzzle') ; writeln('J does not fit!') ),
    difference(Puzzle5, TranslatedJ, Puzzle6),
    writeln('After placing J':Puzzle6),

    dbrotate('L', 90, RotatedL),
    translate(RotatedL, point(4, 0), TranslatedL),
    ( fits(Puzzle6, TranslatedL) -> writeln('L fits in puzzle') ; writeln('L does not fit!') ),
    difference(Puzzle6, TranslatedL, FinalPuzzle),
    writeln('Final Puzzle':FinalPuzzle).
