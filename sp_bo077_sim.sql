-- Procedimiento que genera la informacion de las polizas nuevas y renovadas
-- en un rango de fechas 

-- Creado    : 23/02/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo077_sim;
create procedure "informix".sp_bo077_sim(a_fecha_ini date, a_fecha_fin date)
returning integer, char(50);

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
define li_dia,_cnt      integer;
define li_mes           integer;
define li_mvi,li_mpi    integer;

define _vigencia_soda	date;
define _vigencia_soda2	date;
define _reemplaza_pol	char(30);
define _no_renovar		smallint;

define _fecha_canc		date;


--set debug file to "sp_bo077.trc";
--trace on;

--drop table tmp_persis;

create temp table tmp_persis(
no_documento		char(20),
no_pol_nueva		integer		default 0,
no_pol_nueva_per	integer		default 0,
no_pol_renov		integer 	default 0,
no_pol_renov_per	integer		default 0
) with no log;

set isolation to dirty read;

let _vigencia_soda  = mdy(10, 1, 2011);
let _vigencia_soda2 = mdy(10, 1, 2012);
let _cnt            = 0;

-- Polizas Nuevas (Todos los Ramos)
-- Polizas Renovadas (Menos Salud)

foreach
	select no_poliza
	  into _no_poliza		
	  from endedmae
	 where cod_compania  = "001"
	   and actualizado   = 1
	   and cod_endomov   = "011"
	   and vigencia_inic >= a_fecha_ini
	   and vigencia_inic <= a_fecha_fin
	 
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
	 
	let _no_poliza_per = 1;
	
    if _cod_ramo = "002" then
		select count(*)
		  into _cnt
		  from emipouni
		 where no_poliza = _no_poliza
		   and cod_producto = '00318';	--Producto USADITO
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt = 0 then --No tiene USADITO, debe buscar cobertura de colision para excluirse de la persistencia.
			select count(*)
			  into _cnt
			  from emipocob
			 where no_poliza = _no_poliza
			   and cod_cobertura in('00119','00121');	--Coberturas de COLISION
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then --NO Tiene COLISION, NO debe contar para PERSISTENCIA
				let _no_poliza_per = 0;
			end if
		end if
	elif _cod_ramo = "008" then	  --fianza
		let _no_poliza_per = 0;

	elif _cod_ramo = "009" then	  --transporte

		if _cod_subramo = "003" then  --aereo
			let _no_poliza_per = 0;
		elif _cod_subramo = "004" then --Maritimo
			let _no_poliza_per = 0;
		end if

		if _no_renovar = 1 then
			let _no_poliza_per = 0;
		end if

	elif _cod_ramo = "013" then	 --Montaje
		let _no_poliza_per = 0;

	elif _cod_ramo = "014" then	 --car
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

	if _nueva_renov = "N" then

		insert into tmp_persis(no_documento, no_pol_nueva, no_pol_nueva_per)
		values (_no_documento, 1, _no_poliza_per);

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
			
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per)
			values (_no_documento, 1, _no_poliza_per);

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

	if _estatus_poliza = 2 then	 --esta cancelada
		continue foreach;
	end if

	if (_vigencia_act - _vigencia_ant) >= 365 then
	
		insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per)
		values (_no_documento, 1, 1);

	end if	
end foreach
return 0, "Actualizacion Exitosa";
end procedure