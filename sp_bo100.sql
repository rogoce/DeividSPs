-- Procedimiento que carga el Reporte de Indicadores para Aseguradora Ancon, S.A.
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza
--Modificado Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo100;		
create procedure "informix".sp_bo100()
returning integer,
		  char(100);


define _emi_periodo			char(7);
define _cob_periodo			char(7);

define _per_ini_aa			char(7);
define _per_fin_aa			char(7);
define _per_ini_ap			char(7);
define _per_fin_ap			char(7);
define _per_fin_dic			char(7);
define _ano					integer;
define _mes_evaluar			smallint;
define _ano_evaluar			smallint;
define _fecha_cierre		date;
define _fecha_evaluar		date;

define _mes_pnd				smallint;
define _ano_pnd				smallint;
define _periodo_pnd1		char(7);
define _periodo_pnd2		char(7);
define _periodo_reno		char(7);

define _fecha_ini_ap		date;
define _fecha_fin_ap		date;
define _fecha_ini_aa		date;
define _fecha_fin_aa		date;
define _tipo_mov            smallint;

define _no_documento		char(20);
define _no_poliza			char(10);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _monto				dec(16,2);
define _pos_ramo			smallint;
define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _cod_tipoprod		char(3);
define _porc_coaseguro		dec(16,4);
define _cod_coasegur		char(3);
define _cod_cliente			char(10);
define _fronting			smallint;
define _cod_grupo			char(5);

define _pri_cob_ap			dec(16,2);
define _pri_cob_aa			dec(16,2);
define _pri_cob_map			dec(16,2);
define _pri_cob_maa			dec(16,2);
define _pri_dev_ap			dec(16,2);
define _pri_dev_aa			dec(16,2);
define _pri_sus_ap			dec(16,2);
define _pri_sus_aa			dec(16,2);
define _pri_sus_map			dec(16,2);
define _pri_sus_maa			dec(16,2);

define _pri_sus_ap_mes		dec(16,2);
define _pri_sus_map_mes		dec(16,2);
define _pri_cob_ap_mes		dec(16,2);
define _pri_cob_neto_aa		dec(16,2);

define _vigen_ini			date;
define _vigen_fin			date;
define _fecha_pago			date;
define _fecha_dic_ap		date;
define _fecha_hoy			date;
define _factor_vig			dec(16,2);
define _dias1				integer;
define _dias2				integer;

define _nueva_renov			char(1);
define _cant_nueva			smallint;
define _cant_renov			smallint;
define _tipo_prod           smallint;

define _no_pol_ren_ap		integer;
define _no_pol_nue_ap		integer;
define _no_pol_tot_ap		integer;
define _no_pol_ren_aa		integer;
define _no_pol_nue_aa		integer;
define _no_pol_tot_aa		integer;

define _no_pol_ren_ap_per	integer;
define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;

define _ano_ant				integer;
define _vigencia_ant		date;
define _vigencia_act		date;

define _com_pag_ap			dec(16,2);
define _com_pag_aa			dec(16,2);
define _monto_che			dec(16,2);
define _tipo_agente			char(1);
define _cod_agente			char(5);
define _no_remesa			char(10);
define _renglon				smallint;
define _porc_partic_agt 	dec(5,2);
define _porc_comis_agt		dec(5,2);
define _user_added			char(8);

define _sin_ocu_ap			integer;
define _sin_ocu_aa			integer;
define _sin_pag_ap			dec(16,2);
define _sin_pag_aa			dec(16,2);
define _sin_pen_ap			dec(16,2);
define _sin_pen_aa			dec(16,2);
define _sin_pen_dic			dec(16,2);
define _sin_pen_12avos		dec(16,2);
define _sin_var_aa			dec(16,2);
define _sin_var_ap			dec(16,2);
define _exigible            dec(16,2);
define _sin_ocu_ap_tu		integer;
define _sin_ocu_aa_tu		integer;

define _nombre_agente		char(50);
define _cod_agencia			char(3);
define _centro_costo		char(3);
define _suc_promotoria		char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor		char(50);
define _estatus_poliza		smallint;
define _nombre_ramo			char(50);
define _nombre_agencia		char(50);
define _nombre_promot		char(50);

define _filtros				char(255);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _numrecla			char(18);
define _ramo				char(3);
define _colectiva			char(1);
define _colectivo			char(1);
define _cod_endomov         char(3);

define _pri_sus_ret_ap		dec(16,2);
define _pri_sus_can_ap 		dec(16,2);
define _pri_sus_ret_ap_mes	dec(16,2);
define _pri_sus_can_ap_mes	dec(16,2);
define _pri_sus_ret_aa		dec(16,2);
define _pri_sus_can_aa		dec(16,2);
define _pri_ret_map			dec(16,2);
define _pri_can_map			dec(16,2);
define _pri_ret_map_mes		dec(16,2);
define _pri_sus_can_map_mes	dec(16,2);
define _pri_ret_maa			dec(16,2);
define _pri_sus_can_maa		dec(16,2);
define _prima_can			dec(16,2);

define _sin_ret_pag_ap     dec(16,2);
define _sin_ret_pag_aa     dec(16,2);
define _sin_ret_pen_aa	   dec(16,2);
define _sin_ret_pen_ap	   dec(16,2);
define _sin_ret_var_ap	   dec(16,2);
define _sin_ret_var_aa	   dec(16,2);

--set debug file to "sp_bo043.trc";
--trace on;
--trace "1";

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
--	return _error, _error_isam || " " || _error_desc;
	return _error, _error_desc;
end exception

-- Definiciones Iniciales

return 0, "Actualizacion Exitosa";
delete from deivid_bo:boindancon;

create temp table tmp_multi(
no_documento		char(20),
pri_cob_ap			dec(16,2) 	default 0,
pri_cob_aa			dec(16,2) 	default 0,
pri_dev_aa			dec(16,2) 	default 0,
no_pol_ren_ap		integer 	default 0,
no_pol_nue_ap		integer		default 0,
no_pol_tot_ap		integer 	default 0,
no_pol_ren_aa		integer 	default 0,
no_pol_nue_aa		integer		default 0,
no_pol_tot_aa		integer 	default 0,
com_pag_ap			dec(16,2)	default 0,
com_pag_aa			dec(16,2)	default 0,
sin_ocu_ap			integer		default 0,
sin_ocu_aa			integer		default 0,
sin_pag_ap			dec(16,2)	default 0,
sin_pag_aa			dec(16,2)	default 0,
sin_pen_ap			dec(16,2)	default 0,
sin_pen_aa			dec(16,2)	default 0,
sin_pen_dic		dec(16,2)	default 0,
pri_sus_ap			dec(16,2) 	default 0,
pri_sus_aa			dec(16,2) 	default 0,
sin_pen_12avos		dec(16,2)	default 0,
pri_sus_map		dec(16,2) 	default 0,
pri_sus_maa		dec(16,2) 	default 0,
no_pol_ren_ap_per	integer 	default 0,
no_pol_nue_ap_per	integer		default 0,
no_pol_ren_aa_per	integer 	default 0,
pri_sus_ap_mes		dec(16,2) 	default 0,
pri_sus_map_mes	dec(16,2) 	default 0,
pri_cob_ap_mes		dec(16,2) 	default 0,
pri_cob_neto_aa	dec(16,2) 	default 0,
sin_var_aa			dec(16,2) 	default 0,
sin_var_ap			dec(16,2) 	default 0,
pri_cob_maa		dec(16,2) 	default 0,
pri_cob_map		dec(16,2) 	default 0,
pri_dev_ap			dec(16,2) default 0,

pri_sus_ret_ap		dec(16,2) default 0,
pri_sus_can_ap 		dec(16,2) default 0,
pri_sus_ret_ap_mes	dec(16,2) default 0,
pri_sus_can_ap_mes	dec(16,2) default 0,
pri_sus_ret_aa		dec(16,2) default 0,
pri_sus_can_aa		dec(16,2) default 0,
pri_ret_map			dec(16,2) default 0,
pri_can_map			dec(16,2) default 0,
pri_ret_map_mes		dec(16,2) default 0,
pri_sus_can_map_mes	dec(16,2) default 0,
pri_ret_maa			dec(16,2) default 0,
pri_sus_can_maa		dec(16,2) default 0,
sin_ret_pag_ap      dec(16,2) default 0,
sin_ret_pag_aa      dec(16,2) default 0,
sin_ret_pen_aa		dec(16,2) default 0,
sin_ret_pen_ap		dec(16,2) default 0,
sin_ret_var_ap		dec(16,2) default 0,
sin_ret_var_aa		dec(16,2) default 0
) with no log;

-- Periodos de Comparacion

select par_periodo_ant,
	   par_periodo_act,
	   par_ase_lider,
	   fecha_cierre
  into _emi_periodo,
       _cob_periodo,
	   _cod_coasegur,
	   _fecha_cierre
  from parparam;  

-- Año Actual

if (today - _fecha_cierre) > 1 then
	let _per_fin_aa	= _cob_periodo;
else
	let _per_fin_aa	= _emi_periodo;
end if
 
--let _per_fin_aa = '2015-07';
 
--if _emi_periodo <= _cob_periodo then
--	let _per_fin_aa	= _emi_periodo;
--else
--	let _per_fin_aa	= _cob_periodo;
--end if

--Correr un periodo especifico 
--let _per_fin_aa = "2016-09";

let _ano          = _per_fin_aa[1,4];
let _per_ini_aa   = _ano || "-01";

let _fecha_ini_aa = MDY(1, 1, _ano);
let _fecha_fin_aa = sp_sis36(_per_fin_aa);

let _mes_evaluar  = _per_fin_aa[6,7];

let _fecha_hoy    = sp_sis36(_per_fin_aa);

if _fecha_hoy > today then
	let _fecha_hoy = today;
end if

-- Año Pasado

let _ano = _ano - 1;

let _per_fin_ap   = _ano || _per_fin_aa[5,7];
let _per_ini_ap   = _ano || "-01";

let _fecha_dic_ap = MDY(12, 31, _ano);
let _per_fin_dic  = _ano || "-12";

let _fecha_ini_ap = MDY(1, 1, _ano);
let _fecha_fin_ap = sp_sis36(_per_fin_ap);

let _fecha_evaluar = sp_bo078(_per_fin_aa, _per_fin_ap);

let _exigible = 0.00;

--{
-- Polizas Nuevas y Renovadas Año Pasado

--trace "2";

-- let _fecha_ini_ap = '01/01/2014';   --*********************************
-- let _fecha_fin_ap = '30/04/2014';   --*********************************
let _pri_sus_ret_ap      = 0;
let _pri_sus_can_ap      = 0;
let	_pri_sus_ret_ap_mes  = 0;
let _pri_sus_can_ap_mes  = 0;
let _pri_sus_ret_aa      = 0;
let _pri_sus_can_aa      = 0;
let _pri_ret_map         = 0;
let _pri_can_map         = 0;
let	_pri_ret_map_mes     = 0;
let	_pri_sus_can_map_mes = 0;
let	_pri_ret_maa         = 0;
let	_pri_sus_can_maa	 = 0;

call sp_bo077(_fecha_ini_ap, _fecha_fin_ap) returning _error, _error_desc;

foreach
 select no_documento,
        sum(no_pol_nueva),
		sum(no_pol_nueva_per),
		sum(no_pol_renov),
		sum(no_pol_renov_per)
   into _no_documento,
		_no_pol_nue_ap,
		_no_pol_nue_ap_per,
		_no_pol_ren_ap,
		_no_pol_ren_ap_per
   from tmp_persis
  group by no_documento

		insert into tmp_multi(
		no_documento, 
		no_pol_nue_ap, 
		no_pol_nue_ap_per,
		no_pol_ren_ap,
		no_pol_ren_ap_per
		)
		values(
		_no_documento, 
		_no_pol_nue_ap,
		_no_pol_nue_ap_per,
		_no_pol_ren_ap,
		_no_pol_ren_ap_per
		);

end foreach

drop table tmp_persis;

--trace "3";

-- Polizas Nuevas y Renovadas Año Actual

-- let _fecha_ini_aa = '01/01/2015';         ---***************************************************************
-- let _fecha_fin_aa = '30/04/2015';          --*****************************************************************

call sp_bo077(_fecha_ini_aa, _fecha_fin_aa) returning _error, _error_desc;

foreach
 select no_documento,
        sum(no_pol_nueva),
		sum(no_pol_renov),
		sum(no_pol_renov_per)
   into _no_documento,
		_no_pol_nue_aa,
		_no_pol_ren_aa,
		_no_pol_ren_aa_per
   from tmp_persis
  group by no_documento

		insert into tmp_multi(
		no_documento, 
		no_pol_nue_aa, 
		no_pol_ren_aa,
		no_pol_ren_aa_per
		)
		values(
		_no_documento, 
		_no_pol_nue_aa,
		_no_pol_ren_aa,
		_no_pol_ren_aa_per
		);

end foreach

drop table tmp_persis;
--}

--trace "4";

-- Cobros del Año Pasado a la Fecha
--{
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		no_remesa,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_no_remesa,
		_renglon
   from cobredet
  where periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	and fecha       <= _fecha_evaluar

	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select porc_partic_coas
	  into _porc_coaseguro
	  from emicoama
     where no_poliza 		= _no_poliza
       and cod_coasegur	= '036';

	if _porc_coaseguro is null then
		let _porc_coaseguro = 100;
	end if

	let _monto = _monto * (_porc_coaseguro / 100);
	
	insert into tmp_multi(no_documento, pri_cob_ap)
	values (_no_documento, _monto);
	 
end foreach
--}

-- Cobros del Año Pasado al Mes
--{
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		no_remesa,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_no_remesa,
		_renglon
   from cobredet
  where periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	select user_added
	  into _user_added
	  from cobremae
	 where no_remesa = _no_remesa;

	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select porc_partic_coas
	  into _porc_coaseguro
	  from emicoama
     where no_poliza 		= _no_poliza
       and cod_coasegur	= '036';

	if _porc_coaseguro is null then
		let _porc_coaseguro = 100;
	end if

	let _monto 		= _monto * (_porc_coaseguro / 100);
	let _com_pag_ap	= 0.00;

	-- No proceso cuando son creditos de gerencia

	if _user_added <> "GERENCIA" then 

		foreach
		 Select	porc_comis_agt,
				porc_partic_agt,
				cod_agente
		   Into	_porc_comis_agt,
				_porc_partic_agt,
				_cod_agente
		   From cobreagt
		  Where	no_remesa = _no_remesa
		    and renglon   = _renglon

			select tipo_agente
			  into _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			if _tipo_agente in ("A", "E") then -- Agentes Normales y Agentes Especiales
				let _com_pag_ap = _com_pag_ap + _monto * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
			end if

		end foreach

	end if

	insert into tmp_multi(no_documento, pri_cob_ap_mes, com_pag_ap)
	values (_no_documento, _monto, _com_pag_ap);
	 
end foreach
--}

-- Cobros de este Año
--{
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		no_remesa,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_no_remesa,
		_renglon
   from cobredet
  where periodo     >= _per_ini_aa
    and periodo     <= _per_fin_aa
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	
	select user_added
	  into _user_added
	  from cobremae
	 where no_remesa = _no_remesa;

	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select porc_partic_coas
	  into _porc_coaseguro
	  from emicoama
     where no_poliza 		= _no_poliza
       and cod_coasegur	= '036';

	if _porc_coaseguro is null then
		let _porc_coaseguro = 100;
	end if

	let _monto			= _monto * (_porc_coaseguro / 100);
	let _com_pag_aa 	= 0.00;

	-- No proceso cuando son creditos de gerencia

	if _user_added <> "GERENCIA" then 

		foreach
		 Select	porc_comis_agt,
				porc_partic_agt,
				cod_agente
		   Into	_porc_comis_agt,
				_porc_partic_agt,
				_cod_agente
		   From cobreagt
		  Where	no_remesa = _no_remesa
		    and renglon   = _renglon

			select tipo_agente
			  into _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			if _tipo_agente in ("A", "E") then -- Agentes Normales y Agentes Especiales
				let _com_pag_aa = _com_pag_aa + _monto * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
			end if

		end foreach

	end if

	insert into tmp_multi(no_documento, pri_cob_aa, com_pag_aa)
	values (_no_documento, _monto, _com_pag_aa);

end foreach
--}

-- Cobros del Mes Año Pasado
--{
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		no_remesa,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_no_remesa,
		_renglon
   from cobredet
  where periodo     = _per_fin_ap
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	select user_added
	  into _user_added
	  from cobremae
	 where no_remesa = _no_remesa;

	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select porc_partic_coas
	  into _porc_coaseguro
	  from emicoama
     where no_poliza 		= _no_poliza
       and cod_coasegur	= '036';

	if _porc_coaseguro is null then
		let _porc_coaseguro = 100;
	end if

	let _monto	= _monto * (_porc_coaseguro / 100);

	insert into tmp_multi(no_documento, pri_cob_map)
	values (_no_documento, _monto);
	 
end foreach
--}

-- Cobros de este Año
--{
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		no_remesa,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_no_remesa,
		_renglon
   from cobredet
  where periodo     = _per_fin_aa
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	
	select user_added
	  into _user_added
	  from cobremae
	 where no_remesa = _no_remesa;

	let _no_poliza = null;

	foreach
	 select no_poliza,
	        vigencia_inic,
			vigencia_final
	   into _no_poliza,
	        _vigen_ini,
			_vigen_fin
	   from emipomae
	  where no_documento = _no_documento
	    and actualizado  = 1
	  order by vigencia_final desc

		if _fecha_pago >= _vigen_ini and
		   _fecha_pago <= _vigen_fin then
			exit foreach;
		end if
		
	end foreach
	
	if _no_poliza is null then
		
		let _no_poliza = sp_sis21(_no_documento);

		select vigencia_inic,
		       vigencia_final
		  into _vigen_ini,
		       _vigen_fin
		  from emipomae
		 where no_poliza = _no_poliza;

	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select porc_partic_coas
	  into _porc_coaseguro
	  from emicoama
     where no_poliza 		= _no_poliza
       and cod_coasegur	= '036';

	if _porc_coaseguro is null then
		let _porc_coaseguro = 100;
	end if

	let _monto	= _monto * (_porc_coaseguro / 100);
	
	insert into tmp_multi(no_documento, pri_cob_maa)
	values (_no_documento, _monto);

end foreach
--}

--trace "5";

-- Primas Suscritas Año Pasado a la Fecha
--{
foreach
 select no_documento,
        prima_suscrita,
		prima_retenida,
		cod_endomov
   into _no_documento,
        _pri_sus_ap,
		_pri_sus_ret_ap,
		_cod_endomov
   from endedmae
  where periodo         >= _per_ini_ap
    and periodo         <= _per_fin_ap
	and actualizado     = 1
	and fecha_indicador <= _fecha_evaluar
	
	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;
	 
	let _prima_can = 0;
	if _tipo_mov = 2 then
		let _prima_can = _pri_sus_ap;
	else
		let _prima_can = 0;
	end if

	insert into tmp_multi(no_documento, pri_sus_ap, pri_sus_ret_ap, pri_sus_can_ap)
	values (_no_documento, _pri_sus_ap, _pri_sus_ret_ap, _prima_can);

end foreach
    
-- Primas Suscritas Año Pasado al Mes
--{
foreach
 select no_documento,
        prima_suscrita,
		prima_retenida,
		cod_endomov
   into _no_documento,
        _pri_sus_ap,
		_pri_sus_ret_ap,
		_cod_endomov
   from endedmae
  where periodo         >= _per_ini_ap
    and periodo         <= _per_fin_ap
	and actualizado     = 1
	
	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;
	 
	let _prima_can = 0;
	if _tipo_mov = 2 then
		let _prima_can = _pri_sus_ap;
	else
		let _prima_can = 0;
	end if

	insert into tmp_multi(no_documento, pri_sus_ap_mes, pri_sus_ret_ap_mes, pri_sus_can_ap_mes)
	values (_no_documento, _pri_sus_ap, _pri_sus_ret_ap, _prima_can);

end foreach

-- Primas Suscritas Año Actual

foreach
 select no_documento,
        prima_suscrita,
		prima_retenida,
		cod_endomov
   into _no_documento,
        _pri_sus_aa,
		_pri_sus_ret_aa,
		_cod_endomov
   from endedmae
  where periodo     >= _per_ini_aa
    and periodo     <= _per_fin_aa
	and actualizado = 1
	
	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;
	 
	let _prima_can = 0;
	if _tipo_mov = 2 then
		let _prima_can = _pri_sus_aa;
	else
		let _prima_can = 0;
	end if

	insert into tmp_multi(no_documento, pri_sus_aa, pri_sus_ret_aa, pri_sus_can_aa)
	values (_no_documento, _pri_sus_aa, _pri_sus_ret_aa, _prima_can);

end foreach
--}

-- Primas Suscritas Mes Año Pasado a la Fecha
--{
foreach
 select no_documento,
        prima_suscrita,
		prima_retenida,
		cod_endomov
   into _no_documento,
        _pri_sus_map,
		_pri_ret_map,
		_cod_endomov
   from endedmae
  where periodo         = _per_fin_ap
	and actualizado     = 1
	and fecha_indicador <= _fecha_evaluar
	
	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;
	 
	let _prima_can = 0;
	if _tipo_mov = 2 then
		let _prima_can = _pri_sus_map;
	else
		let _prima_can = 0;
	end if

	insert into tmp_multi(no_documento, pri_sus_map, pri_ret_map, pri_can_map)
	values (_no_documento, _pri_sus_map, _pri_ret_map, _prima_can);

end foreach
    
-- Primas Suscritas Mes Año Pasado al Mes
--{
foreach
 select no_documento,
        prima_suscrita,
		prima_retenida,
		cod_endomov
   into _no_documento,
        _pri_sus_map,
		_pri_ret_map,
		_cod_endomov
   from endedmae
  where periodo         = _per_fin_ap
	and actualizado     = 1

	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;
	 
	let _prima_can = 0;
	if _tipo_mov = 2 then
		let _prima_can = _pri_sus_ap;
	else
		let _prima_can = 0;
	end if
	
	insert into tmp_multi(no_documento, pri_sus_map_mes, pri_ret_map_mes, pri_sus_can_map_mes)
	values (_no_documento, _pri_sus_map, _pri_ret_map, _prima_can);

end foreach

-- Primas Suscritas Mes Año Actual

foreach
 select no_documento,
        prima_suscrita,
		prima_retenida,
		_cod_endomov
   into _no_documento,
        _pri_sus_maa,
		_pri_ret_maa,
		_cod_endomov
   from endedmae
  where periodo     = _per_fin_aa
	and actualizado = 1

	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;
	 
	let _prima_can = 0;
	if _tipo_mov = 2 then
		let _prima_can = _pri_sus_maa;
	else
		let _prima_can = 0;
	end if
	
	insert into tmp_multi(no_documento, pri_sus_maa, pri_ret_maa, pri_sus_can_maa)
	values (_no_documento, _pri_sus_maa, _pri_ret_maa, _prima_can);

end foreach
--}

--trace "6";

-- Primas Devengadas (Primas Suscritas Devengadas NIIF)

--{
-- Año Actual
call sp_dev01(_fecha_ini_aa, _fecha_fin_aa) returning _error, _error_desc;

foreach
 select no_documento,
		sum(prima_devengada)
   into _no_documento,
		_pri_dev_aa
   from tmp_prima_devengada
  group by no_documento

	insert into tmp_multi(no_documento, pri_dev_aa)
	values (_no_documento, _pri_dev_aa);

end foreach

drop table tmp_prima_devengada;

-- Año Pasado
call sp_dev01(_fecha_ini_ap, _fecha_fin_ap) returning _error, _error_desc;

foreach
 select no_documento,
		sum(prima_devengada)
   into _no_documento,
		_pri_dev_ap
   from tmp_prima_devengada
  group by no_documento

	insert into tmp_multi(no_documento, pri_dev_ap)
	values (_no_documento, _pri_dev_ap);

end foreach

drop table tmp_prima_devengada;
--}

--trace "7";

-- Siniestros Ocurridos Año Pasado
--{
foreach
 select no_poliza
   into _no_poliza
   from recrcmae
  where periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap
	and actualizado  = 1

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_multi(no_documento, sin_ocu_ap)
	values (_no_documento, 1);

end foreach

-- Siniestros Ocurridos Año Actual

foreach
 select no_poliza
   into _no_poliza
   from recrcmae
  where periodo     >= _per_ini_aa
    and periodo     <= _per_fin_aa
	and actualizado  = 1

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_multi(no_documento, sin_ocu_aa)
	values (_no_documento, 1);

end foreach
--}

--trace "8";

-- Siniestros Pagados Año Pasado
--{
call sp_rec01("001", "001", _per_ini_ap, _per_fin_ap) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto,
		reserva_bruto,
		pagado_neto,
		reserva_neto
   into _no_documento,
        _sin_pag_ap,
		_sin_var_ap,
        _sin_ret_pag_ap,
		_sin_ret_var_ap
   from tmp_sinis

	insert into tmp_multi(no_documento, sin_pag_ap, sin_var_ap, sin_ret_pag_ap, sin_ret_var_ap)
	values (_no_documento, _sin_pag_ap, _sin_var_ap, _sin_ret_pag_ap, _sin_ret_var_ap);

end foreach

drop table tmp_sinis;
--}

--trace "9";

-- Siniestros Pagados Año Actual
--{
call sp_rec01("001", "001", _per_ini_aa, _per_fin_aa) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto,
		reserva_bruto,
		pagado_neto,
		reserva_neto
   into _no_documento,
        _sin_pag_aa,
		_sin_var_aa,
        _sin_ret_pag_aa,
		_sin_ret_var_aa
   from tmp_sinis

	insert into tmp_multi(no_documento, sin_pag_aa, sin_var_aa, sin_ret_pag_aa, sin_ret_var_aa)
	values (_no_documento, _sin_pag_aa, _sin_var_aa, _sin_ret_pag_aa, _sin_ret_var_aa);

end foreach

drop table tmp_sinis;
--}

--trace "10";

-- Siniestros Pendientes Año Pasado
--{
foreach

	select t.no_reclamo,sum(c.variacion * (e.porc_partic_coas/100)),sum(c.variacion * (e.porc_partic_coas/100) * (r.porc_partic_prima/100))
	  into _no_reclamo,_sin_pen_ap,_sin_ret_pen_ap
	  from rectrmae t, rectrcob c, prdcober p, rectrrea r, reccoas e, reacomae m
	where t.no_reclamo = e.no_reclamo
	   and t.no_tranrec = c.no_tranrec
	   and c.cod_cobertura = p.cod_cobertura
	   and t.no_tranrec = r.no_tranrec
	   and p.cod_cober_reas = r.cod_cober_reas
	   and r.cod_contrato = m.cod_contrato
	   and c.variacion <> 0
	   and t.actualizado = 1
	   and e.cod_coasegur = '036'
	   and m.tipo_contrato = 1
	   and t.periodo <= _per_fin_ap
	group by 1
	having sum(c.variacion * (e.porc_partic_coas/100)) > 0

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_multi(no_documento, sin_pen_ap, sin_ret_pen_ap)
	values (_no_documento, _sin_pen_ap, _sin_ret_pen_ap);

end foreach

-- Siniestros Pendientes Año Actual

foreach

	select t.no_reclamo,sum(c.variacion * (e.porc_partic_coas/100)),sum(c.variacion * (e.porc_partic_coas/100) * (r.porc_partic_prima/100))
	  into _no_reclamo,_sin_pen_aa,_sin_ret_pen_aa
	  from rectrmae t, rectrcob c, prdcober p, rectrrea r, reccoas e, reacomae m
	where t.no_reclamo = e.no_reclamo
	   and t.no_tranrec = c.no_tranrec
	   and c.cod_cobertura = p.cod_cobertura
	   and t.no_tranrec = r.no_tranrec
	   and p.cod_cober_reas = r.cod_cober_reas
	   and r.cod_contrato = m.cod_contrato
	   and c.variacion <> 0
	   and t.actualizado = 1
	   and e.cod_coasegur = '036'
	   and m.tipo_contrato = 1
	   and t.periodo <= _per_fin_aa
	group by 1
	having sum(c.variacion * (e.porc_partic_coas/100)) > 0

	select no_poliza,
		   numrecla
	  into _no_poliza,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	
	if _numrecla = "00-0000-00000-00" then
	   continue foreach;
	end if;
	
	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_multi(no_documento, sin_pen_aa, sin_ret_pen_aa)
	values (_no_documento, _sin_pen_aa, _sin_ret_pen_aa);
	
end foreach

--trace "12";

--trace on;

-- Carga de la Table de enlace en BO

let _pos_ramo = 1;
foreach								--Se agrego este ciclo, debido a que arrojaba error -229 debido a la cantidad de registros almacenado al momento de hacer el sum. 03/12/2015
	select distinct no_documento[1,2]
	  into _ramo
	  from tmp_multi

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
			   sum(pri_dev_ap),
			   sum(pri_sus_ret_ap),
			   sum(pri_sus_can_ap),
			   sum(pri_sus_ret_ap_mes),
			   sum(pri_sus_can_ap_mes),
			   sum(pri_sus_ret_aa),
			   sum(pri_sus_can_aa),
			   sum(pri_ret_map),
			   sum(pri_can_map),
			   sum(pri_ret_map_mes),
			   sum(pri_sus_can_map_mes),
			   sum(pri_ret_maa),
			   sum(pri_sus_can_maa),
			   sum(sin_ret_pag_ap),
			   sum(sin_ret_pag_aa),
			   sum(sin_ret_pen_aa),
			   sum(sin_ret_pen_ap),
			   sum(sin_ret_var_ap),
			   sum(sin_ret_var_aa)
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
			   _pri_dev_ap,
			   _pri_sus_ret_ap,
			   _pri_sus_can_ap,
			   _pri_sus_ret_ap_mes,
			   _pri_sus_can_ap_mes,
			   _pri_sus_ret_aa,
			   _pri_sus_can_aa,
			   _pri_ret_map,
			   _pri_can_map,
			   _pri_ret_map_mes,
			   _pri_sus_can_map_mes,
			   _pri_ret_maa,
			   _pri_sus_can_maa,
			   _sin_ret_pag_ap,
			   _sin_ret_pag_aa,
			   _sin_ret_pen_aa,
			   _sin_ret_pen_ap,
			   _sin_ret_var_ap,
			   _sin_ret_var_aa
		  from tmp_multi
		 where no_documento[1,2] = _ramo
		 group by no_documento

		let _no_poliza = sp_sis21(_no_documento);

		select cod_ramo,
			   sucursal_origen,
			   cod_subramo,
			   cod_contratante,
			   cod_grupo,
			   fronting,
			   colectiva,
			   nueva_renov
		  into _cod_ramo,
			   _cod_agencia,
			   _cod_subramo,
			   _cod_cliente,
			   _cod_grupo,
			   _fronting,
			   _colectiva,
			   _nueva_renov
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _colectiva = 'I' then
			let _colectivo = 'N';
		else
			let _colectivo = 'S';
		end if	
		 
		select nombre
		  into _nombre_promot
		  from cliclien
		 where cod_cliente = _cod_cliente;

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		let _pos_ramo = 1; -- Comercializacion
		
		let _tipo_prod = 0;
		if _fronting = 1 then
			let _pos_ramo = 3; -- Fronting
			let _tipo_prod = 1;
		elif _cod_grupo = "1000" then
			let _pos_ramo = 4; -- Estado
		elif _cod_ramo = "008" then
			let _pos_ramo = 2; -- Fianzas
		end if

		--if _cod_ramo = "008" then
			--let _pos_ramo = 2;
		--elif _cod_ramo = "009" then
			--if _cod_subramo = "003" then
				--let _pos_ramo = 2;
			--elif _cod_subramo = "004" then
				--let _pos_ramo = 2;
			--end if
		--elif _cod_ramo = "013" then
			--let _pos_ramo = 2;
		--elif _cod_ramo = "014" then
			--let _pos_ramo = 2;
		--elif _cod_ramo = "020" then
			--let _pos_ramo = 2;
		--end if
		
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
		 
		select exigible into _exigible from emipoliza where no_documento = _no_documento;
		if _exigible is null then
			let _exigible = 0.00;
		end if	
		
		insert into deivid_bo:boindancon(
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
		sin_ocu_aa_tu,
		cod_agente,
		cod_vendedor,
		cod_cliente,
		pri_vencida_ex,
		tipo_prod,
		nueva_renov,
		pri_sus_ret_ap,
		pri_sus_can_ap,
		pri_sus_ret_ap_mes,
		pri_sus_can_ap_mes,
		pri_sus_ret_aa,
		pri_sus_can_aa,
		pri_ret_map,
		pri_can_map,
		pri_ret_map_mes,
		pri_sus_can_map_mes,
		pri_ret_maa,
		pri_sus_can_maa,
		sin_ret_pag_ap,
		sin_ret_pag_aa,
		sin_ret_pen_aa,
		sin_ret_pen_ap,
		sin_ret_var_ap,
		sin_ret_var_aa,
		colectivo
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
		_sin_ocu_aa_tu,
		_cod_agente,
		_cod_vendedor,
		_cod_cliente,
		_exigible,
		_tipo_prod,
		_nueva_renov,
		_pri_sus_ret_ap,
	    _pri_sus_can_ap,
	    _pri_sus_ret_ap_mes,
	    _pri_sus_can_ap_mes,
	    _pri_sus_ret_aa,
	    _pri_sus_can_aa,
	    _pri_ret_map,
	    _pri_can_map,
	    _pri_ret_map_mes,
	    _pri_sus_can_map_mes,
	    _pri_ret_maa,
	    _pri_sus_can_maa,
		_sin_ret_pag_ap,
		_sin_ret_pag_aa,
		_sin_ret_pen_aa,
		_sin_ret_pen_ap,
		_sin_ret_var_ap,
		_sin_ret_var_aa,
		_colectivo
		);
	end foreach
end foreach

drop table tmp_multi;

end

return 0, "Actualizacion Exitosa";

end procedure
