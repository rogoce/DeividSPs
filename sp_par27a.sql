-- Eliminacion de los Registros de Endosos

--DROP PROCEDURE sp_par27b;
CREATE PROCEDURE sp_par27b(_no_poliza	CHAR(10),_no_endoso	CHAR(5)) 
returning smallint;

DEFINE _actualizado SMALLINT;

--set debug file to "sp_par27.trc";
--trace on;

SELECT actualizado
  INTO _actualizado
  FROM endedmae
 WHERE no_poliza = _no_poliza 
   AND no_endoso = _no_endoso;

IF _actualizado IS NULL THEN
	LET _actualizado = 0;
END IF

IF _actualizado = 0 THEN

	DELETE FROM emifafac WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM emifacon WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamre WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamrf WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

	DELETE FROM endcobde WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcobre WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedcob WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcuend WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmotra WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoaut WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde2 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedacr WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunide WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endunire WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endeduni WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedimp WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedrec WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endeddes WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endasien WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoage WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endmoase WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endcamco WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedde1 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
	DELETE FROM endedmae WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

END IF
return 0;
END PROCEDURE 
