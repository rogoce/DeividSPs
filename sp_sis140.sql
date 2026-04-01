-- Obtener el nombre de las columnas de la tabla cobpaex1

-- Creado    : 26/11/2010 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis140;

create procedure "informix".sp_sis140()
returning char(20);

define _tabid	integer;
define _colname	char(20);

foreach
	select tabid
	  into _tabid
	  from systables
	 where tabname in ('cobpaex1')

	foreach
		select colname
		  into _colname
		  from syscolumns
		 where tabid = _tabid

		return _colname with resume;
	end foreach
end foreach
end procedure



