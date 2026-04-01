-- Procedimiento para generacion de Orden de Compra y de Reparacion
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf43arrg;
CREATE PROCEDURE "informix".sp_rwf43arrg(a_no_orden CHAR(10)) 
			RETURNING SMALLINT, CHAR(50);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _transaccion			CHAR(10);
DEFINE _cod_cliente			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _user_added			CHAR(8);
DEFINE _no_orden			CHAR(10);
DEFINE _ajust_interno	    CHAR(3);
DEFINE _cod_compania	    CHAR(3);
DEFINE _no_parte    	    CHAR(3);
DEFINE _wf_inc_auto         INTEGER;
DEFINE _desc_orden			VARCHAR(50);
DEFINE _cantidad			INTEGER;
DEFINE _valor				DEC(16,2);
DEFINE a_no_tranrec			CHAR(10);

DEFINE _error, _renglon		SMALLINT;


--SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

begin work;
 SELECT no_tranrec
   INTO a_no_tranrec
   FROM recordma
  WHERE no_orden = a_no_orden;

 SELECT no_reclamo,
        cod_compania,
		transaccion,
		cod_cliente,
		monto,
		user_added,
		wf_inc_auto
   INTO _no_reclamo,
        _cod_compania,
		_transaccion,
		_cod_cliente,
		_monto,
		_user_added,
		_wf_inc_auto
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

 LET _renglon = 1;

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

	BEGIN
		ON EXCEPTION SET _error 
			rollback work;
		 	RETURN _error, "Error al actualizar RECORDDE";         
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
		a_no_orden,
		_renglon,
		_no_parte,
		_desc_orden,
		_cantidad,
		_valor
		);
    END

	LET _renglon = _renglon + 1;
 END FOREACH

commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa";
END PROCEDURE