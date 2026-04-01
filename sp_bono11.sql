-- Procedimiento que carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bono11;		

create procedure "informix".sp_bono11()
returning integer,
		  char(100);

{
returning  char(20),
	       date,
		   date,
		   date,
		   date,
		   dec(16,2),
		   dec(16,2),
		   dec(16,2);

	return _no_documento,
	       _vigen_ini,
		   _vigen_fin,
		   _fecha_pago,
		   _fecha_dic_ap,
		   _monto,
		   _factor_vig,
		   _pri_dev_aa
		   with resume;
}

define _emi_periodo		char(7);
define _cob_periodo		char(7);

define _per_ini_aa			char(7);
define _per_fin_aa			char(7);
define _per_ini_ap			char(7);
define _per_fin_ap			char(7);
define _per_fin_dic		char(7);
define _ano				integer;
define _mes_evaluar		smallint;
define _ano_evaluar		smallint;
define _fecha_cierre		date;
define _fecha_evaluar		date;

define _mes_pnd			smallint;
define _ano_pnd			smallint;
define _periodo_pnd1		char(7);
define _periodo_pnd2		char(7);
define _periodo_reno		char(7);

define _fecha_ini_ap		date;
define _fecha_fin_ap		date;
define _fecha_ini_aa		date;
define _fecha_fin_aa		date;

define _no_documento		char(20);
define _no_poliza			char(10);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _monto				dec(16,2);
define _pos_ramo			smallint;
define _cod_ramo			char(3);
define _cod_subramo		char(3);
define _cod_tipoprod		char(3);
define _porc_coaseguro	dec(16,4);
define _cod_coasegur		char(3);
define _cod_cliente		char(10);
define _fronting			smallint;
define _cod_grupo			char(5);

define _pri_cob_ap			dec(16,2);
define _pri_cob_aa			dec(16,2);
define _pri_cob_map		dec(16,2);
define _pri_cob_maa		dec(16,2);
define _pri_dev_ap			dec(16,2);
define _pri_dev_aa			dec(16,2);
define _pri_sus_ap			dec(16,2);
define _pri_sus_aa			dec(16,2);
define _pri_sus_map		dec(16,2);
define _pri_sus_maa		dec(16,2);

define _pri_sus_ap_mes	dec(16,2);
define _pri_sus_map_mes	dec(16,2);
define _pri_cob_ap_mes	dec(16,2);
define _pri_cob_neto_aa	dec(16,2);

define _vigen_ini			date;
define _vigen_fin			date;
define _fecha_pago			date;
define _fecha_dic_ap		date;
define _fecha_hoy			date;
define _factor_vig			dec(16,2);
define _dias1				integer;
define _dias2				integer;

define _nueva_renov		char(1);
define _cant_nueva			smallint;
define _cant_renov			smallint;

define _no_pol_ren_ap		integer;
define _no_pol_nue_ap		integer;
define _no_pol_tot_ap		integer;
define _no_pol_ren_aa		integer;
define _no_pol_nue_aa		integer;
define _no_pol_tot_aa		integer;

define _no_pol_ren_ap_per	integer;
define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;

define _ano_ant			integer;
define _vigencia_ant		date;
define _vigencia_act		date;

define _com_pag_ap			dec(16,2);
define _com_pag_aa			dec(16,2);
define _monto_che			dec(16,2);
define _tipo_agente		char(1);
define _cod_agente			char(5);
define _no_remesa			char(10);
define _renglon			smallint;
define _porc_partic_agt 	dec(5,2);
define _porc_comis_agt	dec(5,2);
define _user_added			char(8);

define _sin_ocu_ap			integer;
define _sin_ocu_aa			integer;
define _sin_pag_ap			dec(16,2);
define _sin_pag_aa			dec(16,2);
define _sin_pen_ap			dec(16,2);
define _sin_pen_aa			dec(16,2);
define _sin_pen_dic		dec(16,2);
define _sin_pen_12avos	dec(16,2);
define _sin_var_aa			dec(16,2);
define _sin_var_ap			dec(16,2);
define _sin_ocu_ap_tu		integer;
define _sin_ocu_aa_tu		integer;

define _nombre_agente		char(50);
define _cod_agencia		char(3);
define _centro_costo		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor	char(50);
define _estatus_poliza	smallint;
define _nombre_ramo		char(50);
define _nombre_agencia	char(50);
define _nombre_promot		char(50);

define _filtros			char(255);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _numrecla			char(18);
define _ramo	char(2);

--set debug file to "sp_bono11.trc";
--trace on;
--trace "1";

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
--	return _error, _error_isam || " " || _error_desc;
	return _error, _error_desc;
end exception

-- Definiciones Iniciales

delete from deivid_bo:boindmul;

let _pos_ramo = 1;

foreach with hold
	select distinct no_documento[1,2]
	  into _ramo
	  from deivid_bo:t_multi
	begin work;
foreach
 select no_documento,
        sum(pri_cob_ap),
	    sum(pri_cob_aa),
	    sum(pri_dev_aa),
		sum(no_pol_ren_ap),
		sum(no_pol_nue_ap),
		sum(no_pol_tot_ap),
		sum(no_pol_ren_aa),
		sum(no_pol_nue_aa),
		sum(no_pol_tot_aa),
		sum(com_pag_ap),
		sum(com_pag_aa),
		sum(sin_ocu_ap),
		sum(sin_ocu_aa),
		sum(sin_pag_ap),
		sum(sin_pag_aa),
		sum(sin_pen_ap),
		sum(sin_pen_dic),
		sum(sin_pen_aa),
        sum(pri_sus_ap),
	    sum(pri_sus_aa),
		sum(sin_pen_12avos),
        sum(pri_sus_map),
	    sum(pri_sus_maa),
		sum(no_pol_ren_ap_per),
		sum(no_pol_nue_ap_per),
		sum(no_pol_ren_aa_per),
		sum(pri_sus_ap_mes),
		sum(pri_sus_map_mes),
		sum(pri_cob_ap_mes),
		sum(pri_cob_neto_aa),
		sum(sin_var_aa),
		sum(sin_var_ap),
		sum(pri_cob_maa),
		sum(pri_cob_map),
		sum(pri_dev_ap)
   into _no_documento,
        _pri_cob_ap,
	    _pri_cob_aa,
	    _pri_dev_aa,
		_no_pol_ren_ap,
		_no_pol_nue_ap,
		_no_pol_tot_ap,
		_no_pol_ren_aa,
		_no_pol_nue_aa,
		_no_pol_tot_aa,
		_com_pag_ap,
		_com_pag_aa,
		_sin_ocu_ap,
		_sin_ocu_aa,
		_sin_pag_ap,
		_sin_pag_aa,
		_sin_pen_ap,
		_sin_pen_dic,
		_sin_pen_aa,
        _pri_sus_ap,
	    _pri_sus_aa,
		_sin_pen_12avos,
        _pri_sus_map,
	    _pri_sus_maa,
		_no_pol_ren_ap_per,
		_no_pol_nue_ap_per,
		_no_pol_ren_aa_per,
		_pri_sus_ap_mes,
		_pri_sus_map_mes,
		_pri_cob_ap_mes,
		_pri_cob_neto_aa,
		_sin_var_aa,
		_sin_var_ap,
		_pri_cob_maa,
		_pri_cob_map,
		_pri_dev_ap
   from deivid_bo:t_multi
  where no_documento[1,2] = _ramo
  group by no_documento


	let _no_poliza = sp_sis21(_no_documento);

	select cod_ramo,
	       sucursal_origen,
		   cod_subramo,
		   cod_contratante,
		   cod_grupo,
		   fronting
	  into _cod_ramo,
	       _cod_agencia,
		   _cod_subramo,
		   _cod_cliente,
		   _cod_grupo,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_promot
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _pos_ramo = 1; -- Comercializacion
	
	if _fronting = 1 then
		let _pos_ramo = 3; -- Fronting
	elif _cod_grupo = "1000" then
		let _pos_ramo = 4; -- Estado
	elif _cod_ramo = "008" then
		let _pos_ramo = 2; -- Fianzas
	end if

	-- Solo Selecciona un  reclamo de la poliza 
	
	if _sin_ocu_ap <> 0 then
		let _sin_ocu_ap_tu = 1;
	else
		let _sin_ocu_ap_tu = 0;
	end if
	
	if _sin_ocu_aa <> 0 then
		let _sin_ocu_aa_tu = 1;
	else
		let _sin_ocu_aa_tu = 0;
	end if

	-- Validaciones para Persistencia

	if _no_pol_ren_ap_per > 1 then
		let _no_pol_ren_ap_per = 1;
	end if

	if _no_pol_nue_ap_per > 1 then
		let _no_pol_nue_ap_per = 1;
	end if

	if _no_pol_ren_aa_per > 1 then
		let _no_pol_ren_aa_per = 1;
	end if

	if _no_pol_ren_aa_per = 1 and 
	   _no_pol_ren_ap_per = 0 and 
	   _no_pol_nue_ap_per = 0 then
		let _no_pol_ren_ap_per = 1;
	end if

	if _no_pol_ren_ap_per = 1 and 
	   _no_pol_nue_ap_per = 1 then
		let _no_pol_nue_ap_per = 0;
	end if

	-- Año Pasado

	if _no_pol_ren_ap > 1 then
		let _no_pol_ren_ap = 1;
	end if

	if _no_pol_nue_ap > 1 then
		let _no_pol_nue_ap = 1;
	end if

	let _no_pol_tot_ap = _no_pol_ren_ap + _no_pol_nue_ap;

	if _no_pol_tot_ap > 1 then
		let _no_pol_tot_ap = 1;
		let _no_pol_ren_ap = 0;
	end if

	-- Año Actual

	if _no_pol_ren_aa > 1 then
		let _no_pol_ren_aa = 1;
	end if

	if _no_pol_nue_aa > 1 then
		let _no_pol_nue_aa = 1;
	end if

	let _no_pol_tot_aa = _no_pol_ren_aa + _no_pol_nue_aa;

	if _no_pol_tot_aa > 1 then
		let _no_pol_tot_aa = 1;
		let _no_pol_ren_aa = 0;
	end if

	if _no_pol_ren_aa > _no_pol_tot_ap then
		let _no_pol_ren_aa = 0;
		let _no_pol_nue_aa = 1;
	end if		

	-- Informacion Necesaria para las Promotorias

	select sucursal_promotoria,
	       centro_costo
	  into _suc_promotoria,
	       _centro_costo
	  from insagen
	 where codigo_agencia = _cod_agencia;

	select descripcion
	  into _nombre_agencia
	  from insagen
	 where codigo_agencia = _centro_costo;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	  order by porc_partic_agt desc
		exit foreach;
	end foreach

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _suc_promotoria
	   and cod_ramo	   = _cod_ramo;

	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	 let _per_fin_aa = '2015-11';
	 
	insert into deivid_bo:boindmul(
	no_documento,
	pri_cob_ap,
	pri_cob_aa,
	pri_dev_aa,
	no_pol_ren_ap,
	no_pol_nue_ap,
	no_pol_tot_ap,
	no_pol_ren_aa,
	no_pol_nue_aa,
	no_pol_tot_aa,
	no_poliza,
	com_pag_ap,
	com_pag_aa,
	sin_ocu_ap,
	sin_ocu_aa,
	sin_pag_ap,
	sin_pag_aa,
	sin_pen_ap,
	sin_pen_dic,
	sin_pen_aa,
	pri_sus_ap,
	pri_sus_aa,
	sin_pen_12avos,
	periodo,
	pos_ramo,
	nombre_vendedor,
	nombre_agente,
	cod_ramo,
	nombre_ramo,
	cod_agencia,
	nombre_agencia,
	sucursal_promotoria,
	pri_sus_map,
	pri_sus_maa,
	no_pol_ren_ap_per,
	no_pol_nue_ap_per,
	no_pol_ren_aa_per,
	pri_sus_ap_mes,
	pri_sus_map_mes,
	pri_cob_ap_mes,
	pri_cob_neto_aa,
	sin_var_aa,
	sin_var_ap,
	pri_cob_maa,
	pri_cob_map,
	pri_dev_ap,
	sin_ocu_ap_tu,
	sin_ocu_aa_tu
	)
	values (
	_no_documento,
	_pri_cob_ap,
	_pri_cob_aa,
	_pri_dev_aa,
	_no_pol_ren_ap,
	_no_pol_nue_ap,
	_no_pol_tot_ap,
	_no_pol_ren_aa,
	_no_pol_nue_aa,
	_no_pol_tot_aa,
	_no_poliza,
	_com_pag_ap,
	_com_pag_aa,
	_sin_ocu_ap,
	_sin_ocu_aa,
	_sin_pag_ap,
	_sin_pag_aa,
	_sin_pen_ap,
	_sin_pen_dic,
	_sin_pen_aa,
	_pri_sus_ap,
	_pri_sus_aa,
	_sin_pen_12avos,
	_per_fin_aa,
	_pos_ramo,
	_nombre_vendedor,
	_nombre_agente,
	_cod_ramo,
	_nombre_ramo,
	_centro_costo,
	_nombre_agencia,
	_nombre_promot,
	_pri_sus_map,
	_pri_sus_maa,
	_no_pol_ren_ap_per,
	_no_pol_nue_ap_per,
	_no_pol_ren_aa_per,
	_pri_sus_ap_mes,
	_pri_sus_map_mes,
	_pri_cob_ap_mes,
	_pri_cob_neto_aa,
	_sin_var_aa,
	_sin_var_ap,
	_pri_cob_maa,
	_pri_cob_map,
	_pri_dev_ap,
	_sin_ocu_ap_tu,
	_sin_ocu_aa_tu
	);

end foreach
	commit work;
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
