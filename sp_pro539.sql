-- Procedure que crea los productos 02052, 02053, 02054 en todas las polizas vigentes del Suntracts

-- Creado    : 29/05/2014 -- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_pro539;

create procedure "informix".sp_pro539()
returning integer,
		  char(100);

define _no_poliza		char(10);
define _no_unidad		char(5);
define _max_unidad		smallint;
define _cod_pagador		char(10);
define _desc_unidad		char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_documento	char(20);

define _poliza_orig		char(10);
define _unidad_orig		char(5);
define _cantidad		smallint;
define _reg_tot			smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_pro539.trc";
--trace on;

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _poliza_orig   = "817446";
let _vigencia_inic = "01/06/2014";

let _reg_tot = 0;

foreach
 select no_poliza,
        cod_pagador,
		vigencia_final,
		no_documento
   into _no_poliza,
        _cod_pagador,
		_vigencia_final,
		_no_documento
   from emipomae
  where actualizado    = 1
    and cod_grupo      = "01016"
    and estatus_poliza = 1
    and cod_ramo       = "016"
	and cod_subramo    = "002"
	and no_documento   not in ("1612-00053-01")
--	and no_documento   = "1609-00506-01"

	--{
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza
	   and cod_producto in ("02052", "02053", "02054");

	if _cantidad <> 0 then
		continue foreach;
	end if

	let _reg_tot = _reg_tot + 1;

	--}
	select nombre
	  into _desc_unidad
	  from cliclien
	 where cod_cliente = _cod_pagador;

	-- Unidades

	select max(no_unidad)
	  into _max_unidad
	  from emipouni
	 where no_poliza = _no_poliza;

	foreach
	 select no_unidad
	   into _unidad_orig
	   from emipouni
	  where no_poliza = _poliza_orig
  	    and no_unidad in ("00003", "00004", "00005")
	  order by no_unidad

		let _max_unidad = _max_unidad + 1;

		if _max_unidad > 9 then
			let _no_unidad = "000" || _max_unidad;
		else
			let _no_unidad = "0000" || _max_unidad;
		end if
			
		--{
		insert into emipouni
		select _no_poliza,
			   _no_unidad,
			   cod_ruta,
			   cod_producto,
			   _cod_pagador,
			   suma_asegurada,
			   prima,
			   descuento,
			   recargo,
			   prima_neta,
			   impuesto,
			   prima_bruta,
			   reasegurada,
			   _vigencia_inic,
			   _vigencia_final,
			   beneficio_max,
			   _desc_unidad,
			   activo,
			   prima_asegurado,
			   prima_total,
			   no_activo_desde,
			   facturado,
			   user_no_activo,
			   perd_total,
			   impreso,
			   _vigencia_inic,
			   prima_suscrita,
			   prima_retenida,
			   eliminada,
			   suma_aseg_adic,
			   tipo_incendio,
			   prima_vida,
			   prima_vida_orig,
			   gastos,
			   doble_cob,
			   doble_cob_cia,
			   doble_cob_fecha,
			   cont_beneficios,
			   cod_doctor,
			   cambiar_tarifas,
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
			   _cod_pagador,		
			   dia_cobros1,		
			   dia_cobros2,		
			   anos_pagador,		
			   monto_visa,
			   cod_manzana		
		  from emipouni
		 where no_poliza = _poliza_orig
		   and no_unidad = _unidad_orig;

		-- Coberturas

		insert into emipocob
		select _no_poliza,
			   _no_unidad,
			   cod_cobertura,
			   orden,
			   tarifa,
			   deducible,
			   limite_1,
			   limite_2,
			   prima_anual,
			   prima,
			   descuento,
			   recargo,
			   prima_neta,
			   _vigencia_inic,
			   _vigencia_inic,
			   factor_vigencia,
			   desc_limite1,
			   desc_limite2,
			   prima_vida,
			   prima_vida_orig,
			   subir_bo
		  from emipocob
		 where no_poliza = _poliza_orig
		   and no_unidad = _unidad_orig;
		--}

		-- Reaseguro
		
		insert into emifacon
		select _no_poliza,
			   "00000",
			   _no_unidad,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   cod_ruta,
			   porc_partic_suma,
			   porc_partic_prima,
			   suma_asegurada,
			   prima,
			   ajustar,
			   subir_bo
		  from emifacon
		 where no_poliza = _poliza_orig
		   and no_unidad = _unidad_orig;

		insert into emireama
		select _no_poliza,
			   _no_unidad,
			   no_cambio,
			   cod_cober_reas,
			   _vigencia_inic,
			   _vigencia_final
		  from emireama
		 where no_poliza = _poliza_orig
		   and no_unidad = _unidad_orig;

		insert into emireaco
		select _no_poliza,
			   _no_unidad,
			   no_cambio,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima
		  from emireaco
		 where no_poliza = _poliza_orig
		   and no_unidad = _unidad_orig;

	end foreach

end foreach

end

--rollback work;
commit work;

return _reg_tot, " Registros Procesados, Actualizacion Exitosa";

end procedure