-- Procedimiento que Determina el Coaseguro y el Reaseguro por Transaccion
-- 
-- Creado    : 05/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_sis58('')

DROP PROCEDURE sp_reainv16;		

CREATE PROCEDURE "informix".sp_reainv16()
RETURNING INTEGER, CHAR(250);

define _cantidad		integer;

DEFINE _no_remesa	CHAR(10); 
define _renglon     integer;
define _error			integer;
define _error_desc	char(50);

SET ISOLATION TO DIRTY READ;

begin
on exception set _error
	return _error, "Error al Generar el Reaseguro de la Transaccion";
end exception

foreach
select no_remesa,
       renglon
  into _no_remesa,	  
       _renglon
  from cobreaco_cam	   

delete from cobreaco where no_remesa = _no_remesa and renglon = _renglon;

end foreach
end

return 0, "Actualizacion Exitosa ...";

end procedure