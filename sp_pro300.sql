
 							--DROP procedure sp_pr94a;	   -- nuevo sp_pro300.sql

 --DROP procedure sp_pro300;	 
   CREATE procedure "informix".sp_300()

DEFINE i 	INTEGER;

    CREATE TEMP TABLE temp_ramo(
			  numero		 INTEGER,		
              cod_ramo       CHAR(3)
			  ) WITH NO LOG;

FOR i = 1 to 19

  IF i = 1 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'019'
	);
  ELIF i = 2 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'004'
	);
  ELIF i = 3 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'018'
	);
  ELIF i = 4 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'016'
	);
  ELIF i = 5 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'001'
	);
  ELIF i = 6 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'003'
	);
  ELIF i = 7 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'009'
	);
  ELIF i = 8 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'017'
	);
  ELIF i = 9 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'002'
	);
  ELIF i = 10 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'010'
	);
  ELIF i = 11 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'011'
	);
  ELIF i = 12 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'012'
	);
  ELIF i = 13 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'013'
	);
  ELIF i = 14 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'014'
	);
  ELIF i = 15 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'006'
	);
  ELIF i = 16 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'005'
	);
  ELIF i = 17 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'008'
	);
  ELIF i = 18 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'015'
	);
  ELIF i = 19 THEN
	INSERT INTO temp_ramo
	VALUES(
	i,
	'007'
	);
  END IF
END FOR

END PROCEDURE;
