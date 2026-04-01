
drop procedure sp_sis200;

create procedure "informix".sp_sis200()--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje			char(250);
define _no_remesa		char(10);
define _cod_cober_reas	char(3);
define _porc_proporcion	dec(16,2);
define _error_isam		integer;
define _renglon			integer;
define _error			integer;

set isolation to dirty read;

--set debug file to "sp_sis200.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

foreach
	select t.no_remesa,
		   t.renglon,
		   c.cod_cober_reas,
		   porc_proporcion
	  into _no_remesa,
		   _renglon,
		   _cod_cober_reas,
		   _porc_proporcion
	  from movim_tec_pri_tt t, cobreaco c
	 where t.no_remesa = c.no_remesa
	   and t.renglon = c.renglon
	   and t.flag = 1
	 group by 1,2,3,4
	 
	update cobreaco
	   set porc_proporcion = 100
	 where no_remesa = _no_remesa
	   and renglon = _renglon
	   and cod_cober_reas = _cod_cober_reas;
end foreach

end
end procedure;