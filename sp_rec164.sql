-- Procedimiento que carga las transacciones de perdida total de un ano
 
-- Creado     :	23/01/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec164;

create procedure sp_rec164(a_ano smallint)
returning integer,
          char(50);

define _no_tranrec	char(10);
define _error		integer;
define _error_desc	char(50);

foreach
 select	no_tranrec
   into _no_tranrec
   from rectrmae
  where periodo[1,4] = a_ano
    and actualizado  = 1
	and perd_total   = 1

	call sp_rec163(_no_tranrec) returning _error, _error_desc;	

	return _error,
	       _error_desc
		    with resume;

end foreach

return 0, "Actualizacion Exitosa";

end procedure