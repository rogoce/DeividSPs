-- Procedure que Retorna el Usuario ejecuntado un proceso
-- 
-- Creado    : 19/01/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis84;

create procedure sp_sis84()
returning char(32); 

define _username	char(32);
define _sessionid	integer;

--SET DEBUG FILE TO "sp_sis84.trc";
--TRACE ON;

--return "informix";

let _sessionid = DBINFO('sessionid');

select tty
  into _username
  from sysmaster:syssessions
 where sid = _sessionid;

return _username;

end procedure
