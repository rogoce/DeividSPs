-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro543;

create procedure sp_pro543()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
	rollback work;
	return _error, _error_desc;
end exception

--set debug file to "sp_pro543.trc";
--trace on;

let _no_documento = '';
let _no_poliza = '';

foreach with hold
	select distinct l.no_poliza
	  into _no_poliza
	  from emiletra l, emipomae e
	 where l.no_poliza = e.no_poliza
	   and l.no_documento is null
	   --and e.cod_ramo = '018'
	 order by l.no_poliza desc

	begin work;
	
	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	update emiletra
	   set no_documento = _no_documento
	 where no_poliza = _no_poliza;

	commit work;
end foreach
end

return 0, "Actualizacion Exitosa";
end procedure
