-- Poner reserva 0.00 para una transaccion

--DROP PROCEDURE sp_par253;

CREATE PROCEDURE "informix".sp_par253(
a_transaccion char(10),
a_variacion		dec(16,2)
) returning integer,
            char(50);

define _no_tranrec		char(10);
define _cantidad		smallint;
define _cod_cobertura	char(3);
	
select no_tranrec
  into _no_tranrec
  from rectrmae
 where transaccion = a_transaccion;

update rectrmae
   set variacion  = a_variacion
 where no_tranrec = _no_tranrec;

select count(*)
  into _cantidad
  from rectrcob
 where no_tranrec = _no_tranrec;

if _cantidad = 1 then

	update rectrcob
	   set variacion  = a_variacion
	 where no_tranrec = _no_tranrec;

	return 0, "Actualizacion Exitosa";

else

	let _cod_cobertura = null;

   foreach	
	select cod_cobertura
	  into _cod_cobertura
	  from rectrcob
	 where no_tranrec = _no_tranrec
	   and monto      <> 0.00
		exit foreach;
	end foreach

	if _cod_cobertura is not null then

		update rectrcob
		   set variacion     = a_variacion
		 where no_tranrec    = _no_tranrec
		   and cod_cobertura = _cod_cobertura;

		return 0, "Actualizacion Exitosa";

	else

		return 1, "Mas de 1 Cobertura";

	end if

end if

end procedure 
