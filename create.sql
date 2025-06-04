DROP TABLE IF EXISTS solutions;
DROP TABLE IF EXISTS puzzles;
DROP TABLE IF EXISTS tetrominoes;

CREATE TABLE tetrominoes (
    letter CHAR(1) PRIMARY KEY,
    color TEXT NOT NULL,
    shape GEOMETRY(POLYGON, 0) NOT NULL
);

INSERT INTO tetrominoes (letter, color, shape) VALUES
('I', 'Cyan',
 ST_GeomFromText('POLYGON((0 0, 0 1, 4 1, 4 0, 0 0))', 0)
);

-- O Tetromino (2x2 square)
INSERT INTO tetrominoes (letter, color, shape) VALUES
('O', 'Yellow',
 ST_GeomFromText('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))', 0)
);

-- T Tetromino
--   ###
--    #
INSERT INTO tetrominoes (letter, color, shape) VALUES
('T', 'Magenta',
 ST_GeomFromText('POLYGON((0 1, 0 2, 3 2, 3 1, 2 1, 2 0, 1 0, 1 1, 0 1))', 0)
);

-- S Tetromino
--   ##
--  ##
INSERT INTO tetrominoes (letter, color, shape) VALUES
('S', 'Green',
 ST_GeomFromText('POLYGON((0 0, 0 1, 1 1, 1 2, 3 2, 3 1, 2 1, 2 0, 0 0))', 0)
);

-- Z Tetromino
--  ##
--   ##
INSERT INTO tetrominoes (letter, color, shape) VALUES
('Z', 'Red',
 ST_GeomFromText('POLYGON((1 0, 1 1, 0 1, 0 2, 2 2, 2 1, 3 1, 3 0, 1 0))', 0)
);

-- J Tetromino
--  #
--  ###
INSERT INTO tetrominoes (letter, color, shape) VALUES
('J', 'Blue',
 ST_GeomFromText('POLYGON((0 0, 0 1, 1 1, 1 3, 2 3, 2 0, 0 0))', 0)
);

-- 0 0, 0 1, 1 1, 1 3, 2 3, 2 0, 0 0
-- L Tetromino
--    #
--  ###
INSERT INTO tetrominoes (letter, color, shape) VALUES
('L', 'Orange',
 ST_GeomFromText('POLYGON((0 0, 0 3, 1 3, 1 1, 2 1, 2 0, 0 0))', 0)
);
-- 00, 03, 13, 11, 21, 20

CREATE TABLE puzzles (
    id SERIAL PRIMARY KEY,
    board GEOMETRY(POLYGON, 0) NOT NULL
);

INSERT INTO puzzles (board) VALUES   
(ST_GeomFromText('
    POLYGON(
      (0 0, 6 0, 6 5, 0 5, 0 0),
      (2 1, 2 2, 3 2, 3 1, 2 1),
      (2 3, 2 4, 3 4, 3 3, 2 3)
    )
  ', 0)),
(ST_GeomFromText('POLYGON((1 0,1 5,0 5,0 6,2 6,2 5,4 5,4 6,6 6,6 5,5 5,5 2,6 2,6 3,7 3,7 0,6 0,6 1,5 1,5 0,1 0))', 0)),
(ST_GeomFromText('POLYGON((0 0,0 4,7 4,7 3,8 3,8 0,0 0), (1 2,1 3,3 3,3 2,1 2), (6 2, 6 3, 7 3, 7 2, 6 2))', 0)),
(ST_GeomFromText('POLYGON((0 4,0 5,1 5,1 7,5 7,5 3,6 3,6 4,7 4,7 1,6 1,6 0,3 0,3 1,4 1,4 2,2 2,2 4,0 4))', 0)),
(ST_GeomFromText('POLYGON((0 0,0 8,1 8,1 10, 0 10,0 12,1 12,1 13, 0 13,0 16,2 16,2 4,1 4,1 3,2 3,2 0,0 0))', 0));

CREATE TABLE solutions (
    id SERIAL PRIMARY KEY,
    solution_id INTEGER NOT NULL,
    puzzle_id INTEGER REFERENCES puzzles(id),
    tetromino_id CHAR(1) REFERENCES tetrominoes(letter) NOT NULL,
    rotation INTEGER CHECK (rotation IN (0, 90, 180, 270)), 
    translation_x INTEGER,  
    translation_y INTEGER
);

INSERT INTO solutions (solution_id, puzzle_id, tetromino_id, rotation, translation_x, translation_y) VALUES
(1, 1, 'I', 0, 1, 4),
(1, 1, 'O', 0, 4, 0),
(1, 1, 'T', 90, 2, 2),
(1, 1, 'S', 0, 2, 2),
(1, 1, 'Z', 90, 2, 0),
(1, 1, 'J', 0, 4, 2),
(1, 1, 'L', 90, 4, 0),
(2, 2, 'I', 0, 1, 0),
(2, 2, 'O', 0, 2, 1),
(2, 2, 'T', 270, 5, 3),
(2, 2, 'S', 0, 3, 4),
(2, 2, 'Z', 0, 0, 4),
(2, 2, 'J', 180, 3, 4),
(2, 2, 'L', 180, 5, 4),
(3, 1, 'I', 0, 1, 4),
(3, 1,'O', 0, 0, 0),
(3, 1,'T', 90, 2, 2),
(3, 1,'S', 0, 2, 0),
(3, 1,'Z', 90, 6, 2),
(3, 1,'J', 0, 4, 0),
(3, 1,'L', 90, 4, 2),
(4, 1, 'I', 0, 0, 0),
(4, 1,'O', 0, 4, 0),
(4, 1,'T', 90, 2, 2),
(4, 1,'S', 0, 0, 1),
(4, 1,'Z', 90, 5, 1),
(4, 1,'J', 90, 4, 3),
(4, 1,'L', 180, 6, 5),
(5, 3, 'I', 0, 0, 3),
(5, 3,'O', 0, 3, 1),
(5, 3,'T', 0, 4, 2),
(5, 3,'S', 0, 4, 0),
(5, 3,'Z', 0, 1, 0),
(5, 3,'J', 0, 6, 0),
(5, 3,'L', 0, 0, 0),
(6, 4, 'I', 0, 1, 6),
(6, 4,'O', 0, 3, 4),
(6, 4,'T', 180, 6, 2),
(6, 4,'S', 0, 0, 4),
(6, 4,'Z', 0, 3, 2),
(6, 4,'J', 0, 5, 1),
(6, 4,'L', 0, 2, 2),
(7, 5, 'I', 90, 1, 1),
(7, 5,'O', 0, 0, 14),
(7, 5,'T', 270, 0, 7),
(7, 5,'S', 90, 2, 9),
(7, 5,'Z', 90, 2, 6),
(7, 5,'J', 0, 0, 0),
(7, 5,'L', 180, 2, 14);        