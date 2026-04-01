-- Procedure que retorna los posibles valores de enlace para los centros de costos

-- Creado    : 26/11/2008 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac91;

create procedure sp_sac91()
returning smallint,
          char(50);


define _cod_centro		char(3);
define _nombre			char(50);
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
 select cen_codigo,
        cen_descripcion
   into _cod_centro,
        _nombre
   from sac:cglcentro

	select count(*)
	  into _cantidad
	  from saccenco
	 where cod_centro = _cod_centro;

	if _cantidad = 0 then

		insert into saccenco(
		cod_centro,
		nombre,
		tipo_centro,
		cod_enlace
		)
		values(
		_cod_centro,
		_nombre,
		999,
		"999"
		);

	else

		update saccenco
		   set nombre     = _nombre
		 where cod_centro = _cod_centro;

	end if

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure