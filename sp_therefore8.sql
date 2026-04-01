-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore8;
create procedure sp_therefore8(a_no_factura char(10))
returning	smallint as exito; 

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
	return _error_cod;
end exception

--if a_no_poliza = '0001283853' then
--set debug file to 'sp_therefore3.trc';
--trace on;
--end if
--let _no_documento = '1800-00035-01';

 update	deivid_tmp:pen_therefore
    set procesado = 1
  where no_factura = a_no_factura;
	  
  RETURN 0;
end
end procedure;