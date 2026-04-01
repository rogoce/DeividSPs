-- Procedure de Generación del detalle Reclamos para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif09a_rsvrs('2018-01','2022-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif09a_rsvrs;
create procedure sp_niif09a_rsvrs(a_periodo_desde char(7),a_periodo_hasta char(7), a_cod_ramo varchar(255) default "*")
returning	char(20)		as poliza,
			char(18)		as reclamo,
			varchar(18)		as transaccion,
			varchar(50)		as descripcion_contable,
			date			as fecha_transaccion,
			varchar(50)		as segm_triangulo,
			varchar(50)		as desc_clasificacion,
			date			as fecha_ocurrencia,
			date			as fecha_declaracion,
			dec(16,2)		as pagado_bruto,
			char(7)			as periodo_trx,
			smallint		as flag_anio_pago;

define _error_desc			varchar(50);
define _segm_triangulo		varchar(50);
define _desc_contable		varchar(50);
define _desc_clasif			varchar(50);
define _no_documento		char(20);
define _transaccion			varchar(18);
define _numrecla			char(18);
define _periodo_trx			char(7);
define _fecha_transaccion	date;
define _fecha_declaracion	date;
define _fecha_ocurrencia	date;
define _error_isam			integer;
define _error				integer;
define _flag_anio_pago		smallint;
define _pagado_bruto		dec(16,2);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc

	if _no_documento is null then
		let _no_documento = '';
	end if
	
	let _error_desc = 'no_documento: ' || trim(_no_documento) || trim(_error_desc);
	return '',
		   '',
		   '',
		   _error_desc,
		   null,
		   '',
		   '',
		   null,
		   null,
		   _error,
		   '',
		   0;
end exception


--set debug file to "sp_niif09a_rsvrs.trc";
--trace on;

call sp_niif09a(a_periodo_desde, a_periodo_hasta, a_cod_ramo) returning _error,_error_isam,_error_desc;

if _error = 0 then
	foreach with hold
		select no_documento,
			   numrecla,
			   transaccion,
			   categoria_contable,			   
			   fecha_transaccion,
			   segm_triangulo,
			   tipo_clasificacion,
			   fecha_ocurrencia,
			   fecha_declaracion,
			   monto_pag,
			   periodo,
			   flag_anio_pago
		  into _no_documento,
			   _numrecla,
			   _transaccion,
			   _desc_contable,
			   _fecha_transaccion,
			   _segm_triangulo,
			   _desc_clasif,
			   _fecha_ocurrencia,
			   _fecha_declaracion,
			   _pagado_bruto,
			   _periodo_trx,
			   _flag_anio_pago
		  from fichero_recl_auto
		 where monto_pag <> 0

		return _no_documento,
			   _numrecla,
			   _transaccion,
			   _desc_contable,
			   _fecha_transaccion,
			   _segm_triangulo,
			   _desc_clasif,
			   _fecha_ocurrencia,
			   _fecha_declaracion,
			   _pagado_bruto,
			   _periodo_trx,
			   _flag_anio_pago with resume;
	end foreach
else
	--NroPoliza	Reclamo	Descr. Cat	FechaTrx	SEGMENTACIÓN TRIÁNGULO	ClasificacionAnterior	FechaOcurrencia	FechaDeclaracion	PagadoBruto

	return '',
		   '',
		   '',
		   _error_desc,
		   null,
		   '',
		   '',
		   null,
		   null,
		   _error,
		   '',
		   0;
end if
end
end procedure;