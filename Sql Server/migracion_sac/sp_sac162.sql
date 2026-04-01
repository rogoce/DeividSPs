-- Procedure que Elimina un comprobante

-- Creado    : 26/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac162;

create procedure sp_sac162()
returning integer,
          char(50);

define _notrx 		integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

foreach
 select trx1_notrx
   into _notrx
   from cgltrx1
  where trx1_origen = "PRO"

	call sp_sac36(_notrx) returning _error, _error_desc;

end foreach

return 0, "Actualizacion Exitosa";

end procedure