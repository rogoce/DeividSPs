-- Procedimiento que genera el Endoso de Cambio de Reaseguro Individual para las polizas automovil vigencia desde 01/07/2013
-- 
-- Creado     : 18/09/2013 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119bk;

create procedure sp_sis119bk(a_usuario char(8))
 returning integer,
           char(200),
           char(5);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(200);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define _no_documento    char(20);
define _no_factura      char(10);
define li_return        integer;
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_unidad       char(5);
define _cnt             smallint;
define _periodo2        char(7);

--set debug file to "sp_sis119bk.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = "001";

let _cod_endomov  = "017"; -- Cambio de Reaseguro Individual
let _cod_tipocan  = ""; 
let _cod_tipocalc = "001"; -- Prorrata
let _null		  = null;  -- Para campos null
let _suma_asegurada = 0;
let _no_endoso      = '00000';

let _cantidad   = 0;
let _periodo2   = "2014-11";


FOREACH	WITH HOLD

	select no_poliza,
	       no_unidad
	  into _no_poliza,
	       _no_unidad
	  from camrea
	 where actualizado = 0
	   and no_poliza in('829836')
	   and no_unidad = '00001'
	 order by 1,2

begin work;
		   
			select max(no_endoso)
			  into _no_endoso_int
			  from endedmae
			 where no_poliza = _no_poliza;

			let _no_endoso     = sp_set_codigo(5, _no_endoso_int + 1);
			let _no_endoso_ext = sp_sis30(_no_poliza, _no_endoso);

			let _cantidad      = _cantidad + 1;

			insert into endedmae(
			no_poliza,
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
			gastos
			)
			select 
			no_poliza,
			_no_endoso,
			cod_compania,
			cod_sucursal,
			_cod_tipocalc,
			cod_formapag,
			_null, 
			cod_perpago,
			_cod_endomov,
			no_documento,
			vigencia_inic,
			vigencia_final,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			tiene_impuesto,
			today,
			today,
			today,
			1,
			0,
			_null,
			_null,
			today,
			today,
			1,
			_periodo,
			a_usuario,
			1,
			0.00,
			0,
			1,
			vigencia_inic,
			vigencia_final,
			_no_endoso_ext,
			cod_tipoprod,
			_null,
			0,
			0.00
			from emipomae
			where no_poliza = _no_poliza;

			insert into endeduni(
				   no_poliza, 
				   no_endoso, 
				   no_unidad, 
				   cod_ruta, 
				   cod_producto, 
				   cod_cliente, 
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
			       gastos, 
				   tipo_incendio)	
			select _no_poliza,
				   _no_endoso,
				   _no_unidad,
				   cod_ruta,
				   cod_producto,
				   cod_asegurado,
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
			       0,
				   gastos,
				   tipo_incendio
			  from emipouni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

             select suma_asegurada
			   into _suma_asegurada
			   from emipouni
			  where no_poliza = _no_poliza
			    and no_unidad = _no_unidad;

			let _error = sp_proe05bk2(_no_poliza, _no_unidad, '00514', _suma_asegurada, _no_endoso);

			if _error <> 0 then
				return _error, '', _no_endoso;
			end if


			let _prima_suscrita = 0;
			let _prima_retenida = 0;
			let _prima          = 0;

			SELECT SUM(e.prima)
			  INTO _prima_retenida
			  FROM emifacon	e, reacomae r
			 WHERE e.no_poliza     = _no_poliza
			   AND e.no_endoso     = _no_endoso
			   AND e.cod_contrato  = r.cod_contrato
			   AND r.tipo_contrato = 1;

			if _prima_retenida is null then
				let _prima_retenida = 0;
			end if

			update endeduni
			   set prima_suscrita = 0,
				   prima_retenida = _prima_retenida,
			       prima          = 0,
				   suma_asegurada = 0,
				   prima          = 0,
				   descuento      = 0,
				   recargo        = 0,
				   prima_neta     = 0,
				   impuesto       = 0,
				   prima_bruta    = 0,
				   cod_ruta       = '00514'
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso
			   and no_unidad      = _no_unidad;

			update endedmae
			   set prima_retenida = _prima_retenida
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso;

			delete from endedcob
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso;

		  	call sp_pro43(_no_poliza, _no_endoso) returning _error, _descripcion;

			delete from emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and porc_partic_suma  = 0
			   and porc_partic_prima = 0;

			if _error <> 0 then
				return _error, trim(_descripcion) || trim(_no_poliza) || trim(_no_unidad), _no_endoso;
			end if

		 	update camrea
			   set actualizado = 1
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

				select no_factura
				  into _no_factura
				  from endedmae
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;


			update endedmae
			   set periodo    = _periodo2
			 where no_factura = _no_factura;

			update endedhis
			   set periodo    = _periodo2
			 where no_factura = _no_factura;
	
	commit work;

	if _cantidad >= 25 then
		exit foreach;
	end if


END FOREACH

end

return 0, "Actualizacion Exitosa, " || _cantidad || " Registros Procesados", _no_endoso;

end procedure