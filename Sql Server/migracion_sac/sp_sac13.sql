-- Procedure que Verifica si se crearon los registro contable para no crearlos denuevo

-- Creado    : 26/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac13;

create procedure sp_sac13(
a_periodo	char(7),
a_origen	smallint
) returning integer;

define _cantidad	integer;

set isolation to dirty read;

return 0;

if a_origen = 1 then -- Produccion

	select	count(*)
	  into	_cantidad
	  from	endedmae e, endasien a
	 where e.periodo     = a_periodo
	   and e.no_poliza   = a.no_poliza
	   and e.no_endoso   = a.no_endoso
	   and e.actualizado = 1;

	return _cantidad;
		
elif a_origen = 2 then -- Reclamos

	select	count(*)
	  into	_cantidad
	   from	rectrmae e, recasien a
	  where e.periodo     = a_periodo
	    and e.no_tranrec  = a.no_tranrec
		and e.actualizado = 1;

	return _cantidad;

end if

end procedure