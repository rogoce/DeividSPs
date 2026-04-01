-- Procedure para cargar tablas temporales en deivid_tmp para luego ser pasadas por ODBC a SQLSERVER
-- 
-- Creado    : 19/12/2016 - Autor: Armando Moreno M.
--

drop procedure sp_therefore5;
create procedure sp_therefore5(a_no_poliza char(10), a_no_endoso char(5))
returning	char(20),
            char(5),
			char(10),
			char(30),
			varchar(100),
			date,
			char(50),
			smallint; 

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
	--rollback work;
	return _error_cod, null, null, null, null, null, null, null;
end exception

--set debug file to 'sp_therefore1.trc';
--trace on;

--let _no_documento = '1800-00035-01';
--let _mensaje = 'Inserción Exitosa';
            select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza = a_no_poliza;

			foreach
				execute procedure sp_therefore2(a_no_poliza,a_no_endoso) into _cod_error,_no_factura,_no_unidad,_cod_cliente2,_llave,_consecutivo

				select cedula,
					   nombre,
					   fecha_aniversario
				  into _cedula2,
					   _n_contratante2,
					   _fecha_aniversario
				  from cliclien
				 where cod_cliente = _cod_cliente2;

				return	_no_documento,
							_no_unidad,
							_no_factura,
							_cedula2,
							_n_contratante2,
							_fecha_aniversario,
							_llave,
							_consecutivo with resume;
			end foreach				
	

end
end procedure;