-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 04/06/2010 - Autor: Itzis Nunez 

drop procedure sp_pro343;

create procedure "informix".sp_pro343(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning integer,
            char(50);

define _no_unidad	char(5);

define _cantidad	smallint;
define _fronting smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fronting = 0;

foreach
 select no_unidad
   into _no_unidad
   from endeduni
  where no_poliza = a_no_poliza
    and no_endoso = a_no_endoso

	select count(*)
	  into _cantidad
	  from emifacon f, reacomae c
	 where f.no_poliza         = a_no_poliza
	   and f.no_endoso         = a_no_endoso
	   and f.no_unidad         = _no_unidad
	   and f.cod_contrato      = c.cod_contrato
	   and c.fronting          = 1
	   and f.porc_partic_prima <> 0;

	if _cantidad <> 0 then
		let _fronting = 1;
		exit foreach;
	end if

end foreach

update endedmae
   set fronting  = _fronting 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _fronting = 1 then

	update emipomae
	   set fronting  = _fronting 
	 where no_poliza = a_no_poliza;

end if

end 

return 0, "Actualizacion Exitosa";

end procedure
