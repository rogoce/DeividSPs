-- Procedimiento para buscar los reclamos con la ultima transaccion sea cerrar reclamos para completar los incidentes en workflow
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf107;
CREATE PROCEDURE "informix".sp_rwf107() 
			RETURNING CHAR(10), INTEGER, CHAR(18), CHAR(1), CHAR(10);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _cod_tipotran		CHAR(3);
DEFINE _no_tramite, _transaccion			CHAR(10);
DEFINE _incidente           INTEGER;
DEFINE _numrecla			CHAR(18);
DEFINE _estatus_reclamo		CHAR(1);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

FOREACH
	SELECT no_reclamo, no_tramite, incidente, numrecla, estatus_reclamo
	  INTO _no_reclamo, _no_tramite, _incidente, _numrecla, _estatus_reclamo 
	  FROM recrcmae
	 WHERE numrecla[1,2] IN ("02", "20")
	   AND fecha_reclamo >= "01/01/2011"
	   AND fecha_reclamo <= "31/01/2011"
	   AND estatus_reclamo = "C"
	order by 1

	FOREACH
		SELECT cod_tipotran, transaccion
		  INTO _cod_tipotran, _transaccion
		  FROM rectrmae
		 WHERE no_reclamo = _no_reclamo
		   AND actualizado = 1
		 order by no_tranrec DESC
		EXIT FOREACH;
	END  FOREACH


	IF _cod_tipotran = "011" THEN
		RETURN _no_tramite, _incidente, _numrecla, _estatus_reclamo, _transaccion WITH RESUME;
	END IF	

END FOREACH
END PROCEDURE