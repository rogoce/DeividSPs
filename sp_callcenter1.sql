
--DROP PROCEDURE sp_callcenter1;
CREATE PROCEDURE "informix".sp_callcenter1()
       RETURNING  int,char(100);

DEFINE _no_poliza  CHAR(10);
DEFINE _cod_cobrador CHAR(3);
DEFINE _error        integer;
DEFINE _error_2      integer;
DEFINE _error_desc   char(50);
DEFINE _mensaje      char(100);


SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION
 
foreach

select e.no_poliza
  into _no_poliza
from emirepo e, emipomae r
 where e.no_poliza = r.no_poliza
   and r.actualizado = 1
   and r.cod_ramo = '016'
   and r.cod_subramo = '002'
   and e.estatus <> 5
   and r.cod_grupo = "01016"

 update emirepo
    set user_added = "AUTOMATI",
	    estatus = 1
  where no_poliza = _no_poliza;

end foreach

LET _mensaje = "Actualizacion Exitosa ...";

return 0,_mensaje;

END
END PROCEDURE