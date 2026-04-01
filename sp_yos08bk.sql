-- Procedimiento para generacion de Orden de Compra y de Reparacion
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.
-- creado: 10/05/2019 - Federico Coronado. es una copia del sp_rwf43 para el tema de las ordenes de reparacion que se estaba multiplicando la cantidad por el monto.

DROP PROCEDURE sp_yos08bk;
CREATE PROCEDURE "informix".sp_yos08bk(a_no_tranrec CHAR(10), a_tipo_orden CHAR(1), a_deducible DEC(16,2) DEFAULT 0.00, a_monto DEC(16,2) DEFAULT 0.00, a_cotizacion VARCHAR(10) DEFAULT NULL, _no_orden char(10)) 
			RETURNING SMALLINT, CHAR(50);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _transaccion			CHAR(10);
DEFINE _cod_cliente			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _user_added			CHAR(8);
--DEFINE _no_orden			CHAR(10);
DEFINE _ajust_interno	    CHAR(3);
DEFINE _cod_compania	    CHAR(3);
DEFINE _no_parte    	    CHAR(5);
DEFINE _wf_inc_auto         INTEGER;
DEFINE _desc_orden			VARCHAR(50);
DEFINE _cantidad			INTEGER;
DEFINE _valor				DEC(16,2);
DEFINE _nombre_cliente      VARCHAR(100);
DEFINE _numrecla            CHAR(18);
DEFINE _no_tramite          CHAR(10);

DEFINE _error, _renglon		SMALLINT;
DEFINE _desc_nota           VARCHAR(250);
DEFINE _hoy                 DATETIME YEAR TO FRACTION (5);
define _fecha               date;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;
--begin work;

IF a_tipo_orden = "C" THEN
	LET a_deducible = 0.00;
END IF

 SELECT no_reclamo,
        cod_compania,
		transaccion,
		cod_cliente,
		monto,
		user_added,
		wf_inc_auto,
		fecha
   INTO _no_reclamo,
        _cod_compania,
		_transaccion,
		_cod_cliente,
		_monto,
		_user_added,
		_wf_inc_auto,
		_fecha
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;
-- let _transaccion = "ultimus";
/* 
	LET _no_orden = sp_sis72(_cod_compania);
--    LET _no_requis_n = "ultimus";
	IF _no_orden IS NULL OR _no_orden = "" OR _no_orden = "00000" THEN
    	RETURN 1, "Error al generar # de orden, verifique...";
	END IF	
*/
 SELECT ajust_interno, numrecla, no_tramite
   INTO _ajust_interno, _numrecla, _no_tramite
   FROM recrcmae
  WHERE no_reclamo = _no_reclamo;

 BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al insertar RECORDMA";         
	END EXCEPTION 
	INSERT INTO recordma(
	no_orden,
	no_reclamo,
	cod_ajustador,
	cod_proveedor,
	fecha_orden,
	tipo_ord_comp,
	actualizado,
	monto,
	transaccion,
	user_added,
	no_tranrec,
	deducible,
	no_cotizacion,
	numrecla,
	no_tramite,
	trans_pend
	)
	VALUES(
	_no_orden,
	_no_reclamo,
	_ajust_interno,
	_cod_cliente,
	_fecha,
	a_tipo_orden,
	1,
	a_monto,
	_transaccion,
	_user_added,
	a_no_tranrec,
	a_deducible,
	a_cotizacion,
	_numrecla,
	_no_tramite,
	_transaccion
	);
 END

 LET _renglon = 1;

IF a_tipo_orden = "C" THEN
	FOREACH
		SELECT no_parte,
		       wf_pieza,
			   cantidad,
			   wf_monto
		  INTO _no_parte,
		       _desc_orden,
			   _cantidad,
			   _valor
		  FROM wf_ordcomp
		 WHERE wf_incidente = _wf_inc_auto
		   AND wf_proveedor = _cod_cliente
		   AND tipo_orden = a_tipo_orden

		BEGIN
			ON EXCEPTION SET _error 
			 	RETURN _error, "Error al insertar RECORDDE";         
			END EXCEPTION 
			INSERT INTO recordde(
			no_orden,
			renglon,
			no_parte,
			desc_orden,
			cantidad,
			valor
			) 
			VALUES(
			_no_orden,
			_renglon,
			_no_parte,
			_desc_orden,
			_cantidad,
			_valor
			);
	    END

		LET _renglon = _renglon + 1;
 	END FOREACH
ELSE
	FOREACH
		SELECT no_parte,
		       wf_pieza,
			   cantidad,
			   wf_monto
		  INTO _no_parte,
		       _desc_orden,
			   _cantidad,
			   _valor
		  FROM wf_ordcomp
		 WHERE wf_incidente = _wf_inc_auto
		   AND wf_proveedor = _cod_cliente
		   AND tipo_orden = a_tipo_orden

		BEGIN
			ON EXCEPTION SET _error 
			 	RETURN _error, "Error al insertar RECORDDE";         
			END EXCEPTION 
			INSERT INTO recordde(
			no_orden,
			renglon,
			no_parte,
			desc_orden,
			cantidad,
			valor
			) 
			VALUES(
			_no_orden,
			_renglon,
			_no_parte,
			_desc_orden,
			_cantidad,
			_valor
			);
	    END

		LET _renglon = _renglon + 1;
 	END FOREACH
END IF
/*
SELECT nombre
  INTO _nombre_cliente
  FROM cliclien
 WHERE cod_cliente = _cod_cliente;

IF a_tipo_orden = "C" THEN
	LET _desc_nota = "Orden de Compra emitida # " || trim(_no_orden) || " para el proveedor " || trim(_nombre_cliente) || ", transaccion # " || _transaccion;
ELSE
	LET _desc_nota = "Orden de Reparacion emitida # " || trim(_no_orden) || " para el taller " || trim(_nombre_cliente) || ", transaccion # " || _transaccion;
END IF

 BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al insertar RECNOTAS";         
	END EXCEPTION 
	INSERT INTO recnotas(
	no_reclamo,
	fecha_nota,
	desc_nota,
	user_added
	) 
	VALUES(
	_no_reclamo,
	a_hoy,
    _desc_nota,
	_user_added
	);
 END
*/

--commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE