-- Actualizacion de valores de Nuevas y Renovadas para BO tomando en cuenta consideraciones
-- especiales para el ramo de salud

-- Creado    : 28/06/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_bo042;

create procedure "informix".sp_bo042()
returning char(20),
          date,
          date,
          integer,
          integer,
          dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_endomov		char(3);
define _prima_suscrita	dec(16,2);

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

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _no_documento	char(20);

set isolation to dirty read;

foreach
 select no_poliza,
        no_endoso,
		cod_endomov,
		prima_suscrita,
		vigencia_final,
		no_documento
   into _no_poliza,
        _no_endoso,
		_cod_endomov,
		_prima_suscrita,
		_vigencia_final,
		_no_documento
   from endedmae
  where actualizado       = 1
--	and no_documento = "1899-00388-01"
	and cod_endomov = "014"
	and no_documento[1,2] = 18
	and periodo[1,4] = 2006
  order by no_documento, vigencia_final

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "018" then -- Ramo de Salud
	
		let _dias = _vigencia_final - _vigencia_inic;

		if _dias > 366 then
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

	if _nueva_renov = "N" then -- Polizas Nuevas

		if _cod_endomov = "011" then
			let _poliza_nueva = 1;
		end if

		let _pbs_nueva_neto	= _prima_suscrita;	

		if _cod_endomov = "002" then
			let _pbs_nueva_canc	 = _prima_suscrita;
		else	
			let _pbs_nueva_nueva = _prima_suscrita;
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

		let _pbs_nueva_neto	= _prima_suscrita;	

		if _cod_endomov = "002" then
			let _pbs_nueva_canc	 = _prima_suscrita;
		else	
			let _pbs_nueva_nueva = _prima_suscrita;
		end if

	elif _nueva_renov = "S" then -- Polizas Segundo Ano Salud

		if _cod_endomov = "014" then
			let _poliza_renovada = 1;
		end if

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

		if _ano1 = _ano2 then

			return _no_documento,
				   _vigencia_inic,
				   _vigencia_final,
				   _dias,
				   _ano1,
				   _ano2
				   with resume;

		end if

		let _pbs_renov_neto	= _prima_suscrita;	

		if _cod_endomov = "002" then
			let _pbs_renov_canc	 = _prima_suscrita;
		else	
			let _pbs_renov_nueva = _prima_suscrita;
		end if

	end if

end foreach

end procedure
