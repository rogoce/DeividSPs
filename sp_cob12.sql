-- Corredores Asignados por Cobrador
-- 
-- Creado    : 12/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob12_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob12;

CREATE PROCEDURE "informix".sp_cob12(
a_compania CHAR(3), 
a_agencia  CHAR(3),
a_cobrador CHAR(255)
) RETURNING CHAR(50),  -- Nombre Agente
			CHAR(5),   -- Codigo Agentes
			CHAR(1),   -- Tipo Persona
			CHAR(10),  -- Numero Licencia
			CHAR(10),  -- Telefono 1
			CHAR(10),  -- Telefono 2
			CHAR(50),  -- Nombre Cobrador
			CHAR(50),  -- Nombre Compania
			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_agente     CHAR(50);
DEFINE v_cod_agente        CHAR(5);
DEFINE v_tipo_persona      CHAR(1);
DEFINE v_numero_licencia   CHAR(10);
DEFINE v_telefono_1        CHAR(10);
DEFINE v_telefono_2        CHAR(10);
DEFINE v_nombre_cobrador   CHAR(50);
DEFINE v_compania_nombre   CHAR(50);

DEFINE _cod_cobrador       CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_agente(
			nombre_agente     CHAR(50),
			cod_agente        CHAR(5),
			tipo_persona      CHAR(1),
			numero_licencia   CHAR(10),
			telefono_1        CHAR(10),
			telefono_2        CHAR(10),
			cod_cobrador 	  CHAR(3),
			seleccionado      SMALLINT	DEFAULT 1
			) WITH NO LOG;

CREATE INDEX xie01_tmp_agente ON tmp_agente(cod_cobrador);

FOREACH
 SELECT	nombre,
		cod_agente,
		tipo_persona,
		no_licencia,
		telefono1,
		telefono2,
		cod_cobrador
   INTO	v_nombre_agente,
        v_cod_agente,        
        v_tipo_persona,      
        v_numero_licencia,   
        v_telefono_1,        
        v_telefono_2,        
		_cod_cobrador
   FROM	agtagent
  WHERE cod_compania = a_compania

		INSERT INTO tmp_agente(
		nombre_agente,   
		cod_agente,      
		tipo_persona,    
		numero_licencia, 
		telefono_1,      
		telefono_2,      
		cod_cobrador 	
		)
		VALUES(
   		v_nombre_agente,
        v_cod_agente,        
        v_tipo_persona,      
        v_numero_licencia,   
        v_telefono_1,        
        v_telefono_2,        
		_cod_cobrador
		);

END FOREACH

LET v_filtros = "";

IF a_cobrador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre_agente,
		cod_agente,
		tipo_persona,
		numero_licencia,
		telefono_1,
		telefono_2,
		cod_cobrador
   INTO	v_nombre_agente,
        v_cod_agente,        
        v_tipo_persona,      
        v_numero_licencia,   
        v_telefono_1,        
        v_telefono_2,        
		_cod_cobrador
   FROM	tmp_agente
  WHERE seleccionado = 1
  ORDER BY cod_cobrador, nombre_agente

	SELECT nombre
	  INTO v_nombre_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	RETURN 	v_nombre_agente,     
            v_cod_agente,        
            v_tipo_persona,      
            v_numero_licencia,   
            v_telefono_1,        
            v_telefono_2,        
            v_nombre_cobrador,   
		    v_compania_nombre,
		    v_filtros
			WITH RESUME;

END FOREACH

END PROCEDURE;

