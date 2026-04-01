-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_emireaco_salud;
create procedure sp_arregla_emireaco_salud(a_no_reclamo char(10))
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

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _cantidad = 0;

select count(*)
  into _cantidad
  from recreaco
 where no_reclamo = a_no_reclamo 
   and porc_partic_suma not in(30,70);

if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad > 0 then
	DELETE FROM recreaco WHERE no_reclamo = a_no_reclamo;

	INSERT INTO recreaco(
	no_reclamo,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima,
	cod_cober_reas)
	values(
	a_no_reclamo,
	5,
	'00801',
	30,
	30,
	'019');

	INSERT INTO recreaco(
	no_reclamo,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima,
	cod_cober_reas)
	values(
	a_no_reclamo,
	6,
	'00800',
	70,
	70,
	'019');
end if

return 0;
end
end procedure;