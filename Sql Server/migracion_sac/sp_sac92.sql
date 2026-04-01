-- Procedure que retorna los posibles valores de enlace para los centros de costos

-- Creado    : 26/11/2008 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac92;

create procedure sp_sac92()
returning char(10),
          char(50),
          char(20);


define _cod_enlace		char(10);
define _nombre			char(50);

define _cod_sucursal	char(3);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);


let _cod_sucursal = "001"; -- Casa Matriz

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

-- Por Definir

return "000",
       "ADMINISTRACION",
	   "ADMINISTRACION"
	   with resume;

-- Por Definir

return "999",
       "POR DEFINIR",
	   "POR DEFINIR"
	   with resume;

-- Sucursales
{
foreach
 select centro_costo
   into _cod_enlace
   from segv05:insagen
  group by centro_costo
  order by centro_costo

	select descripcion
	  into _nombre
	  from segv05:insagen
	 where codigo_agencia = _cod_enlace;

	return _cod_enlace,
	       _nombre,
		   "SUCURSALES"
		   with resume;

end foreach
}

-- Ejecutivos

foreach
 select cod_vendedor,
        nombre
   into _cod_enlace,
        _nombre
   from agtvende
  where cod_sucursal = _cod_sucursal
    and activo       = 1	

	return _cod_enlace,
	       _nombre,
		   "EJECUTIVOS"
		   with resume;

end foreach

end 

end procedure