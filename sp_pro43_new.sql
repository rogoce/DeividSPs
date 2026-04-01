

drop procedure sp_pro43_new;
create procedure sp_pro43_new(a_no_poliza char(10), a_no_endoso char(5)) 
returning	smallint,
			char(200);

define _sobre			varchar(250,1);
define _clausulas		varchar(50,0);
define _contenedor		varchar(50,0);
define _sello			varchar(50,0);
define _viaje_desde		varchar(50,0);
define _viaje_hasta		varchar(50,0);
define _consignado		varchar(50,0);
define _error_desc		char(200);
define _mensaje			char(200);
define _no_doc			char(20);
define _no_fac_orig		char(10);
define nvo_no_pol		char(10);
define _user_added		char(8);
define _periodo_end		char(7);
define _periodo_par		char(7);
define _no_endoso_ext	char(5);
define _no_unidad		char(5);
define _cobertura		char(5);
define _no_endoso		char(5);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _cod_formapag	char(3);
define _cod_coasegur	char(3);
define _cod_tipoprod	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_nave		char(3);
define _cod_ramo		char(3);
define _tipo_embarque	char(1);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _descuento		dec(16,2);
define _impuesto		dec(16,2);
define _recargo			dec(16,2);
define _prima			dec(16,2);
define _prima_sus_sum	dec(16,4);
define _prima_sus_cal	dec(16,4);
define _porcentaje		dec(16,4);
define _fecha_indicador	date;
define _vigencia_final	date;
define _vigencia_inic	date;
define _fecha_viaje		date;
define _tipo_forma		smallint;
define _return			smallint;
define _tiene_impuesto	smallint;
define _tipo_produccion	smallint;
define _error			smallint;
define _tipo_mov		smallint;
define _orden			smallint;
define _estatus_p		smallint;
define _cnt				smallint;
define _error_isam		smallint;
define _cantidad		integer;

set isolation to dirty read;
begin
on exception set _error
 	return _error, 'Error al Actualizar el Endoso ...';
end exception
--set debug file to "sp_pro43_nuevo.trc";
--trace on;

let _no_fac_orig	= null;
let nvo_no_pol		= a_no_poliza;
let _no_endoso		= a_no_endoso;

select cod_compania,
	   cod_sucursal,
	   cod_endomov,
	   periodo,
	   vigencia_inic,
	   vigencia_final,
	   cod_tipocan,
	   prima_bruta,
	   impuesto,
	   prima_neta,
	   descuento,
	   recargo,
	   prima,
	   prima_suscrita,
	   prima_retenida,
	   tiene_impuesto,
	   no_factura,
	   user_added,
	   no_documento
  into _cod_compania,
	   _cod_sucursal,
	   _cod_endomov,
	   _periodo_end,
	   _vigencia_inic,
	   _vigencia_final,
	   _cod_tipocan,
	   _prima_bruta,
	   _impuesto,
	   _prima_neta,
	   _descuento,
	   _recargo,
	   _prima,
	   _prima_suscrita,
	   _prima_retenida,
	   _tiene_impuesto,
	   _no_fac_orig,
	   _user_added,
	   _no_doc
  from endedmae
 where no_poliza   = a_no_poliza
   and no_endoso   = a_no_endoso
   and actualizado = 0;
   
if _prima_bruta <> 0 and _prima_neta = 0 then
	let _mensaje = 'Prima Bruta tiene valor, la Prima Neta No puede ser cero. Por Favor Verifique ...';
	return 1, _mensaje;
end if

let _cnt = sp_sis186(_no_doc,_tiene_impuesto);

if _cnt <> 0 then	--hay error
	if _tiene_impuesto = 1 then
		let _mensaje = 'Este Endoso NO debe llevar Impuesto, Por Favor Verifique ...';
	else
		let _mensaje = 'Este Endoso DEBE Llevar Impuesto, Por Favor Verifique ...';
	end if
	return 1, _mensaje;
end if

if _cod_compania is null then
	let _mensaje = 'Este Endoso Ya Fue Actualizado, Por Favor Verifique ...';
	return 1, _mensaje;
end if

if _tiene_impuesto = 0 then
	delete from endedimp 
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;
	   
	if _impuesto <> 0 then
		let _mensaje = 'Este Endoso No Debe Tener Monto de Impuesto, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end if

if abs(_prima_neta) > 0 then
	if abs(_prima_bruta) = 0 then
		let _mensaje = 'La Prima Bruta no debe ser cero, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end if

select emi_periodo,
	   par_ase_lider 
  into _periodo_par,
	   _cod_coasegur
  from parparam
 where cod_compania = _cod_compania;
 
select tipo_mov 
  into _tipo_mov 
  from endtimov
 where cod_endomov = _cod_endomov;
 
select cod_tipoprod,
	   estatus_poliza 
  into _cod_tipoprod,
	   _estatus_p 
  from emipomae 
 where no_poliza = a_no_poliza;
 
select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;
 
let _cnt = 0;

select count(*)
  into _cnt
  from emireaut
 where no_poliza = a_no_poliza;
 
if _cnt > 0 and _cod_endomov <> '015' then --015=endoso descriptivo
	let _mensaje = 'Esta Vigencia se esta renovando en este momento, no le puede hacer movimiento.';
	return 1, _mensaje;
end if

let _porcentaje = 1;

if _tipo_produccion = 2 then
	select porc_partic_coas
	  into _porcentaje
	  from emicoama
	 where cod_coasegur = _cod_coasegur
	   and no_poliza = a_no_poliza;
	   
	if _porcentaje is null then
		let _porcentaje = 0;
	else
		let _porcentaje = _porcentaje / 100;
	end if
end if

if _tipo_mov <> 17 and  -- cambio de reaseguro individual
   _tipo_mov <> 15 then	-- cambio de coaseguro
	let _prima_sus_sum = _prima_neta * _porcentaje;
	
	if abs(_prima_sus_sum - _prima_suscrita) > 0.68 then
		let _mensaje = 'Prima Suscrita por Calculo Diferente de Prima Suscrita, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
	
	if abs(_prima_retenida) > abs(_prima_suscrita) then
		let _mensaje = 'Prima Retenida No Puede Ser Mayor que Prima Suscrita, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end if

select sum(prima)
  into _prima_sus_sum
  from emifacon
 where no_poliza = a_no_poliza 
   and no_endoso = a_no_endoso;
   
if _prima_sus_sum is null then
	let _prima_sus_sum = 0;
end if

let _prima_suscrita = _prima_suscrita * 1;

if abs(_prima_suscrita - _prima_sus_sum) > 0.02 then
	let _mensaje = 'Sumatoria de Primas de Reaseguro Diferente de Prima Suscrita, Por Favor Verifique ...';
	return 1, _mensaje;
end if

select sum(e.prima)
  into _prima_sus_sum
  from emifacon	e, reacomae r
 where e.no_poliza     = a_no_poliza
   and e.no_endoso     = a_no_endoso
   and e.cod_contrato  = r.cod_contrato
   and r.tipo_contrato = 1;
   
if _prima_sus_sum is null then
	let _prima_sus_sum = 0;
end if

if abs(_prima_retenida - _prima_sus_sum) > 0.03 then
	let _mensaje = 'Sumatoria de Prima de Retencion Diferente a Prima Retenida, Por Favor Verifique ...';
	return 1, _mensaje;
end if

select sum(prima_neta)
  into _prima_sus_sum
  from endedcob
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
   
if _prima_sus_sum is null then
	let _prima_sus_sum = 0;
end if
if _tipo_mov <> 24 and _tipo_mov <> 25 then
	if abs(_prima_neta - _prima_sus_sum) > 0.07 then
		let _mensaje = 'Sumatoria de Primas de Coberturas Diferente de Prima Neta, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end if

foreach
	select no_unidad,
		   cod_cober_reas,
		   sum(porc_partic_prima),
		   sum(porc_partic_suma)
	  into _no_unidad,
		   _cobertura,
		   _prima_sus_cal,
		   _prima_sus_sum
	  from emifacon
	 where no_poliza     = a_no_poliza
	   and no_endoso     = a_no_endoso
	 group by no_unidad, cod_cober_reas
	
	if _prima_sus_cal <> 100 then
		let _mensaje = 'Sumatoria de Porcentajes de Prima Diferente de 100%, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
	if _prima_sus_sum <> 100 then
		let _mensaje = 'Sumatoria de Porcentajes de Suma Diferente de 100%, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end foreach

select count(*)
  into _cantidad
  from emifacon	e, reacomae r
 where e.no_poliza     = a_no_poliza
   and e.no_endoso     = a_no_endoso
   and e.cod_contrato  = r.cod_contrato
   and r.tipo_contrato = 3;
   
if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad <> 0 then
	foreach	
		select no_unidad,
			   cod_cober_reas,
			   prima,orden
		  into _no_unidad,
			   _cobertura,
			   _prima_sus_cal,
			   _orden
		  from emifacon	e, reacomae r
		 where e.no_poliza     = a_no_poliza
		   and e.no_endoso     = a_no_endoso
		   and e.cod_contrato  = r.cod_contrato
		   and e.porc_partic_prima <> 0
		   and r.tipo_contrato = 3

		select sum(prima)
		  into _prima_sus_sum
		  from emifafac
		 where no_poliza      = a_no_poliza
		   and no_endoso      = a_no_endoso
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cobertura
		   and orden          = _orden;

		if abs(_prima_sus_cal - _prima_sus_sum) > 0.03 then
			let _mensaje = 'Sumatoria de Prima de Facultativos Diferente a Prima del Contrato Para la Unidad ' || _no_unidad;
			return 1, _mensaje;
		end if
		
		select sum(porc_partic_reas)
		  into _prima_sus_cal
		  from emifafac
		 where no_poliza      = a_no_poliza
		   and no_endoso      = a_no_endoso
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cobertura
		   and orden          = _orden;
		   
		if _prima_sus_cal is null then
			let _prima_sus_cal = 0;
		end if
		if _prima_sus_cal <> 100 then
			let _mensaje = 'Sumatoria de Porcentajes de Facultativos Diferente de 100, Por Favor Verifique ...';
			return 1, _mensaje;
		end if
	end foreach
end if

if _periodo_end < _periodo_par then
	let _mensaje = 'No Puede Actualizar un Endoso para Un Periodo Cerrado, Por Favor Verifique ...';
	return 1, _mensaje;
end if

if _tipo_mov = 1 then -- aumento de vigencia 	
	begin
		define _deducible		char(50);
		define _no_doc			char(20);
		define _cod_cobertura	char(5);
		define _cambio			char(3);
		define _cod_r			char(3);
		define _no_unidad		char(5);
		define _suma_asegurada	dec(16,2);
		define _prima_bruta		dec(16,2);
		define _prima_anual		dec(16,2);
		define _prima_neta		dec(16,2);
		define _descuento		dec(16,2);
		define _impuesto		dec(16,2);
		define _limite_1		dec(16,2);
		define _limite_2		dec(16,2);
		define _recargo			dec(16,2);
		define _prima			dec(16,2);
		define _renglon			smallint;
		
		call sp_sis57(a_no_poliza, a_no_endoso); -- Informacion Necesaria para BO
		
		select cod_ramo
		  into _cod_r
		  from emipomae
		 where no_poliza = a_no_poliza;
		 
		foreach 
			select no_unidad,
				   suma_asegurada,
				   prima,
				   prima_neta,
				   descuento,
				   recargo,
				   impuesto,
				   prima_bruta
			  into _no_unidad,
				   _suma_asegurada,
				   _prima,
				   _prima_neta,
				   _descuento,
				   _recargo,
				   _impuesto,
				   _prima_bruta
			  from endeduni
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			update emipouni
			   set suma_asegurada = suma_asegurada + _suma_asegurada,
				   prima          = prima          + _prima,
				   prima_neta     = prima_neta     + _prima_neta,
				   descuento      = descuento      + _descuento,
				   recargo        = recargo        + _recargo,
				   impuesto       = impuesto       + _impuesto,
				   prima_bruta    = prima_bruta    + _prima_bruta
			 where no_poliza      = a_no_poliza
			   and no_unidad      = _no_unidad;
			
			if _cod_r = '002' then
				call sp_imp11(a_no_poliza,_no_unidad);
			end if

			foreach 
				select cod_cobertura,
					   prima,
					   prima_neta,
					   descuento,
					   recargo,
					   prima_anual,
					   limite_1,
					   limite_2,
					   deducible
				  into _cod_cobertura,
					   _prima,
					   _prima_neta,
					   _descuento,
					   _recargo,
					   _prima_anual,
					   _limite_1,
					   _limite_2,
					   _deducible
				  from endedcob
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = _no_unidad

				update emipocob
				   set prima         = prima       + _prima,
					   prima_anual   = prima_anual + _prima_anual,
					   prima_neta    = prima_neta  + _prima_neta,
					   descuento     = descuento   + _descuento,
					   recargo	    = recargo     + _recargo,
					   limite_1	    = limite_1    + _limite_1,
					   limite_2	    = limite_2    + _limite_2,
					   deducible     = _deducible
				 where no_poliza     = a_no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;
			end foreach
 		end foreach
		
		if _cod_r <> "019" then  --vida individual
			update emipomae
			   set vigencia_final = _vigencia_final
			 where no_poliza      = a_no_poliza;

			update emipouni
			   set vigencia_final = _vigencia_final
			 where no_poliza      = a_no_poliza;

			update endeduni								--actualizando endeduni amado 31/08/2006
			   set vigencia_final = _vigencia_final
			 where no_poliza      = a_no_poliza
			   and no_endoso      = a_no_endoso;

			select max(no_cambio) 
			  into _renglon
			  from emireama
			 where no_poliza = a_no_poliza;

			if _renglon is not null then
				update emireama
				   set vigencia_final = _vigencia_final
				 where no_poliza      = a_no_poliza
				   and no_cambio      = _renglon;
			end if
			
			select max(no_cambio)
			  into _cambio
			  from emihcmm
			 where no_poliza = a_no_poliza;
			 
			if _cambio is not null then
				update emihcmm 
				   set vigencia_final = _vigencia_final
				 where no_poliza      = a_no_poliza
				   and no_cambio      = _cambio;
			end if
		else
   			update emipomae
			   set vigencia_fin_pol = _vigencia_final
			 where no_poliza        = a_no_poliza;
		end if
		
		select no_documento
		  into _no_doc
		  from emipomae
		 where no_poliza = a_no_poliza;

		delete from emirepo
		 where no_documento = _no_doc;
	end
elif _tipo_mov = 2 then		-- cancelacion
	begin
		define _accion			smallint;
		define _cant_emirepol	smallint;
		define _opcion			smallint;
		define _no_unidad		char(5);
		define _cod_no_renov	char(3);
		define _cod_ubica		char(3);
		define _suma_inc		dec(16,2);
		define _suma_ter		dec(16,2);
		define _prima_inc		dec(16,2);
		define _prima_ter		dec(16,2);
				
		call sp_pro520(a_no_poliza) returning _error, _mensaje;	-- armando, para que no cancelen la misma vigencia varias veces. 02/11/2010
		
		if _error <> 0 then --esta vigencia ya esta cancelada
			return _error, _mensaje;
		end if
		
	   	call sp_sis406(a_no_poliza, a_no_endoso) returning _error, _mensaje;	-- poner periodo de la ren, si la canc. es antes del periodo de la ren.
		
		select accion,
		       cod_no_renov
		  into _accion,
		       _cod_no_renov
		  from endtican
		 where cod_tipocan = _cod_tipocan;

		update emipomae
		   set estatus_poliza    = _accion,
			   fecha_cancelacion = _vigencia_inic
		 where no_poliza         = a_no_poliza;

		select count(*)
		  into _cant_emirepol
		  from emirepol
		 where no_poliza = a_no_poliza;

		if _cant_emirepol is null then
			let _cant_emirepol = 0;
		end if

		update emipomae
		   set cod_no_renov   = _cod_no_renov,
			   fecha_no_renov = current,
			   user_no_renov  = _user_added,
			   no_renovar     = 1
		 where no_poliza      = a_no_poliza;

		delete from emirepol
		 where no_poliza = a_no_poliza;

		delete from emirepo
		 where no_poliza = a_no_poliza;

		delete from emideren
		 where no_poliza = a_no_poliza;
		 
		call sp_sis57(a_no_poliza, a_no_endoso); -- informacion necesaria para bo
		
		foreach
			select no_unidad
			  into _no_unidad
			  from endeduni
		     where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			foreach 
				select cod_ubica,
					   suma_incendio,
					   suma_terremoto,
					   prima_incendio,
					   prima_terremoto,
					   opcion
				  into _cod_ubica,
					   _suma_inc,
					   _suma_ter,
					   _prima_inc,
					   _prima_ter,
					   _opcion
				  from endcuend
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = _no_unidad

				if _opcion = 2 then
				   update emicupol
				      set suma_incendio   = suma_incendio   + _suma_inc,
				          suma_terremoto  = suma_terremoto  + _suma_ter,
						  prima_incendio  = prima_incendio  + _prima_inc,
						  prima_terremoto = prima_terremoto + _prima_ter
				    where no_poliza       = a_no_poliza
				      and no_unidad       = _no_unidad
				      and cod_ubica       = _cod_ubica;
				end if
			end foreach
		end foreach
	end 
elif _tipo_mov = 3 then	-- rehabilitacion
	begin
		define _no_documento		char(20);
		define _periodo_pro			char(7);
		define _mes_char			char(2);
		define _ano_char			char(4);
		define _ramo_sis			smallint;
		define _accion				smallint;
		define _valor				smallint;
		define _vigen_fin_poliza	date;
		
		if _estatus_p <> 2 then
			let _mensaje = 'La poliza no necesita ser rehabilitada, verifique!';
			return 1, _mensaje;
		end if 

		call sp_sis57(a_no_poliza, a_no_endoso); -- bo

		select vigencia_final,
			   cod_formapag,
			   no_documento,
			   cod_ramo
		  into _vigen_fin_poliza,
			   _cod_formapag,
			   _no_documento,
			   _cod_ramo
		  from emipomae
		 where no_poliza = a_no_poliza;

		if  month(_vigen_fin_poliza) < 10 then
			let _mes_char = '0'|| month(_vigen_fin_poliza);
		else
			let _mes_char = month(_vigen_fin_poliza);
		end if

		let _ano_char    = year(_vigen_fin_poliza);
		let _periodo_pro = _ano_char || "-" || _mes_char;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _vigen_fin_poliza < current then
			let _accion = 3;
		else
			let _accion = 1;
		end if

		update emipomae 
		   set estatus_poliza = _accion,
			   fecha_cancelacion = null,
			   no_renovar = 0,
			   cod_no_renov = null,
			   fecha_no_renov = null
		 where no_poliza = a_no_poliza;

		select tipo_forma
		  into _tipo_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		if _accion = 1 and (_tipo_forma = 5 or _tipo_forma = 3) then 
			let _return	= sp_cas022(a_no_poliza);
		end if
		
		if _ramo_sis <> 5 then
			let _valor = sp_pro28c(_periodo_pro,_no_documento); 
		end if
	end
elif _tipo_mov = 4 then	-- inclusion de unidades
	begin
		define _no_motor        char(30);
		define _no_documento    char(20);
		define _s_vig_final     char(10);
		define _no_unidad_m		char(5);
		define _no_unidad		char(5);
		define _cod_cober_reas	char(3);
		define _null            char(1);      
		define _suma_asegurada	dec(16,2);
		define _suma_aseg_adic	dec(16,2);
		define _no_cambio		smallint;
		define _retorno			smallint;
		define _vig_final       date;
		
		let _null      = null;
		let _no_cambio = 0;

		update endeduni 
		   set vigencia_inic = _vigencia_inic,
			   vigencia_final = _vigencia_final
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emipouni(
				no_poliza,
				no_unidad,
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
				activo,
				prima_asegurado,
				prima_total,
				no_activo_desde,
				facturado,
				user_no_activo,
				perd_total,
				impreso,
				fecha_emision,
				prima_suscrita,
				prima_retenida,
				suma_aseg_adic,
				tipo_incendio,
				cod_manzana)
		select no_poliza,
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
			   1,
			   0,
			   0,
			   _null,
			   1,
			   _null,
			   0,
			   1,
			   current,
			   prima_suscrita,
			   prima_retenida,
			   suma_aseg_adic,
			   tipo_incendio,
			   cod_manzana
		  from endeduni
	 	 where no_poliza = a_no_poliza
	 	   and no_endoso = a_no_endoso;

		let _retorno = 0;
		
		foreach	 -- verificando si el motor existe en otra poliza - amado 25-11-2011 - caso 11642
			select no_motor
			  into _no_motor
			  from endmoaut
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso
			
			call sp_proe23(a_no_poliza, _no_motor, _vigencia_inic) returning _retorno, _no_documento, _vig_final, _no_unidad_m;
			let _s_vig_final = _vig_final;
			if _retorno = 1 then 
				exit foreach;
			end if    		
		end foreach
		
 		if _retorno = 1 then
			let _mensaje = 'El No. de Motor ' || trim(_no_motor) || " esta Asegurado en la Unidad No. " || trim(_no_unidad_m) || " de la Poliza " || trim(_no_documento) || " y con Vigencia Final del " || trim(_s_vig_final);
			return 1, _mensaje;
		end if

		insert into emiauto(
				no_poliza,
				no_unidad,
				cod_tipoveh,
				no_motor,
				uso_auto,
				ano_tarifa)
		select no_poliza,
			   no_unidad,
			   cod_tipoveh,
			   no_motor,
			   uso_auto,
			   ano_tarifa
		  from endmoaut
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emipode2(
				no_poliza,
				no_unidad,
				descripcion)
		select no_poliza,
			   no_unidad,
			   descripcion
		  from endedde2
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;		

		insert into emiunide(
				no_poliza,
				no_unidad,
				cod_descuen,
				porc_descuento)
		select no_poliza,
			   no_unidad,
			   cod_descuen,
			   porc_descuento
		  from endunide
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emiunire(
				no_poliza,
				no_unidad,
				cod_recargo,
				porc_recargo)
		select no_poliza,
			   no_unidad,
			   cod_recargo,
			   porc_recargo
		  from endunire
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emipoacr(
				no_poliza,
				no_unidad,
				cod_acreedor,
				limite)
		select no_poliza,
			   no_unidad,
			   cod_acreedor,
			   limite
		  from endedacr
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emipocob(
				no_poliza,
				no_unidad,
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
				date_added,
				date_changed,
				factor_vigencia,
				desc_limite1,
				desc_limite2)
		select no_poliza,
			   no_unidad,
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
			   date_added,
			   date_changed,
			   factor_vigencia,
			   desc_limite1,
			   desc_limite2
		  from endedcob
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;		

		insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento)
		select no_poliza,
			   no_unidad,
			   cod_cobertura,
			   cod_descuen,
			   porc_descuento
		  from endcobde
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;		

		insert into emicobre(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_recargo,
				porc_recargo)
		select no_poliza,
			   no_unidad,
			   cod_cobertura,
			   cod_recargo,
			   porc_recargo
		  from endcobre
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;		

		foreach
			select no_unidad,
				   cod_cober_reas
			  into _no_unidad,
				   _cod_cober_reas
			  from	emifacon
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso
			 group by no_unidad, cod_cober_reas

			delete from emireafa
			 where no_poliza      = a_no_poliza
			   and no_unidad      = _no_unidad
			   and no_cambio      = _no_cambio
			   and cod_cober_reas = _cod_cober_reas;

			delete from emireaco
			 where no_poliza      = a_no_poliza
			   and no_unidad      = _no_unidad
			   and no_cambio      = _no_cambio
			   and cod_cober_reas = _cod_cober_reas;

			delete from emireama
			 where no_poliza      = a_no_poliza
			   and no_unidad      = _no_unidad
			   and no_cambio      = _no_cambio
			   and cod_cober_reas = _cod_cober_reas;

			insert into emireama(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					vigencia_inic,
					vigencia_final)
			values(
					a_no_poliza, 
					_no_unidad,
					_no_cambio,
					_cod_cober_reas,
					_vigencia_inic,
					_vigencia_final);
		end foreach

		insert into emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima)
		select a_no_poliza, 
			   no_unidad,
			   _no_cambio,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emireafa(
				no_poliza,
				no_unidad,
				no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				cod_coasegur,
				porc_partic_reas,
				porc_comis_fac,
				porc_impuesto)
		select a_no_poliza, 
			   no_unidad,
			   _no_cambio,
			   cod_cober_reas,
			   orden,
			   cod_contrato,
			   cod_coasegur,
			   porc_partic_reas,
			   porc_comis_fac,
			   porc_impuesto
		  from emifafac
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emibenef(
				no_poliza,
				no_unidad,
				cod_cliente,
				cod_parentesco,
				benef_desde,
				porc_partic_ben,
				nombre)
		select no_poliza,
			   no_unidad,
			   cod_cliente,
			   cod_parentesco,
			   benef_desde,
			   porc_partic_ben,
			   nombre
		  from endbenef
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into emicupol(
				no_poliza,
				no_unidad,
				cod_ubica,
				suma_incendio,
				suma_terremoto,
				prima_incendio,
				prima_terremoto)
		select no_poliza,
			   no_unidad,
			   cod_ubica,
			   suma_incendio,
			   suma_terremoto,
			   prima_incendio,
			   prima_terremoto
		  from endcuend
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;		   		

	    select sum(suma_asegurada)
		  into _suma_asegurada
		  from emipouni
		 where no_poliza = a_no_poliza;

		update emipomae
		   set suma_asegurada = _suma_asegurada
		 where no_poliza      = a_no_poliza;

		insert into emitrans(
				no_poliza,
				no_unidad,
				cod_nave,
				consignado,
				tipo_embarque,
				clausulas,
				contenedor,
				sello,
				fecha_viaje,
				viaje_desde,
				viaje_hasta,
				sobre)
		select no_poliza,
			   no_unidad,
			   cod_nave,
			   consignado,
			   tipo_embarque,
			   clausulas,
			   contenedor,
			   sello,
			   fecha_viaje,
			   viaje_desde,
			   viaje_hasta,
			   sobre
		  from endmotra
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;
	end 
elif _tipo_mov = 5 then	-- eliminacion de unidades
	begin
		define _no_unidad		char(5);
		define _cod_ubica		char(3);
		define _suma_asegurada	dec(16,2);
		define _cantidad		integer;

		foreach 
			select no_unidad
			  into _no_unidad
			  from endeduni
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			insert into endmoaut(
					no_poliza,
					no_endoso,
					no_unidad,
					cod_tipoveh,
					no_motor,
					uso_auto,
					ano_tarifa)
			select no_poliza,
				   a_no_endoso,	
				   no_unidad,
				   cod_tipoveh,
				   no_motor,
				   uso_auto,
				   ano_tarifa
			  from emiauto
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;		

			insert into endbenef(
					no_poliza,
					no_endoso,
					no_unidad,
					cod_cliente,
					cod_parentesco,
					benef_desde,
					porc_partic_ben,
					nombre)
			select no_poliza,
				   a_no_endoso,	
				   no_unidad,
				   cod_cliente,
				   cod_parentesco,
				   benef_desde,
				   porc_partic_ben,
				   nombre
			  from emibenef
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;

			delete from emibenef
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;

			select cod_ubica
			  into _cod_ubica
			  from endcuend
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso
			   and no_unidad = _no_unidad;

			if _cod_ubica is null then
				insert into endcuend(
						no_poliza,
						no_endoso,
						no_unidad,
						cod_ubica,
						suma_incendio,
						suma_terremoto,
						prima_incendio,
						prima_terremoto)
				select no_poliza,
					   a_no_endoso,	
					   no_unidad,
					   cod_ubica,
					   suma_incendio,
					   suma_terremoto,
					   prima_incendio,
					   prima_terremoto
				  from emicupol
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad;
			end if

			delete from emicupol
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;

			delete from emipouni
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;
		end foreach

		let _cantidad = null;

		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = a_no_poliza;

		if _cantidad < 1 or _cantidad is null then
			let _mensaje = 'La poliza tiene una unidad, debe cancelarla si desea eliminarla...';
			return 1, _mensaje;
		end if 

	    select sum(suma_asegurada)
		  into _suma_asegurada
		  from emipouni
		 where no_poliza = a_no_poliza;

		update emipomae
		   set suma_asegurada = _suma_asegurada
		 where no_poliza = a_no_poliza;
	end
elif _tipo_mov = 6 then	-- modicicacion de unidades
	begin
		define _deducible		char(50);
		define _nom_bene		char(50);
		define _cod_cliente		char(10);
		define _cod_cobertura	char(5);
		define _no_unidad		char(5);
		define _cod_parentesco	char(3);
		define _cod_ubica		char(3);
		define _porc_partic_ben	dec(5,2);
		define _suma_asegurada	dec(16,2);
		define _prima			dec(16,2);
		define _prima_anual		dec(16,2);
		define _prima_neta		dec(16,2);
		define _descuento		dec(16,2);
		define _recargo			dec(16,2);
		define _impuesto		dec(16,2);
		define _prima_bruta		dec(16,2);
		define _limite_1		dec(16,2);
		define _limite_2		dec(16,2);
		define _suma_inc		dec(16,2);
		define _suma_ter		dec(16,2);
		define _prima_inc		dec(16,2);
		define _prima_ter		dec(16,2);
		define _suma_aseg_adic	dec(16,2);
		define _opcion			smallint;
		define r_cant			smallint;
		define _benef_desde		date;

		call sp_sis57(a_no_poliza, a_no_endoso); -- informacion necesaria para bo
		
		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = a_no_poliza;

		if _cod_ramo <> "018" then
			foreach 
				select no_unidad, 
					   suma_asegurada,
					   prima,
					   prima_neta,
					   descuento,
					   recargo,
					   impuesto,
					   prima_bruta,
					   suma_aseg_adic
				  into _no_unidad, 
					   _suma_asegurada,
					   _prima, 
					   _prima_neta,
					   _descuento,
					   _recargo,
					   _impuesto,
					   _prima_bruta,
					   _suma_aseg_adic
				  from endeduni
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso

				update emipouni
				   set suma_asegurada = suma_asegurada + _suma_asegurada,
				       prima          = prima          + _prima,
				       prima_neta     = prima_neta     + _prima_neta,
				       descuento      = descuento      + _descuento,
				       recargo        = recargo        + _recargo,
				       impuesto       = impuesto       + _impuesto,
				       prima_bruta    = prima_bruta    + _prima_bruta,
					   suma_aseg_adic = suma_aseg_adic + _suma_aseg_adic
				 where no_poliza      = a_no_poliza
				   and no_unidad      = _no_unidad;
				   
				if _cod_ramo = '002' then
			   		call sp_imp11(a_no_poliza,_no_unidad);
				end if
				
				{if _suma_asegurada <> 0 then
			   		call sp_pro217(a_no_poliza,_no_unidad,a_no_endoso);
				end if}

				foreach 
					select cod_cobertura,
						   prima,
						   prima_anual,
						   prima_neta,
						   descuento,
						   recargo,
						   limite_1,
						   limite_2,
						   deducible,
						   opcion
					  into _cod_cobertura,
						   _prima,
						   _prima_anual,
						   _prima_neta,
						   _descuento,
						   _recargo,
						   _limite_1,
						   _limite_2,
						   _deducible,
						   _opcion
					  from endedcob
					 where no_poliza = a_no_poliza
					   and no_endoso = a_no_endoso
					   and no_unidad = _no_unidad

					let r_cant = 0;

					select count(*) 
					  into r_cant 
					  from emipocob
					 where no_poliza     = a_no_poliza
					   and no_unidad     = _no_unidad
					   and cod_cobertura = _cod_cobertura;

					if r_cant = 0 then
						insert into emipocob(
								no_poliza,
								no_unidad,
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
								date_added,
								date_changed,
								factor_vigencia,
								desc_limite1,
								desc_limite2)
						select no_poliza,
							   no_unidad,
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
							   date_added,
							   date_changed,
							   factor_vigencia,
							   desc_limite1,
							   desc_limite2
						  from endedcob
						 where no_poliza     = a_no_poliza
						   and no_endoso     = a_no_endoso
						   and no_unidad     = _no_unidad
						   and cod_cobertura = _cod_cobertura;
					else						
						if _opcion = 2 then -- modificacion de coberturas
							update emipocob
							   set prima         = prima       + _prima,
								   prima_anual   = prima_anual + _prima_anual,
								   prima_neta    = prima_neta  + _prima_neta,
								   descuento     = descuento   + _descuento,
								   recargo	    = recargo     + _recargo,
								   limite_1	    = limite_1    + _limite_1,
								   limite_2	    = limite_2    + _limite_2,
								   deducible     = _deducible
							 where no_poliza     = a_no_poliza
							   and no_unidad     = _no_unidad
							   and cod_cobertura = _cod_cobertura;

						elif _opcion = 3 then -- eliminacion de coberturas
							delete from emipocob
						     where no_poliza     = a_no_poliza
						       and no_unidad     = _no_unidad
						       and cod_cobertura = _cod_cobertura;
						end if
					end if
				end foreach

				foreach 
					select cod_cliente, 
						   cod_parentesco,
						   benef_desde,
						   porc_partic_ben,
						   opcion,
						   nombre
					  into _cod_cliente, 
						   _cod_parentesco,
						   _benef_desde,
						   _porc_partic_ben,
						   _opcion,
						   _nom_bene
					  from endbenef
					 where no_poliza = a_no_poliza
					   and no_endoso = a_no_endoso
					   and no_unidad = _no_unidad

					let _nom_bene = trim(_nom_bene);
					let r_cant = 0;

					select count(*)
					  into r_cant
					  from emibenef
					 where no_poliza     = a_no_poliza
					   and no_unidad     = _no_unidad
					   and cod_cliente   = _cod_cliente;

					if r_cant = 0 then
						insert into emibenef(
								no_poliza,
								no_unidad,
								cod_cliente,
								cod_parentesco,
								benef_desde,
								porc_partic_ben,
								nombre)
						select no_poliza,
							   no_unidad,
							   cod_cliente,
							   cod_parentesco,
							   benef_desde,
							   porc_partic_ben,
							   nombre
						  from endbenef
						 where no_poliza     = a_no_poliza
						   and no_endoso     = a_no_endoso
						   and no_unidad     = _no_unidad
						   and cod_cliente   = _cod_cliente;
					else						
						if _opcion = 2 then -- modificacion de beneficiarios
							update emibenef
							   set cod_parentesco  = _cod_parentesco,
								   benef_desde     = _benef_desde,
								   porc_partic_ben = _porc_partic_ben,
								   nombre		  = _nom_bene
							 where no_poliza       = a_no_poliza
							   and no_unidad       = _no_unidad
							   and cod_cliente     = _cod_cliente;
						elif _opcion = 3 then -- eliminacion de beneficiarios
							delete from emibenef
						     where no_poliza     = a_no_poliza
						       and no_unidad     = _no_unidad
						       and cod_cliente   = _cod_cliente;
						end if
					end if
				end foreach

				foreach
					select cod_ubica,
						   suma_incendio,
						   suma_terremoto,
						   prima_incendio,
						   prima_terremoto,
						   opcion
					  into _cod_ubica,
						   _suma_inc,
						   _suma_ter,
						   _prima_inc,
						   _prima_ter,
						   _opcion
					  from endcuend
					 where no_poliza = a_no_poliza
					   and no_endoso = a_no_endoso
					   and no_unidad = _no_unidad

					if _opcion = 2 then -- modificacion de cumulos
						update emicupol
						   set suma_incendio   = suma_incendio   + _suma_inc,
							   suma_terremoto  = suma_terremoto  + _suma_ter,
							   prima_incendio  = prima_incendio  + _prima_inc,
							   prima_terremoto = prima_terremoto + _prima_ter
						 where no_poliza       = a_no_poliza
						   and no_unidad       = _no_unidad
						   and cod_ubica       = _cod_ubica;
					elif _opcion = 3 then -- eliminacion de cumulos
						delete from emicupol
						 where no_poliza     = a_no_poliza
						   and no_unidad     = _no_unidad
						   and cod_ubica     = _cod_ubica;
					end if
				end foreach

				foreach
					select cod_nave,
						   consignado,
						   tipo_embarque,
						   clausulas,
						   contenedor,
						   sello,
						   fecha_viaje,
						   viaje_desde,
						   viaje_hasta,
						   sobre
					  into _cod_nave,
						   _consignado,
						   _tipo_embarque,
						   _clausulas,
						   _contenedor,
						   _sello,
						   _fecha_viaje,
						   _viaje_desde,
						   _viaje_hasta,
						   _sobre
					  from endmotra
					 where no_poliza = a_no_poliza
					   and no_endoso = a_no_endoso
					   and no_unidad = _no_unidad

					update emitrans
					   set cod_nave		 = _cod_nave,
						   consignado	 = _consignado,
						   tipo_embarque = _tipo_embarque,
						   clausulas	 = _clausulas,
						   contenedor	 = _contenedor,
						   sello 		 = _sello,
						   fecha_viaje	 = _fecha_viaje,
						   viaje_desde	 = _viaje_desde,
						   viaje_hasta	 = _viaje_hasta,
						   sobre		 = _sobre
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad;

					update endmotra
					   set cod_nave		 = _cod_nave,
						   consignado	 = _consignado,
						   tipo_embarque = _tipo_embarque,
						   clausulas	 = _clausulas,
						   contenedor	 = _contenedor,
						   sello 		 = _sello,
						   fecha_viaje	 = _fecha_viaje,
						   viaje_desde	 = _viaje_desde,
						   viaje_hasta	 = _viaje_hasta,
						   sobre		 = _sobre
					 where no_poliza = a_no_poliza
					   and no_endoso = "00000"
					   and no_unidad = _no_unidad;
				end foreach
			end foreach

			select sum(suma_asegurada)
			  into _suma_asegurada
			  from endeduni
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso;								  

			update emipomae
			   set suma_asegurada = suma_asegurada + _suma_asegurada
			 where no_poliza      = a_no_poliza;
		end if
	end 
elif _tipo_mov = 9 then		-- cambio de motor/chasis

	begin
		define _no_motor,_no_chasis	char(30);
		define _no_unidad  			char(5);

		foreach	
			select no_motor,
				   no_chasis,
				   no_unidad
			  into _no_motor,
				   _no_chasis,
				   _no_unidad
			  from endmoaut
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso

			if _no_motor is not null then
				update emiauto
				   set no_motor  = _no_motor
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad;
			end if
			
			if _no_chasis is not null then
				update emivehic
				   set no_chasis = _no_chasis
				 where no_motor  = _no_motor;
			end if
		end foreach		
	end
else
	call sp_pro43a(a_no_poliza,a_no_endoso,_tipo_mov) returning _error,_mensaje;
end if

update emifafac
   set monto_comision = prima * porc_comis_fac / 100,
       monto_impuesto = prima * porc_impuesto  / 100
 where no_poliza      = a_no_poliza
   and no_endoso      = a_no_endoso
   and prima          <> 0.00;

begin
	define _no_documento	char(20);
	define _no_tarjeta		char(19);
	define _no_cuenta		char(17);
	define _no_factura		char(10);
	define _no_pol_ele		char(10);
	define _monto_visa		dec(16,2);
	define _suma_aseg		dec(16,2);
	define _cant_fact		integer;
	define _no_pagos		integer;
	define _cantidad_uni	smallint;
	
	let _no_pagos      = 0;
	let _no_tarjeta    = null;
	let _no_documento  = "";
	let _monto_visa    = 0;
	let _cod_formapag  = null;
	let _no_cuenta     = null;

	if _no_fac_orig is null then                                              
		let _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 
	else                                                                      
	 	let _no_factura = _no_fac_orig;                                        
	end if                                                                    

	select count(*)
	  into _cant_fact
	  from endedmae
	 where no_factura  = _no_factura
	   and no_poliza <> a_no_poliza
	   and no_endoso <> a_no_endoso;

	if _cant_fact is null then
		let _cant_fact = 0;
	end if

	if _cant_fact >= 1 then
		let _mensaje = 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...';
		return 1, _mensaje;
	end if
	
	let _no_endoso_ext   = sp_sis30(a_no_poliza, a_no_endoso);
	let _fecha_indicador = sp_sis156(today, _periodo_end);
	
	update endedmae
	   set actualizado 	   = 1,
	       posteado   	   = '1',
		   fecha_emision   = current,
		   date_changed	   = current,
		   no_factura	   = _no_factura,
		   activa          = 1,
		   cod_tipoprod	   = _cod_tipoprod,
		   no_endoso_ext   = _no_endoso_ext,
		   fecha_indicador = _fecha_indicador
	 where no_poliza	   = a_no_poliza
	   and no_endoso	   = a_no_endoso;
	   
	if _tipo_mov <> 15 then	-- el proceso de cambio de coaseguro crea la tabla con los valores
		select suma_asegurada
		  into _suma_aseg
		  from endedmae
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

		insert into endcoama(
		       no_poliza,
			   no_endoso,
			   cod_coasegur,
			   porc_partic_coas,
			   porc_gastos,
			   prima,
			   suma)
		select no_poliza,
		       a_no_endoso,
		       cod_coasegur,
		       porc_partic_coas,
		       porc_gastos,
			   (_prima_neta * porc_partic_coas / 100),
			   (_suma_aseg  * porc_partic_coas / 100)
		  from emicoama
	     where no_poliza = a_no_poliza;
	end if

	select count(*)
	  into _cantidad_uni
	  from emipouni
	  where no_poliza = a_no_poliza;

	if _cantidad_uni > 1 then
		update emipomae
		   set colectiva = "C"
		 where no_poliza = a_no_poliza;
	end if

    update emipomae 
	   set saldo = saldo + _prima_bruta
	 where no_poliza = a_no_poliza;

	if _tipo_mov <> 2 and _tipo_mov <> 3 then -- cancelacion / rehabilitacion
		update emipomae
		   set prima_bruta    = prima_bruta    + _prima_bruta,
			   impuesto       = impuesto       + _impuesto,
			   prima_neta     = prima_neta     + _prima_neta,
			   descuento      = descuento      + _descuento,
			   recargo        = recargo        + _recargo,
			   prima          = prima          + _prima,
			   prima_suscrita = prima_suscrita + _prima_suscrita,
			   prima_retenida = prima_retenida + _prima_retenida
		 where no_poliza      = a_no_poliza;

		select cod_formapag,
		       prima_bruta,
			   no_pagos,
			   no_tarjeta,
			   no_documento,
			   no_cuenta
		  into _cod_formapag,
		       _prima_bruta,
			   _no_pagos,
			   _no_tarjeta,
			   _no_documento,
			   _no_cuenta
		  from emipomae
		 where no_poliza = a_no_poliza;

		select tipo_forma
		  into _tipo_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;
		 
		if _no_documento[1,2] = "18" or _no_documento[1,2] = "19" then
		else
			let _no_pol_ele = sp_sis21(_no_documento);
			
			if _tipo_forma = 2 and _no_tarjeta is not null then -- tarjetas de credito
				let _monto_visa = sp_sis405(a_no_poliza);
			    --let _monto_visa = _prima_bruta / _no_pagos;
			    update emipomae	
				   set monto_visa = _monto_visa
				 where no_poliza = a_no_poliza;
				
				if trim(_no_pol_ele) = trim(a_no_poliza) then
				    update cobtacre
					   set monto = _monto_visa
					 where no_tarjeta = _no_tarjeta
					   and no_documento = _no_documento;
				end if
			end if
			
			if _tipo_forma = 4 and _no_cuenta is not null then -- ach	3/05/2013 implementado armando
  				let _monto_visa = sp_sis405(a_no_poliza);
--			    let _monto_visa = _prima_bruta / _no_pagos;
			    update emipomae	
				   set monto_visa = _monto_visa
				 where no_poliza  = a_no_poliza;
				 
				if trim(_no_pol_ele) = trim(a_no_poliza) then
				    update cobcutas
					   set monto = _monto_visa
					 where no_cuenta = _no_cuenta
					   and no_documento = _no_documento;
				end if
			end if
		end if
	end if
end

call sp_pro517(a_no_poliza, a_no_endoso) returning _error, _mensaje; --nueva ley de seguro
call sp_pro398(a_no_poliza, a_no_endoso) returning _error, _mensaje; --calculo de prima no devengada

if _error <> 0 then
	return _error, _mensaje;
end if 

call sp_pro100(a_no_poliza, a_no_endoso); --genera endedhis
call sp_sis70(a_no_poliza, a_no_endoso);  -- historico de emipoagt (endmoage)
call sp_sis94(a_no_poliza, a_no_endoso) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

return 0, 'Actualizacion Exitosa ...';
end
end procedure;