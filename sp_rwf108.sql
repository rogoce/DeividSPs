-- Procedimiento para buscar los reclamos con la ultima transaccion sea cerrar reclamos para completar los incidentes en workflow
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf108;

CREATE PROCEDURE "informix".sp_rwf108(a_incidente integer) 
			RETURNING CHAR(10), INTEGER, CHAR(18), CHAR(1), CHAR(10), CHAR(3);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _cod_tipotran		CHAR(3);
DEFINE _no_tramite, _transaccion			CHAR(10);
DEFINE _incidente           INTEGER;
DEFINE _numrecla			CHAR(18);
DEFINE _estatus_reclamo		CHAR(1);
define _cerrar_rec			smallint;
define _cantidad			smallint;
define _tipo_reclamante     CHAR(1);


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;
LET _cantidad = 0;
LET _cod_tipotran = "";
LET _cerrar_rec = 0;
LET _transaccion = "";

SELECT count(*) INTO _cantidad
  FROM recrcmae
 WHERE incidente = a_incidente;

IF _cantidad > 0 THEN
	let _tipo_reclamante = "A";
ELSE
	SELECT count(*) INTO _cantidad
	  FROM recterce
	 WHERE no_incidente = a_incidente;
	  
    IF _cantidad > 0 THEN
		let _tipo_reclamante = "T";
	ELSE
		let _tipo_reclamante = "N";
    END IF
END IF

IF _tipo_reclamante = "A" THEN
	FOREACH
		SELECT no_reclamo, no_tramite, incidente, numrecla, estatus_reclamo
		  INTO _no_reclamo, _no_tramite, _incidente, _numrecla, _estatus_reclamo 
		  FROM recrcmae
		 WHERE incidente = a_incidente
		   AND numrecla[1,2] IN ("02", "20", "23")
		order by 1
		
		FOREACH
			SELECT cod_tipotran, transaccion, cerrar_rec
			  INTO _cod_tipotran, _transaccion, _cerrar_rec
			  FROM rectrmae
			 WHERE no_reclamo = _no_reclamo
			   AND actualizado = 1
			   AND (cod_tipotran = '011' OR cerrar_rec = 1)
			 order by no_tranrec DESC
			EXIT FOREACH;
		END  FOREACH

		if _cerrar_rec = 1 then
			let _cod_tipotran = "011";
		end if

		RETURN _no_tramite, _incidente, _numrecla, _estatus_reclamo, _transaccion, _cod_tipotran;

	END FOREACH
ELIF _tipo_reclamante = "T"	THEN
	FOREACH
		SELECT no_reclamo
		  INTO _no_reclamo
		  FROM recterce
		 WHERE no_incidente = a_incidente

		SELECT no_tramite, incidente, numrecla, estatus_reclamo
		  INTO _no_tramite, _incidente, _numrecla, _estatus_reclamo 
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo
		   AND numrecla[1,2] IN ("02", "20", "23");

		FOREACH
			SELECT cod_tipotran, transaccion, cerrar_rec
			  INTO _cod_tipotran, _transaccion, _cerrar_rec
			  FROM rectrmae
			 WHERE no_reclamo = _no_reclamo
			   AND actualizado = 1
			   AND (cod_tipotran = '011' OR cerrar_rec = 1)
			 order by no_tranrec DESC
			EXIT FOREACH;
		END  FOREACH

		if _cerrar_rec = 1 then
			let _cod_tipotran = "011";
		end if

		RETURN _no_tramite, _incidente, _numrecla, _estatus_reclamo, _transaccion, _cod_tipotran;

	END FOREACH
ELSE
	RETURN "", a_incidente, "", "C",	"NOEXISTE", "011";
END IF
END PROCEDURE