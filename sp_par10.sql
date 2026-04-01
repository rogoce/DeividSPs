-- Correccion de la Tabla de Coaseguros de Colon

DROP PROCEDURE sp_par10;

CREATE PROCEDURE "informix".sp_par10() 

DEFINE _no_poliza CHAR(10);
DEFINE _porc 	  DEC(16,4);
	
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par10.trc";
--trace on;

FOREACH
 SELECT no_poliza
   INTO	_no_poliza
   FROM emipomae
  WHERE sucursal_origen = '002'
    AND cod_sucursal    = '002'
	AND cod_tipoprod    = '001'
--	AND no_poliza       = '84028'

	SELECT SUM(porc_partic_coas)
	  INTO _porc
	  FROM emicoama
	 WHERE no_poliza = _no_poliza;

	IF _porc IS NULL THEN
		LET _porc = 100;
	END IF

	IF _porc > 100 THEN
		LET _porc = 100;
	END IF

	IF _porc <> 100 THEN

		LET _porc = 100 - _porc;
			
		BEGIN 
		ON EXCEPTION IN(-268)
		END EXCEPTION

			INSERT INTO emihcmd
			VALUES(
			_no_poliza,
			'000',
			'036',
			_porc,
			0.00
			);

		END 

		BEGIN 
		ON EXCEPTION IN(-268)
		END EXCEPTION

			INSERT INTO emicoama
			VALUES(
			_no_poliza,
			'036',
			_porc,
			0.00
			);

		END 

	END IF

--	EXIT FOREACH;

END FOREACH

END PROCEDURE;