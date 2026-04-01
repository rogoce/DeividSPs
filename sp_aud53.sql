--------------------------------------------
--Verificación de comisiones de corredores de pólizas vigentes
--execute procedure sp_aud54()
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_aud54;

create procedure sp_aud53()
returning	char(3)			as Cod_ramo,
			varchar(50)		as Ramo,
			char(20)		as Poliza,
			varchar(100)	as Contratante,
			date			as Vigencia_inic,
			date			as Vigencia_final,
			char(5)			as Cod_agente,
			varchar(50)		as Corredor,
			char(10)		as No_licencia,
			dec(5,2)		as Porc_partic_agt,
			dec(5,2)		as Porc_comis_agt,
			dec(16,2)		as Prima_suscrita,
			char(10)		as Recibo,
			date			as Fecha_pago,
			dec(16,2)		as Monto_cobrado,
			dec(16,2)		as Monto_neto_cobro,
			dec(16,2)		as Comision,
			dec(5,2)		as Porc_comis_ramo,
			dec(16,2)		as Comis_calc,
			dec(16,2)		as Diferencia_comis 

define _error_desc			varchar(100);
define _nom_contratante		varchar(100);
define _nom_agente			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_licencia			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _cod_agente			char(5);
define _cod_cober_reas		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _porc_comis_ramo		dec(5,2);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _prima_neta_cobro	dec(16,2);
define _diferencia_comis	dec(16,2);
define _prima_suscrita		dec(16,2);
define _monto_cobrado		dec(16,2);
define _comis_calc			dec(16,2);
define _comision			dec(16,2);
define _porc_partic_prima	dec(9,6);
define _porc_dist_cont		dec(9,6);
define _porc_dist_ret		dec(9,6);
define _estatus_poliza		smallint;
define _cnt_pagos			smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_pago			date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return	'',_error_desc,'','',null,null,'','','',0.00,0.00,0.00,'',null,0.00,0.00,0.00,0.00,0.00,0.00;
end exception  

set isolation to dirty read;

foreach
	select no_documento
	  into _no_documento
	  from emipoliza
	 --where cod_ramo in ('004','019')

	let _no_poliza = sp_sis21(_no_documento);

	select cod_ramo,
		   cod_contratante,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   prima_suscrita
	  into _cod_ramo,
		   _cod_contratante,
		   _estatus_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_suscrita
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza <> 1 then
		continue foreach;
	end if

	select nombre,
		   porc_comision
	  into _nom_ramo,
		   _porc_comis_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nom_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;

	let _cnt_pagos = 0;
	select count(*)
	  into _cnt_pagos
	  from cobredet
	 where no_poliza = _no_poliza
	   and actualizado = 1;

	if _cnt_pagos is null then
		let _cnt_pagos = 0;
	end if

	let _prima_neta_cobro = 0.00;
	let _diferencia_comis = 0.00;
	let _monto_cobrado = 0.00;
	let _comis_calc = 0.00;
	let _comision = 0.00;
	let _no_recibo = '';
	let _fecha_pago = null;

	if _cnt_pagos = 0 then
		foreach
			select cod_agente,
				   porc_partic_agt,
				   porc_comis_agt
			  into _cod_agente,
				   _porc_partic_agt,
				   _porc_comis_agt
			  from emipoagt
			 where no_poliza = _no_poliza

			select no_licencia,
				   nombre
			  into _no_licencia,
				   _nom_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			return	_cod_ramo,
					_nom_ramo,
					_no_documento,
					_nom_contratante,
					_vigencia_inic,
					_vigencia_final,
					_cod_agente,
					_nom_agente,
					_no_licencia,
					_porc_partic_agt,
					_porc_comis_agt,
					_prima_suscrita,
					_no_recibo,
					_fecha_pago,
					_monto_cobrado,
					_prima_neta_cobro,
					_comision,
					_porc_comis_ramo,
					_comis_calc,
					_diferencia_comis with resume;
		end foreach
	else
		foreach
			select cod_agente,
				   nombre,
				   no_recibo,
				   fecha,
				   monto,
				   prima,
				   porc_partic,
				   porc_comis,
				   comision,
				   no_licencia
			  into _cod_agente,
				   _nom_agente,
				   _no_recibo,
				   _fecha_pago,
				   _monto_cobrado,
				   _prima_neta_cobro,
				   _porc_partic_agt,
				   _porc_comis_agt,
				   _comision,
				   _no_licencia
			  from chqcomis
			 where no_poliza = _no_poliza
			   and anticipo_comis = 0
			   and seleccionado = 1
			   and fecha_hasta >= '01/01/2016'

			let _comis_calc = _prima_neta_cobro * (_porc_comis_ramo/100);
			
			let _diferencia_comis = 0.00;
			let _diferencia_comis = _comis_calc - _comision;

			return	_cod_ramo,
					_nom_ramo,
					_no_documento,
					_nom_contratante,
					_vigencia_inic,
					_vigencia_final,
					_cod_agente,
					_nom_agente,
					_no_licencia,
					_porc_partic_agt,
					_porc_comis_agt,
					_prima_suscrita,
					_no_recibo,
					_fecha_pago,
					_monto_cobrado,
					_prima_neta_cobro,
					_comision,
					_porc_comis_ramo,
					_comis_calc,
					_diferencia_comis with resume;				
		end foreach
	end if
end foreach

end
end procedure;