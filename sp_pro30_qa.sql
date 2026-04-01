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

--DROP PROCEDURE sp_pro30qa;

CREATE PROCEDURE sp_pro30qa(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_vigencia_desde DATE,
a_vigencia_hasta DATE,
a_usuario        CHAR(8)
) RETURNING INTEGER,
			CHAR(100);

DEFINE _cod_ramo        	CHAR(3);  
DEFINE _no_poliza       	CHAR(10); 
DEFINE _cod_tipoprod1   	CHAR(3);  
DEFINE _cod_tipoprod2   	CHAR(3);  
DEFINE _prima_neta      	DEC(16,2);
DEFINE _fecha1          	DATE;     
DEFINE _fecha2          	DATE;     
DEFINE _cod_perpago     	CHAR(3);  
DEFINE _cod_formapag    	CHAR(3);  
DEFINE _cod_endomov     	CHAR(3);  
DEFINE _no_documento    	CHAR(20); 
DEFINE _periodo         	CHAR(7);  
DEFINE _no_endoso_int   	INTEGER;  
DEFINE _no_endoso_char  	CHAR(5);  
DEFINE _no_factura      	CHAR(10); 
DEFINE _descuento       	DEC(16,2);
DEFINE _recargo         	DEC(16,2);
DEFINE _cod_impuesto    	CHAR(3);  
DEFINE _monto_impuesto  	DEC(16,2);
DEFINE _factor_impuesto 	DEC(5,2); 
DEFINE _no_unidad       	CHAR(5);
DEFINE _porc_coas       	DEC(7,4);
DEFINE _tipo_produccion 	CHAR(3);
DEFINE _cod_coasegur    	CHAR(3);
DEFINE _factor_imp_tot  	DEC(5,2);
DEFINE _no_endoso       	CHAR(5);
DEFINE _vigencia_inic   	DATE;
DEFINE _porc_descuento  	DEC(5,2);
DEFINE _porc_recargo    	DEC(5,2);
DEFINE _prima_certif     	DEC(16,2);
DEFINE _prima_certif2		DEC(16,2);
DEFINE _prima_vida          DEC(16,2);
DEFINE _cod_cliente     	CHAR(10);
DEFINE _nombre_cliente  	CHAR(50);
DEFINE _nombre_compania 	CHAR(50);
DEFINE _cod_subramo			CHAR(50);
DEFINE _nombre_subramo  	CHAR(50);
DEFINE _cod_cober_reas  	CHAR(3);
DEFINE _cod_ruta        	CHAR(5);
DEFINE _no_endoso_ext		CHAR(5);

DEFINE _porc_partic_prima 	DEC(9,6);
DEFINE _porc_partic_suma  	DEC(9,6);
DEFINE _error_desc      	CHAR(100);
DEFINE _mes_contable		smallint;
DEFINE _ano_contable		smallint;
DEFINE _cantidad			smallint;
define _fronting            smallint;
DEFINE _meses           	SMALLINT;
DEFINE _error           	SMALLINT;
define _error_isam			smallint;
DEFINE _serie           	SMALLINT;
DEFINE _tiene_impuesto  	SMALLINT; 
DEFINE ld_prima_dep         DEC(16,2);
DEFINE ld_prima_resta      	DEC(16,2);
DEFINE ld_recargo_dep       DEC(16,2);
define _imp_endeduni		dec(16,2);
define _imp_endedmae		dec(16,2);
define _fecha_indicador	date;


--SET DEBUG FILE TO "sp_pro30.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

let _error_desc = "";

BEGIN
ON EXCEPTION SET _error 
	RETURN _error, _error_desc;
END EXCEPTION           

-- Nombre de la Compania

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

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;

-- Ramo de Salud

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

-- Contrato de Reaseguro

LET _serie    = YEAR(a_vigencia_desde);
LET _cod_ruta = NULL;
LET _error_desc = 'Contrato de Reaseguro. ';

FOREACH
 SELECT cod_ruta
   INTO _cod_ruta
   FROM rearumae
  WHERE cod_ramo = _cod_ramo
    and activo = 1
	and a_vigencia_desde between vig_inic and vig_final
  ORDER BY cod_ruta	DESC
		EXIT FOREACH;
END FOREACH

IF _cod_ruta IS NULL THEN
	LET _error_desc = 'No Existe Distribucion de Reaseguro ...';
	RETURN 1, _error_desc; 
END IF

SELECT SUM(porc_partic_prima),			   
	   SUM(porc_partic_suma)
  INTO _porc_partic_prima,
	   _porc_partic_suma
  FROM rearucon
 WHERE cod_ruta = _cod_ruta;

IF _porc_partic_prima <> 100 THEN
	LET _error_desc = 'La Distribucion No Es 100%, Verifique la Ruta ' || _cod_ruta;
	RETURN 1, _error_desc; 
END IF

IF _porc_partic_suma <> 100 THEN
	LET _error_desc = 'La Distribucion No Es 100%, Verifique la Ruta ' || _cod_ruta;
	RETURN 1, _error_desc; 
END IF

-- Selecciona La Primera Cobertura de Reaseguro

LET _cod_cober_reas = NULL;

FOREACH
 SELECT cod_cober_reas
   INTO _cod_cober_reas
   FROM reacobre
  WHERE cod_ramo = _cod_ramo
  ORDER BY cod_cober_reas
	EXIT FOREACH;
END FOREACH

IF _cod_cober_reas IS NULL THEN
	LET _error_desc = 'No Existe Cobertura de Reaseguro ...';
	RETURN 1, _error_desc; 
END IF

-- Tipo de Produccion Sin Coaseguro y Coaseguro Mayoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;

-- Movimiento de Facturacion de Salud

SELECT cod_endomov
  INTO _cod_endomov
  FROM endtimov
 WHERE tipo_mov = 14;

LET _no_poliza  = '';

DELETE FROM tmp_certif;

-- Seleccion de las Polizas

FOREACH
 SELECT no_poliza,
		cod_perpago,
		vigencia_final,
		cod_formapag,
		no_documento,
		cod_tipoprod,
		vigencia_inic,
		cod_contratante,
		cod_subramo   
   INTO _no_poliza,
		_cod_perpago,
		_fecha1,
		_cod_formapag,
		_no_documento,
		_tipo_produccion,
		_vigencia_inic,
		_cod_cliente,
		_cod_subramo   
   FROM emipomae
  WHERE cod_compania   = a_compania
    AND cod_ramo       = _cod_ramo
    AND vigencia_final >= a_vigencia_desde
    AND vigencia_final <= a_vigencia_hasta
    AND estatus_poliza IN (1,3)
    AND actualizado    = 1
    AND (cod_tipoprod  = _cod_tipoprod1 OR
 	     cod_tipoprod  = _cod_tipoprod2)
	AND no_documento   not in ("1802-00086-01", "1800-00036-01", "1803-00505-01", "1813-00168-01","1812-00077-01","1812-00088-01")

	-- No Facturacion por Morosidad a 61 dias
	LET _error_desc = 'No Facturacion por Morosidad a 61 dias. ' || _no_documento;
	call sp_cob271(_no_poliza, a_usuario)  returning _error, _error_desc;

	if _error = 1 then
		continue foreach;
	end if

	if _error <> 0 then
		return _error, _error_desc;
	end if

	-- Procedure que realiza el calculo de las tarifas nuevas de salud 
	LET _error_desc = 'Calculo de las tarifas nuevas de salud . ' || _no_documento;
	call sp_pro30c(_no_poliza) returning _error, _error_desc;

	if _error <> 0 then
		RETURN _error, _error_desc;
	end if

	-- Nombre del Subramo

	SELECT nombre
	  INTO _nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	-- Nombre del Cliente

	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	-- Se Determina el Porcentaje de Descuento
	LET _error_desc = 'Determina el Porcentaje de Descuento . '|| _no_documento;
	LET _no_unidad      = NULL;
	LET _porc_descuento = 0;

	-- Se Determina el Porcentaje de Recargo
	LET _error_desc = 'Determina el Porcentaje de Recargo . '|| _no_documento;
	LET _no_unidad      = NULL;
	LET _porc_recargo   = 0;

	-- Verificacion si es Coaseguro Mayoritario

	IF _tipo_produccion = _cod_tipoprod2 THEN

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF

	-- Se determina la nueva vigencia final de la poliza
	LET _error_desc = 'Nueva vigencia final . '|| _no_documento;
	SELECT meses
	  INTO _meses
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

	if _meses = 0 then
		if _cod_perpago = '008' then
			let _meses = 12;
		else
			let _meses = 1;
		end if
	end if

	LET _fecha2 = _fecha1 + _meses UNITS MONTH;

	-- Se Determina la Prima a Facturar
	SELECT SUM(prima_total),
	       SUM(prima_vida)
	  INTO _prima_certif,
	       _prima_vida
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND activo    = 1;

	IF _prima_certif IS NULL THEN
		LET _prima_certif = 0;
	END IF

 	LET _prima_vida = 0.00;

	LET _descuento   = sp_proe71(_no_poliza);--_prima_certif / 100 * _porc_descuento;
	LET _recargo     = sp_proe70(_no_poliza);--(_prima_certif - _descuento) / 100 * _porc_recargo;
	LET _prima_neta  = _prima_certif - _descuento + _recargo;

	-- Asignacion del Numero de Endoso
	LET _error_desc = 'Asignacion del Numero de Endoso . '|| _no_documento;
	SELECT MAX(no_endoso)
	  INTO _no_endoso_int
	  FROM endedmae
	 WHERE no_poliza = _no_poliza;

	IF _no_endoso_int IS NULL THEN
		LET _no_endoso_int  = 0;
	END IF

	LET _no_endoso_int  = _no_endoso_int + 1;
	LET _no_endoso_char = '00000';
	 
	IF _no_endoso_int > 9999  THEN	
		LET _no_endoso_char[1,5] = _no_endoso_int;
	ELIF _no_endoso_int > 999 THEN 
		LET _no_endoso_char[2,5] = _no_endoso_int;
	ELIF _no_endoso_int > 99  THEN 
		LET _no_endoso_char[3,5] = _no_endoso_int;  
	ELIF _no_endoso_int > 9   THEN 
		LET _no_endoso_char[4,5] = _no_endoso_int; 	 
	ELSE
		LET _no_endoso_char[5,5] = _no_endoso_int;	  
	END IF

	LET _no_endoso = _no_endoso_char;
		
	-- Asignacion del Numero de Factura
	LET _error_desc = 'Asignacion del Numero de Factura . '|| _no_documento;
	LET _no_factura    		= sp_sis14(a_compania, a_sucursal, _no_documento);
	LET _error_desc = 'Asignacion del no_endoso_ext . '|| _no_documento;
	LET _no_endoso_ext 		= sp_sis30(_no_poliza, _no_endoso);
	LET _error_desc = 'Asignacion de Fecha Indicador . ' || _no_documento;
	let _fecha_indicador	= sp_sis156(today, _periodo);

	select count(*)
	  into _cantidad
	  from endedmae
	 where no_factura = _no_factura;

	if _cantidad >= 1 then

		LET _error_desc = 'Numero de Factura Duplicado ';
		RETURN _error, _error_desc;

	end if

	-- Insercion del Endoso

	LET _error_desc = 'Error al Insertar Endosos, Poliza: ' || _no_poliza || " Endoso: " || _no_endoso;

	INSERT INTO endedmae(
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
    fecha_indicador    
	)
	VALUES(
    _no_poliza,
    _no_endoso,
    a_compania,
    a_sucursal,
    '001',
    _cod_formapag,
    NULL,
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
    CURRENT,
    CURRENT,
    _fecha1,
    1,
    1,
    _no_factura,
    NULL,
    CURRENT,
    CURRENT,
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

	BEGIN

	DEFINE _pagado_por CHAR(1);
	DEFINE _impuesto   DEC(16,2);
	
	LET _monto_impuesto = 0;
	LET _tiene_impuesto = 0;
	LET _factor_imp_tot = 0;

	FOREACH
	 SELECT	cod_impuesto
	   INTO	_cod_impuesto
	   FROM	emipolim
	  WHERE	no_poliza = _no_poliza

		SELECT factor_impuesto,
		       pagado_por
		  INTO _factor_impuesto,
			   _pagado_por	
		  FROM prdimpue
		 WHERE cod_impuesto = _cod_impuesto;

		LET _impuesto = (_prima_neta - _prima_vida) / 100 * _factor_impuesto;

		LET _tiene_impuesto = 1;
		LET _monto_impuesto = _monto_impuesto + _impuesto;		
		LET _factor_imp_tot = _factor_imp_tot + _factor_impuesto;

		LET _error_desc = 'Error al Insertar el Impuesto, Poliza # ' || _no_documento;

		INSERT INTO endedimp(
		no_poliza,
		no_endoso,
		cod_impuesto,
		monto
		)
		VALUES(
		_no_poliza,
		_no_endoso,
		_cod_impuesto,
		_impuesto
		);

	END FOREACH

	-- Actualizacion de Impuestos en la Tabla de Endosos

	UPDATE endedmae
	   SET impuesto       = _monto_impuesto,
	       prima_bruta    = prima_neta + _monto_impuesto,
		   tiene_impuesto = _tiene_impuesto
	 WHERE no_poliza      = _no_poliza
	   AND no_endoso      = _no_endoso;

	-- Actualizacion del Saldo de la Poliza

	UPDATE emipomae
	   SET saldo          = saldo + (_prima_neta + _monto_impuesto),
	       estatus_poliza = 1
	 WHERE no_poliza      = _no_poliza;

	END

	-- Insercion de las Unidades

	BEGIN 

	DEFINE _suma_asegurada DEC(16,2);
	DEFINE _cod_producto   CHAR(5);  
	DEFINE _cod_cliente    CHAR(10); 
	DEFINE _beneficio_max  DEC(16,2);
	DEFINE _desc_unidad    CHAR(50); 
	DEFINE _impuesto_uni   DEC(16,2);
	DEFINE _prima_brut_uni DEC(16,2);
	DEFINE _prima_vida_uni DEC(16,2);
	DEFINE _facturado      SMALLINT; 
	DEFINE _cant_unidades  SMALLINT;
	DEFINE _cant_depen     SMALLINT;
	DEFINE _fecha_nac	   DATE;
	DEFINE _cedula		   CHAR(30);
	DEFINE _fecha_emis	   DATE;
	DEFINE _fecha_efec	   DATE;
	DEFINE _nombre_cli     CHAR(100);
	DEFINE _plan           CHAR(1);
		 					
	SELECT COUNT(*)
	  INTO _cant_unidades
	  FROM emipouni
     WHERE no_poliza = _no_poliza
	   AND activo    = 1;

	FOREACH with hold
	 SELECT	no_unidad,
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
	   INTO	_no_unidad,
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
	   FROM	emipouni
	  WHERE	no_poliza = _no_poliza
	    AND activo    = 1
	  order by no_unidad

		if _prima_vida_uni is null then
			update emipouni
			   set prima_vida = 0
			 where no_poliza  = _no_poliza
			   and no_unidad  = _no_unidad;
		end if

		let _prima_vida_uni = 0;

		IF _facturado = 1 THEN
			LET _suma_asegurada = 0;
		END IF

		-- Se Determina la prima de los dependientes
		LET ld_prima_dep = 0;
		LET _error_desc = 'Determina la prima de los dependientes . '|| _no_documento;
		CALL sp_proe54(_no_poliza, _no_unidad) RETURNING ld_prima_dep;

        let ld_prima_resta = _prima_certif - ld_prima_dep;

	    -- Buscar Descuento
		LET _error_desc = 'Buscar Descuento . '|| _no_documento;
		LET _descuento = 0.00;
		CALL sp_proe21(_no_poliza, _no_unidad, _prima_certif) RETURNING _descuento;

		If _descuento > 0 Then
		   LET ld_prima_resta = _prima_certif - _descuento;
		End If

		-- Buscar Recargo
		LET _recargo = 0.00;
		CALL sp_proe22(_no_poliza, _no_unidad, ld_prima_resta) RETURNING _recargo;

		-- Buscar Recargo por dependiente
		LET ld_recargo_dep = 0.00;
		CALL sp_proe53(_no_poliza, _no_unidad) RETURNING ld_recargo_dep;
		LET _recargo = _recargo + ld_recargo_dep;

		LET _prima_neta     = _prima_certif - _descuento + _recargo;
		LET _impuesto_uni   = (_prima_neta - _prima_vida_uni) / 100 * _factor_imp_tot;
		LET _prima_brut_uni = _prima_neta + _impuesto_uni;

		if _prima_neta = 0.00 then
			LET _error_desc = "La prima es 0.00 para la Poliza " || _no_documento || " Unidad " || _no_unidad;
			RETURN 1, _error_desc;
		end if
	
		IF _cant_unidades > 1 THEN
			
			SELECT cedula,
				   fecha_aniversario,
				   nombre
			  INTO _cedula,
			  	   _fecha_nac,
				   _nombre_cli
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente; 	   		   	

			SELECT COUNT(*)
			  INTO _cant_depen
			  FROM emidepen
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad
			   AND activo    = 1;

			IF _cant_depen IS NULL THEN
				LET _cant_depen = 0;
			END IF

			IF _cant_depen = 0 THEN
				LET _plan = 'A';
			ELIF _cant_depen = 1 THEN
				LET _plan = 'B';
			ELSE
				LET _plan = 'C';
			END IF

			LET _error_desc = "Error al Insertar Certificados Poliza " || _no_documento || " Unidad " || _no_unidad;

			INSERT INTO tmp_certif(
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
			VALUES(
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

		END IF
		LET _error_desc = 'Error al Insertar Unidades'|| _no_documento || " Unidad " || _no_unidad;

		INSERT INTO endeduni(
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
		VALUES(
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

		UPDATE emipouni
		   SET facturado      = 1,
		       vigencia_final = _fecha2
		 WHERE no_poliza      = _no_poliza
		   AND no_unidad      = _no_unidad;

		-- Insercion de Descuento

		BEGIN

        INSERT INTO endunide(
		no_poliza,
		no_endoso,
		no_unidad,
		cod_descuen,
		porc_descuento
		)
		SELECT no_poliza,
		       _no_endoso,
			   no_unidad,
			   cod_descuen,
               porc_descuento
		  FROM emiunide
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		END

		-- Insercion de Recargo

		BEGIN

        INSERT INTO endunire(
		no_poliza,
		no_endoso,
		no_unidad,
		cod_recargo,
		porc_recargo
		)
		SELECT no_poliza,
		       _no_endoso,
			   no_unidad,
			   cod_recargo,
               porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		END

		-- Insercion de Coberturas por Unidad

		BEGIN

		DEFINE _cod_cobertura CHAR(5);
				
		LET _cod_cobertura = NULL;

		FOREACH
		 SELECT	cod_cobertura
		   INTO	_cod_cobertura
		   FROM emipocob
		  WHERE	no_poliza = _no_poliza
		    AND no_unidad = _no_unidad
		  ORDER BY cod_cobertura
			EXIT FOREACH;
		END FOREACH

		IF _cod_cobertura IS NOT NULL THEN

			LET _error_desc = 'Error al Insertar Coberturas' || _no_documento || " Unidad " || _no_unidad;

			INSERT INTO endedcob(
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
			VALUES(
		    _no_poliza,
		    _no_endoso,
		    _no_unidad,
		    _cod_cobertura,
		    1,
		    0,
		    0.00,
		    0,
		    0,
		    _prima_certif,
		    _prima_certif,
		    _descuento,
		    _recargo,
		    _prima_neta,
		    TODAY,
		    TODAY,
		    NULL,
		    NULL,
		    1
			);
				
		END IF

		END
		
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
		 SELECT	orden,
				cod_contrato,     
				porc_partic_prima,
				porc_partic_suma
		   INTO	_orden,
				_cod_contrato,     
				_porc_partic_prima,
				_porc_partic_suma
		   FROM	rearucon
		  WHERE	cod_ruta  = _cod_ruta
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
			return _error,_error_desc;
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

	IF _cod_producto IS NOT NULL THEN

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
			
			UPDATE emipoagt
			   SET porc_comis_agt = _porc_comis
			 WHERE no_poliza      = _no_poliza;

		END IF

	END IF

	END
	-- Registros para el Comprobante de Reaseguro
   	LET _error_desc = 'Actualizando Emipomae. ' || _no_documento;
	call sp_proe03(_no_poliza,'001') returning _error;
	if _error <> 0 then
		return _error, _error_desc;
	end if 
   	LET _error_desc = 'Historico de endedmae (endedhis) .'|| _no_documento;
	CALL sp_pro100(_no_poliza, _no_endoso);	 -- Historico de endedmae (endedhis)
   	LET _error_desc = 'Historico de emipoagt (endmoage) . '|| _no_documento;
	CALL sp_sis70(_no_poliza, _no_endoso);	 -- Historico de emipoagt (endmoage)
	

	-- Registros para el Comprobante de Reaseguro
   	LET _error_desc = 'Registros para el Comprobante de Reaseguro . ' || _no_documento;
	call sp_rea008(1, _no_poliza, _no_endoso) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

END FOREACH
LET _error_desc = 'Actualiza Parparam .';
update parparam
   set emi_fecha_salud = a_vigencia_hasta
 where cod_compania    = a_compania;

RETURN 0, 'Actualizacion Exitosa ...';

END

END PROCEDURE;
