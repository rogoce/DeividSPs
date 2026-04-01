-- Procedure que cierra los reclamos de manera masiva 

-- Creado    : 10/12/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec179;

create procedure sp_rec179()
returning char(20),
		  char(10),
		  char(10),
		  dec(16,2);

define _no_tranrec		char(10);
define _transaccion		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);

set isolation to dirty read;

foreach
 select reclamo
   into _numrecla
   from deivid_tmp:tmp_reservas_4
  where actualizado = 1

	select transaccion,
		   no_tranrec,
		   variacion
	  into _transaccion,
	       _no_tranrec,
		   _reserva
	  from rectrmae
	 where numrecla     = _numrecla
	   and cod_tipotran = "011"
	   and periodo      = "2011-01";
	  
	if _transaccion is not null then

		update rectrmae
		   set fecha      = "31/12/2010",
		       periodo    = "2010-12"
		 where no_tranrec = _no_tranrec;

		return _numrecla,
		       _transaccion,
		       _no_tranrec,
		       _reserva  
			   with resume;

	end if

end foreach

return "",
	   "",
	   "",
	   0
	   with resume;

end procedure