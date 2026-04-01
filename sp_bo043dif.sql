-- Procedimiento que carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_bo043dif;		

create procedure "informix".sp_bo043dif()
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

define _filtros			char(255);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _numrecla		char(18);

--set debug file to "sp_bo043.trc";
--trace on;
--trace "1";

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || _error_desc;
end exception

-- Definiciones Iniciales

delete from deivid_bo:boindmul;

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
sin_pen_dic			dec(16,2)	default 0,
pri_sus_ap			dec(16,2) 	default 0,
pri_sus_aa			dec(16,2) 	default 0,
sin_pen_12avos		dec(16,2)	default 0,
pri_sus_map			dec(16,2) 	default 0,
pri_sus_maa			dec(16,2) 	default 0,
no_pol_ren_ap_per	integer 	default 0,
no_pol_nue_ap_per	integer		default 0,
no_pol_ren_aa_per	integer 	default 0,
pri_sus_ap_mes		dec(16,2) 	default 0,
pri_sus_map_mes		dec(16,2) 	default 0,
pri_cob_ap_mes		dec(16,2) 	default 0
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
 

--if _emi_periodo <= _cob_periodo then
--	let _per_fin_aa	= _emi_periodo;
--else
--	let _per_fin_aa	= _cob_periodo;
--end if
	 

--Correr un periodo 
let _per_fin_aa = "2013-11";

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

--{
-- Polizas Nuevas y Renovadas Año Pasado

--trace "2";

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
	
	let _com_pag_ap = 0.00;

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

	let _com_pag_aa = 0.00;

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

	if _vigen_fin is null then
		let _vigen_fin = _fecha_pago; 
	end if

	if _vigen_ini is null then
		let _vigen_ini = _fecha_pago; 
	end if

	if _fecha_hoy >= _vigen_fin then

		let _factor_vig = 1;

	elif _fecha_hoy <= _vigen_ini then

		let _factor_vig = 0;

	else

		let _dias1      = _vigen_fin - _vigen_ini;
		let _dias2      = _fecha_hoy - _vigen_ini;
		let _factor_vig = _dias2 / _dias1;

	end if

--	let _pri_dev_aa = _monto * _factor_vig;
	let _pri_dev_aa = 0.00;

	insert into tmp_multi(no_documento, pri_cob_aa, pri_dev_aa, com_pag_aa)
	values (_no_documento, _monto, _pri_dev_aa, _com_pag_aa);

end foreach
--}

--trace "5";

-- Primas Suscritas Año Pasado a la Fecha
--{
foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
        _pri_sus_ap
   from endedmae
  where periodo         >= _per_ini_ap
    and periodo         <= _per_fin_ap
	and actualizado     = 1
	and fecha_indicador <= _fecha_evaluar

	insert into tmp_multi(no_documento, pri_sus_ap)
	values (_no_documento, _pri_sus_ap);

end foreach
    
-- Primas Suscritas Año Pasado al Mes
--{
foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
        _pri_sus_ap
   from endedmae
  where periodo         >= _per_ini_ap
    and periodo         <= _per_fin_ap
	and actualizado     = 1

	insert into tmp_multi(no_documento, pri_sus_ap_mes)
	values (_no_documento, _pri_sus_ap);

end foreach

-- Primas Suscritas Año Actual

foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
        _pri_sus_aa
   from endedmae
  where periodo     >= _per_ini_aa
    and periodo     <= _per_fin_aa
	and actualizado = 1

	insert into tmp_multi(no_documento, pri_sus_aa)
	values (_no_documento, _pri_sus_aa);

end foreach
--}

-- Primas Suscritas Mes Año Pasado a la Fecha
--{
foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
        _pri_sus_map
   from endedmae
  where periodo         = _per_fin_ap
	and actualizado     = 1
	and fecha_indicador <= _fecha_evaluar

	insert into tmp_multi(no_documento, pri_sus_map)
	values (_no_documento, _pri_sus_map);

end foreach
    
-- Primas Suscritas Mes Año Pasado al Mes
--{
foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
        _pri_sus_map
   from endedmae
  where periodo         = _per_fin_ap
	and actualizado     = 1

	insert into tmp_multi(no_documento, pri_sus_map_mes)
	values (_no_documento, _pri_sus_map);

end foreach

-- Primas Suscritas Mes Año Actual

foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
        _pri_sus_maa
   from endedmae
  where periodo     = _per_fin_aa
	and actualizado = 1

	insert into tmp_multi(no_documento, pri_sus_maa)
	values (_no_documento, _pri_sus_maa);

end foreach
--}

--trace "6";

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
	  where periodo     >= _periodo_pnd1
	    and periodo     <= _periodo_pnd2
		and actualizado = 1
	  group by 1

		let _pri_dev_aa = _pri_dev_aa / 12;

		insert into tmp_multi(no_documento, pri_dev_aa)
		values (_no_documento, _pri_dev_aa);

	end foreach

end for
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
        pagado_bruto
   into _no_documento,
        _sin_pag_ap
   from tmp_sinis

	insert into tmp_multi(no_documento, sin_pag_ap)
	values (_no_documento, _sin_pag_ap);

end foreach

drop table tmp_sinis;
--}

--trace "9";

-- Siniestros Pagados Año Actual
--{
call sp_rec01("001", "001", _per_ini_aa, _per_fin_aa) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	insert into tmp_multi(no_documento, sin_pag_aa)
	values (_no_documento, _sin_pag_aa);

end foreach

drop table tmp_sinis;
--}

--trace "10";

-- Siniestros Pendientes Año Pasado
--{
foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_ap
   from rectrmae 
  where cod_compania = "001"
    and periodo      <= _per_fin_ap 
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_ap = _sin_pen_ap * (_porc_coaseguro / 100);
	 
	insert into tmp_multi(no_documento, sin_pen_ap)
	values (_no_documento, _sin_pen_ap);

end foreach
--}

--trace "11";

-- Siniestros Pendientes Diciembre Año Pasado
--{
foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_dic
   from rectrmae 
  where cod_compania = "001"
    and periodo      <= _per_fin_dic 
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_dic    = _sin_pen_dic * (_porc_coaseguro / 100);
	let _sin_pen_12avos = _sin_pen_dic * _mes_evaluar / 12;

	insert into tmp_multi(no_documento, sin_pen_dic, sin_pen_12avos)
	values (_no_documento, _sin_pen_dic, _sin_pen_12avos);

end foreach
--}

-- Siniestros Pendientes Año Actual
--{
foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_aa
   from rectrmae 
  where cod_compania = "001"
    and periodo      <= _per_fin_aa
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza,
		   numrecla
	  into _no_poliza,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	
	if _numrecla = "00-0000-00000-00" then
	   continue foreach;
	end if

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_aa = _sin_pen_aa * (_porc_coaseguro / 100);

	insert into tmp_multi(no_documento, sin_pen_aa)
	values (_no_documento, _sin_pen_aa);

end foreach
--}

--trace "12";

--trace on;

-- Carga de la Table de enlace en BO

let _pos_ramo = 1;

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
		sum(pri_cob_ap_mes)
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
		_pri_cob_ap_mes
   from tmp_multi
--where no_documento <> "0808-00336-01"
  group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select cod_ramo,
	       sucursal_origen,
		   cod_subramo,
		   cod_contratante
	  into _cod_ramo,
	       _cod_agencia,
		   _cod_subramo,
		   _cod_cliente
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

	let _pos_ramo = 1;

	if _cod_ramo = "008" then
		let _pos_ramo = 2;
	elif _cod_ramo = "009" then
		if _cod_subramo = "003" then
			let _pos_ramo = 2;
		elif _cod_subramo = "004" then
			let _pos_ramo = 2;
		end if
	elif _cod_ramo = "013" then
		let _pos_ramo = 2;
	elif _cod_ramo = "014" then
		let _pos_ramo = 2;
	elif _cod_ramo = "020" then
		let _pos_ramo = 2;
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
	pri_cob_ap_mes
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
	_pri_cob_ap_mes
	);

end foreach

drop table tmp_multi;

end

return 0, "Actualizacion Exitosa";

end procedure
