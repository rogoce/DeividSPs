-- Actualizacion de monto al salir de pantalla de pagos de cierre automatico

-- Creado    : 04/02/2010 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob235;

create procedure sp_cob235(a_no_caja char(10),a_total_pagos dec(16,2),a_en_balance integer)
returning integer,
          char(100);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

on exception set _error, _error_isam, _error_desc
   return _error, _error_desc;
end exception

update cobcieca
   set total_pagos = a_total_pagos,
       en_balance  = a_en_balance
 where no_caja     = a_no_caja;

return 0, "Actualizacion Exitosa";

end procedure