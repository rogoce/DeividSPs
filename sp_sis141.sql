-- Obtener el nombre de las columnas de la tabla cobpaex0

-- Creado    : 26/11/2010 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis141;

create procedure "informix".sp_sis141()
returning char(20);

define _tabid	integer;
define _colname	char(20);

select tabid
  into _tabid
  from systables
 where tabname = 'cobpaex0';

foreach
	select colname
	  into _colname
	  from syscolumns
	 where tabid = _tabid

return _colname with resume;
end foreach

end procedure



