-- Procedure que Actualiza los valores de los modelos (Grande, Mediano, Pequeño)

-- Creado    : 10/07/2013 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure amado_zona;

create procedure "informix".amado_zona(a_poliza varchar(10)) 
returning integer,
		  char(50);

define _no_reclamo	char(10);
define _cod_marca	char(5);
define _cod_modelo	char(5);
define _tamano      smallint;

define _error           integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_rwf115.trc ";
--TRACE ON;

begin

on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach	with hold

	select no_unidad
	  into _no_reclamo
	  from emipouni
	 where no_poliza = trim(a_poliza) 
	   and activo = 1

   select count(*) 
     into _tamano
	 from emifacon
	where no_poliza = trim(a_poliza)
	  and no_unidad = _no_reclamo
	  and no_endoso = "00000";

   if _tamano = 0 then 
     return _no_reclamo, "no esta" with resume;
   end if

end foreach

--return 0, "Actualizacion Exitosa";

end

end procedure
