-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore7;
create procedure sp_therefore7()
returning	char(10) as no_poliza,
            char(5) as no_endoso,
            char(20) as no_documento,
			char(10) as no_factura; 

define _error_desc			varchar(50);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_endoso			char(10);
define _error_isam			integer;
define _error_cod			integer;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod,null,null,null;
end exception

--if a_no_poliza = '0001283853' then
--set debug file to 'sp_therefore3.trc';
--trace on;
--end if
--let _no_documento = '1800-00035-01';

FOREACH 
    select no_factura
	  into _no_factura
	  from deivid_tmp:pen_therefore
	 where procesado = 0
	  
	select no_documento,
	       no_poliza,
		   no_endoso
	  into _no_documento,
	       _no_poliza,
		   _no_endoso
	  from endedmae
	 where no_factura = _no_factura;
	 
	return 	_no_poliza,
	        _no_endoso,
	        _no_documento,
			_no_factura WITH RESUME;
END FOREACH



end
end procedure;