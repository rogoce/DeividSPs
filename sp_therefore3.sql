-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore3;
create procedure sp_therefore3(a_no_poliza CHAR(10))
returning	char(20) as no_documento,
			varchar(100) as contratante,
			varchar(50) as corredor,
			char(30) as cedula,
			char(10) as cod_contratante; 

define _n_contratante2	    varchar(100);
define _n_contratante	    varchar(100);
define _error_desc			varchar(50);
define _n_agente    		varchar(50);
define _mensaje				char(50);
define _llave				char(50);
define _cedula2				char(30);
define _cedula				char(30);
define _no_documento		char(20);
define _cod_cliente2		char(10);
define _cod_cliente			char(10);
define _no_factura			char(10);
define _no_poliza2			char(10);
define _cod_agente			char(10);
define _no_endoso			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _consecutivo			smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error_cod			integer;
define _cod_error			integer;
define _error				integer;
define _ano					integer;
define _fecha_aniversario	date;
define _vigencia_inic		date;
define _vigencia_final		date;

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, trim(_error_desc) || ' ' || _no_documento,null,null,null;
end exception

if a_no_poliza = '0001283853' then
set debug file to 'sp_therefore3.trc';
trace on;
end if
--let _no_documento = '1800-00035-01';
let _mensaje = 'Inserción Exitosa';

	select no_documento,
	       cod_contratante
	  into _no_documento,
	       _cod_cliente
	  from emipomae
	 where no_poliza = a_no_poliza;

	foreach
		select cod_agente 
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_no_poliza
		 
		exit foreach;
	end foreach	 

	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select cedula,
		   nombre
	  into _cedula,
		   _n_contratante
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	return 	_no_documento,
			_n_contratante,
			_n_agente,
			_cedula,
			_cod_cliente;



end
end procedure;