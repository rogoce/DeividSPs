-- Procedimiento que crea el registro de hojas para el archivo de documentos

-- Creado    : 31/08/2011 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_wf001;

create procedure sp_wf001()
returning char(10);

define _no_cotizacion	char(10);
define _cantidad		smallint;

foreach
 select nrocotizacion
   into	_no_cotizacion
   from wf_cotizacion
  where actualizado = 0

	select count(*)
	  into _cantidad
	  from emipomae
	 where cotizacion  = _no_cotizacion
	   and actualizado = 1;

	if _cantidad <> 0 then
		
		update wf_cotizacion
		   set actualizado   = 1
		 where nrocotizacion = _no_cotizacion;    

		return _no_cotizacion with resume;
	
	end if
		
end foreach

return "0"; 

end procedure

