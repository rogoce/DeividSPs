-- Verificacion de la Informacion de Reclamos

--DROP PROCEDURE sp_par21;

CREATE PROCEDURE "informix".sp_par21()

define _no_reclamo char(10);
define _orden      smallint;

foreach
 select no_tranrec,
        orden
   into _no_reclamo,
        _orden
   from rectrrea
  where porc_partic_suma  = 0
    and porc_partic_prima = 0
  
	begin
	on exception in(-692)
	end exception

		delete from rectrrea
		 where no_tranrec = _no_reclamo
		   and orden      = _orden;

	end

end foreach

end procedure;