-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_emireaco_salud_1;
create procedure sp_arregla_emireaco_salud_1(a_no_poliza char(10), a_no_endoso char(5), a_no_unidad char(5),a_opc smallint default 0)
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio,_valor		        integer;
define _error_isam	        integer;
define _no_tranrec,_no_reclamo        char(10); 
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

--	set debug file to "sp_reainv_amm1.trc";
--	trace on;

let _valor    = 0;
let _cod_ramo = '018';

select vigencia_inic,
       vigencia_final
  into _vigencia_inic,
       _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza
   and actualizado = 1;

select vigencia_inic
  into _fecha_actual
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and actualizado = 1;

if a_opc = 1 then
	let _fecha_actual = current;
end if

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
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;
 
 if _no_cambio is null then
	let _no_cambio = 0;
 end if	
 
select count(*)
  into _cantidad
 from emireaco
where no_poliza = a_no_poliza
  and no_unidad = a_no_unidad
  and no_cambio = _no_cambio
  and porc_partic_prima in(30,70);
  
if _cantidad is null then 
	let _cantidad = 0;
end if

if _cantidad = 0 then --Emireaco no tiene la distribucion 30/70

	let _no_cambio = _no_cambio + 1;
		 
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
			a_no_poliza, 
			a_no_unidad,
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
		a_no_poliza, 
		a_no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM rearucon
		WHERE cod_ruta = _cod_ruta;
end if
return _valor;
end
end procedure;