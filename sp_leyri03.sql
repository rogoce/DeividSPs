
DROP PROCEDURE sp_leyri03;

CREATE PROCEDURE "informix".sp_leyri03(
) RETURNING CHAR(20),  -- Poliza
			char(18),  -- Vigencia Inicial
			DEC(16,2);

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);
define v_nombre_perpago	   char(50);
DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE _gestion            CHAR(1); 
DEFINE v_forma_pago        CHAR(4);
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_fecha_ult_pago    DATE;
DEFINE v_monto_ult_pago    DEC(16,2);
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_telefono,v_codigo,_no_poliza CHAR(10);
DEFINE v_nombre_vendedor   CHAR(50);
DEFINE v_cod_agente		   CHAR(5);	
DEFINE v_compania_nombre, v_nombre_prod,v_desc   CHAR(50);
DEFINE v_fecha_cancelacion DATE;
DEFINE _cod_vendedor,v_saber CHAR(3);
DEFINE _apartado           	 CHAR(20);
define _estado             char(10);
define _n_acreedor,_n_motivo_noren  varchar(50);
define _cod_ramo        char(3);
define _no_pagos        smallint;
define _cod_perpago,_cod_no_renov     char(3);
define v_nombre_ramo   char(50);
define _cod_acreedor   char(5);
define v_estatus       smallint;
define _poliza char(20);
define _cnt    integer;
define _numrecla char(18);

--SET DEBUG FILE TO "sp_cob03a.trc";
--trace on;

--DROP TABLE tmp_moros;

-- Nombre de la Compania

let v_prima_bruta = 0;

SET ISOLATION TO DIRTY READ;

call sp_rec01('001', '001', '2010-01', '2010-06') returning v_filtros;

foreach

 select poliza
   into _poliza
   from a

 select count(*)
   into _cnt
   from tmp_sinis
  where doc_poliza = _poliza;

 if _cnt > 0 then

	foreach
	 select pagado_bruto,
			numrecla
	   into v_prima_bruta,
	        _numrecla
	   from tmp_sinis
	  where doc_poliza = _poliza

		   return
		   _poliza,
		   _numrecla,
		   v_prima_bruta
		   WITH RESUME;
    end foreach
 end if

END FOREACH
					 
drop table tmp_sinis;

END PROCEDURE;

