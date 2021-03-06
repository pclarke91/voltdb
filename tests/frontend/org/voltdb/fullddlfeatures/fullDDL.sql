-- CREATE INDEX
-- basic features

CREATE TABLE T1
(
    width INTEGER
,   length INTEGER
,   volume INTEGER
);

CREATE UNIQUE INDEX area
ON
T1
(
    width * length
);

CREATE TABLE T2
(
    width INTEGER
,   length INTEGER
,   area INTEGER NOT NULL
,   volume INTEGER
);

PARTITION TABLE T2
ON
COLUMN
    area
;

CREATE ASSUMEUNIQUE INDEX absVal
ON
T2
(
    ABS(area * 2)
,   ABS(volume / 2)
);

-- hash index

CREATE TABLE T3
(
    val INTEGER
,   str VARCHAR(30)
,   id INTEGER
);

CREATE UNIQUE INDEX abs_Hash_idx
ON
T3
(
    ABS(val)
);

CREATE UNIQUE INDEX nomeaninghashweirdidx
ON
T3
(
    ABS(id)
);

-- function in index definition

CREATE INDEX strMatch
ON
T3
(
    FIELD
    (
        str
    ,   'arbitrary'
    )
,   id
);


-- CREATE ROLE
-- basic

CREATE ROLE guest;

CREATE ROLE admin
WITH
    sysproc
,   adhoc
,   defaultproc;


-- CREATE PROCEDURE AS
-- as sql stmt

CREATE TABLE User
(
    age INTEGER
,   name VARCHAR(20)
);

CREATE PROCEDURE p1
ALLOW
    admin
AS
    SELECT COUNT(*)
         , name
    FROM User
    WHERE age = ?
    GROUP BY name;

CREATE PROCEDURE p2
ALLOW
    admin
AS
    INSERT INTO User
    VALUES (?, ?);

-- as source code

--CREATE PROCEDURE p3
--ALLOW
--    admin
--AS
--    ###
--    stmt = new SQLStmt('SELECT age, name FROM User WHERE age = ?')
--    transactOn = { int key ->
--                   voltQueueSQL(stmt,key)
--                   voltExecuteSQL(true)
--                 }
--    ### LANGUAGE GROOVY
--;


-- CREATE TABLE
-- test all supported SQL datatypes

CREATE TABLE T4
(
    C1 TINYINT DEFAULT 127 NOT NULL
,   C2 SMALLINT DEFAULT 32767 NOT NULL
,   C3 INTEGER DEFAULT 2147483647 NOT NULL
,   C4 BIGINT NOT NULL
,   C5 FLOAT NOT NULL
,   C6 DECIMAL NOT NULL
,   C7 VARCHAR(32) NOT NULL
,   C8 VARBINARY(32) NOT NULL
,   C9 TIMESTAMP DEFAULT NOW NOT NULL
,   C10 TIMESTAMP DEFAULT CURRENT_TIMESTAMP
,   PRIMARY KEY
    (
        C1
    ,   C9
    )
);

-- test maximum varchar size

CREATE TABLE T5
(
    C VARCHAR(1048576 BYTES)
);

CREATE TABLE T6
(
    C VARCHAR(262144)
);

-- test maximum varbinary size

CREATE TABLE T7
(
    C VARBINARY(1048576)
);

-- test maximum limit partition rows

CREATE TABLE T8
(
    C INTEGER
,   LIMIT PARTITION ROWS 2147483647
);

-- column constraint

CREATE TABLE T9
(
    C1 INTEGER PRIMARY KEY NOT NULL
,   C2 SMALLINT UNIQUE NOT NULL
);

CREATE TABLE T10
(
    C INTEGER DEFAULT 123 NOT NULL
,   CONSTRAINT con UNIQUE
    (
        C
    )
);

CREATE TABLE T11
(
    C INTEGER DEFAULT 123 NOT NULL
,   CONSTRAINT pk1 PRIMARY KEY
    (
        C
    )
);

CREATE TABLE T12
(
    C1 INTEGER NOT NULL
,   C2 INTEGER DEFAULT 123 NOT NULL
,   CONSTRAINT au ASSUMEUNIQUE
    (
        C2
    )
);
PARTITION TABLE T12 ON COLUMN C1;

-- table constraints

CREATE TABLE T13
(
    C INTEGER
,   CONSTRAINT pk2 PRIMARY KEY
    (
        C
    )
);

CREATE TABLE T14
(
    C INTEGER
,   CONSTRAINT uni1 UNIQUE
    (
        C
    )
);

CREATE TABLE T15
(
    C INTEGER
,   C2 TINYINT NOT NULL
,   CONSTRAINT assumeuni ASSUMEUNIQUE
    (
        C
    )
);
PARTITION TABLE T15 ON COLUMN C2;

CREATE TABLE T16
(
    C INTEGER
,   CONSTRAINT lpr1 LIMIT PARTITION ROWS 1
);

-- table constraint without keyword

CREATE TABLE T17
(
    C INTEGER
,   PRIMARY KEY
    (
        C
    )
);

CREATE TABLE T18
(
    C INTEGER
,   UNIQUE
    (
        C
    )
);

CREATE TABLE T19
(
    C INTEGER
,   C2 TINYINT NOT NULL
,   ASSUMEUNIQUE
    (
        C
    )
);
PARTITION TABLE T19 ON COLUMN C2;

CREATE TABLE T20
(
    C INTEGER
,   LIMIT PARTITION ROWS 123
);


-- both column and table constraints

CREATE TABLE T21
(
    C1 TINYINT DEFAULT 127 NOT NULL
,   C2 SMALLINT DEFAULT 32767 NOT NULL
,   C3 INTEGER DEFAULT 2147483647 NOT NULL
,   C4 BIGINT NOT NULL
,   C5 FLOAT NOT NULL
,   C6 DECIMAL ASSUMEUNIQUE NOT NULL
,   C7 VARCHAR(32) NOT NULL
,   C8 VARBINARY(32) NOT NULL
,   C9 TIMESTAMP DEFAULT NOW NOT NULL
,   C10 TIMESTAMP DEFAULT CURRENT_TIMESTAMP
,   ASSUMEUNIQUE
    (
        C1
    ,   C9
    )
);
PARTITION TABLE T21 ON COLUMN C3;

CREATE TABLE T22
(
    C1 TINYINT DEFAULT 127 NOT NULL UNIQUE
,   C2 SMALLINT DEFAULT 32767 NOT NULL
,   C3 INTEGER DEFAULT 2147483647 NOT NULL
,   C4 BIGINT NOT NULL
,   C5 FLOAT NOT NULL
,   C6 DECIMAL UNIQUE NOT NULL
,   C7 VARCHAR(32) NOT NULL
,   C8 VARBINARY(32) NOT NULL
,   C9 TIMESTAMP DEFAULT NOW NOT NULL
,   C10 TIMESTAMP DEFAULT CURRENT_TIMESTAMP
,   UNIQUE
    (
        C1
    ,   C9
    )
);

CREATE TABLE T23
(
    C1 INTEGER NOT NULL
,   C2 SMALLINT UNIQUE
,   C3 VARCHAR(32) NOT NULL
,   C4 TINYINT NOT NULL
,   C5 TIMESTAMP NOT NULL
,   C6 BIGINT NOT NULL
,   C7 FLOAT NOT NULL
,   C8 DECIMAL NOT NULL
,   C9 INTEGER
,   CONSTRAINT hash_pk PRIMARY KEY
    (
        C1
    ,   C5
    )
,   CONSTRAINT uni2 UNIQUE
    (
        C1
    ,   C7
    ),
    CONSTRAINT lpr2 LIMIT PARTITION ROWS 123
);


-- CREATE VIEW
-- basic

CREATE TABLE T24
(
    C1 INTEGER
,   C2 INTEGER
);

CREATE VIEW VT1
(
    C1
,   C2
,   TOTAL
)
AS
    SELECT C1
        ,  C2
        ,  COUNT(*)
    FROM T24
    GROUP BY C1
          ,  C2
;

CREATE VIEW VT2
(
    C1
,   C2
,   TOTAL
,   SUMUP
)
AS
    SELECT C1
        ,  C2
        ,  COUNT(*)
        ,  SUM(C2)
    AS
        newTble
    FROM T24
    WHERE T24.C1 < 1000
    GROUP BY C1
          ,  C2
;


-- EXPORT TABLE
-- basic

CREATE TABLE T25
(
    id INTEGER NOT NULL
);
EXPORT TABLE T25;

CREATE TABLE T25S
(
    id INTEGER NOT NULL
);
EXPORT TABLE T25S TO STREAM imagine;


-- IMPORT CLASS
-- basic

-- IMPORT CLASS org.voltdb_testprocs.fullddlfeatures.NoMeaningClass;
-- CREATE PROCEDURE FROM CLASS org.voltdb_testprocs.fullddlfeatures.testImportProc;


-- CREATE PROCEDURE ... PARTITION ON ...
-- basic

CREATE TABLE T26
(
    age BIGINT NOT NULL
,   gender TINYINT
);

PARTITION TABLE T26 ON COLUMN age;

CREATE PROCEDURE p4
ALLOW
    admin
PARTITION ON
    TABLE
        T26
    COLUMN
        age
    PARAMETER
        1
AS
    SELECT COUNT(*)
    FROM T26
    WHERE gender = ? AND age = ?;

-- This would not have worked before the PARTITION clause existed,
-- e.g. a separate PARTITION PROCEDURE statement would be too late.
CREATE PROCEDURE p4a
ALLOW
    admin
PARTITION ON
    TABLE
        T26
    COLUMN
        age
    PARAMETER
        0
AS
    SELECT *
    FROM T26
    WHERE age = ? UNION ALL (
        SELECT *
        FROM T26
        WHERE age = ?);

CREATE PROCEDURE
ALLOW
    admin
PARTITION ON
    TABLE
        T26
    COLUMN
        age
FROM CLASS
    org.voltdb_testprocs.fullddlfeatures.testCreateProcFromClassProc
;


-- PARTITION TABLE
-- basic

CREATE TABLE T27
(
    C INTEGER NOT NULL
);

PARTITION TABLE T27 ON COLUMN C;


-- CREATE PROCEDURE
-- Verify that the sqlcmd parsing survives two consecutive create procedures

CREATE TABLE T28
(
    C1 BIGINT
,   C2 BIGINT
);

CREATE TABLE T29
(
    C1 INTEGER
,   LIMIT PARTITION ROWS 5 EXECUTE (DELETE FROM T29 WHERE C1 > 0)
);

CREATE TABLE T30
(
    C1 INTEGER
,   CONSTRAINT lpr5exec
    LIMIT PARTITION ROWS 5 EXECUTE (DELETE FROM T30 WHERE C1 > 0)
);

CREATE PROCEDURE FOO1 AS SELECT * FROM T28;
CREATE PROCEDURE FOO2 AS SELECT COUNT(*) FROM T28;

-- Verify that consecutive procedure/view statements survive sqlcmd parsing
CREATE PROCEDURE FOO3 AS SELECT * FROM T28;

CREATE VIEW VT3
(
    C1
,   C2
,   TOTAL
)
AS
    SELECT C1
        ,  C2
        ,  COUNT(*)
    FROM T28
    GROUP BY C1
          ,  C2
;

CREATE PROCEDURE FOO4 AS SELECT * FROM VT3;

-- Verify that create procedure with INSERT INTO SELECT
-- survives sqlcmd
CREATE PROCEDURE INS_T1_SELECT_T1 AS
    INSERT INTO T1 SELECT * FROM T1;

CREATE PROCEDURE INS_T1_COLS_SELECT_T1 AS
    INSERT INTO T1 (WIDTH, LENGTH, VOLUME)
        SELECT WIDTH, LENGTH, VOLUME FROM T1;

CREATE PROCEDURE UPS_T4_SELECT_T4 AS
    INSERT INTO T4 SELECT * FROM T4 ORDER BY C1, C9;

CREATE PROCEDURE UPS_T4_COLS_SELECT_T4 AS
    INSERT INTO T4 (C9, C1, C4, C5, C8, C6, C7)
        SELECT C9, C1, C4, C5, C8, C6, C7 FROM T4;


-- DROP VIEWS
CREATE TABLE T30A (
   C1 VARCHAR(15),
   C2 VARCHAR(15),
   C3 VARCHAR(15) NOT NULL,
   PRIMARY KEY (C3)
);

CREATE VIEW VT30A
(
    C1
,   C2
,   TOTAL
)
AS
    SELECT C1
        ,  C2
        ,  COUNT(*)
    FROM T30A
    GROUP BY C1
          ,  C2
;

CREATE VIEW VT30B
(
    C2
,   C1
,   TOTAL
)
AS
    SELECT C2
        ,  C1
        ,  COUNT(*)
    FROM T30A
    GROUP BY C2
          ,  C1
;

DROP VIEW VT000 IF EXISTS;
DROP VIEW VT30A IF EXISTS;
DROP VIEW VT30B;

-- DROP INDEX

CREATE TABLE T31 (
    C1 INTEGER
,   C2 INTEGER
,   C3 INTEGER
,   PRIMARY KEY (C3)
);

CREATE UNIQUE INDEX abs_T31A_idx
ON
T31
(
    ABS(C1*C3)
);

DROP INDEX abs_T31A_idx;
DROP INDEX abs_T000_idx IF EXISTS;

-- DROP PROCEDURE
CREATE TABLE T32 (
   C1 VARCHAR(15),
   C2 VARCHAR(15),
   C3 VARCHAR(15) NOT NULL,
   PRIMARY KEY (C3)
);

PARTITION TABLE T32 ON COLUMN C3;

CREATE PROCEDURE T32A PARTITION ON TABLE T32 COLUMN C3 AS SELECT * FROM T32 WHERE C3 = ?;
CREATE PROCEDURE T32B PARTITION ON TABLE T32 COLUMN C3 AS SELECT COUNT(*) FROM T32 WHERE C3 = ?;

DROP PROCEDURE T32A;
DROP PROCEDURE T32B;

-- DROP TABLE
-- basic
CREATE TABLE T33 (
   C1 VARCHAR(15),
);
DROP TABLE T33;
-- cascade and if exists
CREATE TABLE T34 (
   C1 INTEGER,
   C2 INTEGER,
   C3 INTEGER NOT NULL,
   PRIMARY KEY (C3)
);
CREATE VIEW VT34A
(
    C1
,   C2
,   TOTAL
)
AS
    SELECT C1
        ,  C2
        ,  COUNT(*)
    FROM T34
    GROUP BY C1
          ,  C2
;
CREATE UNIQUE INDEX abs_T34A_idx
ON
T34
(
    ABS(C1*C3)
);
DROP TABLE T34 IF EXISTS CASCADE;

-- ALTER TABLE DROP CONSTRAINT
CREATE TABLE T35
(
    C1 INTEGER PRIMARY KEY NOT NULL
,   C2 SMALLINT UNIQUE NOT NULL
);
ALTER TABLE T35 DROP PRIMARY KEY;

CREATE TABLE T35A (
   C1 INTEGER
,  LIMIT PARTITION ROWS 1
);
ALTER TABLE T35A DROP LIMIT PARTITION ROWS;

CREATE TABLE T36
(
    C INTEGER
,   CONSTRAINT pk36A PRIMARY KEY
    (
        C
    )
);
ALTER TABLE T36 DROP CONSTRAINT pk36A;

CREATE TABLE T37
(
    C INTEGER
,   CONSTRAINT con37A UNIQUE
    (
        C
    )
);
ALTER TABLE T37 DROP CONSTRAINT con37A;

CREATE TABLE T38
(
    C INTEGER
,   CONSTRAINT con38A ASSUMEUNIQUE
    (
        C
    )
);
ALTER TABLE T38 DROP CONSTRAINT con38A;

CREATE TABLE T39
(
    C INTEGER
,   CONSTRAINT lpr39A LIMIT PARTITION ROWS 1
);
ALTER TABLE T39 DROP CONSTRAINT lpr39A;

-- ALTER TABLE ADD CONSTRAINT
CREATE TABLE T40
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C2 INTEGER
);
ALTER TABLE T40 ADD CONSTRAINT con40A UNIQUE ( C1, C2 );

CREATE TABLE T41
(
    C1 INTEGER
);
-- ENG-7321 - bug with PRIMARY KEY and verification of generated DDL
-- ALTER TABLE T41 ADD PRIMARY KEY ( C1 );
-- ALTER TABLE T41 ADD CONSTRAINT pk41 PRIMARY KEY ( C1 );

CREATE TABLE T42
(
    C1 INTEGER
,   C2 INTEGER
);
ALTER TABLE T42 ADD CONSTRAINT con42A ASSUMEUNIQUE ( C1, C2 );

CREATE TABLE T42A
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C2 INTEGER
,   C3 INTEGER
);
ALTER TABLE T42A ADD CONSTRAINT con42AA ASSUMEUNIQUE (
    ABS(C1*C2)
,   C2+C3
);

CREATE TABLE T43
(
    C1 INTEGER DEFAULT 123 NOT NULL
);
ALTER TABLE T43 ADD CONSTRAINT con43A LIMIT PARTITION ROWS 1;

-- ALTER TABLE ADD COLUMN
CREATE TABLE T44
(
    C1 INTEGER DEFAULT 123 NOT NULL
);
ALTER TABLE T44 ADD COLUMN C2 VARCHAR(1);

CREATE TABLE T45
(
    C1 INTEGER DEFAULT 123 NOT NULL
);
ALTER TABLE T45 ADD COLUMN C2 INTEGER DEFAULT 1 NOT NULL;

CREATE TABLE T46
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C3 INTEGER
);
ALTER TABLE T46 ADD COLUMN C2 INTEGER DEFAULT 1 NOT NULL ASSUMEUNIQUE BEFORE C3;

CREATE TABLE T47
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C3 INTEGER
);
ALTER TABLE T47 ADD COLUMN C2 INTEGER DEFAULT 1 NOT NULL UNIQUE BEFORE C3;

CREATE TABLE T48
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C3 INTEGER
);
-- ENG-7321 - bug with PRIMARY KEY and verification of generated DDL
-- ALTER TABLE T48 ADD COLUMN C2 INTEGER DEFAULT 1 NOT NULL PRIMARY KEY BEFORE C3;

-- ALTER TABLE DROP COLUMN
CREATE TABLE T49
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C2 INTEGER
);
ALTER TABLE T49 DROP COLUMN C1;

CREATE TABLE T50
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C2 INTEGER
,   C3 INTEGER
,   CONSTRAINT pk391 PRIMARY KEY
    (
        C1
    )
,   CONSTRAINT con391 UNIQUE
    (
        C2
    )
);
CREATE VIEW VT50A
(
    C1
,   C2
,   TOTAL
)
AS
    SELECT C1
        ,  C2
        ,  COUNT(*)
    FROM T50
    GROUP BY C1
          ,  C2
;
CREATE UNIQUE INDEX abs_T50A_idx
ON
T50
(
    ABS(C1*C2)
);
ALTER TABLE T50 DROP COLUMN C2 CASCADE;

-- ALTER TABLE ALTER COLUMN
CREATE TABLE T51
(
    C1 INTEGER NOT NULL
,   C2 INTEGER DEFAULT 123 NOT NULL
);
ALTER TABLE T51 ALTER COLUMN C1 SET DEFAULT NULL;
ALTER TABLE T51 ALTER COLUMN C1 SET NULL;


CREATE TABLE T52
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C2 INTEGER NOT NULL
);
ALTER TABLE T52 ALTER COLUMN C2 SET NULL;


CREATE TABLE T53
(
    C1 INTEGER DEFAULT 123 NOT NULL
,   C2 INTEGER NOT NULL
);
ALTER TABLE T53 ALTER COLUMN C1 VARCHAR(2);
ALTER TABLE T53 ALTER COLUMN C2 VARCHAR(2);

CREATE TABLE T54
(
    C1 VARCHAR(2) NOT NULL
,   C2 INTEGER DEFAULT NULL
);
CREATE UNIQUE INDEX abs_T54A_idx
ON
T54
(
    C2
);
ALTER TABLE T54 ALTER COLUMN C2 VARCHAR(2) CASCADE;

CREATE TABLE T55
(
    STR VARCHAR(30)
,   TS TIMESTAMP
,   BIG BIGINT    
);

-- These statements were added when use of some Volt-specific functions or ||
-- or NULL in indexed expressions was discovered to be mishandled (ENG-7792).
-- They showed that views and procs did NOT share these problems,
-- but let's make sure things stay that way.
CREATE PROCEDURE PROC_USES_CONCAT AS SELECT CONCAT(SUBSTRING(STR,4), SUBSTRING(STR,1,3)) FROM T55;
CREATE PROCEDURE PROC_USES_BARBARCONCAT AS SELECT SUBSTRING(STR,5) || SUBSTRING(STR,1,3) FROM T55;
CREATE PROCEDURE PROC_USES_NULL AS SELECT DECODE(STR, NULL, 'NULLISH', STR) FROM T55;
CREATE PROCEDURE PROC_USES_TO_TIMESTAMP AS SELECT TO_TIMESTAMP(SECOND, BIG) FROM T55;
CREATE VIEW V55_USES_NULL AS
    SELECT   DECODE(STR, NULL, 'NULLISH', STR), COUNT(*), SUM(BIG)
    FROM T55 
    GROUP BY DECODE(STR, NULL, 'NULLISH', STR);
CREATE VIEW V55_USES_TO_TIMESTAMP AS
    SELECT   TO_TIMESTAMP(SECOND, BIG), COUNT(*), COUNT(STR)
    FROM T55 
    GROUP BY TO_TIMESTAMP(SECOND, BIG);
CREATE VIEW V55_USES_CONCAT AS
    SELECT   CONCAT(SUBSTRING(STR,4), SUBSTRING(STR,1,3)), COUNT(*), COUNT(STR)
    FROM T55 
    GROUP BY CONCAT(SUBSTRING(STR,4), SUBSTRING(STR,1,3));
CREATE VIEW V55_USES_BARBARCONCAT AS
    SELECT   SUBSTRING(STR,5) || SUBSTRING(STR,1,3), COUNT(*), COUNT(STR)
    FROM T55 
    GROUP BY SUBSTRING(STR,5) || SUBSTRING(STR,1,3);

-- ENG-7792 Make sure that concat, ||, and volt-specific SQL functions survive DDL roundtripping.
-- This especially exercises FunctionForVoltDB.getSQL().
CREATE INDEX ENG7792_INDEX_USES_CONCAT ON T55 (CONCAT(SUBSTRING(STR,4), SUBSTRING(STR,1,3)));
CREATE INDEX ENG7792_INDEX_USES_BARBARCONCAT ON T55 (SUBSTRING(STR,5) || SUBSTRING(STR,1,3));
-- ENG-7840 Make sure that a NULL constant survives DDL roundtripping.
CREATE INDEX ENG7840_INDEX_USES_NULL ON T55 (DECODE(STR, NULL, 'NULLISH', STR));
CREATE INDEX INDEX_USES_DECODE ON T55 (DECODE(STR, '', 'NULLISH', STR));
CREATE INDEX INDEX_USES_SINCE_EPOCH ON T55 (SINCE_EPOCH(SECOND, TS)/60);
CREATE INDEX INDEX_USES_TRUNCATE_AND_TO_TIMESTAMP ON T55 (TRUNCATE(DAY, TO_TIMESTAMP(SECOND, BIG)));
CREATE INDEX INDEX_USES_JSON_SET_FIELD_ON_FIELD ON T55 (SET_FIELD(FIELD(STR, 'A'), 'B', ''));
CREATE INDEX INDEX_USES_JSON_ARRAY_OPS ON T55 (ARRAY_ELEMENT(STR, ARRAY_LENGTH(STR)-1));
