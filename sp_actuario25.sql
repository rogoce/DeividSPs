-- Procedimiento que carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_actuario25;

create procedure "informix".sp_actuario25(a_periodo char(7))
returning smallint;


define _emi_periodo		char(7);
define _cob_periodo		char(7);

define _per_ini_aa		char(7);
define _per_fin_aa		char(7);
define _per_ini_ap		char(7);
define _per_fin_ap		char(7);
define _per_fin_dic		char(7);
define _ano				integer;
define _mes_evaluar		smallint;
define _ano_evaluar		smallint;
define _fecha_cierre	date;
define _fecha_evaluar	date;

define _mes_pnd			smallint;
define _ano_pnd			smallint;
define _periodo_pnd1	char(7);
define _periodo_pnd2	char(7);
define _periodo_reno	char(7);

define _fecha_ini_ap	date;
define _fecha_fin_ap	date;
define _fecha_ini_aa	date;
define _fecha_fin_aa	date;

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_reclamo		char(10);
define _no_requis		char(10);
define _monto			dec(16,2);
define _pos_ramo		smallint;
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cod_tipoprod	char(3);
define _porc_coaseguro	dec(16,4);
define _cod_coasegur	char(3);
define _cod_cliente		char(10);

define _pri_cob_ap		dec(16,2);
define _pri_cob_aa		dec(16,2);
define _pri_dev_ap		dec(16,2);
define _pri_dev_aa		dec(16,2);
define _pri_sus_ap		dec(16,2);
define _pri_sus_aa		dec(16,2);
define _pri_sus_map		dec(16,2);
define _pri_sus_maa		dec(16,2);

define _pri_sus_ap_mes	dec(16,2);
define _pri_sus_map_mes	dec(16,2);
define _pri_cob_ap_mes	dec(16,2);

define _vigen_ini		date;
define _vigen_fin		date;
define _fecha_pago		date;
define _fecha_dic_ap	date;
define _fecha_hoy		date;
define _factor_vig		dec(16,2);
define _dias1			integer;
define _dias2			integer;

define _nueva_renov		char(1);
define _cant_nueva		smallint;
define _cant_renov		smallint;

define _no_pol_ren_ap	integer;
define _no_pol_nue_ap	integer;
define _no_pol_tot_ap	integer;
define _no_pol_ren_aa	integer;
define _no_pol_nue_aa	integer;
define _no_pol_tot_aa	integer;

define _no_pol_ren_ap_per	integer;
define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;

define _ano_ant			integer;
define _vigencia_ant	date;
define _vigencia_act	date;

define _com_pag_ap		dec(16,2);
define _com_pag_aa		dec(16,2);
define _monto_che		dec(16,2);
define _tipo_agente		char(1);
define _cod_agente		char(5);
define _no_remesa		char(10);
define _renglon			smallint;
define _porc_partic_agt dec(5,2);
define _porc_comis_agt	dec(5,2);
define _user_added		char(8);

define _sin_ocu_ap		integer;
define _sin_ocu_aa		integer;
define _sin_pag_ap		dec(16,2);
define _sin_pag_aa		dec(16,2);
define _sin_pen_ap		dec(16,2);
define _sin_pen_aa		dec(16,2);
define _sin_pen_dic		dec(16,2);
define _sin_pen_12avos	dec(16,2);

define _nombre_agente	char(50);
define _cod_agencia		char(3);
define _centro_costo	char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _estatus_poliza	smallint;
define _nombre_ramo		char(50);
define _nombre_agencia	char(50);
define _nombre_promot	char(50);
define v_grupo          char(7);
define v_no_unidad		char(5);
define _cod_producto	char(5);
define _filtros			char(255);
define v_no_poliza      char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _colectivo       char(1);
define _cantidad        integer;

--set debug file to "sp_bo043.trc";
--trace on;

set isolation to dirty read;

begin

-- Definiciones Iniciales

create temp table tmp_multi(
no_documento		char(20),
pri_dev_aa			dec(16,2) 	default 0
) with no log;


--let _per_fin_aa	= '2014-10';
let _per_fin_aa = a_periodo;


let _ano          = _per_fin_aa[1,4]; --2014
let _per_ini_aa   = _ano || "-01";	  --2014-01

let _fecha_ini_aa = MDY(1, 1, _ano);
let _fecha_fin_aa = sp_sis36(_per_fin_aa);

let _mes_evaluar  = _per_fin_aa[6,7];

let _fecha_hoy    = sp_sis36(_per_fin_aa); --30/09/2014

if _fecha_hoy > today then
	let _fecha_hoy = today;
end if

-- Año Pasado

let _ano = _ano - 1; --2013

let _per_fin_ap   = _ano || _per_fin_aa[5,7];  --2013-09
let _per_ini_ap   = _ano || "-01";			   --2013-01

let _fecha_dic_ap = MDY(12, 31, _ano);
let _per_fin_dic  = _ano || "-12";

let _fecha_ini_ap = MDY(1, 1, _ano);
let _fecha_fin_ap = sp_sis36(_per_fin_ap);	 --30/09/2013


let _fecha_evaluar = sp_bo078(_per_fin_aa, _per_fin_ap);  --30/09/2013



-- Primas Devengadas (Primas Suscritas Devengadas PND)

--{
let _ano_evaluar = _per_fin_aa[1,4];

for _mes_pnd = _mes_evaluar to 1 step -1

	if _mes_pnd = 12 then

		let _periodo_pnd1 = _ano_evaluar || "-01";

	else
		
		if _mes_pnd < 10 then
			let _periodo_pnd1 = _ano_evaluar - 1 || "-0" || _mes_pnd + 1;
		else
			let _periodo_pnd1 = _ano_evaluar - 1 || "-" || _mes_pnd + 1;
		end if

	end if

	if _mes_pnd < 10 then
		let _periodo_pnd2 = _ano_evaluar || "-0" || _mes_pnd;
	else
		let _periodo_pnd2 = _ano_evaluar || "-" || _mes_pnd;
	end if

	foreach
	 select no_documento,
	        sum(prima_suscrita)
	   into _no_documento,
	        _pri_dev_aa
	   from endedmae
	  where periodo           >= _periodo_pnd1
	    and periodo           <= _periodo_pnd2
		and actualizado       = 1
		and no_documento[1,2] in('02','23')
	  group by 1

		let _pri_dev_aa = _pri_dev_aa / 12;

		insert into tmp_multi(no_documento, pri_dev_aa)
		values (_no_documento, _pri_dev_aa);

	end foreach

end for
return 0;
end

end procedure
