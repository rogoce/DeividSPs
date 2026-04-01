-- Procedimiento que Realiza la anulacion masiva de transaccion de pago de reclamos 
-- Elimina las transacciones de salud de la tabla temporal que fueron pagadas 

-- Creado    : 23/07/2013 - Autor: Demetrio Hurtado Almanza

drop procedure sp_rec216;

create procedure "informix".sp_rec216()
returning integer,
          char(50);

define _id				integer;
define _transaccion		char(10);
define _transaccion2	char(10);
define _no_requis		char(10);
define _no_tranrec		char(10);

define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

foreach
 select transaccion,
        id
   into _transaccion,
        _id
   from deivid_tmp:tmp_rec2013salud_3
  where cancelada = 0

	delete from deivid_tmp:tmp_rec2013salud
	 where id = _id;

	update rectrmae
	   set pagado = 1
	 where transaccion = _transaccion;

	update deivid_tmp:tmp_rec2013salud_3
	   set cancelada = 1
	 where id = _id;

end foreach

return 0, "Actualizacion Exitosa";

end procedure