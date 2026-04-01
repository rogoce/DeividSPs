-- Actualizacion de valores de Nuevas y Renovadas para BO tomando en cuenta consideraciones
-- especiales para el ramo de salud

-- Creado    : 28/06/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_bo029_jc;

create procedure "informix".sp_bo029_jc()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_endomov		char(3);
define _prima_suscrita	dec(16,2);
define _cod_perpago     char(3);

define _nueva_renov		char(1);
define _cod_ramo		char(3);
define _vigencia_inic	date;
define _vigencia_final	date;
define _dias			integer;

define _ano1			integer;
define _ano2			dec(16,1);
define _ano_bis1		integer;
define _ano_bis2		dec(16,2);
define _dias_dif		smallint;

define _poliza_nueva	smallint;
define _poliza_renovada	smallint;
define _pbs_nueva_nueva	dec(16,2);
define _pbs_nueva_canc	dec(16,2);
define _pbs_nueva_neto	dec(16,2);
define _pbs_renov_nueva	dec(16,2);
define _pbs_renov_canc	dec(16,2);
define _pbs_renov_neto	dec(16,2);

define _pbs_ant_neto	dec(16,2);
define _pbs_ant_canc	dec(16,2);
define _pbs_ant_nueva	dec(16,2);

define _emi_ano			smallint;
define _emi_ano_susc    smallint;
define _emi_ano_act     smallint;
define _meses_por       smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc);
end exception

delete from deivid_bo:boendedmae;

select emi_periodo[1,4]
  into _emi_ano
  from parparam;
  
let _emi_ano = "2019";  

let _emi_ano_act = _emi_ano;
let _emi_ano     = _emi_ano - 2;
let _meses_por   = 1;

foreach
	select no_poliza,
		   no_endoso,
		   cod_endomov,
		   prima_suscrita,
		   vigencia_final
	  into _no_poliza,
		   _no_endoso,
		   _cod_endomov,
		   _prima_suscrita,
		   _vigencia_final
	  from endedmae
	 where actualizado  = 1
	   and periodo[1,4] >= _emi_ano

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic,
		   cod_perpago,
		   year(fecha_suscripcion)
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic,
		   _cod_perpago,
		   _emi_ano_susc
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "018" then -- Ramo de Salud
	
		let _dias = _vigencia_final - _vigencia_inic;
		
		if _dias > 365 then
			let _nueva_renov = "S";
		else
			let _nueva_renov = "P";
		end if			

	end if

	let _poliza_nueva	 = 0;	
	let _poliza_renovada = 0;	
	let _pbs_nueva_nueva = 0.00;	
	let _pbs_nueva_canc	 = 0.00;	
	let _pbs_nueva_neto	 = 0.00;	
	let _pbs_renov_nueva = 0.00;	
	let _pbs_renov_canc	 = 0.00;	
	let _pbs_renov_neto	 = 0.00;
	let _pbs_ant_neto    = 0.00;
	let _pbs_ant_canc    = 0.00;
	let _pbs_ant_nueva   = 0.00;

	if _nueva_renov = "N" then -- Polizas Nuevas
	
		if _emi_ano_susc = _emi_ano_act then
			if _cod_endomov = "011" then
				let _poliza_nueva = 1;
			end if

			let _pbs_nueva_neto	= _prima_suscrita;	

			if _cod_endomov = "002" then
				let _pbs_nueva_canc	 = _prima_suscrita;
			else	
				let _pbs_nueva_nueva = _prima_suscrita;
			end if
		else
			let _pbs_ant_neto	= _prima_suscrita;	

			if _cod_endomov = "002" then
				let _pbs_ant_canc	 = _prima_suscrita;
			else	
				let _pbs_ant_nueva = _prima_suscrita;
			end if
		end if

	elif _nueva_renov = "R" then -- Polizas Renovadas

		if _cod_endomov = "011" then
			let _poliza_renovada = 1;
		end if

		let _pbs_renov_neto	= _prima_suscrita;	

		if _cod_endomov = "002" then
			let _pbs_renov_canc	 = _prima_suscrita;
		else	
			let _pbs_renov_nueva = _prima_suscrita;
		end if

	elif _nueva_renov = "P" then -- Polizas Primer Ano Salud

		if _cod_endomov = "011" then
			let _poliza_nueva = 1;
		end if
		
		if _cod_perpago = '002' then
			let _meses_por = 12;
		elif _cod_perpago = '003' then
			let _meses_por = 6;
		elif _cod_perpago = '004' then
			let _meses_por = 4;
		elif _cod_perpago = '005' then
			let _meses_por = 3;
		elif _cod_perpago = '006' then
			let _meses_por = 12;
		elif _cod_perpago = '007' then
			let _meses_por = 2;
		elif _cod_perpago = '008' then
			let _meses_por = 1;
		elif _cod_perpago = '009' then
			let _meses_por = 3;
		end if

--		let _prima_suscrita = _prima_suscrita * _meses_por;

		let _pbs_nueva_neto	= _prima_suscrita;	

		if _cod_endomov = "002" then
			let _pbs_nueva_canc	 = _prima_suscrita;
		else	
			let _pbs_nueva_nueva = _prima_suscrita;
		end if

	elif _nueva_renov = "S" then -- Polizas Segundo Ano Salud

		-- Se determina el estatus de renovada para las polizas de salud

		let _ano_bis1 = year(_vigencia_final) / 4;
		let _ano_bis2 = year(_vigencia_final) / 4;
		
		if _ano_bis1 = _ano_bis2 then
			let _dias_dif = 366;
		else
			let _dias_dif = 365;
		end if

		let _ano1 = year(_vigencia_final) - year(_vigencia_inic);
		let _ano2 = _dias / _dias_dif;
	
		if _ano1 = _ano2 then
			let _poliza_renovada = 1;
		end if

		-- Para el calculo de las primas

		let _pbs_renov_neto	= _prima_suscrita;	

		if _cod_endomov = "002" then
			let _pbs_renov_canc	 = _prima_suscrita;
		else	
			let _pbs_renov_nueva = _prima_suscrita;
		end if

	end if

	insert into deivid_bo:boendedmae(
	no_poliza,
	no_endoso,
	poliza_nueva,	
	poliza_renovada,
	pbs_nueva_emis,
	pbs_nueva_canc,	
	pbs_nueva_neto,	
	pbs_renov_nueva,
	pbs_renov_canc,	
	pbs_renov_neto,
    pbs_ant_neto,
	pbs_ant_canc,
	pbs_ant_nueva
	)
	values(
	_no_poliza,
	_no_endoso,
	_poliza_nueva,	
	_poliza_renovada,
	_pbs_nueva_nueva,
	_pbs_nueva_canc,	
	_pbs_nueva_neto,	
	_pbs_renov_nueva,
	_pbs_renov_canc,	
	_pbs_renov_neto,
	_pbs_ant_neto,
	_pbs_ant_canc,
	_pbs_ant_nueva
	);
end foreach
end
return 0, "Actualizacion Exitosa";
end procedure
