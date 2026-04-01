-- Procedimiento que Carga de Informe de Abogado
-- a una Fecha Dada
-- 
-- Creado    : 16/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 16/08/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec09;
--DROP TABLE tmp_abogado;
CREATE PROCEDURE "informix".sp_rec09(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE, a_abogado CHAR(255) DEFAULT "*", a_estatus_abogado CHAR(255) DEFAULT "*") 
			RETURNING   CHAR(100),
		    	        CHAR(18),
		            	DATE,
		            	DATE,
		            	CHAR(100),
		               	DEC(16,2),
						CHAR(15),
						CHAR(50),
						CHAR(50),
						CHAR(255);


DEFINE v_asegurado     	  	 CHAR(100);
DEFINE v_numrecla         	 CHAR(18);
DEFINE v_fecha_resolucion    DATE;
DEFINE v_fecha_envio	     DATE;
DEFINE v_responsable         CHAR(100);
DEFINE v_monto_recuperado    DEC(16,2);
DEFINE v_nombre_estatus      CHAR(15);
DEFINE v_nombre_abogado      CHAR(50);
DEFINE v_compania_nombre     CHAR(50);
DEFINE v_filtros             CHAR(255);

DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_abogado     CHAR(3);
DEFINE _estatus_abogado CHAR(1);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_cliente		CHAR(10);
DEFINE _tipo            CHAR(1);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_abogado(
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		fecha_resolucion     DATE,
		fecha_envio 		 DATE,
		responsable 		 CHAR(100),
		monto_recuperado     DEC(16,2),
		nombre_estatus       CHAR(15),
		abogado				 CHAR(50),
		cod_ramo             CHAR(3)   NOT NULL,
		cod_abogado			 CHAR(3),
		estatus_abogado      CHAR(1),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;
FOREACH	

 SELECT no_reclamo,
		cod_abogado,
		estatus_abogado,
		fecha_resolucion,
		fecha_envio,
		nombre_tercero,
		monto_arreglo
   INTO _no_reclamo,
		_cod_abogado,
		_estatus_abogado,
		v_fecha_resolucion,
		v_fecha_envio,
		v_responsable,
		v_monto_recuperado
   FROM recrecup
  WHERE cod_compania    = a_compania
    AND estatus_recobro = 4
    AND fecha_recupero <= a_fecha

   	-- Lectura de Reclamos

 	SELECT numrecla,
           no_poliza
   	  INTO v_numrecla,
           _no_poliza
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo 
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT cod_ramo,
		   cod_contratante
	  INTO _cod_ramo,
		   _cod_cliente
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

    IF _estatus_abogado = 'N' THEN
	  LET v_nombre_estatus = 'NADA';
	ELSE
	  IF _estatus_abogado = 'I'	THEN
	    LET	v_nombre_estatus = 'INVESTIGACION';
	  ELSE
	    LET	v_nombre_estatus = 'DEMANDA';
      END IF 
	END IF

	INSERT INTO tmp_abogado(
	asegurado,          
	numrecla,           
	fecha_resolucion,
	fecha_envio, 		
	responsable, 		
	monto_recuperado,   
	nombre_estatus,
	abogado,				
	cod_ramo,
	cod_abogado,           
	estatus_abogado    
	)
	VALUES(
	v_asegurado,     	  	
	v_numrecla,         	
	v_fecha_resolucion,   
	v_fecha_envio,	    
	v_responsable,        
	v_monto_recuperado,   
	v_nombre_estatus,
	v_nombre_abogado,
	_cod_ramo,
	_cod_abogado,
	_estatus_abogado
	);
END FOREACH;

-- Filtros
LET v_filtros = "";

IF a_abogado <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Abogado: " ||  TRIM(a_abogado);

	LET _tipo = sp_sis04(a_abogado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_abogado
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_abogado
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_abogado IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_estatus_abogado <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Estatus Abogado: " ||  TRIM(a_estatus_abogado);

	LET _tipo = sp_sis04(a_estatus_abogado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_abogado
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND estatus_abogado NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_abogado
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND estatus_abogado IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT asegurado,           
 		numrecla,           
 		fecha_resolucion,
 		fecha_envio, 		
 		responsable, 		
 		monto_recuperado,   
 		nombre_estatus,
 		abogado,			
 		cod_ramo,  
 		cod_abogado,
 		estatus_abogado
   INTO v_asegurado,
    	v_numrecla,
    	v_fecha_resolucion,
    	v_fecha_envio,
    	v_responsable,
    	v_monto_recuperado,
    	v_nombre_estatus,
    	v_nombre_abogado,
    	_cod_ramo,
		_cod_abogado,
    	_estatus_abogado
   FROM tmp_abogado
  WHERE seleccionado = 1
  ORDER BY abogado, estatus_abogado, numrecla

	RETURN v_asegurado,
		   v_numrecla,
		   v_fecha_resolucion,
		   v_fecha_envio,
		   v_responsable,
		   v_monto_recuperado,
		   v_nombre_estatus,
		   v_nombre_abogado,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;
END FOREACH

DROP TABLE tmp_abogado;
END PROCEDURE;