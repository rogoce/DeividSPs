-- Obtener el nombre de las columnas de una tabla
-- Creado    : 01/08/2012 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis140b;

create procedure "informix".sp_sis140b(a_tabname char(20))
returning char(25);

define _tabid	integer;
define _colname	char(25);

select tabid
  into _tabid
  from systables
 where tabname = a_tabname;

foreach
	select colname
	  into _colname
	  from syscolumns
	 where tabid = _tabid

return _colname with resume;
end foreach

end procedure



