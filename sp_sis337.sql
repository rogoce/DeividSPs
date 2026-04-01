
-- Creado    : 14/10/2011 - Autor: Armando Moreno

drop procedure sp_sis337;

create procedure "informix".sp_sis337(a_no_eval char(10))
RETURNING INTEGER;

define _cnt		        integer;

--SET DEBUG FILE TO "sp_sis336.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

SELECT count(*)
  INTO _cnt
  FROM emievalu
 WHERE no_evaluacion = a_no_eval
   AND usuario_eval is not null;

if _cnt = 0 then
	RETURN _cnt;
end if

END
RETURN 1;
end procedure;


