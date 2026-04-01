-- Procedimiento que carga la tabla para el presupuesto de ventas 2010

-- Creado    : 04/06/2010 - Autor: Itzis Nunez 

drop procedure sp_it_fronting;

create procedure "informix".sp_it_fronting(
) returning integer,
            char(50);

define _no_poliza	char(10);
define _no_endoso	char(5);

define _fronting smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--let _fronting = 0;

foreach
	select no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from emifacon f, reacomae c
	 where f.cod_contrato      = c.cod_contrato
	   and c.fronting     = 1
	   and f.porc_partic_prima <> 0
	   --and f.cod_contrato = '00589'

	update endedmae
	   set fronting = 1 
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso;
	

end foreach


end 

return 0, "Actualizacion Exitosa";

end procedure
