-- Extraer datos del rutero para insertar en tablas para los (cobros moviles).
-- 
-- Creado    : 09/09/2005 - Autor: Armando Moreno M.
-- Modificado: 13/09/2005 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_act_cobreaco;

CREATE PROCEDURE "informix".sp_act_cobreaco()
Returning integer,char(50);

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
define _porc_proporcion		 DEC(9,6);
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
DEFINE _cod_cliente      CHAR(10);
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
DEFINE _direccion_cob    CHAR(100);
define _nombre_grupo	 CHAR(40);
DEFINE _cod_grupo		 CHAR(5);
DEFINE _cod_grupocl	 	 CHAR(5);
DEFINE _tipo_pol		 CHAR(2);
DEFINE _modo			 CHAR(1);
DEFINE _m_visita		 CHAR(8);
define _cobrar_sn		 CHAR(1);
DEFINE _fecha_ult_dia    DATE;
DEFINE _fecha		     DATE;
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;
DEFINE _fecha_registro   datetime year to fraction(5);
DEFINE _tipo_labor       smallint;
DEFINE _dia_cobros1		 smallint;
DEFINE _dia_cobros2		 smallint;
define _orden_2			 smallint;
DEFINE _dia				 INTEGER;
DEFINE _cant			 INTEGER;
define _error   		 integer;
define _fecha_time       datetime year to fraction(5);
define _nombre_usuario   varchar(50);
define _alias			 varchar(50);
define _usuario			 varchar(10);
define _cod_agente		 CHAR(5);
define _corr_cedula		 varchar(30);
define _tipo_cte		 integer;
DEFINE v_corredor		 CHAR(50);
DEFINE v_direccion1		 CHAR(50);
DEFINE v_direccion2		 CHAR(50);
DEFINE v_telefono1,v_telefono2   CHAR(10);
define _id				 integer;
define _abrev			 char(1);
define _tipo_pag		 char(50);
define _id_turno         integer;
define _id_transaccion   integer;
define _secuencia		 integer;
define _existe			 integer;
define _existe2			 integer;
define _contacto		 CHAR(50);
define _mensaje          CHAR(50);
define _no_remesa        char(10);
define _renglon          integer;
define _cnt_cobreaco	smallint;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob165.trc"; 
--trace on;

let _mensaje = "";

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,_mensaje;         
END EXCEPTION



let v_saldo      = 0;
let v_corriente  = 0;
let v_monto_30   = 0;
let v_monto_60   = 0;
let	v_monto_90	 = 0;
let v_monto_120  = 0;
let v_por_vencer = 0;
let	v_exigible 	 = 0;

foreach

select c.no_remesa,
	   c.renglon,
	   sum(c.porc_proporcion),
	   count(*)
  into _no_remesa,
	   _renglon,
	   _porc_proporcion,
	   _cnt_cobreaco
  from cobreaco c, cobredet d
 where c.no_remesa = d.no_remesa
   and c.renglon = d.renglon
   and d.periodo >= '2014-01'
   and d.periodo <= '2014-03'
 group by 1,2
 having count(*) = 1
 and sum(porc_proporcion) < 100



 update cobreaco
    set porc_proporcion = 100
  where no_remesa       = _no_remesa
    and renglon         = _renglon;
    --and cod_cober_reas  = '002';

end foreach

return 0, "Actualizacion Exitosa";

end

end procedure