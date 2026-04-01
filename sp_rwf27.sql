-- Consulta de Cobertura de una Transaccion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf27;

CREATE PROCEDURE sp_rwf27(a_no_reclamo CHAR(10) default "%")
RETURNING char(5),
      	  varchar(50),
		  varchar(20),
          varchar(20),
          varchar(20);

define _no_tranrec          char(10);
define v_cod_cobertura		char(5);
define v_desc_cobertura		varchar(50);
define v_monto       	    dec(16,2);
define v_variacion			dec(16,2);
define v_monto_tot     	    dec(16,2);

--set debug file to "sp_rwf02.trc";

create temp table tmp_reclamo(
	cod_cobertura   char(5),
	monto           dec(16,2),
	variacion       dec(16,2)
	) with no log;


SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT no_tranrec
	  INTO _no_tranrec
	  FROM rectrmae
	 WHERE no_reclamo = a_no_reclamo
	   AND actualizado = 1
	   AND cod_tipotran = "004"

	FOREACH
		SELECT cod_cobertura,
		       monto,
			   variacion
		  INTO v_cod_cobertura,
			   v_monto,       	
			   v_variacion			
		  FROM rectrcob 		  
		 WHERE no_tranrec = _no_tranrec

		insert into tmp_reclamo
		values(
		v_cod_cobertura,
		v_monto,
		v_variacion
		);

	END FOREACH
END FOREACH

LET v_monto_tot	= 0;

FOREACH
	SELECT cod_cobertura,
	       SUM(monto),
		   SUM(variacion)
	  INTO v_cod_cobertura,
		   v_monto,       	
		   v_variacion			
	  FROM tmp_reclamo 
	 GROUP BY 1 		  

    LET v_monto_tot	= v_monto_tot +	v_monto;

	SELECT nombre
	  INTO v_desc_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = v_cod_cobertura;

	RETURN v_cod_cobertura, 
	       v_desc_cobertura,
		   v_monto, 
		   v_variacion,
		   v_monto_tot      	
	 	   WITH RESUME;
END FOREACH
	
drop table tmp_reclamo;

END PROCEDURE;