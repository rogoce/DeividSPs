-- Informe de Reclamos por Ramo
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec734a;

CREATE PROCEDURE "informix".sp_rec734a(
a_compania 	char(3), 
a_fecha1 	date, 
a_fecha2 	date, 
a_ramo 		char(255) default '*', 
a_concepto 	char(255) default '*') 
RETURNING CHAR(18),CHAR(20),CHAR(100),CHAR(100),DEC(16,2),VARCHAR(50),VARCHAR(50),VARCHAR(50),VARCHAR(255),VARCHAR(50),DEC(16,2); 

DEFINE v_filtros         		VARCHAR(255);

DEFINE v_numrecla        		CHAR(18);
DEFINE v_no_poliza       		CHAR(20);
DEFINE v_asegurado       		CHAR(100);
DEFINE v_proveedor              CHAR(100);
DEFINE v_ramo_nombre     		VARCHAR(50);
DEFINE v_concepto_nombre        VARCHAR(50);
DEFINE v_cobertura_nombre       VARCHAR(50);
DEFINE v_compania_nombre 		VARCHAR(50);
DEFINE v_monto                  dec(16,2);

DEFINE _cod_ramo,_cod_concepto  CHAR(3);
define _cod_cobertura   		char(5);
define _no_reclamo              CHAR(10);
DEFINE _pago_asegurado          DEC(16,2);
DEFINE v_pago_asegurado_tot     DEC(16,2);
DEFINE _cod_concepto_tr         CHAR(3);
DEFINE _no_tranrec              CHAR(10);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec734(
a_compania, 
a_fecha1, 
a_fecha2,
a_ramo,
a_concepto
);

FOREACH 
 SELECT no_reclamo,
        cod_concepto,
		cod_cobertura,
		numrecla,
		no_poliza,
		asegurado,
		a_nombre_de,
		monto,
		cod_ramo
   INTO _no_reclamo,
        _cod_concepto,
        _cod_cobertura,
		v_numrecla,
		v_no_poliza,
		v_asegurado,
		v_proveedor,
		v_monto,
		_cod_ramo
   FROM tmp_pagos
  WHERE seleccionado = 1
  ORDER BY cod_ramo, cod_concepto, cod_cobertura, numrecla
    
	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo 
	 WHERE cod_ramo = _cod_ramo;
	 
	SELECT nombre
	  INTO v_concepto_nombre
	  FROM recconce 
	 WHERE cod_concepto = _cod_concepto;

	SELECT nombre
	  INTO v_cobertura_nombre
	  FROM prdcober 
	 WHERE cod_cobertura = _cod_cobertura;
	 
	LET v_pago_asegurado_tot = 0.00;
	LET _pago_asegurado = 0.00;
	 
	FOREACH 
		SELECT no_tranrec
		  INTO _no_tranrec
		  FROM rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado  = 1
		   and cod_tipotran = "004"
		 
        FOREACH		 
			SELECT monto,
				   cod_concepto
			  INTO _pago_asegurado,
				   _cod_concepto_tr
			  FROM rectrcon
			 WHERE no_tranrec = _no_tranrec
			 
			IF  _cod_concepto_tr = '015' THEN
				LET v_pago_asegurado_tot = v_pago_asegurado_tot + _pago_asegurado;
			END IF
        END FOREACH	
    END FOREACH		
	 
	RETURN v_numrecla,        
		   v_no_poliza,       
		   v_asegurado,  
		   v_proveedor,
           v_monto,		   
		   v_ramo_nombre,
		   v_concepto_nombre,
		   v_compania_nombre,
		   v_filtros,
		   v_cobertura_nombre,
		   v_pago_asegurado_tot
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_pagos;
                                                     
END PROCEDURE;




