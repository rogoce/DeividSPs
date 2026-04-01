drop procedure sp_tmp01;
create procedure sp_tmp01(a_cod_agente char(10), a_no_remesa char(10), a_numero char[10])
returning integer,
          char(100);

define _numero	char(10);
define _cant	integer;
define _error	integer;