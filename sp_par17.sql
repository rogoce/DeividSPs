-- Verificacion de Emireama, Emireaco, Emireafa

DROP PROCEDURE sp_par17;

CREATE PROCEDURE "informix".sp_par17()
RETURNING CHAR(10),
          CHAR(5),
		  SMALLINT,
		  CHAR(3),
		  DEC(16,6),
		  DEC(16,6),
		  CHAR(20),
		  CHAR(10);

DEFINE _error          INTEGER;

DEFINE _no_poliza      CHAR(10);
DEFINE _no_unidad      CHAR(5); 
DEFINE _no_cambio      SMALLINT;
DEFINE _cod_cober_reas CHAR(3);
DEFINE _porc_prima	   DEC(16,6);
DEFINE _porc_suma	   DEC(16,6);

DEFINE _porc_prima_or  DEC(16,6);
DEFINE _porc_suma_or   DEC(16,6);

DEFINE _cod_contrato   CHAR(5);

DEFINE _no_documento   CHAR(20);
DEFINE _no_factura     CHAR(10);
DEFINE _orden          INTEGER;
DEFINE _diferencia     DEC(16,6);
DEFINE _cantidad       INTEGER;
DEFINE _prima1         DEC(16,2);
DEFINE _prima2         DEC(16,2);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par17.trc";      
--TRACE ON;                                                                     

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 

	LET _no_poliza = _error;

	RETURN _no_poliza,
	       '',
		   '',
		   '',
		   '',
		   '',
		   '',
		   ''
		   WITH RESUME;

END EXCEPTION           

FOREACH
 SELECT	no_poliza,
 		no_unidad,
		no_cambio,
		cod_cober_reas
   INTO	_no_poliza,
 		_no_unidad,
		_no_cambio,
		_cod_cober_reas
   FROM	emireama
--  WHERE no_poliza = '79095'
  ORDER BY no_poliza DESC, no_unidad, no_cambio, cod_cober_reas

	SELECT SUM(porc_partic_prima),
	       SUM(porc_partic_suma)
	  INTO _porc_prima,
	       _porc_suma
	  FROM emireaco
	 WHERE no_poliza      = _no_poliza
	   AND no_unidad      = _no_unidad
	   AND no_cambio      = _no_cambio
	   AND cod_cober_reas = _cod_cober_reas;        

	IF _porc_prima <> 100 OR 
	   _porc_suma  <> 100 THEN

		IF _no_cambio <> 0 THEN
			CONTINUE FOREACH;
		END IF

		{
		SELECT COUNT(*)
		  INTO _cantidad
		  FROM emireaco
		 WHERE no_poliza      = _no_poliza
		   AND no_unidad      = _no_unidad
		   AND no_cambio      = _no_cambio
		   AND cod_cober_reas = _cod_cober_reas;        
		}
		{
		UPDATE emireaco
		   SET porc_partic_suma  = porc_partic_prima
		 WHERE no_poliza         = _no_poliza
		   AND no_unidad         = _no_unidad
	   	   AND no_cambio         = _no_cambio
		   AND cod_cober_reas    = _cod_cober_reas;        
		--}

		{
		SELECT MIN(orden)
		  INTO _orden
		  FROM emireaco
		 WHERE no_poliza      = _no_poliza
		   AND no_unidad      = _no_unidad
	 	   AND no_cambio      = _no_cambio
		   AND cod_cober_reas = _cod_cober_reas;        
		  	
		IF _porc_prima <> 100 THEN

			LET _diferencia = 100 - _porc_prima;
						
			UPDATE emireaco
			   SET porc_partic_prima = porc_partic_prima + _diferencia
			 WHERE no_poliza         = _no_poliza
			   AND no_unidad         = _no_unidad
		   	   AND no_cambio         = _no_cambio
			   AND cod_cober_reas    = _cod_cober_reas
			   AND orden             = _orden;        

		END IF
						
		IF _porc_suma <> 100 THEN

			LET _diferencia = 100 - _porc_suma;

			UPDATE emireaco
			   SET porc_partic_suma = porc_partic_suma + _diferencia
			 WHERE no_poliza        = _no_poliza
			   AND no_unidad        = _no_unidad
		   	   AND no_cambio        = _no_cambio
			   AND cod_cober_reas   = _cod_cober_reas
			   AND orden            = _orden;        

		END IF
		--}

--		IF _cantidad = 1 THEN
			{
			SELECT SUM(prima_neta)
			  INTO _prima1
			  FROM endedcob
			 WHERE no_poliza = _no_poliza
			   AND no_endoso = '00000'
			   AND no_unidad = _no_unidad;
			}

			SELECT SUM(porc_partic_prima)
			  INTO _porc_prima_or
			  FROM emifacon
			 WHERE no_poliza      = _no_poliza
			   AND no_endoso      = '00000'
			   AND no_unidad      = _no_unidad
			   AND cod_cober_reas = _cod_cober_reas;

			IF _porc_prima_or = 100 THEN			   

				SELECT no_documento,
				       no_factura
				  INTO _no_documento,
				       _no_factura
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				RETURN _no_poliza,
				       _no_unidad,
					   _no_cambio,
					   _cod_cober_reas,
					   _porc_prima,
					   _porc_suma,
					   _no_documento,
					   _no_factura
					   WITH RESUME;

			END IF

--		END IF

	END IF

END FOREACH

END 

END PROCEDURE;

