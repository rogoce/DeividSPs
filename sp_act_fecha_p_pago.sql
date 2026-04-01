-- Extraer datos del rutero para insertar en tablas para los (cobros moviles).
-- 
-- Creado    : 09/09/2005 - Autor: Armando Moreno M.
-- Modificado: 13/09/2005 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_act_fecha_p_pago;
CREATE PROCEDURE sp_act_fecha_p_pago()
Returning char(10),char(20),date,date,date;


DEFINE v_saldo     		 DEC(16,2);
DEFINE v_a_pagar	 	 DEC(16,2);
DEFINE v_por_vencer	 	 DEC(16,2);
DEFINE v_exigible	 	 DEC(16,2);
DEFINE v_corriente	 	 DEC(16,2);
DEFINE v_monto_30	 	 DEC(16,2);
DEFINE v_monto_60	 	 DEC(16,2);
DEFINE v_monto_90	 	 DEC(16,2);
DEFINE v_monto_120		 DEC(16,2);
DEFINE v_saldo1			 DEC(16,2);
define _prima_orig		 DEC(16,2);
DEFINE _poliza		     CHAR(20);
DEFINE _cod_motiv	     CHAR(3);
DEFINE _area		     CHAR(5);
DEFINE _cedula		     CHAR(25);
DEFINE _un_blank	     CHAR(1);
DEFINE _relacion	     CHAR(10);
DEFINE _orden_visita     CHAR(3);
DEFINE _campo		     CHAR(349);
DEFINE _campo2		     CHAR(349);
DEFINE v_documento  	 CHAR(20);
DEFINE _descripcion		 CHAR(100);
DEFINE _cod_ramo		 CHAR(3);
DEFINE _cod_banco	     CHAR(3);
DEFINE _no_poliza      CHAR(10);
DEFINE v_no_poliza       CHAR(10);
DEFINE _cod_cobrador	 CHAR(3);
DEFINE _code_pais		 CHAR(3);
DEFINE v_ciudad          CHAR(30);
DEFINE _code_provincia 	 CHAR(2);
DEFINE _code_ciudad		 CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_correg	     CHAR(5);
DEFINE _mes_char         CHAR(2);
DEFINE _letra	         CHAR(4);
DEFINE _signo	         CHAR(1);
DEFINE _imp		         CHAR(1);
DEFINE _ano_char		 CHAR(4);
DEFINE _periodo          CHAR(7);
DEFINE _cod_pagador		 CHAR(10);
define _tel_pag1		 CHAR(10);
define _tel_pag2		 CHAR(10);
define _tel_grupo		 CHAR(10);
DEFINE _nombre_pagador	 CHAR(100);
define _nombre			 CHAR(100);
DEFINE _vigencia_inic    DATE;
define _mensaje          CHAR(50);
define _fecha_1_pago,_fecha_p_p date;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob165.trc"; 
--trace on;

let _mensaje = "";

BEGIN

foreach
	select no_poliza,
		   fecha_primer_pago,
		   vigencia_inic,
		   no_documento
	  into _no_poliza,
		   _fecha_p_p,
		   _vigencia_inic,
		   v_documento
	  from emipomae
	 where actualizado = 1
	   and estatus_poliza = 1
	   and cod_grupo in(
	select cod_grupo from cligrupo
	 where cod_grupo in ('00068','77978','77974','77980','77973','77979'))
	 
 	let _fecha_1_pago = _vigencia_inic + 30 units day;

	 update emipomae
		set fecha_primer_pago = _fecha_1_pago
	  where no_poliza = _no_poliza;

    return _no_poliza,v_documento,_fecha_p_p,_vigencia_inic,_fecha_1_pago with resume;
end foreach

end

end procedure