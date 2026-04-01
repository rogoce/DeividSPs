

DROP PROCEDURE sp_update_avisocanc;
CREATE PROCEDURE sp_update_avisocanc()
returning smallint;

DEFINE _no_aviso		CHAR(10);
DEFINE _renglon			smallint;

SET ISOLATION TO DIRTY READ;

FOREACH
	select no_aviso,
		   renglon
	  into _no_aviso,
		   _renglon
	  from avisocanc
     where fecha_proceso >= '08/04/2025'
       and fecha_proceso <= '09/04/2025'
       and estatus = 'I'
	 order by no_aviso

	update avisocanc
	   set estatus  = 'X'
	 where no_aviso = _no_aviso
       and renglon  = _renglon;
	   
END FOREACH

RETURN 0;

END PROCEDURE;