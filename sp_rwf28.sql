-- Consulta de Pagos de una Transaccion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

-- DROP PROCEDURE sp_rwf28;

CREATE PROCEDURE sp_rwf28(a_no_reclamo CHAR(10) default "%")
RETURNING char(3),
      	  varchar(50),
          varchar(20),
          varchar(20);

define _no_tranrec          char(10);
define v_cod_concepto		char(3);
define v_desc_concepto		varchar(50);
define v_monto       	    dec(16,2);
define v_monto_tot     	    dec(16,2);


--set debug file to "sp_rwf02.trc";
--drop table tmp_reclamo;

create temp table tmp_reclamo(
	cod_concepto    char(3),
	monto           dec(16,2)
	) with no log;


SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT no_tranrec
	  INTO _no_tranrec
	  FROM rectrmae
	 WHERE no_reclamo = a_no_reclamo
	   AND actualizado = 1

	FOREACH
		SELECT cod_concepto,
		       monto
		  INTO v_cod_concepto,
			   v_monto       	
		  FROM rectrcon 		  
		 WHERE no_tranrec = _no_tranrec

		insert into tmp_reclamo
		values(
		v_cod_concepto,
		v_monto
		);
	END FOREACH

END FOREACH

LET v_monto_tot	= 0;

FOREACH
	SELECT cod_concepto,
	       SUM(monto)
	  INTO v_cod_concepto,
		   v_monto       	
	  FROM tmp_reclamo 
	 GROUP BY 1 		  

	SELECT nombre
	  INTO v_desc_concepto
	  FROM recconce
	 WHERE cod_concepto = v_cod_concepto;

    LET v_monto_tot	= v_monto_tot +	v_monto;

	RETURN v_cod_concepto, 
	       v_desc_concepto,
		   v_monto,
		   v_monto_tot 
	 	   WITH RESUME;
END FOREACH

drop table tmp_reclamo;

END PROCEDURE;