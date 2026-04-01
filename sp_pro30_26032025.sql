-- Procedimiento que Realiza la Facturacion de Salud

-- Creado    : 16/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 25/05/2007 - Autor: Amado Perez Mendoza 
--                          Se inserta en las tablas de endunire y endunide los recargos y descuentos
-- Modificado: 13/08/2012 - Autor: Roman Gordon
--							Verificacion de diferencias entre endeduni y endedmae  
-- Modificado: 14/03/2013 - Autor: Roman Gordon 
--							Cambiar la forma en que se calcula el recargo y el descuento (sp_proe70 y sp_proe71)

-- SIS v.2.0 - d_prod_sp_pro30_dw1 - DEIVID, S.A.

drop procedure sp_pro30;
create procedure sp_pro30(a_compania char(3), a_sucursal char(3), a_vigencia_desde date, a_vigencia_hasta date, a_usuario char(8))
returning integer, char(100);

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
define _cod_impuesto    	char(3);  
define _cod_coasegur    	char(3);
define _cod_formapag    	char(3);  
define _cod_endomov     	char(3);  
define _cod_perpago     	char(3); 
define _cod_ramo        	char(3);  
define _factor_impuesto 	dec(5,2); 
define _porc_descuento  	dec(5,2);
define _factor_imp_tot  	dec(5,2);
define _porc_recargo    	dec(5,2);
define _porc_coas       	dec(7,4);
define _porc_partic_prima 	dec(9,6);
define _porc_partic_suma  	dec(9,6);
define _monto_impuesto  	dec(16,2);
define ld_prima_resta      	dec(16,2);
define ld_recargo_dep       dec(16,2);
define _prima_certif2		dec(16,2);
define _imp_endeduni		dec(16,2);
define _imp_endedmae		dec(16,2);
define _prima_certif     	dec(16,2);
define ld_prima_dep         dec(16,2);
define _prima_vida          dec(16,2);
define _prima_neta      	dec(16,2);
define _descuento       	dec(16,2);
define _recargo         	dec(16,2);
define _tiene_impuesto  	smallint;
define _cnt_inactivo	  	smallint;
define _mes_contable		smallint;
define _ano_contable		smallint;
define _error_isam			smallint;
define _cantidad			smallint;
define _fronting            smallint;
define _meses           	smallint;
define _error           	smallint;
define _serie           	smallint;
define _no_endoso_int   	integer;
define _fecha_indicador		date;
define _vigencia_inic   	date;
define _fecha1          	date;
define _fecha2          	date;
define _error_d1            char(5);
define _saber				smallint;
define _cod_agente          char(5);
define _tipo_agente         char(1);


--SET DEBUG FILE TO "sp_pro30.trc"; 
--trace on;

set isolation to dirty read;

let _error_desc = "";
let _error_d1 = '';
let _saber = 0;
let _tipo_agente = null;
let _error = 0;

begin
on exception set _error,_error_isam,_error_desc
	insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
	values (_no_documento, _periodo,0,_error_desc,'Error de Base de Datos',_error);
	return _error, _error_desc;
end exception           

LET _nombre_compania = sp_sis01(a_compania);

-- Coaseguradora Lider
-- Periodo de Facturacion

let _ano_contable = year(a_vigencia_desde);
let _mes_contable = month(a_vigencia_desde);

if _mes_contable < 10 then
	let _periodo = _ano_contable || "-0" || _mes_contable;
else
	let _periodo = _ano_contable || "-" || _mes_contable;
end if

update parcontrol
   set fecha_inicio = today
 where periodo = _periodo;

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_compania;

-- Ramo de Salud

select cod_ramo
  into _cod_ramo
  from prdramo
 where ramo_sis = 5;

-- Contrato de Reaseguro

let _serie    = year(a_vigencia_desde);
let _cod_ruta = null;
let _error_desc = 'Contrato de Reaseguro. ';

--***DTERMINACION DE LA RUTA

foreach
	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo = 1
	   and a_vigencia_desde between vig_inic and vig_final
	 order by cod_ruta	desc
	exit foreach;
end foreach

if _cod_ruta is null then
	let _error_desc = 'No Existe Distribucion de Reaseguro ...';
	insert into emifacerr(no_documento, periodo, estatus,descripcion1,descripcion2,cerror)
	values (_cod_ruta, _periodo,0,_error_desc,'La Ruta No existe para la vigencia.',0);
	return 1, _error_desc; 
end if

select sum(porc_partic_prima),			   
	   sum(porc_partic_suma)
  into _porc_partic_prima,
	   _porc_partic_suma
  from rearucon
 where cod_ruta = _cod_ruta;

if _porc_partic_prima <> 100 then
	let _error_desc = 'La Distribucion No Es 100%, Verifique la Ruta ' || _cod_ruta;
	insert into emifacerr(no_documento, periodo, estatus,descripcion1,descripcion2,cerror)
	values (_cod_ruta, _periodo,0,_error_desc,'porc_partic_prima',0);
	return 1, _error_desc; 
end if

if _porc_partic_suma <> 100 then
	let _error_desc = 'La Distribucion No Es 100%, Verifique la Ruta ' || _cod_ruta;
	insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
	values (_cod_ruta, _periodo,0,_error_desc,'porc_partic_suma',0);
	return 1, _error_desc; 
end if

-- Selecciona La Primera Cobertura de Reaseguro

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
	let _error_desc = 'No Existe Cobertura de Reaseguro ...';
	insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
	values (_cod_cober_reas, _periodo,0,_error_desc,'reacobre',0);
	return 1, _error_desc; 
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

-- Movimiento de Facturacion de Salud

select cod_endomov
  into _cod_endomov
  from endtimov
 where tipo_mov = 14;

let _no_poliza  = '';

delete from tmp_certif;

-- Seleccion de las Polizas

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
	   and vigencia_final >= a_vigencia_desde
	   and vigencia_final <= a_vigencia_hasta
	   and estatus_poliza in (1,3)
	   and actualizado    = 1
	   and (cod_tipoprod  = _cod_tipoprod1 or cod_tipoprod  = _cod_tipoprod2)
	   and no_documento   not in(select no_documento from emifacex where estatus = 1)

       --and no_documento   = "1812-00089-01"
	   --and vigencia_final between '23/07/2016' and '31/07/2016'
	   --and no_documento   not in ("1800-00035-01")
	   --and no_documento   in ('1811-00282-01')
       --and no_poliza      = "75419" 

	select count(*)
	  into _cnt_inactivo
	  from emipouni
	 where no_poliza = _no_poliza
	   and activo = 1;

	if _cnt_inactivo is null then
		let _cnt_inactivo = 0;
	end if

	let _error_desc = 'Póliza sin Unidades Activas.' || _no_documento;
	if _cnt_inactivo = 0 then
		
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'Póliza sin Unidades Activas.',_error);
		continue foreach;
	end if

	-- No Facturacion por Morosidad a 61 dias
	let _error_desc = 'No Facturacion por Morosidad a 61 dias. ' || _no_documento;
	call sp_cob271(_no_poliza, a_usuario)  returning _error, _error_desc;

	if _error = 1 then
		continue foreach;
	end if

	if _error <> 0 then
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'No Facturacion por Morosidad a 61 dias',_error);
		continue foreach;
		--return _error, _error_desc;
	end if
	
	-- Procedure para aumento de recargo
	

	-- Procedure que realiza el calculo de las tarifas nuevas de salud 
	let _error_desc = 'Calculo de las tarifas nuevas de salud . ' || _no_documento;
	call sp_pro30c(_no_poliza) returning _error, _error_desc;

	if _error <> 0 then
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'calculo de las tarifas nuevas de salud',_error);
		continue foreach;
		--RETURN _error, _error_desc;
	end if

	-- Nombre del Subramo
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	-- Nombre del Cliente
	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	-- Se Determina el Porcentaje de Descuento
	let _error_desc     = 'Determina el Porcentaje de Descuento . '|| _no_documento;
	let _no_unidad      = null;
	let _porc_descuento = 0;

--Se Puso en comentario para cambiar el calculo al procedure sp_proe71	Roman	14/03/2013
   {FOREACH	
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emiunide
	 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _no_unidad IS NOT NULL THEN
		SELECT SUM(porc_descuento)
		  INTO _porc_descuento
		  FROM emiunide
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_descuento IS NULL THEN
			LET _porc_descuento = 0;
		END IF
	END IF}

	-- Se Determina el Porcentaje de Recargo
	let _error_desc   = 'Determina el Porcentaje de Recargo . '|| _no_documento;
	let _no_unidad    = null;
	let _porc_recargo = 0;

--Se Puso en comentario para cambiar el calculo al procedure sp_proe70	Roman	14/03/2013
   {FOREACH	
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emiunire
	 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _no_unidad IS NOT NULL THEN		  

		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF
	END IF}

	-- Verificacion si es Coaseguro Mayoritario

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

	-- Se determina la nueva vigencia final de la poliza
	let _error_desc = 'Nueva vigencia final . '|| _no_documento;
	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		if _cod_perpago = '008' then
			let _meses = 12;
		else
			let _meses = 1;
		end if
	end if

	let _fecha2 = _fecha1 + _meses units month;

	-- Se Determina la Prima a Facturar

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

    --IF _prima_vida IS NULL THEN	 --se quita 01/12/2011 por que el impuesto debe ser a toda la prima. Armando por inst.de Demetrio.
   	let _prima_vida = 0.00;
    --END IF
--************************************************************************************************************************************
	let _descuento   = sp_proe71(_no_poliza);--_prima_certif / 100 * _porc_descuento;
	let _recargo     = sp_proe70(_no_poliza);--(_prima_certif - _descuento) / 100 * _porc_recargo;
	let _prima_neta  = _prima_certif - _descuento + _recargo;

	-- Asignacion del Numero de Endoso
	let _error_desc = 'Asignacion del Numero de Endoso . '|| _no_documento;
	
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
		
	-- Asignacion del Numero de Factura
	let _error_desc = 'Asignacion del Numero de Factura . '|| _no_documento;
	let _no_factura = sp_sis14(a_compania, a_sucursal, _no_documento);
	let _error_desc = 'Asignacion del no_endoso_ext . '|| _no_documento;
	let _no_endoso_ext = sp_sis30(_no_poliza, _no_endoso);
	let _error_desc = 'Asignacion de Fecha Indicador . ' || _no_documento;
	let _fecha_indicador = sp_sis156(today, _periodo);

	select count(*)
	  into _cantidad
	  from endedmae
	 where no_factura = _no_factura;

	if _cantidad >= 1 then
		let _error_desc = 'Numero de Factura Duplicado ';
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'',_error);
		continue foreach;
		--return _error, _error_desc;
	end if

	-- Insercion del Endoso

	let _error_desc = 'Error al Insertar Endosos, Poliza: ' || _no_poliza || " Endoso: " || _no_endoso;

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
    vigencia_inic,     --11
    vigencia_final,    --12
    prima,             
    descuento,         
    recargo,           
    prima_neta,        
    impuesto,          
    prima_bruta,       
    prima_suscrita,    
    prima_retenida,    
    tiene_impuesto,    
    fecha_emision,     --22
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
    fecha_indicador    
	)
	values(
    _no_poliza,
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
    a_vigencia_desde,	--current,
    a_vigencia_desde,	--current,
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
    _fecha_indicador    
	);

	-- Impuestos por Endoso

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

--		if _pagado_por = 'A' then
		let _tiene_impuesto = 1;
		let _monto_impuesto = _monto_impuesto + _impuesto;		
		let _factor_imp_tot = _factor_imp_tot + _factor_impuesto;
--		end if

		let _error_desc = 'Error al Insertar el Impuesto, Poliza # ' || _no_documento;

		insert into endedimp(
				no_poliza,
				no_endoso,
				cod_impuesto,
				monto)
		values(	_no_poliza,
				_no_endoso,
				_cod_impuesto,
				_impuesto);

	end foreach

	-- Actualizacion de Impuestos en la Tabla de Endosos

	update endedmae
	   set impuesto       = _monto_impuesto,
	       prima_bruta    = prima_neta + _monto_impuesto,
		   tiene_impuesto = _tiene_impuesto
	 where no_poliza      = _no_poliza
	   and no_endoso      = _no_endoso;

	-- Actualizacion del Saldo de la Poliza

	update emipomae
	   set saldo          = saldo + (_prima_neta + _monto_impuesto),
	       estatus_poliza = 1
	 where no_poliza      = _no_poliza;

	end

	-- Insercion de las Unidades

	begin 

	define _nombre_cli     char(100);
	define _desc_unidad    char(50);
	define _cedula		   char(30);
	define _cod_cliente    char(10); 
	define _cod_producto   char(5);
	define _plan           char(1);
	define _suma_asegurada dec(16,2);
	define _prima_brut_uni dec(16,2);
	define _prima_vida_uni dec(16,2);
	define _beneficio_max  dec(16,2);
	define _impuesto_uni   dec(16,2);
	define _cant_unidades  smallint;
	define _cant_depen     smallint;
	define _facturado      smallint; 
	define _fecha_emis	   date;
	define _fecha_efec	   date;
	define _fecha_nac	   date;

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
			update emipouni
			   set prima_vida = 0
			 where no_poliza  = _no_poliza
			   and no_unidad  = _no_unidad;
		end if

		let _prima_vida_uni = 0;

		if _facturado = 1 then
			let _suma_asegurada = 0;
		end if

		-- Se Determina el Porcentaje de Descuento

	   {	LET _porc_descuento = 0;

		SELECT SUM(porc_descuento)
		  INTO _porc_descuento
		  FROM emiunide
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_descuento IS NULL THEN
			LET _porc_descuento = 0;
		END IF

		-- Se Determina el Porcentaje de Recargo

		LET _porc_recargo   = 0;

		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF
}
		-- Se Determina la prima de los dependientes
		let ld_prima_dep = 0;
		let _error_desc = 'Determina la prima de los dependientes . '|| _no_documento;
		call sp_proe54(_no_poliza, _no_unidad) returning ld_prima_dep;

        let ld_prima_resta = _prima_certif - ld_prima_dep;

	    -- Buscar Descuento
		let _error_desc = 'Buscar Descuento . '|| _no_documento;
		let _descuento = 0.00;
		call sp_proe21(_no_poliza, _no_unidad, _prima_certif) returning _descuento;

		if _descuento > 0 then
		   let ld_prima_resta = _prima_certif - _descuento;
		end if

		-- Buscar Recargo
		let _recargo = 0.00;
		call sp_proe22(_no_poliza, _no_unidad, ld_prima_resta) returning _recargo;

		-- Buscar Recargo por dependiente
		let ld_recargo_dep = 0.00;
		call sp_proe53(_no_poliza, _no_unidad) returning ld_recargo_dep;
		let _recargo = _recargo + ld_recargo_dep;

	   --	LET _descuento      = _prima_certif / 100 * _porc_descuento;
	   --	LET _recargo        = (_prima_certif - _descuento) / 100 * _porc_recargo;  Verificar Amado 18-11-2010
		let _prima_neta     = _prima_certif - _descuento + _recargo;
		let _impuesto_uni   = (_prima_neta - _prima_vida_uni) / 100 * _factor_imp_tot;
		let _prima_brut_uni = _prima_neta + _impuesto_uni;
        let _saber = 0;
		if _prima_neta = 0.00 then
			let _error_desc = "La prima es 0.00 para la Poliza " || _no_documento || " Unidad " || _no_unidad;
			insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
			values (_no_documento, _periodo,0,_error_desc,'',_error);
			let _saber = 1;
			exit foreach;
			--return 1, _error_desc;
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

			let _error_desc = "Error al Insertar Certificados Poliza " || _no_documento || " Unidad " || _no_unidad;

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
		let _error_desc = 'Error al Insertar Unidades'|| _no_documento || " Unidad " || _no_unidad;

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

		-- Actualizacion de la Tabla de Unidades

		update emipouni
		   set facturado      = 1,
		       vigencia_final = _fecha2
		 where no_poliza      = _no_poliza
		   and no_unidad      = _no_unidad;

		-- Insercion de Descuento

		begin
			insert into endunide(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_descuen,
			porc_descuento)
			select no_poliza,
				   _no_endoso,
				   no_unidad,
				   cod_descuen,
				   porc_descuento
			  from emiunide
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
		end

		-- Insercion de Recargo
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

		-- Insercion de Coberturas por Unidad
		begin
			define _cod_cobertura                            char(5);
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
					let _error_desc = 'Error al Insertar Coberturas' || _no_documento || " Unidad " || _no_unidad;

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
		-- Actualizacion del Reaseguro Individual - Contratos
		BEGIN
			DEFINE _orden             SMALLINT;
			DEFINE _cod_contrato      CHAR(5); 
			DEFINE _porc_partic_prima DEC(9,6);
			DEFINE _porc_partic_suma  DEC(9,6);
			DEFINE _suma_contrato     DEC(16,2);
			DEFINE _prima_contrato    DEC(16,2);
		
			LET _suma_asegurada = _suma_asegurada / 100 * _porc_coas;
			LET _prima_neta     = _prima_neta     / 100 * _porc_coas;

			-- Selecciona Los Contratos

			DELETE FROM emireafa         --> No existia este delete Amado 01/03/2010           
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad; 

			DELETE FROM emifafac         --> No existia este delete Amado 05/04/2010           
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad
			   AND no_endoso = _no_endoso; 

			DELETE FROM emifacon         --> No existia este delete Amado 05/04/2010           
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad
			   AND no_endoso = _no_endoso; 

			DELETE FROM emireaco           
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad; 

			DELETE FROM emireama           
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad; 

			INSERT INTO emireama( 
			no_poliza,            
			no_unidad,            
			no_cambio,
			cod_cober_reas,       
			vigencia_inic,
			vigencia_final
			)                     
			VALUES(               
			_no_poliza,           
			_no_unidad,
			0,           
			_cod_cober_reas,      
			_vigencia_inic,
			_fecha2
			);                    

			let _fronting = sp_sis135(_no_poliza);

			if _fronting = 1 then	--> se agrego para las polizas fronting Amado - Armando 6/10/2010
				FOREACH
					SELECT orden, 
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

					LET _suma_contrato  = _suma_asegurada / 100 * _porc_partic_suma;
					LET _prima_contrato = _prima_neta     / 100 * _porc_partic_prima;
				  
					LET _error_desc = 'Error al Insertar Contratos - Poliza ' || _no_documento || " Unidad " || _no_unidad;

					INSERT INTO emifacon(
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
					VALUES(
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

					INSERT INTO emireaco( 
					no_poliza,            
					no_unidad,            
					no_cambio,
					cod_cober_reas,       
					orden,                
					cod_contrato,         
					porc_partic_prima,    
					porc_partic_suma     
					)                     
					VALUES(               
					_no_poliza,           
					_no_unidad,           
					0,
					_cod_cober_reas,      
					_orden,               
					_cod_contrato,        
					_porc_partic_prima,   
					_porc_partic_suma
					);                    

				END FOREACH 	
		    else			    
				FOREACH
					SELECT orden,
						   cod_contrato,     
						   porc_partic_prima,
						   porc_partic_suma
					  INTO _orden,
						   _cod_contrato,     
						   _porc_partic_prima,
						   _porc_partic_suma
					  FROM rearucon
					 WHERE	cod_ruta = _cod_ruta
					 ORDER BY orden

					LET _suma_contrato  = _suma_asegurada / 100 * _porc_partic_suma;
					LET _prima_contrato = _prima_neta     / 100 * _porc_partic_prima;
				  
					LET _error_desc = 'Error al Insertar Contratos - Poliza ' || _no_documento || " Unidad " || _no_unidad;

					INSERT INTO emifacon(
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
					VALUES(
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

					INSERT INTO emireaco( 
					no_poliza,            
					no_unidad,            
					no_cambio,
					cod_cober_reas,       
					orden,                
					cod_contrato,         
					porc_partic_prima,    
					porc_partic_suma     
					)                     
					VALUES(               
					_no_poliza,           
					_no_unidad,           
					0,
					_cod_cober_reas,      
					_orden,               
					_cod_contrato,        
					_porc_partic_prima,   
					_porc_partic_suma
					);                    

				END FOREACH
		    end if
			-- Prima Suscrita de la Unidad

			SELECT SUM(prima)
			  INTO _prima_contrato
			  FROM emifacon
			 WHERE no_poliza = _no_poliza
			   AND no_endoso = _no_endoso
			   AND no_unidad = _no_unidad;

			IF _prima_contrato IS NULL THEN
				LET _prima_contrato = 0;
			END IF

			UPDATE endeduni
			   SET prima_suscrita = _prima_contrato
			 WHERE no_poliza      = _no_poliza
			   AND no_endoso      = _no_endoso
			   AND no_unidad      = _no_unidad;

			-- Prima Retenida de la Unidad
			BEGIN
				DEFINE _cod_contrato  CHAR(5); 
				DEFINE _tipo_contrato SMALLINT;

				LET _prima_contrato = 0;

			    FOREACH	
					SELECT prima,
						   cod_contrato	
					  INTO _suma_contrato,
						   _cod_contrato
					  FROM emifacon
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   AND no_unidad = _no_unidad

					SELECT tipo_contrato
					  INTO _tipo_contrato
					  FROM reacomae
					 WHERE cod_contrato = _cod_contrato;
					 
					IF _tipo_contrato = 1 THEN
						LET _prima_contrato = _prima_contrato + _suma_contrato;
					END IF

			    END FOREACH

				IF _prima_contrato IS NULL THEN
					LET _prima_contrato = 0;
				END IF

				UPDATE endeduni
				   SET prima_retenida = _prima_contrato
				 WHERE no_poliza      = _no_poliza
				   AND no_endoso      = _no_endoso
				   AND no_unidad      = _no_unidad;

			END
		END
	END FOREACH
	if _saber = 1 then
		call sp_sis119a(_no_poliza,_no_endoso) returning _error, _error_desc, _error_d1;
		continue foreach;
	end if

	-- Verificacion de diferencias entre endeduni y endedmae
		
	select sum(impuesto)
	  into _imp_endeduni
	  from endeduni
	 where no_poliza	= _no_poliza
	   and no_endoso	= _no_endoso;

	select impuesto
	  into _imp_endedmae
	  from endedmae
	 where no_poliza	= _no_poliza
	   and no_endoso	= _no_endoso;

	if _imp_endeduni <> _imp_endedmae then
		call sp_pro365(_no_poliza,_no_endoso) returning _error,_error_isam, _error_desc;
		if _error <> 0 then
			insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
			values (_no_documento, _periodo,0,'diferencias entre endeduni y endedmae','sp_pro365',_error);
			
			call sp_sis119a(_no_poliza,_no_endoso) returning _error, _error_desc, _error_d1;
			continue foreach;
			--return _error,_error_desc;
		end if
	end if 

	END
	-- Actualizacion de Prima Suscrita, Prima Retenida, Suma Asegurada
	BEGIN
		DEFINE _prima_sus	DEC(16,2);
		DEFINE _prima_ret	DEC(16,2);
		DEFINE _suma_aseg	DEC(16,2);
		DEFINE _descuento   DEC(16,2);
		DEFINE _recargo	    DEC(16,2);
		DEFINE _prima_neta  DEC(16,2);
		DEFINE _impuesto    DEC(16,2);
		DEFINE _prima_bruta	DEC(16,2);
		DEFINE _no_pagos  	INTEGER;
		DEFINE _no_tarjeta	CHAR(19);
		DEFINE _no_doc		CHAR(20); 
		DEFINE _monto_visa	DEC(16,2);
		DEFINE _no_cuenta	CHAR(17);
		DEFINE _tipo_forma	SMALLINT;
		
		let _no_pagos		= 0;
		let _no_tarjeta		= null;
		let _no_doc			= "";
		let _monto_visa		= 0;
		let _cod_formapag	= null;
		let _no_cuenta		= null;

		SELECT SUM(prima_suscrita),
			   SUM(prima_retenida),
			   SUM(suma_asegurada),
			   SUM(descuento),
			   SUM(recargo),
			   SUM(prima_neta),
			   SUM(impuesto),
			   SUM(prima_bruta)
		  INTO _prima_sus,
			   _prima_ret,
			   _suma_aseg,
			   _descuento,  
			   _recargo,	   
			   _prima_neta, 
			   _impuesto,   
			   _prima_bruta
		  FROM endeduni
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso;

		IF _prima_sus IS NULL THEN
			LET _prima_sus = 0;
		END IF

		IF _prima_ret IS NULL THEN
			LET _prima_ret = 0;
		END IF

		IF _suma_aseg IS NULL THEN
			LET _suma_aseg = 0;
		END IF

		UPDATE endedmae
		   SET prima_suscrita = _prima_sus,
			   prima_retenida = _prima_ret,
			   suma_asegurada = _suma_aseg,
			   descuento      = _descuento,
			   recargo        = _recargo,	
			   prima_neta     = _prima_neta, 
			   impuesto       = _impuesto,   
			   prima_bruta	  = _prima_bruta
		  WHERE no_poliza     = _no_poliza
			AND no_endoso     = _no_endoso;
		
		-- Datos a Retornar

		SELECT prima_neta,
			   impuesto
		  INTO _prima_neta,
			   _monto_impuesto
		  FROM endedmae
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso;

		--********************************************************--
		--Actualizar Montos de visa y ach  a la tabla emipomae / cobtacre / cobcutas--
		--********************************************************--
		LET _error_desc = 'Actualizar Montos de visa y ach .';
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

		SELECT tipo_forma
		  INTO _tipo_forma
		  FROM cobforpa
		 WHERE cod_formapag = _cod_formapag;

		IF _tipo_forma = 2 and _no_tarjeta is not null THEN -- Tarjetas de Credito

			LET _monto_visa = _prima_bruta / _no_pagos;

			UPDATE emipomae
			   SET monto_visa = _monto_visa
			 WHERE no_poliza  = _no_poliza;

			UPDATE cobtacre
			   SET monto        = _monto_visa
			 WHERE no_tarjeta   = _no_tarjeta
			   and no_documento = _no_doc;

		END IF

		IF _tipo_forma = 4 and _no_cuenta is not null THEN -- Ach

			LET _monto_visa = _prima_bruta / _no_pagos;

			UPDATE emipomae
			   SET monto_visa = _monto_visa
			 WHERE no_poliza  = _no_poliza;

			UPDATE cobcutas
			   SET monto        = _monto_visa
			 WHERE no_cuenta    = _no_cuenta
			   and no_documento = _no_doc;

		END IF
	END

	-- Actualizacion de la vigencia final de la poliza

	UPDATE emipomae
	   SET vigencia_final = _fecha2,
	       ult_no_endoso  = _no_endoso_int
	 WHERE no_poliza      = _no_poliza;

	-- Cambio de Comision para la Polizas

	BEGIN
		DEFINE _cod_producto CHAR(5);
		DEFINE _anos         SMALLINT;
		DEFINE _porc_comis   DEC(5,2);
		DEFINE _periodo1     DATETIME YEAR TO MONTH;
		DEFINE _periodo2     DATETIME YEAR TO MONTH;
		DEFINE _periodo_char CHAR(80);
		DEFINE _mes          CHAR(2);
		DEFINE _no_doc       CHAR(20);
		DEFINE _cnnt         integer;

		IF MONTH(_vigencia_inic) < 10 THEN
			LET _periodo1 = YEAR(_vigencia_inic)  || "-0" || MONTH(_vigencia_inic);
		ELSE
			LET _periodo1 = YEAR(_vigencia_inic)  || "-" || MONTH(_vigencia_inic);
		END IF

		IF MONTH(_fecha2) < 10 THEN
			LET _periodo2 = YEAR(_fecha2) || "-0" || MONTH(_fecha2);
		ELSE
			LET _periodo2 = YEAR(_fecha2) || "-" || MONTH(_fecha2);
		END IF

		LET _periodo_char = _periodo2 - _periodo1;
		LET _anos         = _periodo_char[1,5];

		IF _periodo_char[7,8] <> '00' THEN
			LET _anos = _anos + 1;
		END IF
		
		LET _cod_producto = NULL;
		LET _porc_comis   = NULL;

		FOREACH
		 SELECT	cod_producto
		   INTO	_cod_producto
		   FROM	emipouni
		  WHERE	no_poliza = _no_poliza
			AND activo    = 1
			EXIT FOREACH;
		END FOREACH

		select no_documento
		  into _no_doc
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			exit foreach;
		end foreach

		select count(*)
		  into _cnnt
		  from chqcomsa
		 where no_documento = _no_doc;
			 
		if _cnnt is null then
			let _cnnt = 0;
		end if

		IF _cod_producto IS NOT NULL THEN
		
			if _cnnt = 0 then

			   FOREACH	
				SELECT porc_comis_agt
				  INTO _porc_comis
				  FROM prdcoprd
				 WHERE cod_producto = _cod_producto
				   AND ano_desde   <= _anos
				   AND ano_hasta   >= _anos
					EXIT FOREACH;
				END FOREACH

				IF _porc_comis IS NOT NULL THEN
				
					select tipo_agente
					  into _tipo_agente
					  from agtagent
					 where cod_agente = _cod_agente;

					if _tipo_agente = "O" then
						let _porc_comis = 0.00;
					end if
								
					UPDATE emipoagt
					   SET porc_comis_agt = _porc_comis
					 WHERE no_poliza      = _no_poliza;

				END IF
			end if
		END IF
		--Volver a la comision normal despues de cumplir un año 21/04/2015
		if _anos >= 2 then

			if _cnnt > 0 then
				select porc_comision
				  into _porc_comis
				  from prdramo
				 where cod_ramo = '018';
				 
				select tipo_agente
				  into _tipo_agente
				  from agtagent
				 where cod_agente = _cod_agente;

				if _tipo_agente = "O" then
					let _porc_comis = 0.00;
				end if			 
				if _cod_subramo = '019' then --subramo de cancer 2017, debe tener 25% a partir del segundo año 08/06/2017
					let _porc_comis = 25;
				end if
				UPDATE emipoagt
				   SET porc_comis_agt = _porc_comis
				 WHERE no_poliza      = _no_poliza;			 
			end if		
		end if
	END
	-- Actualización de la información de Emiletra --30/01/2015
	call sp_pro541b(_no_poliza,_no_endoso) returning _error,_error_desc;
	if _error <> 0 then
		let _error_desc = 'Actualizando Emiletra. ' || _no_documento || ' ' || trim(_error_desc);
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'sp_pro541b',_error);
			
		call sp_sis119a(_no_poliza,_no_endoso) returning _error, _error_desc, _error_d1;
		continue foreach;
	end if 
	
	-- Registros para el Comprobante de Reaseguro
   	LET _error_desc = 'Actualizando Emipouni. ' || _no_documento;
	call sp_proe01(_no_poliza,'*','001') returning _error;
	if _error <> 0 then
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'sp_proe01',_error);
		call sp_sis119a(_no_poliza,_no_endoso) returning _error, _error_desc, _error_d1;
		continue foreach;
	end if 
	
   	LET _error_desc = 'Actualizando Emipomae. ' || _no_documento;
	call sp_proe03(_no_poliza,'001') returning _error;
	if _error <> 0 then
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'sp_proe03',_error);
		call sp_sis119a(_no_poliza,_no_endoso) returning _error, _error_desc, _error_d1;
		continue foreach;
	end if 
   	LET _error_desc = 'Historico de endedmae (endedhis) .'|| _no_documento;
	CALL sp_pro100(_no_poliza, _no_endoso);	 -- Historico de endedmae (endedhis)
   	LET _error_desc = 'Historico de emipoagt (endmoage) . '|| _no_documento;
	CALL sp_sis70(_no_poliza, _no_endoso);	 -- Historico de emipoagt (endmoage)
	

	-- Registros para el Comprobante de Reaseguro
   	LET _error_desc = 'Registros para el Comprobante de Reaseguro . ' || _no_documento;
	call sp_rea008(1, _no_poliza, _no_endoso) returning _error, _error_desc;

	if _error <> 0 then
		insert into emifacerr(no_documento, periodo, estatus, descripcion1,descripcion2,cerror)
		values (_no_documento, _periodo,0,_error_desc,'sp_rea008',_error);
		call sp_sis119a(_no_poliza,_no_endoso) returning _error, _error_desc, _error_d1;
		continue foreach;
	end if 

END FOREACH
LET _error_desc = 'Actualiza Parparam .';
update parparam
   set emi_fecha_salud = a_vigencia_hasta
 where cod_compania    = a_compania;

update parcontrol
   set estatus = 1,
       fecha_fin = today
 where periodo = _periodo;

RETURN 0, 'Actualizacion Exitosa ...';
END
END PROCEDURE;