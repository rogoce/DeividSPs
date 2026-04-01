-- Procedimiento que Realiza el proceso de Rehabilitación de pólizas en cobros legal .
-- Creado    : 03/02/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis252;
create procedure "informix".sp_sis252(a_cod_producto char(8))
returning		integer,	--1._error
				char(250),	--2._error_desc
				char(10);	--3._no_endoso

define _error_desc			char(250);
define _comentario			char(250);
define _no_documento	char(20);
define _no_factura_rehab	char(10);
define _no_factura_canc		char(10);
define _no_poliza			char(10);
define _no_endoso_rehab		char(5);
define _no_endoso_canc		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_abogado			char(3);
define _cod_tipocan			char(3);
define _prima_b_rehab		dec(16,2);
define _monto_endoso		dec(16,2);
define _prima_b_canc		dec(16,2);
define _estatus_poliza		smallint;
define _no_endoso_int		smallint;
define _cnt_endoso			smallint;
define _recupero			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_hoy			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error, _error_desc,_no_poliza;
end exception

--set debug file to "sp_cob337.trc";
--trace on;

let _no_endoso = '00000';

foreach 
	select emi.no_poliza,
		   uni.no_unidad
	  into _no_poliza,
		   _no_unidad
	  from emipomae emi
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza 
	 where uni.cod_producto = a_cod_producto
	   and emi.vigencia_inic >= '31/07/2024'
	   and emi.cod_ramo = '002'
	   and emi.cod_grupo in ('00068','77978')
	   and emi.no_poliza = '2824256'

	delete from endedde2
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_endoso = _no_endoso;

	delete from emipode2
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	Insert into endedde2
			(no_poliza,
			no_endoso,
			no_unidad,
			descripcion)
	 select first 1 _no_poliza,
			_no_endoso,
			_no_unidad,
			descripcion
	   from prddesc
	  where cod_producto = a_cod_producto;


	Insert into emipode2
			(no_poliza,
			no_unidad,
			descripcion)
	 select first 1 _no_poliza,
			_no_unidad,
			descripcion
	   from prddesc
	  where cod_producto = a_cod_producto;


	return 0,'Actualización Exitosa',_no_poliza with resume;
end foreach

end
end procedure 