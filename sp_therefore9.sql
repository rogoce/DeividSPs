-- Procedure para BUSCAR INFORMACIÓN PARA GRABAR EN EL THEREFORE
-- 
-- Creado    : 19/09/2022 - Autor: Armando Moreno M.
--

drop procedure sp_therefore9;
create procedure sp_therefore9(a_no_factura CHAR(10))
returning	char(10) as no_poliza,
            char(5) as no_endoso,
            char(20) as no_documento,
			char(10) as no_factura,
			integer  as error,
			varchar(50) as desc_error; 

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
	return null,null,null,null,_error_cod,_error_desc;
end exception

--if a_no_poliza = '0001283853' then
--set debug file to 'sp_therefore3.trc';
--trace on;
--end if
--let _no_documento = '1800-00035-01';

	  
	select no_documento,
	       no_poliza,
		   no_endoso
	  into _no_documento,
	       _no_poliza,
		   _no_endoso
	  from endedmae
	 where no_factura = a_no_factura;
	 
	return 	_no_poliza,
	        _no_endoso,
	        _no_documento,
			a_no_factura,
			0,
			"Exitoso" WITH RESUME;




end
end procedure;