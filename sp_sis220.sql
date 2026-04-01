-- Creado: Armando Moreno	25/04/2012

--Procedimiento para hacer una copia de la tabla cobsuspe hacia la tabla cobsuspeh
--Para Auditoria

drop procedure sp_sis220;

create procedure "informix".sp_sis220()
returning integer,char(10);

define _no_documento_r 		char(20);
define _no_documento 		char(20);
define _no_poliza_r			char(10);
define _no_poliza 			char(10);
define _no_endoso 			char(5);
define _error				integer;

BEGIN
ON EXCEPTION SET _error
	return _error,_no_poliza;
end exception

--set debug file to "sp_sis118.trc";
--trace on;

let _no_poliza_r = '874769';
let _no_documento_r = '1614-00702-09';

foreach
	select no_poliza,
		   no_endoso,
		   no_documento
	  into _no_poliza,
		   _no_endoso,
		   _no_documento
	  from endedmae
	 where no_poliza = '874810'
	   and no_documento = '1614-00702-09'
	   and no_endoso = '00006'

	insert into endedmae
	select	_no_poliza_r,
			no_endoso,
			cod_compania,
			cod_sucursal,
			cod_tipocalc,
			cod_formapag,
			cod_tipocan,
			cod_perpago,
			cod_endomov,
			no_documento,
			vigencia_inic,
			vigencia_final,
			prima,
			descuento,
			recargo,
			prima_neta,
			impuesto,
			prima_bruta,
			prima_suscrita,
			prima_retenida,
			tiene_impuesto,
			fecha_emision,
			fecha_impresion,
			fecha_primer_pago,
			no_pagos,
			actualizado,
			no_factura,
			fact_reversar,
			date_added,
			date_changed,
			interna,
			periodo,
			user_added,
			factor_vigencia,
			suma_asegurada,
			posteado,
			activa,
			vigencia_inic_pol,
			vigencia_final_pol,
			no_endoso_ext,
			cod_tipoprod,
			cotizacion,
			de_cotizacion,
			gastos,
			sac_asientos,
			subir_bo,
			sac_notrx,
			flag_web_corr,
			facultativo,
			fronting,
			wf_aprob,
			wf_firma_aprob,
			wf_incidente,
			wf_fecha_entro,
			wf_fecha_aprob,
			fecha_indicador,
			no_hoja,
			no_poliza_coaseguro
	   from endedmae
	  where no_poliza =_no_poliza
	    and no_endoso = _no_endoso;

	update endmoage
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;

	update endedimp
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;

	update endedde1
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;
	   
	   
	insert into endeduni
	select _no_poliza_r,
			no_endoso,
			no_unidad,
			cod_ruta,
			cod_producto,
			'332564',
			suma_asegurada,
			prima,
			descuento,
			recargo,
			prima_neta,
			impuesto,
			prima_bruta,
			reasegurada,
			vigencia_inic,
			vigencia_final,
			beneficio_max,
			desc_unidad,
			prima_suscrita,
			prima_retenida,
			suma_aseg_adic,
			tipo_incendio,
			gastos,
			subir_bo,
			cod_formapag,
			cod_perpago,
			no_pagos,
			fecha_primer_pago,
			tipo_tarjeta,
			no_tarjeta,
			fecha_exp,
			cod_banco,
			cobra_poliza,
			no_cuenta,
			tipo_cuenta,
			cod_pagador,
			cod_manzana
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   
	update endedde2
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;	   
	   
	update endedcob
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;	   

	update emifacon
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;

	update endedhis
	   set no_poliza = _no_poliza_r
	 where no_poliza =_no_poliza
	   and no_endoso = _no_endoso;	   
end foreach
end
end procedure;