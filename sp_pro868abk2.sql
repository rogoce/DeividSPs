--***********************************************************************************
-- Procedimiento que genera Mini Convencion MIAMI 2019
--***********************************************************************************
-- Creado    : 04/01/2019 - Autor: Armando Moreno M.
-- Creado    : 04/01/2019 - Autor: Armando Moreno M.

--DROP PROCEDURE sp_pro868abk2;
CREATE PROCEDURE sp_pro868abk2(a_compania CHAR(3),a_sucursal CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT;
DEFINE _cnt_traspaso       SMALLINT;
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE _dif		        DEC(16,2);
define _cnt             integer;
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _per_ini 		char(7);
define _per_ini_ap 		char(7);
define _per_fin_ap 		char(7);
define _pri_sus 		DEC(16,2);
define _error           smallint;
define _filtros			char(255);
define _per_fin_dic     char(7);
define _prima_sus_pag,_monto_pen   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _prima_can		DEC(16,2);
define _sin_pag_aa		DEC(16,2);
define _no_reclamo		char(10);
define _sin_pen_dic		DEC(16,2);
define _sin_pen_aa      DEC(16,2);
define _pri_pag         DEC(16,2);
define _pri_can         DEC(16,2);
define _pri_dev         DEC(16,2);
define v_monto_90       DEC(16,2);
define _prima_orig      DEC(16,2);
define _prima_sus_agt   DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini    date;
define _fecha_aa_fin    date;
define _fecha_ap_ini    date;
define _fecha_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;
define _no_pol_nue_ap_per	integer;
define _estatus_poliza	smallint;
define _pri_sus_pag_ap  DEC(16,2);
define _pri_pag_ap      DEC(16,2);
define _pri_can_ap      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _prima_sus_ramo  DEC(16,2);
define _prima_fac       DEC(16,2);
define _ano				smallint;
define _ano_ant			smallint;
define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _tipo_persona	char(1);
define _nombre_tipo		char(20);
define _concurso,_unificar smallint;
define _pagada smallint;
DEFINE _porc_partic_agt    DEC(5,2);
define _meses           smallint;
define _valor           decimal(16,2);
define _cod_perpago     char(3);
define _cod_agente_anterior   char(5);

define _pri_sus_ap          DEC(16,2);
define _flag_1				smallint;
define _flag_2				smallint;
define _flag_3				smallint;
define _flag_4				smallint;
define _flag_5				smallint;

--SET DEBUG FILE TO "sp_pro868a.trc";
--TRACE ON;

let _error          = 0;
let _prima_can      = 0;
let _pri_can        = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_dev        = 0;
let _cnt            = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;
let v_por_vencer    = 0;
let v_exigible	    = 0;
let v_corriente	    = 0;
let v_monto_30	    = 0;
let v_monto_90	    = 0;
let _valor          = 0;
let _dif            = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;
let _porc_partic_agt = 0;
let _prima_fac       = 0;

let _pri_sus_ap      = 0;
let _flag_1          = 0;
let _flag_2          = 0;
let _flag_3          = 0;
let _flag_4          = 0;
let _flag_5          = 0;

let _fecha_aa_ini = "01/02/2019";
let _fecha_aa_fin = "31/05/2019";

let _prima_suscrita  = 0;
let _nombre_tipo     = "";
let _prima_sus_agt   = 0; 

SET ISOLATION TO DIRTY READ;

foreach
	select cod_agente,
 	       sum(prima_sus_nva)
	  into _cod_agente,
	       _pri_sus
	  from punta_cana
	 where cod_ramo in('018','003','019','002')	--OPCION A
	 group by cod_agente
	 order by sum(prima_sus_nva) desc

	if _pri_sus >= 50000 then
		let _nombre_tipo = "Grupo I Opc. A";
	elif (_pri_sus >= 40000 and _pri_sus <= 49999) then
			let _nombre_tipo = "Grupo II Opc. A";
	elif (_pri_sus >= 25000 and _pri_sus <= 39999) then
			let _nombre_tipo = "Grupo III Opc. A";
	elif (_pri_sus >= 20000 and _pri_sus <= 24999) then
			let _nombre_tipo = "Grupo IV Opc. A";
	elif _pri_sus <= 15000 then
			let _nombre_tipo = "Grupo V Opc. A";
	end if

	update punta_cana
	   set tipo_agente2 = _nombre_tipo
	 where cod_agente  = _cod_agente;  
end foreach
foreach
	select cod_agente,
 	       sum(prima_sus_nva)
	  into _cod_agente,
	       _pri_sus
	  from punta_cana
	 where cod_ramo in('018','003','019')	--OPCION B
	 group by cod_agente
	 order by sum(prima_sus_nva) desc

	if _pri_sus >= 15000 then
		let _nombre_tipo = "Grupo I Opc. B";
	elif (_pri_sus >= 12000 and _pri_sus <= 14999) then
			let _nombre_tipo = "Grupo II Opc. B";
	elif (_pri_sus >= 9000 and _pri_sus <= 11999) then
			let _nombre_tipo = "Grupo III Opc. B";
	elif (_pri_sus >= 7000 and _pri_sus <= 8999) then
			let _nombre_tipo = "Grupo IV Opc. B";
	elif _pri_sus <= 5000 then
			let _nombre_tipo = "Grupo V Opc. B";
	end if

	update punta_cana
	   set tipo_agente = _nombre_tipo
	 where cod_agente  = _cod_agente;
end foreach
return 0;

END PROCEDURE;