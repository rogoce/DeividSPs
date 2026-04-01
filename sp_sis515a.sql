--Detalle de Reclamo de Pólizas con Cese de Cobertura
--Roman Gordon 03/06/2025

drop procedure sp_sis515a;
create procedure sp_sis515a()
returning	char(20)	as poliza,
			date		as vigencia_inicial,
			date		as vigencia_final,
			date		as vigencia_cese,
			date		as fecha_emision,
			char(20)	as reclamo,
			date		as fecha_siniestro,
			date		as fecha_reclamo,
			char(10)	as no_tramite,
			char(1)	as estatus_reclamo,
			smallint	as estatus_audiencia,
			dec(16,2)	as estimado,
			dec(16,2)	as deducible,
			dec(16,2)	as reserva_inicial,
			dec(16,2)	as reserva_actual,
			dec(16,2)	as pagos,
			dec(16,2)	as recupero,
			dec(16,2)	as salvamento,
			dec(16,2)	as deducible_pagado,
			dec(16,2)	as deducible_devuelto,
			dec(9,6)	as porcentaje_reaseguro,
			dec(7,4)	as porcentaje_coaseguro,
			dec(16,2)	as tr_deducible,
			dec(16,2)	as incurrido_reclamo,
			dec(16,2)	as incurrido_bruto,
			dec(16,2)	as incurrido_neto;

define _error_desc			varchar(50);
define _no_documento			char(20);
define _numrecla				char(20);
define _no_reclamo			char(10);
define _no_tramite			char(10);
define _user_added			char(8);
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
define _vigencia_final		date;
define _fecha_reclamo			date;
define _vigencia_inic			date;
define _fecha_emision			date;
define _vigencia_end			date;


SET ISOLATION TO DIRTY READ;
begin
on exception set _error, _error_isam, _error_desc
   return	_error_desc,
			'01/01/1900',
			'01/01/1900',
			'01/01/1900',
			'01/01/1900',
			'',
			'01/01/1900',
			'01/01/1900',
			'',
			'',
			_error, 
			_error_isam,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00;
end exception

--set debug file to "sp_sis515a.trc";
--trace on;

foreach with hold
	select emi.no_documento,
			emi.vigencia_inic,
			emi.vigencia_final,
			mae.vigencia_inic,
			mae.fecha_emision,
			rec.numrecla,
			rec.no_reclamo,
			rec.fecha_siniestro,
			rec.fecha_reclamo,
			rec.no_tramite,
			rec.estatus_reclamo,
			rec.estatus_audiencia
	  into _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _vigencia_end,
		   _fecha_emision,
		   _numrecla,
		   _no_reclamo,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _no_tramite,
		   _estatus_reclamo,
		   _estatus_audiencia
	  from emipomae emi
	  left join recrcmae rec on rec.no_poliza = emi.no_poliza
	  left join endedmae mae on mae.no_poliza = emi.no_poliza and mae.cod_endomov = '032'
	 where emi.cod_no_renov = '039'
	   and emi.actualizado = 1

	if _no_reclamo is null then
		let _estimado = 0.00;
		let _deducible = 0.00;
		let _reserva_inicial = 0.00;
		let _reserva_actual = 0.00;
		let _pagado = 0.00;
		let _recupero = 0.00;
		let _salvamento = 0.00;
		let _deduc_pagado = 0.00;
		let _deduc_devuelto = 0.00;
		let _porc_reaseg = 0.00;
		let _porc_coaseg = 0.00;
		let _deducible = 0.00;
		let _incurrido_reclamo = 0.00;
		let _incurrido_bruto = 0.00;
		let _incurrido_neto = 0.00;
		
	else
		call sp_rec33(_no_reclamo) returning _estimado,_deducible,_reserva_inicial,_reserva_actual,_pagado,_recupero,_salvamento,_deduc_pagado,_deduc_devuelto,_porc_reaseg,_porc_coaseg,_deducible,_incurrido_reclamo,_incurrido_bruto,_incurrido_neto;
	end if
	
	let _error = 0;
	let _error_desc = null;
	
	return	_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_vigencia_end,
			_fecha_emision,
			_numrecla,
			_fecha_siniestro,
			_fecha_reclamo,
			_no_tramite,
			_estatus_reclamo,
			_estatus_audiencia,
			_estimado,
			_deducible,
			_reserva_inicial,
			_reserva_actual,
			_pagado,
			_recupero,
			_salvamento,
			_deduc_pagado,
			_deduc_devuelto,
			_porc_reaseg,
			_porc_coaseg,
			_deducible,
			_incurrido_reclamo,
			_incurrido_bruto,
			_incurrido_neto
			with resume;	
end foreach
end
end procedure;