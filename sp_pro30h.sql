-- procedimiento que realiza la facturacion de salud

-- creado    : 16/10/2000 - autor: demetrio hurtado almanza 
-- modificado: 26/04/2001 - autor: demetrio hurtado almanza
-- modificado: 25/05/2007 - autor: amado perez mendoza 
--                          se inserta en las tablas de endunire y endunide los recargos y descuentos                                   

-- sis v.2.0 - d_prod_sp_pro30_dw1 - deivid, s.a.

drop procedure sp_pro30h;
create procedure sp_pro30h(
a_compania			char(3), 
a_sucursal			char(3),
a_no_documento		char(20),	
a_vigencia_desde	date,
a_vigencia_hasta	date,
a_usuario			char(8))
returning	integer,
			char(100);

define _error_desc      	char(100);
define _nombre_compania 	char(50);
define _nombre_cliente  	char(50);
define _nombre_subramo  	char(50);
define _cod_subramo			char(50);
define _no_documento    	char(20); 
define _cod_cliente     	char(10);
define _no_factura      	char(10); 
define _no_poliza       	char(10); 
define _periodo         	char(7);  
define _no_endoso_char  	char(5);  
define _no_endoso_ext		char(5);
define _no_unidad       	char(5);
define _no_endoso       	char(5);
define _cod_ruta        	char(5);
define _tipo_produccion 	char(3);
define _cod_cober_reas  	char(3);
define _cod_tipoprod1   	char(3);  
define _cod_tipoprod2   	char(3);  
define _cod_formapag    	char(3);  
define _cod_impuesto    	char(3);  
define _cod_coasegur    	char(3);
define _cod_perpago     	char(3);  
define _cod_endomov     	char(3);  
define _cod_ramo        	char(3);  
define _factor_impuesto 	dec(5,2); 
define _factor_imp_tot  	dec(5,2);
define _porc_descuento  	dec(5,2);
define _porc_recargo    	dec(5,2);
define _porc_coas       	dec(7,4);
define _porc_partic_prima 	dec(9,6);
define _porc_partic_suma  	dec(9,6);
define _monto_impuesto  	dec(16,2);
define _prima_certif2		dec(16,2);
define ld_prima_resta      	dec(16,2);
define ld_recargo_dep       dec(16,2);
define _prima_certif     	dec(16,2);
define ld_prima_dep         dec(16,2);
define _prima_neta      	dec(16,2);
define _prima_vida          dec(16,2);
define _descuento       	dec(16,2);
define _recargo         	dec(16,2);
define _tiene_impuesto  	smallint;
define _mes_contable		smallint;
define _ano_contable		smallint;
define _cantidad			smallint;
define _fronting            smallint;
define _serie           	smallint;
define _error           	smallint;
define _meses           	smallint; 
define _no_endoso_int   	integer;  
define _fecha1          	date;     
define _fecha2          	date;     
define _fecha_indicador		date;
define _vigencia_inic   	date;

--set debug file to "sp_pro30.trc"; 
--trace on;

set isolation to dirty read;

let _error_desc = "";

begin
on exception set _error 
	return _error, _error_desc;
end exception           

-- nombre de la compania

let _nombre_compania = sp_sis01(a_compania); 

-- coaseguradora lider periodo de facturacion
select par_ase_lider,
       emi_periodo
  into _cod_coasegur,
       _periodo
  from parparam
 where cod_compania = a_compania;

-- ramo de salud
select cod_ramo
  into _cod_ramo
  from prdramo
 where ramo_sis = 5;

-- contrato de reaseguro
let _serie    = year(a_vigencia_desde);
let _cod_ruta = null;

foreach
	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo = 1
	   and a_vigencia_desde between vig_inic and vig_final
	exit foreach;
end foreach

{foreach
 select cod_ruta
   into _cod_ruta
   from rearumae
  where cod_ramo = _cod_ramo
    and serie    = _serie
  order by cod_ruta	desc
		exit foreach;
end foreach}

if _cod_ruta is null then
	return 1, 'no existe distribucion de reaseguro ...';
end if

select sum(porc_partic_prima),			   
	   sum(porc_partic_suma)
  into _porc_partic_prima,
	   _porc_partic_suma
  from rearucon
 where cod_ruta = _cod_ruta;

if _porc_partic_prima <> 100 then
	return 1, 'la distribucion no es 100%, verifique la ruta ' || _cod_ruta;
end if

if _porc_partic_suma <> 100 then
	return 1, 'la distribucion no es 100%, verifique la ruta ' || _cod_ruta;
end if

-- selecciona la primera cobertura de reaseguro

let _cod_cober_reas = null;

foreach
	select cod_cober_reas
	  into _cod_cober_reas
	  from reacobre
	 where cod_ramo = _cod_ramo
	 order by cod_cober_reas
	exit foreach;
end foreach

if _cod_cober_reas is null then
	return 1, 'no existe cobertura de reaseguro ...';
end if

-- tipo de produccion sin coaseguro y coaseguro mayoritario
select cod_tipoprod
  into _cod_tipoprod1
  from emitipro
 where tipo_produccion = 1;

select cod_tipoprod
  into _cod_tipoprod2
  from emitipro
 where tipo_produccion = 2;

-- movimiento de facturacion de salud
select cod_endomov
  into _cod_endomov
  from endtimov
 where tipo_mov = 14;

let _no_poliza  = sp_sis21(a_no_documento);

delete from tmp_certif;

-- seleccion de las polizas

foreach
	select no_poliza,
		   cod_perpago,
		   vigencia_final,
		   cod_formapag,
		   no_documento,
		   cod_tipoprod,
		   vigencia_inic,
		   cod_contratante,
		   cod_subramo   
	  into _no_poliza,
		   _cod_perpago,
		   _fecha1,
		   _cod_formapag,
		   _no_documento,
		   _tipo_produccion,
		   _vigencia_inic,
		   _cod_cliente,
		   _cod_subramo   
	  from emipomae
	 where cod_compania   = a_compania
	   and cod_ramo       = _cod_ramo
	   and actualizado    = 1
	   and (cod_tipoprod  = _cod_tipoprod1 or cod_tipoprod  = _cod_tipoprod2)
	   and no_poliza      = _no_poliza--"75419" 

	-- procedure que realiza el calculo de las tarifas nuevas de salud 
	call sp_pro30c(_no_poliza) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if

	-- nombre del subramo
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	-- nombre del cliente
	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	-- se determina el porcentaje de descuento
	let _no_unidad      = null;
	let _porc_descuento = 0;

	foreach	
		select no_unidad
		  into _no_unidad
		  from emiunide
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	if _no_unidad is not null then
		select sum(porc_descuento)
		  into _porc_descuento
		  from emiunide
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _porc_descuento is null then
			let _porc_descuento = 0;
		end if
	end if

	-- se determina el porcentaje de recargo
	let _no_unidad      = null;
	let _porc_recargo   = 0;

	foreach	
		select no_unidad
		  into _no_unidad
		  from emiunire
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	if _no_unidad is not null then
		select sum(porc_recargo)
		  into _porc_recargo
		  from emiunire
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _porc_recargo is null then
			let _porc_recargo = 0;
		end if
	end if

	-- verificacion si es coaseguro mayoritario
	if _tipo_produccion = _cod_tipoprod2 then

		select porc_partic_coas
		  into _porc_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coas is null then
			let _porc_coas = 100;
		end if
	else
		let _porc_coas = 100;
	end if

	-- se determina la nueva vigencia final de la poliza
	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		let _meses = 1;
	end if

	let _fecha2 = _fecha1 + _meses units month;

	-- se determina la prima a facturar
	select sum(prima_total),
	       sum(prima_vida)
	  into _prima_certif,
	       _prima_vida
	  from emipouni
	 where no_poliza = _no_poliza
	   and activo    = 1;

	if _prima_certif is null then
		let _prima_certif = 0;
	end if

--    if _prima_vida is null then	 --se quita 23/07/2014 por que el impuesto debe ser a toda la prima. Armando por inst.de Demetrio.
   		let _prima_vida = 0.00;
--    end if

	let _descuento   = _prima_certif / 100 * _porc_descuento;
	let _recargo     = (_prima_certif - _descuento) / 100 * _porc_recargo;
	let _prima_neta  = _prima_certif - _descuento + _recargo;

	-- asignacion del numero de endoso
	select max(no_endoso)
	  into _no_endoso_int
	  from endedmae
	 where no_poliza = _no_poliza;

	if _no_endoso_int is null then
		let _no_endoso_int  = 0;
	end if

	let _no_endoso_int  = _no_endoso_int + 1;
	let _no_endoso_char = '00000';
	 
	if _no_endoso_int > 9999  then	
		let _no_endoso_char[1,5] = _no_endoso_int;
	elif _no_endoso_int > 999 then
		let _no_endoso_char[2,5] = _no_endoso_int;
	elif _no_endoso_int > 99  then
		let _no_endoso_char[3,5] = _no_endoso_int;
	elif _no_endoso_int > 9   then
		let _no_endoso_char[4,5] = _no_endoso_int;
	else
		let _no_endoso_char[5,5] = _no_endoso_int;
	end if

	let _no_endoso = _no_endoso_char;
		
	-- asignacion del numero de factura
	let _no_factura    		= sp_sis14(a_compania, a_sucursal, _no_poliza);
	let _no_endoso_ext 		= sp_sis30(_no_poliza, _no_endoso);
	let _fecha_indicador	= sp_sis156(today, _periodo);

	select count(*)
	  into _cantidad
	  from endedmae
	 where no_factura = _no_factura;

	if _cantidad >= 1 then
		let _error_desc = 'numero de factura duplicado ';
		return _error, _error_desc;
	end if

	-- insercion del endoso
	let _error_desc = 'error al insertar endosos, poliza: ' || _no_poliza || " endoso: " || _no_endoso;

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
			activa,
			vigencia_inic_pol,
			vigencia_final_pol,
			no_endoso_ext,
			cod_tipoprod,
			fecha_indicador)
	values( _no_poliza,
			_no_endoso,
			a_compania,
			a_sucursal,
			'001',
			_cod_formapag,
			null,
			_cod_perpago,
			_cod_endomov,
			_no_documento,
			_fecha1,
			_fecha2,
			_prima_certif,
			_descuento,
			_recargo,
			_prima_neta,
			0,
			0,
			0,
			0,
			0,
			current,
			current,
			_fecha1,
			1,
			1,
			_no_factura,
			null,
			current,
			current,
			1,
			_periodo,
			a_usuario,
			1,
			0,
			1,
			_vigencia_inic,
			_fecha1,
			_no_endoso_ext,
			_tipo_produccion,
			_fecha_indicador);

	-- impuestos por endoso
	begin

		define _pagado_por char(1);
		define _impuesto   dec(16,2);
		
		let _monto_impuesto = 0;
		let _tiene_impuesto = 0;
		let _factor_imp_tot = 0;

		foreach
			select cod_impuesto
			  into _cod_impuesto
			  from emipolim
			 where no_poliza = _no_poliza

			select factor_impuesto,
				   pagado_por
			  into _factor_impuesto,
				   _pagado_por	
			  from prdimpue
			 where cod_impuesto = _cod_impuesto;

			let _impuesto = (_prima_neta - _prima_vida) / 100 * _factor_impuesto;
			let _tiene_impuesto = 1;
			let _monto_impuesto = _monto_impuesto + _impuesto;		
			let _factor_imp_tot = _factor_imp_tot + _factor_impuesto;
			let _error_desc = 'error al insertar el impuesto, poliza # ' || _no_documento;

			insert into endedimp(
			no_poliza,
			no_endoso,
			cod_impuesto,
			monto
			)
			values(
			_no_poliza,
			_no_endoso,
			_cod_impuesto,
			_impuesto
			);
		end foreach

		-- actualizacion de impuestos en la tabla de endosos
		update endedmae
		   set impuesto       = _monto_impuesto,
			   prima_bruta    = prima_neta + _monto_impuesto,
			   tiene_impuesto = _tiene_impuesto
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		-- actualizacion del saldo de la poliza
		update emipomae
		   set saldo = saldo + (_prima_neta + _monto_impuesto),
			   estatus_poliza = 1
		 where no_poliza = _no_poliza;
	end

	-- insercion de las unidades

	begin
		define _nombre_cli		char(100);
		define _desc_unidad		char(50); 
		define _cedula			char(30);
		define _cod_cliente		char(10); 
		define _cod_producto	char(5);  
		define _plan			char(1);
		define _suma_asegurada	dec(16,2);
		define _prima_brut_uni	dec(16,2);
		define _prima_vida_uni	dec(16,2);
		define _beneficio_max	dec(16,2);
		define _impuesto_uni	dec(16,2);
		define _cant_unidades	smallint;
		define _cant_depen		smallint;
		define _facturado		smallint; 
		define _fecha_emis		date;
		define _fecha_efec		date;
		define _fecha_nac		date;

	select count(*)
	  into _cant_unidades
	  from emipouni
     where no_poliza = _no_poliza
	   and activo    = 1;

	foreach with hold
		select no_unidad,
			   facturado,
			   suma_asegurada,
			   cod_producto,
			   cod_asegurado,
			   beneficio_max,
			   desc_unidad,
			   prima_total,
			   fecha_emision,
			   vigencia_inic,
			   prima_vida
		  into _no_unidad,
			   _facturado,
			   _suma_asegurada,
			   _cod_producto,
			   _cod_cliente,
			   _beneficio_max,
			   _desc_unidad,
			   _prima_certif,
			   _fecha_emis,
			   _fecha_efec,
			   _prima_vida_uni
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo    = 1
		 order by no_unidad

		if _prima_vida_uni is null then
			let _prima_vida_uni = 0;
			update emipouni
			   set prima_vida = 0
			 where no_poliza  = _no_poliza
			   and no_unidad  = _no_unidad;
		end if

		if _facturado = 1 then
			let _suma_asegurada = 0;
		end if
		let _prima_vida_uni = 0;

		-- se determina el porcentaje de descuento

	   {	let _porc_descuento = 0;

		select sum(porc_descuento)
		  into _porc_descuento
		  from emiunide
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _porc_descuento is null then
			let _porc_descuento = 0;
		end if

		-- se determina el porcentaje de recargo

		let _porc_recargo   = 0;

		select sum(porc_recargo)
		  into _porc_recargo
		  from emiunire
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _porc_recargo is null then
			let _porc_recargo = 0;
		end if
}
		-- se determina la prima de los dependientes
		let ld_prima_dep = 0;

		call sp_proe54(_no_poliza, _no_unidad) returning ld_prima_dep;

        let ld_prima_resta = _prima_certif - ld_prima_dep;

	    -- buscar descuento
		let _descuento = 0.00;
		call sp_proe21(_no_poliza, _no_unidad, _prima_certif) returning _descuento;

		if _descuento > 0 then
		   let ld_prima_resta = _prima_certif - _descuento;
		end if

		-- buscar recargo
		let _recargo = 0.00;
		call sp_proe22(_no_poliza, _no_unidad, ld_prima_resta) returning _recargo;

		-- buscar recargo por dependiente
		let ld_recargo_dep = 0.00;
		call sp_proe53(_no_poliza, _no_unidad) returning ld_recargo_dep;
		let _recargo = _recargo + ld_recargo_dep;

	   --	let _descuento      = _prima_certif / 100 * _porc_descuento;
	   --	let _recargo        = (_prima_certif - _descuento) / 100 * _porc_recargo;  verificar amado 18-11-2010
		let _prima_neta     = _prima_certif - _descuento + _recargo;
		let _impuesto_uni   = (_prima_neta - _prima_vida_uni) / 100 * _factor_imp_tot;
		let _prima_brut_uni = _prima_neta + _impuesto_uni;

		if _prima_neta = 0.00 then
			let _error_desc = "la prima es 0.00 para la poliza " || _no_documento || " unidad " || _no_unidad;
			return 1, _error_desc;
		end if
	
		if _cant_unidades > 1 then			
			select cedula,
				   fecha_aniversario,
				   nombre
			  into _cedula,
			  	   _fecha_nac,
				   _nombre_cli
			  from cliclien
			 where cod_cliente = _cod_cliente; 	   		   	

			select count(*)
			  into _cant_depen
			  from emidepen
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and activo    = 1;

			if _cant_depen is null then
				let _cant_depen = 0;
			end if

			if _cant_depen = 0 then
				let _plan = 'A';
			elif _cant_depen = 1 then
				let _plan = 'B';
			else
				let _plan = 'C';
			end if

			let _error_desc = "error al insertar certificados poliza " || _no_documento || " unidad " || _no_unidad;

			insert into tmp_certif(
			no_poliza,
			no_unidad,
			nombre,
			plan,
			cedula,
			fecha_nac,
			fecha_emis,
			fecha_efec,
			prima_net,
			impuesto,
			prima_bru,
			contratante,
		    doc_poliza,
			vigen_inic,
			subramo,
			compania,
			vigencia_i,
			vigencia_f
			)
			values(
			_no_poliza,
			_no_unidad,
			_nombre_cli,
			_plan,
			_cedula,
			_fecha_nac,
			_fecha_emis,
			_fecha_efec,
			_prima_neta,
			_impuesto_uni,
			_prima_brut_uni,
			_nombre_cliente,
			_no_documento,
			_vigencia_inic,
			_nombre_subramo,
			_nombre_compania,
			a_vigencia_desde,
			a_vigencia_hasta
			);

		end if

		let _error_desc = 'error al insertar unidades'|| _no_documento || " unidad " || _no_unidad;

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
	    prima_retenida
		)
		values(
	    _no_poliza,
	    _no_endoso,
	    _no_unidad,
	    _cod_ruta,
	    _cod_producto,
	    _cod_cliente,
	    _suma_asegurada,
	    _prima_certif,
	    _descuento,
	    _recargo,
	    _prima_neta,
	    _impuesto_uni,
	    _prima_brut_uni,
	    1,
	    _fecha1,
	    _fecha2,
	    _beneficio_max,
	    _desc_unidad,
	    0,
	    0
		);

		-- actualizacion de la tabla de unidades

		update emipouni
		   set facturado      = 1,
		       vigencia_final = _fecha2
		 where no_poliza      = _no_poliza
		   and no_unidad      = _no_unidad;

        -- insercion de descuento

		begin

        insert into endunide(
		no_poliza,
		no_endoso,
		no_unidad,
		cod_descuen,
		porc_descuento
		)
		select no_poliza,
		       _no_endoso,
			   no_unidad,
			   cod_descuen,
               porc_descuento
		  from emiunide
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		end

		-- insercion de recargo

		begin

        insert into endunire(
		no_poliza,
		no_endoso,
		no_unidad,
		cod_recargo,
		porc_recargo
		)
		select no_poliza,
		       _no_endoso,
			   no_unidad,
			   cod_recargo,
               porc_recargo
		  from emiunire
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		end

		-- insercion de coberturas por unidad

		begin

		define _cod_cobertura char(5);
		define _orden                                    smallint;
		define _tarifa                                   dec(9,6);
		define _lim_1,_lim_2,_prima_certbk,_prima_netabk dec(16,2);
		define _ded,_desc_limite1,_desc_limite2	         varchar(50);

		let _cod_cobertura = null;
		let _prima_certbk = 0.00;
		let _prima_netabk = 0.00;
		let _prima_certbk = _prima_certif;
		let _prima_netabk = _prima_neta;

		foreach
			select cod_cobertura,orden,tarifa,deducible,limite_1,limite_2,desc_limite1,desc_limite2
			  into _cod_cobertura,_orden,_tarifa,_ded,_lim_1,_lim_2,_desc_limite1,_desc_limite2
			  from emipocob
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			 order by orden

			if _cod_cobertura is not null then

				let _error_desc = 'error al insertar coberturas' || _no_documento || " unidad " || _no_unidad;

				insert into endedcob(
				no_poliza,
				no_endoso,
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
				desc_limite1,
				desc_limite2,
				factor_vigencia
				)
				values(
				_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cobertura,
				_orden,
				_tarifa,
				_ded,
				_lim_1,
				_lim_2,
				_prima_certif,
				_prima_certif,
				_descuento,
				_recargo,
				_prima_neta,
				today,
				today,
				_desc_limite1,
				_desc_limite2,
				1
				);
				let _prima_certif = 0.00;
				let _prima_neta   = 0.00;
			end if
		end foreach
		let _prima_certif = _prima_certbk;
		let _prima_neta   = _prima_netabk;
		end
		-- actualizacion del reaseguro individual - contratos
		begin

		define _orden             smallint;
		define _cod_contrato      char(5); 
		define _porc_partic_prima dec(9,6);
		define _porc_partic_suma  dec(9,6);
		define _suma_contrato     dec(16,2);
		define _prima_contrato    dec(16,2);
	
		let _suma_asegurada = _suma_asegurada / 100 * _porc_coas;
		let _prima_neta     = _prima_neta     / 100 * _porc_coas;

		-- selecciona los contratos

 	   	delete from emireafa         --> no existia este delete amado 01/03/2010           
 	   	 where no_poliza = _no_poliza  
 		   and no_unidad = _no_unidad; 

 		delete from emifafac         --> no existia este delete amado 05/04/2010           
 		 where no_poliza = _no_poliza  
 		   and no_unidad = _no_unidad
 		   and no_endoso = _no_endoso; 

 		delete from emifacon         --> no existia este delete amado 05/04/2010           
 		 where no_poliza = _no_poliza  
 		   and no_unidad = _no_unidad
 		   and no_endoso = _no_endoso; 

 		delete from emireaco           
 		 where no_poliza = _no_poliza  
 		   and no_unidad = _no_unidad; 

 		delete from emireama           
 		 where no_poliza = _no_poliza  
 		   and no_unidad = _no_unidad; 

		insert into emireama( 
	    no_poliza,            
		no_unidad,            
		no_cambio,
		cod_cober_reas,       
		vigencia_inic,
		vigencia_final
		)                     
		values(               
	    _no_poliza,           
		_no_unidad,
		0,           
		_cod_cober_reas,      
		_vigencia_inic,
	    _fecha2
		);                    

		let _fronting = sp_sis135(_no_poliza);

        if _fronting = 1 then	--> se agrego para las polizas fronting amado - armando 6/10/2010
		    foreach
				select orden, 
				       cod_contrato, 
				       porc_partic_prima, 
				       porc_partic_suma
				  into _orden, 
				       _cod_contrato, 
				       _porc_partic_prima, 
				       _porc_partic_suma
				  from emigloco
				 where no_poliza = _no_poliza
				   and no_endoso = '00000'

				let _suma_contrato  = _suma_asegurada / 100 * _porc_partic_suma;
				let _prima_contrato = _prima_neta     / 100 * _porc_partic_prima;
			  
				let _error_desc = 'error al insertar contratos - poliza ' || _no_documento || " unidad " || _no_unidad;

				insert into emifacon(
			    no_poliza,	   
			    no_endoso,
				no_unidad,
				cod_cober_reas,
			    orden,
			    cod_contrato,
			    porc_partic_prima,
			    porc_partic_suma,
			    suma_asegurada,
			    prima
				)
				values(
			    _no_poliza,
			    _no_endoso,
				_no_unidad,
				_cod_cober_reas,
			    _orden,
			    _cod_contrato,
			    _porc_partic_prima,
			    _porc_partic_suma,
			    _suma_contrato,
			    _prima_contrato
				);

	 			insert into emireaco( 
	 		    no_poliza,            
	 			no_unidad,            
				no_cambio,
	 			cod_cober_reas,       
	 		    orden,                
	 		    cod_contrato,         
	 		    porc_partic_prima,    
	 		    porc_partic_suma     
	 			)                     
	 			values(               
	 		    _no_poliza,           
	 			_no_unidad,           
				0,
	 			_cod_cober_reas,      
	 		    _orden,               
	 		    _cod_contrato,        
	 		    _porc_partic_prima,   
	 		    _porc_partic_suma
	 			);                    

		end foreach 	
	   else			    

		foreach
		 select	orden,
				cod_contrato,     
				porc_partic_prima,
				porc_partic_suma
		   into	_orden,
				_cod_contrato,     
				_porc_partic_prima,
				_porc_partic_suma
		   from	rearucon
		  where	cod_ruta  = _cod_ruta
		  order by orden

			let _suma_contrato  = _suma_asegurada / 100 * _porc_partic_suma;
			let _prima_contrato = _prima_neta     / 100 * _porc_partic_prima;
		  
			let _error_desc = 'error al insertar contratos - poliza ' || _no_documento || " unidad " || _no_unidad;

			insert into emifacon(
		    no_poliza,
		    no_endoso,
			no_unidad,
			cod_cober_reas,
		    orden,
		    cod_contrato,
		    porc_partic_prima,
		    porc_partic_suma,
		    suma_asegurada,
		    prima
			)
			values(
		    _no_poliza,
		    _no_endoso,
			_no_unidad,
			_cod_cober_reas,
		    _orden,
		    _cod_contrato,
		    _porc_partic_prima,
		    _porc_partic_suma,
		    _suma_contrato,
		    _prima_contrato
			);

 			insert into emireaco( 
 		    no_poliza,            
 			no_unidad,            
			no_cambio,
 			cod_cober_reas,       
 		    orden,                
 		    cod_contrato,         
 		    porc_partic_prima,    
 		    porc_partic_suma     
 			)                     
 			values(               
 		    _no_poliza,           
 			_no_unidad,           
			0,
 			_cod_cober_reas,      
 		    _orden,               
 		    _cod_contrato,        
 		    _porc_partic_prima,   
 		    _porc_partic_suma
 			);                    

		end foreach 	
	   end if
		-- prima suscrita de la unidad

		select sum(prima)
		  into _prima_contrato
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		if _prima_contrato is null then
			let _prima_contrato = 0;
		end if

		update endeduni
		   set prima_suscrita = _prima_contrato
		 where no_poliza      = _no_poliza
		   and no_endoso      = _no_endoso
		   and no_unidad      = _no_unidad;

		-- prima retenida de la unidad

		begin

			define _cod_contrato  char(5); 
			define _tipo_contrato smallint;

		 	let _prima_contrato = 0;

		   foreach	
			select prima,
				   cod_contrato	
			  into _suma_contrato,
			       _cod_contrato
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad

				select tipo_contrato
				  into _tipo_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;
				 
				 if _tipo_contrato = 1 then
				 	let _prima_contrato = _prima_contrato + _suma_contrato;
				 end if 			

		   end foreach

			if _prima_contrato is null then
				let _prima_contrato = 0;
			end if

			update endeduni
			   set prima_retenida = _prima_contrato
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso
			   and no_unidad      = _no_unidad;

		end

		end

	end foreach

	end

	-- actualizacion de prima suscrita, prima retenida, suma asegurada

	begin

	define _prima_sus dec(16,2);
	define _prima_ret dec(16,2);
	define _suma_aseg dec(16,2);
	define _descuento   dec(16,2);
	define _recargo	    dec(16,2);
	define _prima_neta  dec(16,2);
	define _impuesto    dec(16,2);
	define _prima_bruta dec(16,2);
	define _no_pagos  		integer;
	define _no_tarjeta      char(19);
	define _no_doc          char(20); 
	define _monto_visa      dec(16,2);
	define _no_cuenta       char(17);
	define _tipo_forma      smallint;
	
	let _no_pagos = 0;
	let _no_tarjeta = null;
	let _no_doc = "";
	let _monto_visa = 0;
	let _cod_formapag = null;
	let _no_cuenta    = null;

	select sum(prima_suscrita),
	       sum(prima_retenida),
		   sum(suma_asegurada),
		   sum(descuento),
		   sum(recargo),
		   sum(prima_neta),
		   sum(impuesto),
		   sum(prima_bruta)
	  into _prima_sus,
	       _prima_ret,
		   _suma_aseg,
		   _descuento,  
		   _recargo,	   
		   _prima_neta, 
		   _impuesto,   
		   _prima_bruta
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima_sus is null then
		let _prima_sus = 0;
	end if

	if _prima_ret is null then
		let _prima_ret = 0;
	end if

	if _suma_aseg is null then
		let _suma_aseg = 0;
	end if

	update endedmae
	   set prima_suscrita = _prima_sus,
	       prima_retenida = _prima_ret,
		   suma_asegurada = _suma_aseg,
		   descuento      = _descuento,
		   recargo        = _recargo,	
		   prima_neta     = _prima_neta, 
		   impuesto       = _impuesto,   
		   prima_bruta	  = _prima_bruta
	  where no_poliza     = _no_poliza
	    and no_endoso     = _no_endoso;
	
	-- datos a retornar

	select prima_neta,
		   impuesto
	  into _prima_neta,
	       _monto_impuesto
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

		--********************************************************--
		--actualizar montos de visa y ach  a la tabla emipomae / cobtacre / cobcutas--
		--********************************************************--

			select cod_formapag,
				   no_pagos,
				   no_tarjeta,
				   no_documento,
				   no_cuenta
			  into _cod_formapag,
				   _no_pagos,
				   _no_tarjeta,
				   _no_doc,
				   _no_cuenta
			  from emipomae
			 where no_poliza = _no_poliza;

			select tipo_forma
			  into _tipo_forma
			  from cobforpa
			 where cod_formapag = _cod_formapag;

			if _tipo_forma = 2 and _no_tarjeta is not null then -- tarjetas de credito

			    let _monto_visa = _prima_bruta / _no_pagos;

			    update emipomae
			       set monto_visa = _monto_visa
			     where no_poliza  = _no_poliza;

			    update cobtacre
			       set monto        = _monto_visa
			     where no_tarjeta   = _no_tarjeta
				   and no_documento = _no_doc;

			end if

			if _tipo_forma = 4 and _no_cuenta is not null then -- ach

			    let _monto_visa = _prima_bruta / _no_pagos;

			    update emipomae
			       set monto_visa = _monto_visa
			     where no_poliza  = _no_poliza;

			    update cobcutas
			       set monto        = _monto_visa
			     where no_cuenta    = _no_cuenta
				   and no_documento = _no_doc;

			end if

	end

	-- actualizacion de la vigencia final de la poliza

	update emipomae
	   set vigencia_final = _fecha2,
	       ult_no_endoso  = _no_endoso_int
	 where no_poliza      = _no_poliza;


	-- cambio de comision para la polizas

	begin

	define _cod_producto char(5);
	define _anos         smallint;
	define _porc_comis   dec(5,2);
	define _periodo1     datetime year to month;
	define _periodo2     datetime year to month;
	define _periodo_char char(80);
	define _mes          char(2);
	define _no_doc       char(20);
	define _cnnt         integer;

	if month(_vigencia_inic) < 10 then
		let _periodo1 = year(_vigencia_inic)  || "-0" || month(_vigencia_inic);
	else
		let _periodo1 = year(_vigencia_inic)  || "-" || month(_vigencia_inic);
	end if

	if month(_fecha2) < 10 then
		let _periodo2 = year(_fecha2) || "-0" || month(_fecha2);
	else
		let _periodo2 = year(_fecha2) || "-" || month(_fecha2);
	end if

	let _periodo_char = _periodo2 - _periodo1;
	let _anos         = _periodo_char[1,5];

	if _periodo_char[7,8] <> '00' then
		let _anos = _anos + 1;
	end if
	
	let _cod_producto = null;
	let _porc_comis   = null;

	foreach
	 select	cod_producto
	   into	_cod_producto
	   from	emipouni
	  where	no_poliza = _no_poliza
	    and activo    = 1
		exit foreach;
	end foreach
	
	select no_documento
	  into _no_doc
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cnnt
	  from chqcomsa
	 where no_documento = _no_doc;
		 
	if _cnnt is null then
		let _cnnt = 0;
	end if
	
	if _cod_producto is not null then

		if _cnnt = 0 then	

		   foreach	
			select porc_comis_agt
			  into _porc_comis
			  from prdcoprd
			 where cod_producto = _cod_producto
			   and ano_desde   <= _anos
			   and ano_hasta   >= _anos
				exit foreach;
			end foreach

			if _porc_comis is not null then
				
				update emipoagt
				   set porc_comis_agt = _porc_comis
				 where no_poliza      = _no_poliza;

			end if
			
		end if	

	end if
	--Volver a la comision normal despues de cumplir un año 21/04/2015
	if _anos >= 2 then

		if _cnnt > 0 then
			select porc_comision
			  into _porc_comis
			  from prdramo
			 where cod_ramo = '018';
			 
			UPDATE emipoagt
			   SET porc_comis_agt = _porc_comis
			 WHERE no_poliza      = _no_poliza;			 
		end if		
	end if

	end

	call sp_pro100(_no_poliza, _no_endoso);	 -- historico de endedmae (endedhis)
	call sp_sis70(_no_poliza, _no_endoso);	 -- historico de emipoagt (endmoage)

	-- Actualización de la información de Emiletra
	call sp_pro541b(_no_poliza,_no_endoso) returning _error,_error_desc;
	if _error <> 0 then
		let _error_desc = 'Actualizando Emiletra. ' || _no_documento || ' ' || trim(_error_desc);
		return _error, _error_desc;
	end if 
	
	-- registros para el comprobante de reaseguro

	call sp_rea008(1, _no_poliza, _no_endoso) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

end foreach

--update parparam
--   set emi_fecha_salud = a_vigencia_hasta
-- where cod_compania    = a_compania;

return 0, 'actualizacion exitosa ...';

end

end procedure;
