-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro545;

create procedure sp_pro545(a_no_documento	char(20))
returning	int,
			char(50);

define _error_desc		char(50);
define _documento		char(10);
define _no_remesa		char(10);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_endomov		char(3);
define _tipo_doc		char(1);
define _cnt_credito		smallint;
define _renglon			smallint;
define _fecha_emision	date;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_movimientos;
	drop table tmp_emiletra;

	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_documento) || trim(_error_desc);
	return _error, _error_desc;
end exception

--set debug file to "sp_pro545.trc";
--trace on;

foreach
	select distinct no_documento
	  into _no_documento
	  from emiletra
	 order by 1

	foreach
		select no_poliza,
			   no_letra
		  into _no_poliza,
			   _no_letra
		  from emiletra
		 where no_documento = _no_documento
		 order by vigencia_inic
end foreach
end
end procedure;