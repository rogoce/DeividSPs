--Detalle de Reclamo de Pólizas con Cese de Cobertura
--Roman Gordon 03/06/2025

drop procedure sp_sis515b;
create procedure sp_sis515b(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	varchar(50)	as ramo,
			char(20)		as poliza,
			char(5)		as unidad,
			char(20)		as reclamo,
			date			as fecha_siniestro,
			date			as fecha_reclamo,
			char(10)		as no_tramite,
			dec(16,2)		as reserva_actual,
			dec(16,2)		as pagos,
			dec(16,2)		as incurrido_bruto;
			
define _error_desc			varchar(50);
define _nom_ramo				varchar(50);
define _filtros				varchar(50);
define _no_documento			char(20);
define _numrecla				char(20);
define _no_reclamo			char(10);
define _no_tramite			char(10);
define _user_added			char(8);
define _no_unidad				char(5);
define s_tipopro				char(3);
define _estatus_reclamo		char(1);
define _porc_reaseg			dec(9,6);
define _porc_coaseg			dec(7,4);
define _incurrido_reclamo	dec(16,2);
define _incurrido_bruto		dec(16,2);
define _reserva_inicial		dec(16,2);
define _incurrido_neto		dec(16,2);
define _reserva_actual		dec(16,2);
define _deduc_devuelto		dec(16,2);
define _deduc_pagado			dec(16,2);
define _salvamento			dec(16,2);
define _deducible				dec(16,2);
define _recupero				dec(16,2);
define _reserva				dec(16,2);
define _pagado					dec(16,2);
define _error_isam			integer;
define _error					integer;
define _estimado				integer;
define _estatus_audiencia	integer;
define _incidente				integer;
define _fecha_siniestro		date;
define _fecha_desde			date;
define _fecha_reclamo			date;
define _fecha_hasta			date;
define _fecha_emision			date;
define _vigencia_end			date;


SET ISOLATION TO DIRTY READ;
begin
on exception set _error, _error_isam, _error_desc
   return	_error_desc,
			'',
			'00000',
			'',
			'01/01/1900',
			'01/01/1900',
			'',
			_error, 
			_error_isam,
			0.00;
end exception

--set debug file to "sp_sis515a.trc";
--trace on;

let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

drop table if exists tmp_sinis;
call sp_rec01('001','001',a_periodo_desde, a_periodo_hasta) returning _filtros;

foreach with hold
	select rec.no_reclamo,
			rec.fecha_siniestro,
			rec.fecha_reclamo,
			rec.no_tramite,
			rec.numrecla,
			rec.no_documento,
			rec.no_unidad,
			ram.nombre
	  into _no_reclamo,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _no_tramite,
		   _numrecla,
		   _no_documento,
		   _no_unidad,
		   _nom_ramo
	  from recrcmae rec 
	 inner join emipomae emi on emi.no_poliza = rec.no_poliza
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 where rec.fecha_reclamo between _fecha_desde and _fecha_hasta
	   and rec.actualizado = 1

	--call sp_rec33(_no_reclamo) returning _estimado,_deducible,_reserva_inicial,_reserva_actual,_pagado,_recupero,_salvamento,_deduc_pagado,_deduc_devuelto,_porc_reaseg,_porc_coaseg,_deducible,_incurrido_reclamo,_incurrido_bruto,_incurrido_neto;
	
	select pagado_bruto,
		    reserva_bruto,
			incurrido_bruto
	  into _pagado,
		   _reserva_actual,
		   _incurrido_bruto
	  from tmp_sinis
	 where no_reclamo = _no_reclamo;
	
	return	_nom_ramo,
			_no_documento,
			_no_unidad,
			_numrecla,
			_fecha_siniestro,
			_fecha_reclamo,
			_no_tramite,
			_reserva_actual,
			_pagado,
			_incurrido_bruto
			with resume;	
end foreach
end
end procedure;