-- Procedimiento que retorna el windows user

-- Creado    : 01/02/2013 - Autor: Amado Perez M 

--drop procedure sp_rwf112;

create procedure sp_rwf112(a_usuario char(8))
returning varchar(20);

define _windows_user	varchar(20);

set isolation to dirty read;

select windows_user
  into _windows_user
  from insuser
 where usuario = upper(a_usuario);

return _windows_user;


end procedure