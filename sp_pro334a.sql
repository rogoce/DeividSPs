-- Creado    : 12/07/2010 - Autor: Armando Moreno M.

-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_pro334a;

CREATE PROCEDURE "informix".sp_pro334a(a_old_usr char(8), a_new_usr char(8))
RETURNING integer;


define _no_poliza      CHAR(10); 
define _user_added     char(8);

--SET DEBUG FILE TO "sp_pro334.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

update emirepo
   set user_added = a_new_usr
 where user_added = a_old_usr;

update emirepo
   set user_cobros = a_new_usr
 where user_cobros = a_old_usr;


return 0;

END PROCEDURE;
