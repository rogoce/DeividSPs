-- Procedimiento que Carga el Listado de Presentacion de Cuenta - Recobros
-- en un Periodo Dado
-- 
-- Creado    : 26/10/2015 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_rec259;
--DROP TABLE tmp_pos_recob;
CREATE PROCEDURE "informix".sp_rec259(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7), a_ramo CHAR(255) DEFAULT '*',a_cliente CHAR(255) DEFAULT "*") 
			RETURNING   CHAR(20), 
						CHAR(10),
		            	DEC(16,2),
						VARCHAR(50),
		            	DATE,
						CHAR(50),
						VARCHAR(50),
						VARCHAR(255);
						

DEFINE v_asegurado       VARCHAR(100);
DEFINE v_numrecla        CHAR(18);
DEFINE v_nombre_ramo	 CHAR(50);
DEFINE v_compania_nombre VARCHAR(50);
DEFINE v_filtros         VARCHAR(255);
DEFINE v_no_recupero     CHAR(10);

DEFINE _cod_ramo        CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       INT;
DEFINE _cod_contratante	CHAR(10);
DEFINE _cod_coasegur    CHAR(10);
DEFINE v_nombre_emicoase VARCHAR(50);
DEFINE v_fecha_notificacion DATE;
DEFINE v_monto_arreglo   DEC(16,2);
DEFINE _tipo            CHAR(1);

DEFINE _fecha_inic       DATE;
DEFINE _fecha_fin        DATE;

-- Nombre de la Compania
--SET DEBUG FILE TO "sp_rec259.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_pos_recob(
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		fecha_envio          DATE      NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		monto_arreglo        DEC(16,2) NOT NULL,
		cod_contratante      CHAR(10)  NOT NULL,
		no_recupero          CHAR(10)  NOT NULL,
		cod_coasegur         CHAR(10),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   

let _fecha_inic      = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]); 
let _fecha_fin       = sp_sis36(a_periodo2);

FOREACH	

 SELECT	a.no_reclamo,
 		a.numrecla,
		a.no_poliza,
        b.no_recupero,
        b.cod_coasegur,
        b.fecha_envio,
        b.monto_arreglo		
   INTO	_no_reclamo,
   		v_numrecla,
		_no_poliza,
        v_no_recupero,
        _cod_coasegur,
        v_fecha_notificacion,
        v_monto_arreglo		
   FROM recrcmae a, recrecup b
  WHERE a.no_reclamo = b.no_reclamo
    AND a.cod_compania    = a_compania
 	AND a.actualizado = 1
    AND b.fecha_envio >= _fecha_inic
    AND b.fecha_envio <= _fecha_fin	
		

	-- Lectura de Polizas

	SELECT cod_ramo,
		   cod_contratante
	  INTO _cod_ramo,
		   _cod_contratante
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura de Contratante

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;


	INSERT INTO tmp_pos_recob(
    asegurado,      
	numrecla,     
    fecha_envio,	
	cod_ramo,       
	cod_contratante,
	monto_arreglo,
    no_recupero,
    cod_coasegur	
	)
	VALUES(
	v_asegurado,      
	v_numrecla,       
	v_fecha_notificacion,
	_cod_ramo,    
	_cod_contratante,
	v_monto_arreglo,
	v_no_recupero,
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
        fecha_envio,	
		cod_ramo,       
		cod_contratante,
		monto_arreglo,
		no_recupero,
		cod_coasegur	
   INTO v_asegurado,      
		v_numrecla,       
	    v_fecha_notificacion,
		_cod_ramo,    
		_cod_contratante,
		v_monto_arreglo,
		v_no_recupero,
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

	RETURN v_numrecla,       
		   v_no_recupero,
		   v_monto_arreglo,   
		   v_nombre_emicoase,
		   v_fecha_notificacion,
		   v_nombre_ramo,	
		   TRIM(v_compania_nombre),
		   TRIM(v_filtros)
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_pos_recob;
END PROCEDURE;