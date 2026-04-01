-- Consulta de Cobertura de una Transaccion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf25;

CREATE PROCEDURE sp_rwf25(a_no_tranrec CHAR(10) default "%")
RETURNING char(5),
      	  varchar(50),
		  varchar(20),
          varchar(20),
          varchar(20),
          varchar(20),
          varchar(20),
          varchar(20),
          varchar(20),
		  varchar(20),
		  varchar(20),
		  char(3),
		  varchar(20),
		  char(3),
		  varchar(20),
		  varchar(20);

define v_cod_cobertura		char(5);
define v_desc_cobertura		varchar(50);
define v_monto       	    dec(16,2);
define v_variacion			dec(16,2);
define v_monto_tot     	    dec(16,2);
define v_variacion_tot     	dec(16,2);
define v_facturado       	dec(16,2);
define v_facturado_tot     	dec(16,2);
define v_elegible			dec(16,2);
define v_a_deducible		dec(16,2);
define v_co_pago			dec(16,2);
define v_cod_no_cubierto	char(3);
define v_monto_no_cubierto	dec(16,2);
define v_cod_tipo			char(3);
define v_coaseguro			dec(16,2);
define v_ahorro				dec(16,2);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

LET v_monto_tot	= 0;
LET v_variacion_tot	= 0;
LET v_facturado_tot	= 0;

FOREACH
	SELECT cod_cobertura,
	       monto,
		   variacion,
		   facturado,
		   elegible,
		   a_deducible,
		   co_pago,
		   cod_no_cubierto,
		   monto_no_cubierto,
		   cod_tipo,
		   coaseguro,
		   ahorro
	  INTO v_cod_cobertura,
		   v_monto,       	
		   v_variacion,
		   v_facturado,
		   v_elegible,
		   v_a_deducible,
		   v_co_pago,
		   v_cod_no_cubierto,
		   v_monto_no_cubierto,
		   v_cod_tipo,
		   v_coaseguro,
		   v_ahorro			
	  FROM rectrcob 		  
	 WHERE no_tranrec = a_no_tranrec

    LET v_variacion_tot	= v_variacion_tot +	v_variacion;
    LET v_monto_tot	= v_monto_tot +	v_monto;
    LET v_facturado_tot	= v_facturado_tot +	v_facturado;

	SELECT nombre
	  INTO v_desc_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = v_cod_cobertura;

	RETURN v_cod_cobertura, 
	       v_desc_cobertura,
		   v_monto, 
		   v_variacion,
		   v_monto_tot,
		   v_variacion_tot,
		   v_facturado,
		   v_facturado_tot,
		   v_elegible,
		   v_a_deducible,
		   v_co_pago,
		   v_cod_no_cubierto,
		   v_monto_no_cubierto,
		   v_cod_tipo,
		   v_coaseguro,     	
	 	   v_ahorro			
	 	   WITH RESUME;

END FOREACH


	


END PROCEDURE;