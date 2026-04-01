-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore4;
create procedure sp_therefore4(a_no_poliza char(10), a_no_endoso char(5))
returning	char(10),
            char(20),
			char(50),
			char(30),
			date,
			date; 

define _n_contratante2	    varchar(100);
define _n_contratante	    varchar(100);
define _error_desc			varchar(50);
define _n_agente    		char(50);
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
--	rollback work;
	return _error_cod, trim(_error_desc) || ' ' || _no_documento, null, null, null, null;
end exception

--set debug file to 'sp_therefore1.trc';
--trace on;

--let _no_documento = '1800-00035-01';
let _mensaje = 'Inserción Exitosa';

	select no_documento,
	       cod_contratante
	  into _no_documento,
	       _cod_cliente
	  from emipomae
	 where no_poliza = a_no_poliza;

		select no_factura,
			   no_poliza,
			   no_endoso
		  into _no_factura,
			   _no_poliza2,
			   _no_endoso
		  from endedmae
		 where no_poliza = a_no_poliza
           and no_endoso = a_no_endoso;		 

		let _llave = '';
		call sp_therefore0(_no_poliza2,_no_endoso,'00000',_cod_cliente,'FACT') returning _error,_llave;

		select cedula
		  into _cedula
		  from cliclien
		 where cod_cliente = _cod_cliente;

		select vigencia_inic,
			   vigencia_final
		  into _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza2;

			return	_no_factura,
					_no_documento,
					_llave,
					_cedula,
					_vigencia_inic,
					_vigencia_final;


end
end procedure;