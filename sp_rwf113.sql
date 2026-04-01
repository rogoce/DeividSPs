-- Procedimiento que retorna el windows user

-- Creado    : 01/02/2013 - Autor: Amado Perez M 

drop procedure sp_rwf113;

create procedure sp_rwf113(a_windows_user char(20))
returning smallint;

define _salud_default	smallint;

set isolation to dirty read;

select salud_default 
  into _salud_default 
  from wf_firmas 
 where windows_user = a_windows_user;

return _salud_default;


end procedure