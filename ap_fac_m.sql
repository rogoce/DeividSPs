-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_fac_m;

create procedure "informix".ap_fac_m() 
returning	smallint,varchar(200);


define _error_title			varchar(200);
define _error_desc			varchar(200);
define _deducible_colision	varchar(50);
define _deducible_incendio	varchar(50);
define _deducible_robo		varchar(50);
define _asegurado			varchar(50);
define _email				varchar(50);
define _poliza_ant			varchar(30);
define _cedula				varchar(30);
define _no_documento		varchar(20);
define _no_chasis			varchar(30);
define _no_motor			varchar(30);
define _uso_auto			char(30);
define _ruc					char(30);
define _poliza_maestra_auto	char(20);
define _poliza_maestra_tran	char(20);
define _cod_producto		char(5);
define _cod_cliente			char(10);
define _no_poliza_mae		char(10);
define _no_poliza			char(10);
define _estatus				char(10);
define _tipo				char(10);
define _periodo				char(7);
define _asiento				char(7);
define _tomo				char(7);
define _placa				char(6);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _prima_suscrita		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_prd			dec(16,2);
define _impuesto			dec(16,2);
define _error_isam			smallint;
define li_return			smallint;
define _ramo_sis			smallint;
define _ano_auto			smallint;
define _tipo_doc			smallint;
define _cnt_auto			smallint;
define _existe				smallint;
define _error				smallint;
define _cod_perpago         char(3);
define _meses               smallint; 
define _porc_descuento      dec(5,2);
define _porc_recargo        dec(5,2); 
define _descuento		    dec(16,2);
define _recargo			    dec(16,2);
define _cod_cober           char(5);
define _desc_limite1        varchar(50,0);
define _desc_limite2	    varchar(50,0);
define _orden_n             smallint;
define _ded_n               varchar(50);
define _ded_nn              dec(16,2);
define v_fecha_r            date;
define _prima_nn            dec(16,2);

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;
LET v_fecha_r = current;

foreach
	select feb.no_documento,
		   feb.no_poliza,
		   feb.no_endoso,
		   feb.prima_neta,
		   feb.prima_suscrita,
		   uni.no_unidad,
		   prd.prima,
		   sal.producto_nuevo
	  into _no_documento,
		   _no_poliza,
		   _no_endoso,
		   _prima_neta,
		   _prima_suscrita,
		   _no_unidad,
		   _prima_prd,
		   _cod_producto
	  from endedmae feb
	 inner join endeduni uni on uni.no_poliza = feb.no_poliza and uni.no_endoso = feb.no_endoso
     inner join prdnewpro sal on sal.cod_producto = uni.cod_producto
	 inner join prdtaeda prd on prd.cod_producto = sal.producto_nuevo
	-- inner join prdtaeda mae on prd.cod_producto = une.cod_producto
	 where feb.cod_endomov = '014'
	   and feb.periodo = '2023-04'
	   and feb.actualizado = 0
	  -- and no_documento = '1822-00240-01'
	 order by prd.cod_producto
	   	  
	 
	select cod_perpago
      into _cod_perpago
      from emipomae
     where no_poliza = _no_poliza;	  

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		If _cod_perpago = '008' then  --Anual
			let _meses = 12;
		else
			let _meses = 1;
		End if
	end if
	
	let _prima_prd = _prima_prd * _meses;
	
	let _porc_descuento = 0.00;
	let _porc_recargo = 0.00;
	let _descuento = 0.00;
	let _recargo = 0.00;
	let _prima_neta = _prima_prd;

    foreach	
		select porc_descuento
		  into _porc_descuento
		  from endunide
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   
		if _porc_descuento is null then
			let _porc_descuento = 0.00;
		end if	
		
		let _descuento = _descuento + _prima_neta * _porc_descuento / 100;
		let _prima_neta = _prima_neta - _prima_neta * _porc_descuento / 100;
	end foreach   
	   
	select sum(porc_recargo)
	  into _porc_recargo
	  from endunire
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	
    if _porc_recargo is null then
		let _porc_recargo = 0.00;
	end if	
	
	let _recargo = _prima_neta * _porc_recargo / 100;
	let _prima_neta = _prima_neta + _prima_neta * _porc_recargo / 100;
	
	let _impuesto = _prima_neta * .05;
	let _prima_bruta = _prima_neta + _impuesto;
	
	update endeduni
	   set prima_neta = _prima_neta,
		   prima_retenida = _prima_neta,
		   prima_suscrita = _prima_neta,
		   impuesto = _impuesto,
		   prima = _prima_prd,
		   prima_bruta = _prima_bruta,
		   cod_producto = _cod_producto,
		   descuento = _descuento,
		   recargo = _recargo
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedcob
	   set prima_anual = _prima_prd,
		   prima = _prima_prd,
		   prima_neta = _prima_neta,
		   descuento = _descuento,
		   recargo = _recargo
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and prima_neta <> 0;
	   
	update emifacon
	   set prima = _prima_neta
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedmae
	   set prima = _prima_prd,
		   prima_neta = _prima_neta,		   
		   impuesto = _impuesto,
		   prima_bruta = _prima_bruta,
		   prima_retenida = _prima_neta,
		   prima_suscrita = _prima_neta,
		   actualizado = 1,
		   descuento = _descuento,
		   recargo = _recargo
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedhis
	   set prima = _prima_prd,
		   prima_neta = _prima_neta,		   
		   impuesto = _impuesto,
		   prima_bruta = _prima_bruta,
		   prima_retenida = _prima_neta,
		   prima_suscrita = _prima_neta,
		   descuento = _descuento,
		   recargo = _recargo
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   	   
	update emipouni
	   set cod_producto 	= _cod_producto,
	       prima        	= _prima_prd,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   impuesto			= _impuesto,
		   prima_bruta 		= _prima_bruta,
		   prima_asegurado	= _prima_prd,
		   prima_total		= _prima_prd,
		   prima_suscrita   = _prima_neta
	 where no_poliza = _no_poliza;	   
	 
	delete from emipocob
	 where no_poliza = _no_poliza;

	let _desc_limite1 = null;
	let _desc_limite2 = null;
	let _ded_n        = "";

	 foreach			--Actualizar los beneficios del producto en los campos de la cobertura, Armando 27/08/2012
		select cod_cobertura,
			   desc_limite1,
			   desc_limite2,
			   orden,
			   deducible
		  into _cod_cober,
			   _desc_limite1,
			   _desc_limite2,
			   _orden_n,
			   _ded_nn
		  from prdcobpd
		 where cod_producto  = _cod_producto
		   and cob_requerida = 1
		 order by orden

		if _ded_nn is null then
			let _ded_nn = 0;
		end if
		let _ded_n = _ded_nn;

		let _prima_nn = 0;
		if _orden_n = 1 then
			let _prima_nn = 1;
		end if
		 
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
			   desc_limite2
			   )	
			   values (
				_no_poliza,
				_no_unidad,
				_cod_cober,
				_orden_n,
				0,
				_ded_n,
				0,     		 							
				0,
				_prima_nn,
				0,	 	 							
				0,	 		 							
				0,
				0,
				v_fecha_r,
				v_fecha_r,
				1,
				_desc_limite1,
				_desc_limite2
				);

	 end foreach

	update emipocob
	   set prima        	= _prima_prd,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   prima_anual		= _prima_prd
	 where no_poliza		= _no_poliza
	   and no_unidad		= _no_unidad
	   and prima_anual      <> 0.00;

	-- Realiza el cambio automatico de la nueva prima

	-- En caso de que sean Tarjetas de Credito 

	update cobtacre
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;      	

	-- En caso de que sean ACH 

	update cobcutas
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;
	 
	Update emipomae
	   Set prima 		  = _prima_prd, 
		   descuento	  = _descuento,
		   recargo		  = _recargo,
		   prima_neta 	  = _prima_neta,
		   prima_bruta	  = _prima_bruta,
		   impuesto 	  = _impuesto,
		   prima_suscrita = _prima_neta,
		   prima_retenida = _prima_neta
	 Where no_poliza 	  = _no_poliza;	
	 
	 

	return 0, 'Exito. ' ||_no_documento with resume;
end foreach


	return 0,"Actualización Exitosa";
	end
end procedure
