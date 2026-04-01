-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_emireaco_auto;
create procedure sp_arregla_emireaco_auto(a_no_reclamo char(10), a_opc smallint default 0)
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio,_valor		        integer;
define _error_isam	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad           char(5);
define _cantidad,_renglon,_cant_ruta            smallint;
define _porc_suma,_porcentaje  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic,_fecha_actual date;
define _mensaje 			varchar(250);

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

if a_no_reclamo = '1065586' and a_opc = 1 then
	set debug file to "sp_reainv_amm1.trc";
	trace on;
end if

let _fecha_actual = current;
let _valor = 0;

if a_opc = 0 then
	select no_poliza,
		   no_unidad
	  into _no_poliza,
		   _no_unidad
	  from recrcmae
	 where no_reclamo = a_no_reclamo;
else
	let _no_poliza = a_no_reclamo;
end if

select cod_ramo,
	   vigencia_inic,
	   vigencia_final
  into _cod_ramo,
	   _vigencia_inic,
	   _vigencia_final
  from emipomae
 where no_poliza = _no_poliza;
 
select cod_ruta
  into _cod_ruta
  from rearumae
 where cod_ramo = _cod_ramo
   and activo = 1
   and _fecha_actual between vig_inic and vig_final;
 
let _no_cambio = 0;

select max(no_cambio)
  into _no_cambio
  from emireaco
 where no_poliza = _no_poliza;
 
 if _no_cambio is null then
	let _no_cambio = 0;
 end if	
 
if a_opc = 1 then
	 select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
end if	   
 
let _cant_ruta = 0;
if _cod_ramo = '018' then
	select count(distinct porc_partic_suma)
	  into _cant_ruta
	  from rearucon
	 where cod_ruta in(
	select cod_ruta from rearumae
	 where cod_ramo = _cod_ramo
	   and activo = 1
	   and _fecha_actual between vig_inic and vig_final);
else
	select count(distinct cod_cober_reas)
	  into _cant_ruta
	  from rearucon
	 where cod_ruta in(
	select cod_ruta from rearumae
	 where cod_ramo = _cod_ramo
	   and activo = 1
	   and _fecha_actual between vig_inic and vig_final);
end if
--************************************		
let _cantidad = 0;
if _cod_ramo = '018' then
	select count(distinct porc_partic_suma)
	  into _cantidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_cambio = _no_cambio;
else
	select count(distinct cod_cober_reas)
	  into _cantidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_cambio = _no_cambio;
end if

if _cantidad = _cant_ruta then
else
--Emireaco no tiene completas las coberturas de reaseguro, hay que insertarlo.
	let _no_cambio = _no_cambio + 1;
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		 
		foreach
			select distinct cod_cober_reas
			  into _cod_cober_reas
			  from rearucon
			 where cod_ruta = _cod_ruta

			INSERT INTO emireama(
			no_poliza,
			no_unidad,
			no_cambio,
			cod_cober_reas,
			vigencia_inic,
			vigencia_final
			)
			VALUES(
			_no_poliza, 
			_no_unidad,
			_no_cambio,
			_cod_cober_reas,
			_vigencia_inic,
			_vigencia_final
			);
		end foreach
		
		INSERT INTO emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		)
		SELECT 
		_no_poliza, 
		_no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM rearucon
		WHERE cod_ruta = _cod_ruta;
	end foreach
	if a_opc = 0 then
		call sp_sis18(a_no_reclamo) returning _cantidad, _error_desc;
		let _valor = _cantidad;
	end if
end if
return _valor;
end
end procedure;