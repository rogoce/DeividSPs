-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

--DROP PROCEDURE sp_rwf79;

create procedure "informix".sp_rwf79(
a_requis 		char(10), 
a_renglon 		int, 
a_desc      	varchar(100))
returning       integer;

define _error	integer;

--SET DEBUG FILE TO "sp_rwf62.trc";
--TRACE ON ;

set lock mode to wait 60;

begin
on exception set _error
	return _error;
end exception

insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
values(
	a_requis,   
   	a_renglon, 	 
	a_desc	 
	); 

end

return 0;

end procedure
