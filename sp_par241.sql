-- Poner reserva 0.00 para una transaccion

--DROP PROCEDURE sp_par241;

CREATE PROCEDURE "informix".sp_par241(
a_transaccion char(10)
) returning integer,
            char(50);

define _no_tranrec	char(10);

select no_tranrec
  into _no_tranrec
  from rectrmae
 where transaccion = a_transaccion;

update rectrcob
   set variacion  = 0
 where no_tranrec = _no_tranrec;

update rectrmae
   set variacion  = 0
 where no_tranrec = _no_tranrec;

return 0, "Actualizacion Exitosa";

end procedure 
