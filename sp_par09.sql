-- Correccion de la Tabla Emihcmm

DROP PROCEDURE sp_par09;

CREATE PROCEDURE "informix".sp_par09() 

DEFINE _no_poliza CHAR(10);
DEFINE _no_cambio CHAR(3);
DEFINE _cantidad  SMALLINT;
	
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par09.trc";
--trace on;

LET _no_cambio = '0';

FOREACH
 SELECT no_poliza
   INTO	_no_poliza
   FROM emihcmm
  WHERE no_endoso = '00000'
    AND no_cambio = _no_cambio

{
	SELECT COUNT(*)
	  INTO _cantidad
	  FROM emihcmd
	 WHERE no_poliza = _no_poliza;

	IF _cantidad IS NULL THEN
		LET _cantidad = 0;
	END IF

	IF _cantidad = 0 THEN
		DELETE FROM emihcmm
		 WHERE no_poliza = _no_poliza;
	END IF
}

	INSERT INTO emihcmm
	SELECT no_poliza,
	       '000',
		   vigencia_inic,
		   vigencia_final,
		   fecha_mov,
		   no_endoso
	  FROM emihcmm
	 WHERE no_poliza = _no_poliza
	   AND no_cambio = _no_cambio;
	
	UPDATE emihcmd
	   SET no_cambio = '000'
	 WHERE no_poliza = _no_poliza
	   AND no_cambio = _no_cambio;

	DELETE FROM emihcmm
	 WHERE no_poliza = _no_poliza
	   AND no_cambio = _no_cambio;

--	EXIT FOREACH;

END FOREACH

END PROCEDURE;