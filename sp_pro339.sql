-- Carta para corredores concurso Paris 2010

-- Creado    : 01/03/2010 - Autor: Armando Moreno					
-- Modificado: 01/03/2010 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro339;

CREATE PROCEDURE sp_pro339()
RETURNING char(50),DEC(16,2),char(15),DEC(16,2),date,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);

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
define _prima_sus_pag   DEC(16,2);
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
define _valor		    DEC(16,2);
define _pri_pag_aa      DEC(16,2);

define _ano				smallint;
define _ano_ant			smallint;

define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _tipo_persona	char(1);
define _nombre_tipo		char(15);
define _concurso		smallint;
define _periodo         char(7);
define _fecha_ult_dia   date;
define _mes             integer;
define _crecimiento     DEC(16,2);
define _creci_f         DEC(16,2);
define _crec_pol        DEC(16,2);
define _creci_pol_f     DEC(16,2);
define _renovaa         integer;
define _renovap         integer;
define _persistencia    DEC(16,2);
define _persis_f		DEC(16,2);

--SET DEBUG FILE TO "sp_pro339.trc";
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
let _periodo        = '';
let _pri_pag_aa		= 0;
let	_pri_pag_ap		= 0;


SET ISOLATION TO DIRTY READ;

select par_periodo_act
  into _periodo
  from parparam;

let _mes = _periodo[6,7];
let _mes = _mes - 1;
let _periodo = _periodo[1,5] || "0" || _mes;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

foreach

	select n_agente,
		   sum(pri_sus_pag_aa),
		   sum(pri_pag_aa),
		   sum(pri_pag_ap),
		   sum(sini_inc),
		   sum(vigenteaa),
		   sum(vigenteap),
		   sum(renovaa),
		   sum(renovap),
		   tipo_agente
	  into _nombre,
		   _pri_pag,
		   _pri_pag_aa,
		   _pri_pag_ap,
		   _sini_incu,
		   _no_pol_nue_aa,
		   _no_pol_nue_ap,
		   _renovaa,
		   _renovap,
		   _nombre_tipo
	  from milan08
	 where cod_agente = '00141'
	 group by tipo_agente,n_agente
	 order by tipo_agente,n_agente

	if _nombre_tipo = "INDIVIDUALES" then
		let _valor = 100000;
	else
		let _nombre_tipo = "BROKERS";
		let _valor = 150000;
	end if

	let _dif = _valor - _pri_pag;

	if _dif < 0 then
		let _dif = 0;
	end if

	--CRECIMIENTO EN PRIMA COBRADA
	let _crecimiento = ((_pri_pag_aa - _pri_pag_ap) / _pri_pag_ap) * 100;
	let _creci_f     = 35 - _crecimiento;
	if _creci_f < 0 then
		let _creci_f = 0;
	end if

	--CRECIMIENTO EN CANTIDAD DE POLIZAS
	let _crec_pol    = ((_no_pol_nue_aa - _no_pol_nue_ap) / _no_pol_nue_ap) * 100;
	let _creci_pol_f = 20 - _crec_pol;
	if _creci_pol_f < 0 then
		let _creci_pol_f = 0;
	end if

	--PERSISTENCIA:	Cantidad renovadas este anno / total polizas annp pasado * 100

	let _persistencia = (_renovaa / (_no_pol_nue_ap + _renovap)) * 100;
	let _persis_f     = 70 - _persistencia;

	if _persis_f < 0 then
		let _persis_f = 0;
	end if


   RETURN _nombre,
   		  _pri_pag,
   		  _nombre_tipo,
		  _dif,
		  _fecha_ult_dia,
		  _crecimiento,
		  _creci_f,
		  _sini_incu,
		  _crec_pol,
		  _creci_pol_f,
		  _persistencia,
		  _persis_f
          WITH RESUME;

end foreach

END PROCEDURE;