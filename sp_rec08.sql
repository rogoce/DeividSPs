-- Procedimiento que Carga de Posible Recobro
-- en un Periodo Dado
-- 
-- Creado    : 14/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 14/08/2000 - Autor: Amado Perez Mendoza
-- Modificado: 22/10/2015 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec08;
--DROP TABLE tmp_pos_recob;
CREATE PROCEDURE "informix".sp_rec08(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7), a_ramo CHAR(255) DEFAULT '*',a_cliente CHAR(255) DEFAULT "*", a_lugci CHAR(255) DEFAULT "*") 
			RETURNING   VARCHAR(100),
		    	        CHAR(18),
		            	CHAR(20), 
		            	DATE,
		            	DATE,
		            	CHAR(10),
		            	CHAR(100),
		            	CHAR(30),
		            	CHAR(50),
		            	DEC(16,2),
						CHAR(50),
						VARCHAR(50),
						VARCHAR(255);
						

DEFINE v_asegurado       VARCHAR(100);
DEFINE v_numrecla        CHAR(18);
DEFINE v_no_documento    CHAR(20);
DEFINE v_fecha_siniestro DATE;
DEFINE v_fecha_audiencia DATE;
DEFINE v_parte_policivo  CHAR(10);
DEFINE v_conductor       CHAR(100);
DEFINE v_cedula_cond     CHAR(30);
DEFINE v_lugar_audiencia CHAR(50);
DEFINE v_monto_pagado    DEC(16,2);
DEFINE v_nombre_ramo	 CHAR(50);
DEFINE v_compania_nombre VARCHAR(50);
DEFINE v_filtros         VARCHAR(255);

DEFINE _cod_ramo        CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       INT;
DEFINE _cod_conductor   CHAR(10);
DEFINE _cod_contratante	CHAR(10);
DEFINE _cod_lugci       CHAR(3);
DEFINE _tipo            CHAR(1);
DEFINE _cant_recu, _cant_sin_pag SMALLINT;  
DEFINE _cant_pag 		INT;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);


CREATE TEMP TABLE tmp_pos_recob(
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		documento            CHAR(20)  NOT NULL,
		cod_lugci			 CHAR(3)   NOT NULL, 
		fecha_siniestro      DATE      NOT NULL,
		fecha_audiencia		 DATE,	   
		parte_policivo		 CHAR(10)  NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		conductor      		 CHAR(100) NOT NULL,
		cedula_cond 		 CHAR(30)  NOT NULL,
		lugar_audiencia		 CHAR(50)  NOT NULL,
		monto_pagado         DEC(16,2) NOT NULL,
		cod_contratante      CHAR(10)  NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   
		
FOREACH	

 SELECT	no_reclamo,
 		numrecla,
        no_poliza,
		cod_conductor,
		fecha_siniestro,
		fecha_audiencia,
		parte_policivo,
		cod_lugci 
   INTO	_no_reclamo,
   		v_numrecla,
        _no_poliza,
		_cod_conductor,
        v_fecha_siniestro,
		v_fecha_audiencia,
		v_parte_policivo,
		_cod_lugci 
   FROM recrcmae
  WHERE cod_compania    = a_compania
    AND estatus_audiencia in (1,7)
	AND actualizado = 1
    AND periodo >= a_periodo1
    AND periodo <= a_periodo2	

    -- VERIFICANDO QUE NO TENGA RECUPERO -- Amado 22/10/2015	
	let _cant_recu = 0;
 
	select count(*)
	  into _cant_recu
	  from recrecup
	 where no_reclamo = _no_reclamo;
  
	if _cant_recu > 0 then
		CONTINUE FOREACH;
	end if
	
    -- VERIFICANDO QUE HAYAN TRANSACCIONES DE PAGO - CHAPISTERIA, PIEZAS, DEVOLUCION DE DEDUCIBLE Y REEMBOLSO A ASEGURADO -- Amado 22/10/2015	
	let _cant_pag = 0;
	
	select count(*)
	  into _cant_pag
	  from rectrmae a, rectrcon b
	 where a.no_tranrec = b.no_tranrec
	   and a.no_reclamo = _no_reclamo	    
	   and a.cod_tipotran = '004'
	   and a.actualizado = 1
	   and b.cod_concepto in ('003','008','017','044');
  
	if _cant_pag = 0 then
		CONTINUE FOREACH;
	end if
  
    -- VERIFICANDO QUE SE HAYAN PAGADO LOS PAGOS A PROVEEDORES Y TALLER -- Amado 22/10/2015	
	let _cant_sin_pag = 0;
 
	select count(*)
	  into _cant_sin_pag
	  from rectrmae a, rectrcon b
	 where a.no_tranrec = b.no_tranrec
	   and a.no_reclamo = _no_reclamo	    
	   and a.cod_tipotran = '004'
	   and a.pagado = 0
	   and a.actualizado = 1
	   and b.cod_concepto in ('003','008','017','044');
  
	if _cant_sin_pag > 0 then
		CONTINUE FOREACH;
	end if

	-- Lectura de Polizas

	SELECT no_documento,
	       cod_ramo,
		   cod_contratante
	  INTO v_no_documento,
	       _cod_ramo,
		   _cod_contratante
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura de Contratante

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

    -- Lectura de Conductor

	SELECT nombre,
		   cedula
	  INTO v_conductor,
	       v_cedula_cond
	  FROM cliclien
	 WHERE cod_cliente = _cod_conductor;


    -- Lectura de Lugar de Audiencia
	
	SELECT nombre
	  INTO v_lugar_audiencia
	  FROM reclugci
	 WHERE cod_lugci = _cod_lugci;


	-- Monto Pagado

	 SELECT SUM(monto) 
	   INTO v_monto_pagado
	   FROM rectrmae 
	  WHERE no_reclamo   = _no_reclamo
	    AND cod_tipotran IN ('004','005','006','007')
		AND pagado = 1;

	IF v_monto_pagado IS NULL THEN
		LET v_monto_pagado = 0;
	END IF 

	IF v_parte_policivo IS NULL THEN
		LET v_parte_policivo = " ";
	END IF 

	IF v_conductor IS NULL THEN
		LET v_conductor = " ";
	END IF 

	IF v_cedula_cond IS NULL THEN
		LET v_cedula_cond = " ";
	END IF 

	IF _cod_lugci IS NULL THEN
		LET _cod_lugci = " ";
	END IF 

	IF v_lugar_audiencia IS NULL THEN
		LET v_lugar_audiencia = " ";
	END IF 

	INSERT INTO tmp_pos_recob(
    asegurado,      
	numrecla,       
	documento, 
	cod_lugci,     
	fecha_siniestro,
	fecha_audiencia,
	parte_policivo,	
	cod_ramo,       
	conductor,      
	cedula_cond, 	
	lugar_audiencia,
	cod_contratante,
	monto_pagado   
	)
	VALUES(
	v_asegurado,      
	v_numrecla,       
	v_no_documento,   
	_cod_lugci,
	v_fecha_siniestro,
	v_fecha_audiencia,
	v_parte_policivo, 
	_cod_ramo,    
	v_conductor,      
	v_cedula_cond,    
	v_lugar_audiencia,
	_cod_contratante,
	v_monto_pagado
	);
END FOREACH;

-- Filtros
LET v_filtros = "";


IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Asegurado: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_lugci <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Lugar Audiencia: " ||  TRIM(a_lugci);

	LET _tipo = sp_sis04(a_lugci);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_lugci NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_lugci IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT asegurado,      
 		numrecla,       
 		documento,  
 		cod_lugci,
 		fecha_siniestro,
 		fecha_audiencia,
 		parte_policivo,	
 		cod_ramo,       
 		conductor,      
 		cedula_cond, 	
 		lugar_audiencia,
 		monto_pagado   
   INTO v_asegurado,       
    	v_numrecla,       
    	v_no_documento, 
    	_cod_lugci,  
    	v_fecha_siniestro,
    	v_fecha_audiencia,
    	v_parte_policivo, 
    	_cod_ramo,
    	v_conductor,      
    	v_cedula_cond,    
    	v_lugar_audiencia,
    	v_monto_pagado
   FROM tmp_pos_recob
  WHERE seleccionado = 1
  ORDER BY cod_ramo, numrecla

	--Selecciona los nombres de Ramos
	SELECT 	nombre
  	  INTO 	v_nombre_ramo
  	  FROM 	prdramo
	 WHERE	cod_ramo = _cod_ramo;

	RETURN TRIM(v_asegurado),      	
		   v_numrecla,       
		   v_no_documento,   
		   v_fecha_siniestro,
		   v_fecha_audiencia,
		   v_parte_policivo, 
		   v_conductor,      
		   v_cedula_cond,    
		   v_lugar_audiencia,
		   v_monto_pagado,   
		   v_nombre_ramo,	
		   TRIM(v_compania_nombre),
		   TRIM(v_filtros)
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_pos_recob;
END PROCEDURE;