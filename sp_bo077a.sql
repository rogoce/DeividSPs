-- Procedimiento que genera la informacion de las polizas nuevas y renovadas
-- en un rango de fechas 
-- Creado    : 23/02/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo077_ind;
create procedure "informix".sp_bo077_ind(a_no_documento char(20),a_fecha_ini date, a_fecha_fin date)
returning integer, char(20),date,date,date;

define _no_poliza		char(10);
define _no_documento	char(20);
define _nueva_renov		char(1);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _estatus_poliza	integer;

define _no_poliza_per	integer;

define _vigencia_inic	date;
define _vigencia_final	date;
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;

define _periodo_ini		char(7);
define _periodo_fin		char(7);
define _periodo_reno	char(7);
define _ano_ant			integer;
define li_dia           integer;
define li_mes           integer;
define li_mvi,li_mpi    integer;

define _vigencia_soda	date;
define _vigencia_soda2	date;
define _reemplaza_pol	char(30);
define _no_renovar,_pagada	smallint;
define _cnt_cam				smallint;

define _fecha_canc		date;


--set debug file to "sp_bo077.trc";
--trace on;

--drop table tmp_persis;

create temp table tmp_persis(
no_documento		char(20),
no_pol_nueva		integer		default 0,
no_pol_nueva_per	integer		default 0,
no_pol_renov		integer 	default 0,
no_pol_renov_per	integer		default 0,
cambio_plan         integer     default 0,
vigencia_inic       date        
) with no log;

set isolation to dirty read;

let _vigencia_soda  = mdy(10, 1, 2011);
let _vigencia_soda2 = mdy(10, 1, 2012);

-- Polizas Nuevas (Todos los Ramos)
-- Polizas Renovadas (Menos Salud)
let _vigencia_inic = '01/01/1900';
let _vigen_ini     = '01/01/1900';
let _vigencia_ant  = '01/01/1900';
let _vigencia_act  = '01/01/1900';

foreach
	select no_poliza
	  into _no_poliza		
	  from endedmae
	 where cod_compania  = "001"
	   and actualizado   = 1
	   and cod_endomov   = "011"
	   and vigencia_inic >= a_fecha_ini
	   and vigencia_inic <= a_fecha_fin
	   and no_documento = a_no_documento
	 
	let _fecha_canc = null; 

	select nueva_renov,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_subramo,
		   estatus_poliza,
		   reemplaza_poliza,
		   no_renovar,
		   fecha_cancelacion
	  into _nueva_renov,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_subramo,
		   _estatus_poliza,
		   _reemplaza_pol,
		   _no_renovar,
		   _fecha_canc
	  from emipomae
	 where no_poliza = _no_poliza;

	let _reemplaza_pol = TRIM(_reemplaza_pol);
	let _no_poliza_per = 1;
	if _cod_ramo = "008" then	        --fianza
		let _no_poliza_per = 0;
	elif _cod_ramo = "009" then	        --transporte
		if _cod_subramo = "003" then    --aereo
			let _no_poliza_per = 0;
		elif _cod_subramo = "004" then  --Maritimo
			let _no_poliza_per = 0;
		end if
		if _no_renovar = 1 then
			let _no_poliza_per = 0;
		end if
	elif _cod_ramo = "013" then	        --Montaje
		let _no_poliza_per = 0;
	elif _cod_ramo = "014" then	        --car
		let _no_poliza_per = 0;

	-- Por instrucciones del Sr. Tobias, las Sodas se van a renovar a Partir de Octubre 2012
	-- Demetrio Hurtado (02/10/2012)
	elif _cod_ramo = "020" then	 -- Soda 
		let _no_poliza_per = 0;
	end if

	if _cod_ramo <> "018" then

		if (_vigencia_final - _vigencia_inic) < 365 then
			let _no_poliza_per = 0;
		end if

	end if
    let _pagada  = 0;
	let _cnt_cam = 0;
	if _nueva_renov = "N" then
		if _cod_ramo = "018" then
			IF _reemplaza_pol <> "" or _reemplaza_pol is not null then
				let _cnt_cam = 0;
				select count(*)
				  into _cnt_cam
				  from endedmae
				 where actualizado = 1
				   and no_documento = _reemplaza_pol
				   and cod_tipocan = '018';  --cambio de plan
				if _cnt_cam is null then
					let _cnt_cam = 0;
				end if
			END IF	   
		end if   
		select pagada
		  into _pagada
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = 1;
		   
		if _pagada = 0 then        -- tomar en cuenta solo las del primer pago
			continue foreach;
		end if
		if _cnt_cam > 0 then	   --tiene cambio de plan, debe colocarse como renovada
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_inic)
			values (_no_documento, 1, 1,1,_vigencia_inic);
		else		
			insert into tmp_persis(no_documento, no_pol_nueva, no_pol_nueva_per,cambio_plan,vigencia_inic)
			values (_no_documento, 1, _no_poliza_per,0,_vigencia_inic);
		end if	

	else

		if _estatus_poliza = 2 then  --esta cancelada
			if _fecha_canc is not null then
				if _fecha_canc > a_fecha_fin then
				else
					continue foreach;
				end if
			end if	
		end if

		if _cod_ramo <> "018" then
			
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_inic)
			values (_no_documento, 1, _no_poliza_per,0,_vigencia_inic);

		end if

	end if
end foreach

-- Polizas Renovadas Salud

let _periodo_ini = sp_sis39(a_fecha_ini);
let _periodo_fin = sp_sis39(a_fecha_fin);

foreach
	select no_documento,
		   max(periodo)
	  into _no_documento,
		   _periodo_reno
	  from endedmae
	 where periodo     >= _periodo_ini
	   and periodo     <= _periodo_fin
	   and actualizado = 1
	   and cod_endomov = "014"
	   and no_documento = a_no_documento
	 group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_inic,
		   estatus_poliza
	  into _vigen_ini,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _periodo_ini[1,4] = _periodo_reno[1,4] then
		let _ano_ant     = _periodo_fin[1,4] - 1;
	elif _periodo_reno[1,4] > _periodo_ini[1,4] then
	    let li_mvi = month(_vigen_ini);
		let li_mpi = _periodo_ini[6,7];
	    if li_mvi >= li_mpi then
			let _ano_ant     = _periodo_fin[1,4] - 2;
		else
			let _ano_ant     = _periodo_fin[1,4] - 1;
		end if
	else 
		let _ano_ant     = _periodo_fin[1,4] - 1;
	end if	
   	let _vigencia_ant = mdy(month(_vigen_ini), day(_vigen_ini), _ano_ant);

	let li_dia = day(_vigen_ini);
	let li_mes = _periodo_reno[6,7];

	If li_mes = 2 Then
		If li_dia > 28 Then
			let li_dia = 28;
	    	let _vigencia_act = mdy(_periodo_reno[6,7], li_dia, _periodo_reno[1,4]);
		else
			let _vigencia_act = mdy(_periodo_reno[6,7], day(_vigen_ini), _periodo_reno[1,4]);
		End If
	else
		let _vigencia_act = mdy(_periodo_reno[6,7], day(_vigen_ini), _periodo_reno[1,4]);
	End If

	if _vigencia_ant < _vigen_ini then
		continue foreach;
	end if

	let _pagada = 0;
	if (_vigencia_act - _vigencia_ant) >= 365 then
	
		select pagada
		  into _pagada
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = 1;
		   
		if _pagada = 0 then        -- tomar en cuenta solo las del primer pago
			continue foreach;
		end if
	
		insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_inic)
		values (_no_documento, 1, 1,0,_vigen_ini);

	end if	
end foreach
return 0, _no_documento,_vigencia_ant,_vigencia_act,_vigen_ini;
end procedure