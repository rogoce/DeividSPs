-- Correccion del la Fecha de Cancelacion para Polizas Rehabilitadas

DROP PROCEDURE sp_par11;

CREATE PROCEDURE "informix".sp_par11() 
RETURNING CHAR(20), 
          CHAR(10);

DEFINE _no_poliza    CHAR(10);
DEFINE _no_endoso    CHAR(5); 
DEFINE _cod_endomov  CHAR(3); 
DEFINE _no_documento CHAR(20);
	
--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par11.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT no_poliza,
        no_documento
   INTO	_no_poliza,
        _no_documento
   FROM emipomae
  WHERE actualizado = 1
    AND fecha_cancelacion IS NOT NULL
	AND estatus_poliza NOT IN (2, 4)

	SELECT MAX(no_endoso)
	  INTO _no_endoso
	  FROM endedmae
	 WHERE no_poliza   = _no_poliza
	   AND actualizado = 1
	   AND cod_endomov IN ('002', '003');

	SELECT cod_endomov
	  INTO _cod_endomov
	  FROM endedmae
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso;

	IF _cod_endomov IS NULL THEN

		UPDATE emipomae
		   SET fecha_cancelacion = NULL
		 WHERE no_poliza         = _no_poliza;

		RETURN _no_documento,
		       _no_poliza 
			   WITH RESUME;

	END IF

	IF _cod_endomov = '003' THEN
		
		UPDATE emipomae
		   SET fecha_cancelacion = NULL
		 WHERE no_poliza         = _no_poliza;

		RETURN _no_documento,
		       _no_poliza 
			   WITH RESUME;

	ELSE

		UPDATE emipomae
		   SET estatus_poliza = 2
		 WHERE no_poliza      = _no_poliza;

		RETURN _no_documento,
		       _no_poliza 
			   WITH RESUME;

	END IF

END FOREACH

END PROCEDURE;