-- Procedimiento para buscar los reclamos con la ultima transaccion sea cerrar reclamos para completar los incidentes en workflow
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf165;
CREATE PROCEDURE "informix".sp_rwf165() 
			RETURNING CHAR(10) as tramite, INTEGER as incidente, CHAR(18) as numrecla, CHAR(1) as estatus_reclamo, CHAR(10) as no_reclamo;  

DEFINE _no_reclamo			CHAR(10);
DEFINE _cod_tipotran		CHAR(3);
DEFINE _no_tramite, _transaccion			CHAR(10);
DEFINE _incidente           INTEGER;
DEFINE _numrecla			CHAR(18);
DEFINE _estatus_reclamo		CHAR(1);
DEFINE _variacion           DEC(16,2);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

LET _variacion = 0.00;

FOREACH WITH HOLD
	SELECT no_reclamo, no_tramite, incidente, numrecla, estatus_reclamo
	  INTO _no_reclamo, _no_tramite, _incidente, _numrecla, _estatus_reclamo 
	  FROM recrcmae
	 WHERE numrecla[1,2] IN ("02", "20", "23")
	   AND fecha_reclamo >= '01/01/2020'
--	   AND fecha_reclamo >= today - 1 units year
	   AND estatus_reclamo in ("C", "D")
	   AND incidente IS NOT NULL
--	   AND incidente = 116223
	order by 1

{	SELECT sum(variacion)
	  INTO _variacion
	  FROM rectrmae
	 WHERE no_reclamo = _no_reclamo
	   AND actualizado = 1;
}	   
	SELECT sum(reserva_actual)
	  INTO _variacion
	  FROM recrccob
	 WHERE no_reclamo = _no_reclamo;
	   
	IF _variacion IS NULL THEN
		LET _variacion = 0.00;
	END IF

--	IF _variacion = 0.00 THEN
		RETURN _no_tramite, _incidente, _numrecla, _estatus_reclamo, _no_reclamo WITH RESUME;
--	END IF	
	
	FOREACH WITH HOLD
		SELECT no_incidente 
		  INTO _incidente
		  FROM recterce
		 WHERE no_reclamo = _no_reclamo
		 
		RETURN _no_tramite, _incidente, _numrecla, _estatus_reclamo, _no_reclamo WITH RESUME;		 
	
	END FOREACH

END FOREACH
END PROCEDURE