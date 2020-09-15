CREATE TABLE t1(a INTEGER PRIMARY KEY, b VARCHAR, c VARCHAR);
INSERT INTO t1 VALUES   (1, 'A', 'one'  ),
                        (2, 'B', 'two'  ),
                        (3, 'C', 'three'),
                        (4, 'D', 'one'  ),
                        (5, 'E', 'two'  ),
                        (6, 'F', 'three'),
                        (7, 'G', 'one'  );

CREATE TABLE t2(a INTEGER PRIMARY KEY, b VARCHAR, c VARCHAR);
INSERT INTO t2 VALUES   (1, 'A', 'one'  ),
                        (2, 'B', 'two'  ),
                        (3, 'C', 'three'),
                        (4, 'D', 'one'  ),
                        (5, 'E', 'two'  );

CREATE VIEW v_tracks 
AS 
SELECT t1.c, sum(t1.a) as suma

FROM t1 inner join t2 on t1.a = t2.a 

group by t1.c
having sum(t1.a) > 0
order by sum(t1.a) asc
;

SELECT * from v_tracks limit 1,1