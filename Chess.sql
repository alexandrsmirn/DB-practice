--CREATE DATABASE chess;
--USE DATABASE chess;

CREATE TABLE chessman 
	(cid SMALLINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY(INCREMENT BY 1 START WITH 1),
	 type VARCHAR(10) NOT NULL,
	 colour VARCHAR(6) NOT NULL CHECK(colour IN ('white', 'black')),
	 CHECK(type IN ('pawn', 'rook', 'knight', 'bishop', 'king', 'queen'))
	);

CREATE TABLE chessboard
	(cid SMALLINT PRIMARY KEY REFERENCES chessman(cid), --важно что primary key
	 x CHAR NOT NULL CHECK(x SIMILAR TO '[a-h]'),
	 y SMALLINT NOT NULL CHECK(y > 0 AND y < 9),
	 UNIQUE(x, y) --уникальные координаты
	);

INSERT INTO chessman(type, colour) VALUES
	('pawn', 'white'),
	('pawn', 'white'),
	('pawn', 'white'),
	('pawn', 'white'),
	('pawn', 'white'),
	('pawn', 'white'),
	('pawn', 'white'),
	('pawn', 'white'),
	('rook', 'white'),
	('knight', 'white'),
	('bishop', 'white'),
	('king', 'white'),
	('queen', 'white'),
	('bishop', 'white'),
	('knight', 'white'),
	('rook', 'white'),
	
	('pawn', 'black'),
	('pawn', 'black'),
	('pawn', 'black'),
	('pawn', 'black'),
	('pawn', 'black'),
	('pawn', 'black'),
	('pawn', 'black'),
	('pawn', 'black'),
	('rook', 'black'),
	('knight', 'black'),
	('bishop', 'black'),
	('king', 'black'),
	('queen', 'black'),
	('bishop', 'black'),
	('knight', 'black'),
	('rook', 'black');
	
INSERT INTO chessboard(cid, x, y) VALUES
	(1, 'a', 2),
	(2, 'b', 2),
	(3, 'c', 2),
	(4, 'd', 2),
	(5, 'e', 2),
	(6, 'f', 2),
	(7, 'g', 2),
	(8, 'h', 2),
	(9, 'a', 1),
	(10,'b', 1),
	(11,'c', 1),
	(12,'d', 1),
	(13,'e', 1),
	(14,'f', 1),
	(15,'g', 1),
	(16,'h', 1),
	(17,'a',7),
	(18,'b',7),
	(19,'c',7),
	(20,'d',7),
	(21,'e',7),
	(22,'f',7),
	(23,'g',7),
	(24,'h',7),
	(25,'a',8),
	(26,'b',8),
	(27,'c',8),
	(28,'d',8),
	(29,'e',8),
	(30,'f',8),
	(31,'g',8),
	(32,'h',8);

--1 
	SELECT COUNT(cid) AS fig_on_board FROM chessboard;

--2
	SELECT cid FROM chessman WHERE type LIKE 'k%';

--3
	SELECT type, COUNT(type) FROM chessman WHERE colour='black' GROUP BY type;
/*либо*/SELECT type, COUNT(type)/2 FROM chessman GROUP BY type;

--CREATE VIEW
	CREATE VIEW result
	AS SELECT chessman.*, x, y
	FROM chessman INNER JOIN chessboard ON chessman.cid = chessboard.cid;

--4
	SELECT chessman.cid FROM chessboard, chessman
	WHERE chessman.cid = chessboard.cid AND chessman.type = 'pawn' AND color = 'white';
/*либо*/
	SELECT result.cid FROM result 
	WHERE type = 'pawn'AND colour = 'white';

--5
	SELECT type, colour FROM result
	WHERE ASCII(x)-ASCII('a') + 1 = y;

--6
	SELECT colour AS player, COUNT(result.cid) AS figures_left
	FROM result
	GROUP BY colour;

--7
	SELECT DISTINCT type FROM result
	WHERE colour = 'black';
/*либо*/
	SELECT type FROM result
	WHERE colour = 'black'
	GROUP BY type;

--8
	SELECT type, COUNT(result.cid) AS figures_left
	FROM result
	WHERE colour = 'black'
	GROUP BY type;

--9
	SELECT type, COUNT(result.cid)
	FROM result
	GROUP BY type HAVING COUNT(result.cid) > 1;
	
--10
	SELECT colour
	FROM
		(SELECT colour, COUNT(result.cid) AS figures_left
		 FROM result
		 GROUP BY colour
		)
	WHERE figures_left = MAX(colour);

	/*либо*/
	SELECT colour
	FROM
		(SELECT colour, COUNT(result.cid) AS figures_left
		 FROM result
		 GROUP BY colour
		)
	ORDER BY DESC
	LIMIT 1;
	
--11
	SELECT result.cid
	FROM result
	WHERE x IN (SELECT x FROM result WHERE type = 'rook')
		OR y IN (SELECT y from result WHERE type = 'rook');

	/*либо -- трюк с декартовым произведением*/
	SELECT DISTINCT b.cid
	FROM result AS a, result AS b
	WHERE a.type = 'rook' AND (a.x = b.x OR a.y = b.y);

--12
	SELECT colour
	FROM result
	WHERE type = 'pawn'
	GROUP BY colour HAVING COUNT(result.cid) > 0;

--13
	SELECT board1.cid
	FROM board1 LEFT JOIN board2 ON board1.cid = board2.cid
	WHERE board2.x IS NULL OR board1.x != board2.x OR board1.y != board2.y;

--14
	SELECT result.cid
	FROM result, chessboard
	WHERE chessboard.cid = 28 AND result.cid != 28
		AND ABS(result.y - chessboard.y) <= 2 AND ABS(ASCII(result.x)-ASCII(chessboard.x)) <= 2;

--15
	SELECT result.cid
	FROM result, chessboard
	WHERE chessboard.cid = 12 AND result.cid != 12
	ORDER BY (ABS(result.y - chessboard.y) + ABS(ASCII(result.x)-ASCII(chessboard.x))) ASC
	LIMIT 1;