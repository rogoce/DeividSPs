-- Procedimiento para actualizar el resultado del proceso electrónico en las tablas históricas
-- Creado    : 20/05/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob364;
create procedure sp_cob364(a_fecha_desde date, a_fecha_hasta date)
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _motivo_rechazo		varchar(50);
define _no_documento		char(20);
define _user_added			char(8);
define _no_lote				char(5);
define _cod_chequera		char(3);
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _procesar			smallint;
define _fecha_actual		datetime year to fraction(5);

--set debug file to "sp_cob363.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception 

foreach
	select no_lote,
		   renglon,
		   no_documento,
		   date_added
	  into _no_lote,
		   _renglon,
		   _no_documento,
		   _date_added
	  from cobtatrabk
	 where date(date_added) >= a_fecha_desde
	   and date(date_added) <= a_fecha_hasta

	select count(*)
	  into _cnt_pago
	  from cobremae m, cobredet d
	 where m.no_remesa = d.no_remesa
	   and doc_remesa = _no_documento
	   and m.date_posteo = date(_date_added)
	   and cod_chequera in ('029','031')
	   and m.actualizado = 1;

	if _cnt_pago is null then
		let _cnt_pago = 0;
	end if

	if _cnt_pago = 0 then
		select count(*)
		  into _cnt_pago
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and doc_remesa = _no_documento
		   and m.date_posteo = date(_date_added) + 1 units day
		   and cod_chequera in ('029','031')
		   and m.actualizado = 1;

		if _cnt_pago is null then
			let _cnt_pago = 0;
		end if

		if _cnt_pago = 0 then
			select count(*)
			  into _cnt_rechazo
			  from cobgesti
			 where no_documento = _no_documento
			   and date(fecha_gestion) = _date_added
			   and desc_gestion like '%RECHAZO VISA: %';

			if _cnt_rechazo is null then
				let _cnt_rechazo = 0;
			end if
			
			if _cnt_rechazo > 0 then
			else
			end if
		else
			let _motivo_rechazo = 'Pago Aprobado';
		end if
	else
		let _motivo_rechazo = 'Pago Aprobado';
	end if

return 0,'Actualización Exitosa';
end
end procedure;