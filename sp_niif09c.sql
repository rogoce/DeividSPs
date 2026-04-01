-- Procedure de Generación del detalle Reclamos para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif09a_rsvrs('2018-01','2022-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif09c;
create procedure sp_niif09c(a_periodo_desde char(7),a_periodo_hasta char(7), a_cod_ramo varchar(255) default "*")
returning	char(10)		as no_poliza,
			char(20)		as no_documento,
			date			as vigencia_inic,
			date			as vigencia_final,
			char(3)			as cod_ramo,
			varchar(50)		as ramo,
			char(3)			as cod_subramo,
			varchar(50)		as subramo,
			char(10)			as no_reclamo,
			char(21)		as numrecla,
			char(10)		as no_tranrec,
			char(10)		as transaccion,
			char(10)		as anular_nt,
            date			as fecha_transaccion,
            char(3)			as cod_tipotran,
            varchar(50)		as tipotran,
            varchar(50)		as estatus_reclamo,
            varchar(30)		as tipo_clasificacion,
            varchar(30)		as segm_triangulo,
			varchar(30)		as categoria_contable,
			varchar(30)		as nueva_renov,
			date			as fecha_ocurrencia,
			date			as fecha_declaracion,
			date			as fecha_pago,
			date			as fecha_cierre,
			dec(16,2)		as reserva_bruta,
			dec(16,2)		as reserva_ret,
			dec(16,2)		as reserva_cedida,
			dec(16,2)		as monto_pag,
			dec(16,2)		as monto_pag_acum,
			dec(16,2)		as monto_pag_ret,
			dec(16,2)		as monto_pag_acum_ret,
			dec(16,2)		as monto_pag_cedido,
			dec(16,2)		as monto_pag_acum_ced,
			char(7)			as periodo,
			char(5)			as cod_grupo,
			varchar(30)		as nom_grupo,
			dec(9,6)		as porc_retencion,
			dec(9,6)		as porc_cedido,
			dec(9,6)		as porc_facultativo,
			dec(9,6)		as porc_fronting,
			char(10)		as no_requis,
			smallint		as pagado,
			date			as fecha_cobrado,
			char(7)			as periodo_pago,
			smallint		as flag_anio_pago;
			

define _error_desc			char(50);
define _estatus_recl		varchar(20);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _nom_subramo			varchar(50);
define _filtros				varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _tipotran			varchar(50);
define _no_documento		char(20);
define _numrecla			char(18);
define _no_requis			char(10);
define _transaccion			char(10);
define _anular_nt			char(10);
define _no_reclamo2			char(10);
define _nueva_renov			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_grupo			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_tipotran		char(3);
define _cod_ramo			char(3);
define _periodo_requis		char(7);
define _periodo_pago		char(7);
define _periodo				char(7);
define _estatus_reclamo		char(1);
define _tipo				char(1);
define _estatus_poliza		smallint;
define _flag_anio_pago		smallint;
define _clasificacion		smallint;
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _fronting			smallint;
define _cnt_cob				smallint;
define _pagado				smallint;
define _fecha_decl			date;
define _fecha_ocurr			date;
define _fecha_transaccion	date;
define _fecha_cancelacion	date;
define _fecha_declaracion	date;
define _fecha_ocurrencia	date;
define _fecha_pago		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_cobrado		date;
define _fecha_cierre		date;
define _error_isam			integer;
define my_sessionid			integer;
define _error				integer;
define _pagado_cedido_acum	dec(16,2);
define _pagado_neto_acum	dec(16,2);
define _pag_bruto_acum		dec(16,2);
define _reserva_cedida		dec(16,2);
define _pagado_cedido		dec(16,2);
define _reserva_bruta		dec(16,2);
define _monto_reserva		dec(16,2);
define _monto_pag_ret		dec(16,2);
define _monto_pagado		dec(16,2);
define _pagado_bruto		dec(16,2);
define _reserva_ret			dec(16,2);
define _monto_total			dec(16,2);
define _monto_bruto			dec(16,2);
define _pagado_neto			dec(16,2);
define _variacion			dec(16,2);
define _monto_pag			dec(16,2);
define _porc_reas			dec(9,6);
define _porc_partic_prima	dec(9,6);
define _porc_facultativo	dec(9,6);
define _porc_retencion		dec(9,6);
define _porc_fronting		dec(9,6);
define _porc_cedido			dec(9,6);
define _porc_coas			dec(7,4);


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc

	if _no_documento is null then
		let _no_documento = '';
	end if
	
	let _error_desc = 'no_documento: ' || trim(_no_documento) || trim(_error_desc);
	return '',
		     '',
		     null,
		     null,
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     null,
		     '',
		     _error_desc,
		     _error,
		     _error_isam,
		     0.00,
		     0.00,
		     0.00,
		     null,
		     null,
		     null,
		     null,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     '',
		     '',
		     '',
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     '',
			 0,
			 null,
			 '',
			 0;
end exception
          
--set debug file to "sp_niif09a_rsvrs.trc";
--trace on;

call sp_niif09a(a_periodo_desde, a_periodo_hasta, a_cod_ramo) returning _error,_error_isam,_error_desc;

if _error = 0 then
	foreach with hold
		select no_poliza,
			   no_documento,
			   vigencia_inic,
			   vigencia_final,
			   cod_ramo,
			   ramo,
			   cod_subramo,
			   subramo,
			   no_reclamo,
			   numrecla,
			   no_tranrec,
			   transaccion,
			   anular_nt,
			   fecha_transaccion,
			   cod_tipotran,
			   tipotran,
			   estatus_reclamo,
			   tipo_clasificacion,
			   segm_triangulo,
			   categoria_contable,
			   nueva_renov,
			   fecha_ocurrencia,
			   fecha_declaracion,
			   fecha_pago,
			   fecha_cierre,
			   reserva_bruta,
			   reserva_ret,
			   reserva_cedida,
			   monto_pag,
			   monto_pag_acum,
			   monto_pag_ret,
			   monto_pag_acum_ret,
			   monto_pag_cedido,
			   monto_pag_acum_ced,
			   periodo,
			   cod_grupo,
			   nom_grupo,
			   porc_retencion,
			   porc_cedido,
			   porc_facultativo,
			   porc_fronting,
			   no_requis,
			   pagado,
			   fecha_cobrado,
			   periodo_pago,
			   flag_anio_pago
		  into _no_poliza,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _nom_ramo,
			   _cod_subramo,
			   _nom_subramo,
			   _no_reclamo,
			   _numrecla,
			   _no_tranrec,
			   _transaccion,
			   _anular_nt,
			   _fecha_transaccion,
			   _cod_tipotran,
			   _tipotran,
			   _estatus_recl,
			   _desc_clasif,
			   _segm_triangulo,
			   _categoria_contable,
			   _nueva_renov,
			   _fecha_ocurrencia,
			   _fecha_declaracion,
			   _fecha_pago,
			   _fecha_cierre,
			   _reserva_bruta,
			   _reserva_ret,
			   _reserva_cedida,
			   _pagado_bruto,
			   _pag_bruto_acum,
			   _monto_pag_ret,
			   _pagado_neto_acum,
			   _pagado_cedido,
			   _pagado_cedido_acum,
			   _periodo,
			   _cod_grupo,
			   _nom_grupo,
			   _porc_retencion,
			   _porc_cedido,
			   _porc_facultativo,
			   _porc_fronting,
			   _no_requis,
			   _pagado,
			   _fecha_cobrado,
			   _periodo_requis,
			   _flag_anio_pago
		  from fichero_recl_auto
--		 where monto_pag <> 0

		return _no_poliza,
			   _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _nom_ramo,
			   _cod_subramo,
			   _nom_subramo,
			   _no_reclamo,
			   _numrecla,
			   _no_tranrec,
			   _transaccion,
			   _anular_nt,
			   _fecha_transaccion,
			   _cod_tipotran,
			   _tipotran,
			   _estatus_recl,
			   _desc_clasif,
			   _segm_triangulo,
			   _categoria_contable,
			   _nueva_renov,
			   _fecha_ocurrencia,
			   _fecha_declaracion,
			   _fecha_pago,
			   _fecha_cierre,
			   _reserva_bruta,
			   _reserva_ret,
			   _reserva_cedida,
			   _pagado_bruto,
			   _pag_bruto_acum,
			   _monto_pag_ret,
			   _pagado_neto_acum,
			   _pagado_cedido,
			   _pagado_cedido_acum,
			   _periodo,
			   _cod_grupo,
			   _nom_grupo,
			   _porc_retencion,
			   _porc_cedido,
			   _porc_facultativo,
			   _porc_fronting,
			   _no_requis,
			   _pagado,
			   _fecha_cobrado,
			   _periodo_requis,
			   _flag_anio_pago with resume;
	end foreach
else
	--NroPoliza	Reclamo	Descr. Cat	FechaTrx	SEGMENTACIÓN TRIÁNGULO	ClasificacionAnterior	FechaOcurrencia	FechaDeclaracion	PagadoBruto

	return '',
		     '',
		     null,
		     null,
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     '',
		     null,
		     '',
		     _error_desc,
		     _error,
		     _error_isam,
		     0.00,
		     0.00,
		     0.00,
		     null,
		     null,
		     null,
		     null,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     '',
		     '',
		     '',
		     0.00,
		     0.00,
		     0.00,
		     0.00,
		     '',
			 0,
			 null,
			 '',
			 0;
end if
end
end procedure;