-- Procedimiento que Carga de Arreglo de Pago por Abogado
-- a una Fecha Dada
-- 
-- Creado    : 17/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 22/05/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec11c;
CREATE PROCEDURE "informix".sp_rec11c(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE, a_abogado CHAR(255) DEFAULT "*", a_forma_pago CHAR(255) DEFAULT "*" ) 
			RETURNING   CHAR(5),
						CHAR(100),
		    	        CHAR(18),
		            	CHAR(15),
						date,
						date,
						date,
						dec(16,2);
			

DEFINE v_no_recupero         CHAR(5);
DEFINE v_asegurado     	  	 CHAR(100);
DEFINE v_numrecla         	 CHAR(18);
DEFINE v_responsable         CHAR(100);
DEFINE v_direcc_respo		 CHAR(100);
DEFINE v_telefono_respo		 CHAR(10);
DEFINE v_forma_pago          CHAR(50);
DEFINE v_monto_arreglo       DEC(16,2);
DEFINE v_fecha_firma         DATE;
DEFINE v_no_pagos			 INT;
DEFINE v_fecha_pri_pago      DATE;
DEFINE v_pago_mensual  		 DEC(16,2);
DEFINE v_pagos_al			 DEC(16,2);
DEFINE v_saldo_al            DEC(16,2);
DEFINE v_nombre_abogado      CHAR(50);
DEFINE v_compania_nombre     CHAR(50);
DEFINE v_filtros             CHAR(255);
DEFINE v_prima_orig          DEC(16,2);
DEFINE v_saldo               DEC(16,2);
DEFINE v_por_vencer          DEC(16,2);
DEFINE v_exigible            DEC(16,2);
DEFINE v_corriente           DEC(16,2);
DEFINE v_monto_30            DEC(16,2);
DEFINE v_monto_60            DEC(16,2);
DEFINE v_monto_90            DEC(16,2);
DEFINE _recuperado           DEC(16,2);
define _incurrido_bruto      DEC(16,2);
DEFINE _estatus_audiencia    CHAR(15);
define _fecha_resolucion date;
define _fecha_siniestro date;
define _fecha_reclamo date;

DEFINE _cod_abogado     CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_cliente		CHAR(10);
DEFINE _cod_perpago     CHAR(3);
DEFINE _tipo            CHAR(1);
DEFINE _mes             CHAR(2);
DEFINE _ano             CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE _estatus_recobro SMALLINT;

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);

drop table if exists tmp_arreglo1;

CREATE TEMP TABLE tmp_arreglo1(
        no_recupero          CHAR(5)   NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		responsable 		 CHAR(100),
		direccion_respo		 CHAR(100),
		telefono_respo		 CHAR(10),
		forma_pago           CHAR(50),
		monto_arreglo	     DEC(16,2),
		fecha_firma		     DATE,
		no_pagos             INT, 
		fecha_pri_pago       DATE,
		monto_pagado         DEC(16,2),
		abogado				 CHAR(50),
		cod_abogado          CHAR(3),
		cod_perpago          CHAR(3),
		no_reclamo			 CHAR(10),
		recuperado           DEC(16,2),
		fecha_siniestro      date,
		fecha_reclamo        date,
		fecha_resolucion     date,
		estatus_aud          char(15),
		incurrido_bruto      dec(16,2),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   

FOREACH	
	SELECT no_recupero,
		no_reclamo,
		cod_abogado,
		cod_perpago,
		fecha_envio,
		nombre_tercero,
		direccion_tercero,
		telefono_tercero,
		monto_arreglo,
		no_pagos,
		fecha_primer_pago,
		estatus_recobro,
		fecha_resolucion
	INTO v_no_recupero,
		_no_reclamo,
		_cod_abogado,
		_cod_perpago,
		v_fecha_firma,
		v_responsable,
		v_direcc_respo,
		v_telefono_respo,
		v_monto_arreglo,
		v_no_pagos,
		v_fecha_pri_pago,
		_estatus_recobro,
		_fecha_resolucion
	FROM recrecup
	WHERE cod_compania = a_compania
	AND year(fecha_recupero) = year(a_fecha)
 
	SELECT numrecla,
           no_poliza,
		   fecha_siniestro,
		   fecha_reclamo,
		   decode(estatus_audiencia,1,'GANADO',0,'PERDIDO',2,'POR DEFINIR',3,'PROCESO PENAL',4,'PROCESO CIVIL',5,'APELACION',6,'RESUELTO',7,'FUT-GANADO',8,'FUT-RESP.')
   	  INTO v_numrecla,
           _no_poliza,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _estatus_audiencia
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo 
	   AND actualizado = 1;

	let _incurrido_bruto = 0.00;
    call sp_rec33(_no_reclamo) RETURNING v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,
									     v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,v_monto_arreglo,_incurrido_bruto,v_monto_arreglo;

	-- Lectura de Polizas

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

    -- Lectura de Abogado

	SELECT nombre_abogado
	  INTO v_nombre_abogado
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado;

	-- Lectura de Periodo de Pago

	SELECT nombre
	  INTO v_forma_pago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 
	IF v_numrecla IS NULL THEN
		LET v_numrecla = " ";
	END IF 

	INSERT INTO tmp_arreglo1(
	no_recupero,
	asegurado,          
	numrecla,           
	responsable, 	
	direccion_respo,
	telefono_respo,	
	forma_pago,     	
	monto_arreglo,		
	fecha_firma,		 
	no_pagos,       		
	fecha_pri_pago, 
	monto_pagado,
	abogado,			
	cod_abogado,
	cod_perpago,
	no_reclamo,
	recuperado,
	incurrido_bruto,
	fecha_siniestro,
	fecha_reclamo,
	fecha_resolucion,
	estatus_aud
	)
	VALUES(
	v_no_recupero,
	v_asegurado,     	  	
	v_numrecla,         	
	v_responsable,   
	v_direcc_respo,	
	v_telefono_respo, 
	v_forma_pago,    
	0,   
	v_fecha_firma,	
	0,    
	v_fecha_pri_pago,
	0,
	v_nombre_abogado,
	_cod_abogado,
	_cod_perpago,
	_no_reclamo,
	0,
	_incurrido_bruto,
	_fecha_siniestro,
	_fecha_reclamo,
	_fecha_resolucion,
	_estatus_audiencia
	);
END FOREACH;

--Filtros

LET v_filtros = "";
IF a_abogado <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Abogado: " ||  TRIM(a_abogado);

	LET _tipo = sp_sis04(a_abogado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_arreglo1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_arreglo1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_forma_pago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_forma_pago);

	LET _tipo = sp_sis04(a_forma_pago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_arreglo1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_perpago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_arreglo1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_perpago IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_recupero,
 		asegurado,          
 		numrecla,
		fecha_siniestro,
		fecha_reclamo,
		fecha_resolucion,
		incurrido_bruto,
		estatus_aud
   INTO v_no_recupero,
   		v_asegurado,     	  
    	v_numrecla,        	
    	_fecha_siniestro,
	    _fecha_reclamo,
		_fecha_resolucion,
		_incurrido_bruto,
		_estatus_audiencia
   FROM tmp_arreglo1
  WHERE seleccionado = 1
  ORDER BY no_recupero, numrecla

 	RETURN v_no_recupero,
 		   v_asegurado,
		   v_numrecla,
		   _estatus_audiencia,
		   _fecha_siniestro,
	       _fecha_reclamo,
		   _fecha_resolucion,
		   _incurrido_bruto
      WITH RESUME;

END FOREACH

DROP TABLE tmp_arreglo1;
END PROCEDURE;