-- Listado de Cooredores segun Bonos y sus agrupados
-- Creado    : 23/01/2019 - Autor: Henry Girón
-- SIS v.2.0 - d_cobr_sp_cob168_REP_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob168_rep;
CREATE PROCEDURE "informix".sp_cob168_rep(
a_compania CHAR(3), 
a_agencia  CHAR(3),
a_cobrador CHAR(255)
) RETURNING CHAR(50) as Nombre_Agente,
			CHAR(5) as Codigo_Agentes,
			CHAR(1) as Tipo_Persona,
			CHAR(10) as Numero_Licencia,
			CHAR(10) as Telefono_1,
			CHAR(10) as Telefono_2,
			CHAR(50) as Nombre_Cobrador,
			CHAR(50) as Nombre_Compania,
			CHAR(255) as Filtros, 
			smallint as bono, 
			char(5) as cod_agrupado,
			CHAR(50) as nombre_agrupado,
			CHAR(1) as tipo_agente,
		    CHAR(1) as estatus_licencia,
		    char(30) as cedula_agt,
		    char(5) as agente_agrupado;

			

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
DEFINE _cod_agrupado       CHAR(5);
define _bono               smallint;
DEFINE _nombre_agrupado    CHAR(50);
DEFINE _tipo_agente        CHAR(1);
define _estatus_licencia   char(1);
define _cedula_agt         char(30);
define _agente_agrupado    char(5);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

let v_compania_nombre = sp_sis01(a_compania); 
let _cod_agrupado = '';
let _bono = 0;

CREATE TEMP TABLE tmp_agente(
			nombre_agente     CHAR(50),
			cod_agente        CHAR(5),
			tipo_persona      CHAR(1),
			numero_licencia   CHAR(10),
			telefono_1        CHAR(10),
			telefono_2        CHAR(10),
			cod_cobrador 	  CHAR(3),
			seleccionado      SMALLINT	DEFAULT 1,
			bono              smallint,
			agrupado          CHAR(5),
			nombre_agrupado   char(50),
			tipo_agente       char(1),
		    estatus_licencia  char(1),
		    cedula            char(30),
		    agente_agrupado   char(5)
			) WITH NO LOG;

CREATE INDEX xie01_tmp_agente ON tmp_agente(cod_cobrador);

FOREACH
 SELECT	nombre,
		cod_agente,
		tipo_persona,
		no_licencia,
		telefono1,
		telefono2,
		cod_cobrador,
		tipo_agente,
		estatus_licencia,
		cedula,
		agente_agrupado
   INTO	v_nombre_agente,
        v_cod_agente,        
        v_tipo_persona,      
        v_numero_licencia,   
        v_telefono_1,        
        v_telefono_2,        
		_cod_cobrador,
		_tipo_agente,
		_estatus_licencia,
		_cedula_agt,
		_agente_agrupado
   FROM	agtagent
  WHERE cod_compania = a_compania
  
        call sp_che168(v_cod_agente) returning _bono, _cod_agrupado;
		
	 SELECT	nombre
	   INTO	_nombre_agrupado
	   FROM	agtagent
	   where cod_agente = _cod_agrupado;

		INSERT INTO tmp_agente(
		nombre_agente,   
		cod_agente,      
		tipo_persona,    
		numero_licencia, 
		telefono_1,      
		telefono_2,      
		cod_cobrador,
		bono, 
		agrupado,
		nombre_agrupado,
		tipo_agente,
		estatus_licencia,
		cedula,
		agente_agrupado
		)
		VALUES(
   		v_nombre_agente,
        v_cod_agente,        
        v_tipo_persona,      
        v_numero_licencia,   
        v_telefono_1,        
        v_telefono_2,        
		_cod_cobrador,
		_bono, 
		_cod_agrupado,
		_nombre_agrupado,
		_tipo_agente,
		_estatus_licencia,
		_cedula_agt,
		_agente_agrupado
		);
		
		let _cod_agrupado = '';
		let _nombre_agrupado = '';
		let _bono = 0;

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
		cod_cobrador,
		bono, 
		agrupado,
		nombre_agrupado,
		tipo_agente,
		estatus_licencia,
		cedula,
		agente_agrupado
   INTO	v_nombre_agente,
        v_cod_agente,        
        v_tipo_persona,      
        v_numero_licencia,   
        v_telefono_1,        
        v_telefono_2,        
		_cod_cobrador,
		_bono, 
		_cod_agrupado,
		_nombre_agrupado,
		_tipo_agente,
		_estatus_licencia,
		_cedula_agt,
		_agente_agrupado
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
		    v_filtros,
			_bono, 
		    _cod_agrupado,
			_nombre_agrupado,
			_tipo_agente,
		    _estatus_licencia,
		    _cedula_agt,
		    _agente_agrupado
			WITH RESUME;

END FOREACH

END PROCEDURE;

