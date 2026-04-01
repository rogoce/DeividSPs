-- Obtener el tipo de dato de las columnas de una tabla
-- Creado    : 06/08/2012 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis173;

create procedure "informix".sp_sis173(a_tabname char(20),a_colname char(30))
returning char(10);

define _tabid			integer;
define _coltype			smallint;
define _coltype_char	char(10);

--set debug file to "sp_sis173.trc";
--trace on;

let _coltype_char = '';

select tabid
  into _tabid
  from systables
 where tabname = a_tabname;

select coltype
  into _coltype
  from syscolumns
 where tabid = _tabid
   and colname = a_colname;

if _coltype in (0,13,256,269) then
	let _coltype_char = 'char';
elif _coltype in (1,2,258) then
	let _coltype_char = 'int';
elif _coltype in (7,263) then
	let _coltype_char = 'date';
elif _coltype in (5,261) then
	let _coltype_char = 'decimal';
end if

return _coltype_char;

end procedure


