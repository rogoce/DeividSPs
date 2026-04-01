
create procedure "informix".sp_rec132()
returning integer,
          char(50);

define _no_reclamo		char(10);
define _no_tranrec		char(10);
define _cod_cobertura	char(5);
define _monto			dec(16,2);

foreach
 select no_reclamo,
        no_tranrec
   into _no_reclamo,
        _no_tranrec
   from rectrmae
  where periodo     = "2006-09"
    and actualizado = 1
	and user_added  = "GERENCIA"

	foreach
	 select cod_cobertura,
	        monto
	   into _cod_cobertura,
	        _monto
	   from rectrcob
	  where no_tranrec = _no_tranrec

		update recrccob
		   set reserva_actual = reserva_actual - _monto
		 where no_reclamo     = _no_reclamo
		   and cod_cobertura  = _cod_cobertura;

	end foreach

end foreach   

return 0, "Actualizacion Exitosa";

end procedure