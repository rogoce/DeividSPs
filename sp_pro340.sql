-- Procedimiento que carga la tabla para el presupuesto de ventas 2010

-- Creado    : 09/03/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_pro340;

create procedure "informix".sp_pro340(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning integer,
            char(50);

define _no_unidad	char(5);

define _cantidad	smallint;
define _facultativo smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _facultativo = 0;

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
	   and c.tipo_contrato     = 3
	   and f.porc_partic_prima <> 0;

	if _cantidad <> 0 then
		let _facultativo = 1;
		exit foreach;
	end if

end foreach

update endedmae
   set facultativo = _facultativo 
 where no_poliza   = a_no_poliza
   and no_endoso   = a_no_endoso;

end 

return 0, "Actualizacion Exitosa";

end procedure
