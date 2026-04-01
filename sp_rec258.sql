-- Procedimiento que Carga el Listado Inteligente de Recobro
-- en un Periodo Dado
-- 
-- Creado    : 23/10/2015 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

-- Parecido al sp_rec08 Casos con Posible Recobro

DROP PROCEDURE sp_rec258;
--DROP TABLE tmp_pos_recob;
CREATE PROCEDURE "informix".sp_rec258(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE, a_ramo CHAR(255) DEFAULT '*',a_cliente CHAR(255) DEFAULT "*", a_est_recupero SMALLINT DEFAULT 0) 
			RETURNING   VARCHAR(100),
		    	        CHAR(18),
		            	CHAR(20), 
		            	DATE,
		            	DEC(16,2),
						CHAR(50),
						VARCHAR(50),
						VARCHAR(255),
						CHAR(10),
						VARCHAR(50),
						VARCHAR(15);
						

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
DEFINE v_no_recupero     CHAR(10);

DEFINE _cod_ramo        CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       INT;
DEFINE _cod_conductor   CHAR(10);
DEFINE _cod_contratante	CHAR(10);
DEFINE _cod_lugci       CHAR(3);
DEFINE _tipo            CHAR(1);
DEFINE _cant_recu, _cant_sin_pag, _pagado SMALLINT;  
DEFINE _cant_pag, _chq_sin_pag 			  INT;
DEFINE _no_requis       CHAR(10);
DEFINE _cod_coasegur    CHAR(10);
DEFINE _estatus_recobro SMALLINT;
DEFINE v_nombre_emicoase VARCHAR(50);
DEFINE v_est_recobro     VARCHAR(15);  
DEFINE _est_recupero1    SMALLINT;
DEFINE _est_recupero2    SMALLINT;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_pos_recob(
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		documento            CHAR(20)  NOT NULL,
		fecha_siniestro      DATE      NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		monto_pagado         DEC(16,2) NOT NULL,
		cod_contratante      CHAR(10)  NOT NULL,
		no_recupero          CHAR(10)  NOT NULL,
		estatus_recobro      SMALLINT,
		cod_coasegur         CHAR(10),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   

IF a_est_recupero = 0 THEN
	LET _est_recupero1 = 2;
	LET _est_recupero2 = 3;
ELIF a_est_recupero = 1 THEN
	LET _est_recupero1 = 3;
	LET _est_recupero2 = 3;
ELSE
	LET _est_recupero1 = 2;
	LET _est_recupero2 = 2;
END IF		
FOREACH	

 SELECT	a.no_reclamo,
 		a.numrecla,
        a.no_poliza,
		a.fecha_siniestro,
        b.no_recupero,
        b.estatus_recobro,
        b.cod_coasegur,
        b.monto_arreglo		
   INTO	_no_reclamo,
   		v_numrecla,
        _no_poliza,
        v_fecha_siniestro,
        v_no_recupero,
        _estatus_recobro,
        _cod_coasegur,
        v_monto_pagado		
   FROM recrcmae a, recrecup b
  WHERE a.no_reclamo = b.no_reclamo
    AND a.cod_compania    = a_compania
    AND a.estatus_audiencia in (1,7)
	AND a.actualizado = 1
    AND b.fecha_recupero <= a_fecha
	AND b.fecha_envio is null
	AND b.estatus_recobro in (_est_recupero1,_est_recupero2)
	
    -- VERIFICANDO QUE HAYAN TRANSACCIONES DE PAGO - CHAPISTERIA, PIEZAS, DEVOLUCION DE DEDUCIBLE Y REEMBOLSO A ASEGURADO 	
	let _cant_pag = 0;
	
	select count(*)
	  into _cant_pag
	  from rectrmae a, rectrcon b
	 where a.no_tranrec = b.no_tranrec
	   and a.no_reclamo = _no_reclamo	    
	   and a.cod_tipotran = '004'
	   and a.actualizado = 1
	   and b.cod_concepto in ('003','008','017','044','016');
  
	if _cant_pag = 0 then
		CONTINUE FOREACH;
	end if
  
    -- VERIFICANDO QUE SE HAYAN PAGADO LOS PAGOS A PROVEEDORES Y TALLER 	
	let _cant_sin_pag = 0;
 
	select count(*)
	  into _cant_sin_pag
	  from rectrmae a, rectrcon b
	 where a.no_tranrec = b.no_tranrec
	   and a.no_reclamo = _no_reclamo	    
	   and a.cod_tipotran = '004'
	   and a.pagado = 0
	   and a.actualizado = 1
	   and b.cod_concepto in ('003','008','017','044','016');
  
	if _cant_sin_pag > 0 then
		CONTINUE FOREACH;
	end if
	
    -- VERIFICANDO QUE SE HAYAN GENERADO CHEQUES DE LOS PAGOS	
	let _chq_sin_pag = 0;
 
    FOREACH
		select a.no_requis
		  into _no_requis
		  from rectrmae a, rectrcon b
		 where a.no_tranrec = b.no_tranrec
		   and a.no_reclamo = _no_reclamo	    
		   and a.cod_tipotran = '004'
		   and a.pagado = 0
		   and a.actualizado = 1
		   and b.cod_concepto in ('003','008','017','044','016')
		   
		if _no_requis is null or TRIM(_no_requis) = '' then
			let _chq_sin_pag = _chq_sin_pag + 1;
		else
			select pagado
			  into _pagado
			  from chqchmae
			 where no_requis = _no_requis;
			 
			if _pagado = 0 then
				let _chq_sin_pag = _chq_sin_pag + 1;
			end if
		end if	
	END FOREACH
	  
	if _chq_sin_pag > 0 then
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


	IF v_monto_pagado IS NULL THEN
		LET v_monto_pagado = 0;
	END IF 


	INSERT INTO tmp_pos_recob(
    asegurado,      
	numrecla,       
	documento, 
	fecha_siniestro,
	cod_ramo,       
	cod_contratante,
	monto_pagado,
    no_recupero,
    estatus_recobro,
    cod_coasegur	
	)
	VALUES(
	v_asegurado,      
	v_numrecla,       
	v_no_documento,   
	v_fecha_siniestro,
	_cod_ramo,    
	_cod_contratante,
	v_monto_pagado,
	v_no_recupero,
	_estatus_recobro,
	_cod_coasegur
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


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT asegurado,      
 		numrecla,       
 		documento,  
  		fecha_siniestro,
 		cod_ramo,       
 		monto_pagado,
        no_recupero,		
        estatus_recobro,
        cod_coasegur	
   INTO v_asegurado,       
    	v_numrecla,       
    	v_no_documento, 
    	v_fecha_siniestro,
    	_cod_ramo,
    	v_monto_pagado,
		v_no_recupero,
	    _estatus_recobro,
	    _cod_coasegur
   FROM tmp_pos_recob
  WHERE seleccionado = 1
  ORDER BY cod_ramo, cod_coasegur, numrecla

	--Selecciona los nombres de Ramos
	SELECT 	nombre
  	  INTO 	v_nombre_ramo
  	  FROM 	prdramo
	 WHERE	cod_ramo = _cod_ramo;
	 
	--Busca nombre de compañia
	SELECT 	nombre
  	  INTO 	v_nombre_emicoase
  	  FROM 	emicoase
	 WHERE	cod_coasegur = _cod_coasegur;

	if _estatus_recobro = 2 then
		let v_est_recobro = 'INVESTIGACION';
	elif _estatus_recobro = 3 then
		let v_est_recobro = 'SUBROGACION';
	end if

	RETURN TRIM(v_asegurado),      	
		   v_numrecla,       
		   v_no_documento,   
		   v_fecha_siniestro,
		   v_monto_pagado,   
		   v_nombre_ramo,	
		   TRIM(v_compania_nombre),
		   TRIM(v_filtros),
		   v_no_recupero,
		   v_nombre_emicoase,
		   v_est_recobro
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_pos_recob;
END PROCEDURE;