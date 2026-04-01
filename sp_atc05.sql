-- Procedure que carga los registros de imagenes respaldadas

drop procedure sp_atc05;

create procedure sp_atc05()
returning integer,
          char(50),
          integer,
          char(10),
          char(10);

define _cod_asignacion	char(10);
define _cod_asignacion1	char(10);
define _cantidad		smallint;
define _cant_reg		integer;
define _cant_pro		integer;
define _cant_tot		integer;

define _ano_imagen		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, _error_isam, _cod_asignacion, "";
end exception

let _cant_reg = 0;
let _cant_tot = 0;
let _cant_pro = 100;

foreach	with hold
 select	cod_asignacion,
        year(fecha_completado)
   into _cod_asignacion,
		_ano_imagen
   from imagen:atcdocfa
  	
	if _cant_reg = 0 then
		begin work;
		let _cod_asignacion1 = _cod_asignacion;
	end if

	let _cant_tot = _cant_tot + 1;
	let _cant_reg = _cant_reg + 1;

	select count(*)
	  into _cantidad
	  from atcdocde
	 where cod_asignacion = _cod_asignacion;

	if _cantidad = 0 then

		insert into atcdocde
		select * from imagen:atcdocfa
		 where cod_asignacion = _cod_asignacion;

	end if

	if _ano_imagen <= 2006 then

		update atcdocde
		   set datos_adjuntos = null
		 where cod_asignacion = _cod_asignacion;

	end if

	if _cant_reg >= _cant_pro then
		commit work;
		return 0, "Actualizacion Exitosa ", _cant_tot, _cod_asignacion1, _cod_asignacion with resume;
		let _cant_reg = 0;
	end if

{
	if _cant_tot >= 150 then
		exit foreach;
	end if
}

end foreach

if _cant_reg < _cant_pro and _cant_reg <> 0 then
	commit work;
	return 0, "Actualizacion Exitosa ", _cant_tot, _cod_asignacion1, _cod_asignacion with resume;
	let _cant_reg = 0;
end if

end 

return 0, "Actualizacion Exitosa ", _cant_tot, "", "";
 
end procedure