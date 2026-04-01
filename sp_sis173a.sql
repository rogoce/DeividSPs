-- Obtener el tipo de dato de las columnas de una tabla
-- Creado    : 06/08/2012 - Autor: Roman Gordon 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis173a;

create procedure "informix".sp_sis173a(a_tabname char(20))
returning char(30),
		  char(15),
		  smallint;

define _colname			char(30);
define _coltype_char	char(15);
define _collength_char	char(3);
define _colname_len		smallint;
define _collength		smallint;
define _coltype			smallint;
define _tabid			integer;

--set debug file to "sp_sis173.trc";
--trace on;

let _coltype_char = '';

select tabid
  into _tabid
  from systables
 where tabname = a_tabname;

foreach 
	select colname,
		   coltype,
		   collength
	  into _colname,
	  	   _coltype,
		   _collength
	  from syscolumns
	 where tabid = _tabid

	if _coltype in (0,256) then
		let _collength_char = cast(_collength as char(3));
		let _coltype_char = 'char['|| trim(_collength_char) || ']';
	elif _coltype in (13,269) then
		let _collength_char = cast(_collength as char(3));
		let _coltype_char = 'varchar['|| trim(_collength_char) || ']';
	elif _coltype in (1,2,258) then
		let _coltype_char = 'integer';
	elif _coltype in (1) then
		let _coltype_char = 'smallint';
	elif _coltype in (7) then
		let _coltype_char = 'date';
	elif _coltype in (5,261) then
		let _coltype_char = 'decimal';
	end if

	let _colname_len = length(trim(_colname));
	return _colname,_coltype_char,_colname_len with resume;

end foreach
end procedure


