-- Procedure que arregla que cuadre cglresumen vs cglresumen1

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac133;

create procedure sp_sac133()
returning integer,
          char(50);

define _notrx	integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin work;

foreach
 select res_notrx
   into _notrx
   from cglresumen
  where res_origen          = "COB"
    and year(res_fechatrx)  = 2009
	and month(res_fechatrx) = 12
  group by res_notrx
  order by res_notrx

	call sp_sac105(_notrx) returning _error, _error_desc; 	

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

	return _notrx, "Transaccion Eliminada" with resume;

end foreach

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure