-- Obtener el nombre de las columnas de la tabla enviada
-- Creado    : 26/11/2010 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis140a;

create procedure "informix".sp_sis140a(a_table char(15))
returning char(20);

define _tabid	integer;
define _colname	char(20);

select tabid
  into _tabid
  from systables
 where tabname = a_table;

foreach
	select colname
	  into _colname
	  from syscolumns
	 where tabid = _tabid
	   and coltype = 13		--varchar
   	   and collength = 255	


return _colname with resume;
end foreach

end procedure



