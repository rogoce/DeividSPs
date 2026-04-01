-- Procedure que guarda la poliza que se envio a imprimir
-- desde el pool de impresion.


-- Creado    : 30/11/2009 - Autor: Armando Moreno
-- Modificado: 15/01/2013 - Autor: Roman Gordon -- se modifica para que actualice la fecha y el usuario que se imprimio la póliza.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro984;

create procedure sp_pro984(a_no_poliza char(10),a_usuario char(8),a_documento char(20))
RETURNING smallint;

define _cantidad	 smallint;

set lock mode to wait;

select count(*)
  into _cantidad
  from emireimp
 where no_poliza = a_no_poliza;

if _cantidad <> 0 then
	update emireimp
	   set fecha_impresion	= current,
		   user_imprimio	= a_usuario
	 where no_poliza = a_no_poliza;
else
	insert into emireimp(
	no_poliza,		  
	no_documento,
	fecha_impresion,
	user_imprimio
	)
	VALUES (
	a_no_poliza,
	a_documento,
	current,
	a_usuario);
end if

return 0;
end procedure