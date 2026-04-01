-- Obtener el tipo de dato de las columnas de una tabla
-- Creado    : 06/08/2012 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis173b;

create procedure "informix".sp_sis173b(a_tabname char(20),a_colno smallint)
returning char(40);

define _tabid	integer;
define _colname	char(40);

--set debug file to "sp_sis173b.trc";
--trace on;

let _colname = '';

select tabid
  into _tabid
  from systables
 where tabname = a_tabname;

select colname
  into _colname
  from syscolumns
 where tabid = _tabid
   and colno = a_colno;

return _colname;

end procedure


