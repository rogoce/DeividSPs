-- Procedimiento para crear la carta de fianza
-- 
-- Creado    : 12/05/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe42;
--DROP TABLE tmp_fianza;
CREATE PROCEDURE "informix".sp_proe42(a_poliza CHAR(10)) 
			RETURNING   CHAR(10),   -- v_no_poliza 
 						CHAR(20),   -- v_no_documento  
						CHAR(10),   -- v_cod_cliente
						CHAR(3),	-- v_cod_ramo
						CHAR(3),    -- v_cod_subramo
						CHAR(100),	-- v_nombre_contrat
						CHAR(50),   -- v_nombre_subramo
						CHAR(100),	-- v_vigen_ini
						CHAR(100),	-- v_vigen_final
						CHAR(100),	-- v_vigencia_real
						CHAR(100),  -- v_hoy
						DEC(16,2),	-- v_suma_aseg
						CHAR(250) ;	-- v_valor_aseg  

DEFINE v_no_poliza       CHAR(10);    
DEFINE v_no_documento    CHAR(20);    
DEFINE v_cod_cliente     CHAR(10);  
DEFINE v_cod_ramo		 CHAR(3);
DEFINE v_cod_subramo	 CHAR(3);
DEFINE v_nombre_contrat  CHAR(100);
DEFINE v_nombre_subramo  CHAR(50);
DEFINE v_vigen_ini       CHAR(100);
DEFINE v_vigen_final     CHAR(100);
DEFINE v_vigencia_real	 CHAR(100);
DEFINE v_hoy			 CHAR(100);
DEFINE v_suma_aseg		 DEC(16,2);
DEFINE v_valor_aseg		 CHAR(250);
DEFINE vs_suma_asegurada CHAR(16);											 
DEFINE v_contratante     CHAR(100);	
DEFINE v_subramo	     CHAR(50);
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _documento		 CHAR(20);
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;
DEFINE _vigencia_real    DATE;
DEFINE _hoy    			 DATE;
DEFINE _suma_asegurada	 CHAR(200);

-- Crear la tabla temporal del documento

CREATE TEMP TABLE tmp_fianza(
		no_poliza        CHAR(10),
		no_documento     CHAR(20),
		cod_cliente      CHAR(10),
		cod_ramo		 CHAR(3),
		cod_subramo		 CHAR(3),
		nombre_contrat   CHAR(100),
		nombre_subramo   CHAR(50),
		vigen_ini        CHAR(100),
		vigen_final      CHAR(100),
		vigencia_real	 CHAR(100),
		hoy				 CHAR(100),
		suma_aseg		 DEC(16,2),
		valor_aseg		 CHAR(250)
		) WITH NO LOG;   

SET ISOLATION TO DIRTY READ;
LET v_no_poliza = a_poliza;

-- Lectura de emipomae
SELECT cod_ramo,
	cod_subramo,
	no_documento,
	cod_contratante,
	vigencia_inic,
	vigencia_final,
	suma_asegurada, 
	vigencia_final + 30 UNITS DAY
INTO _cod_ramo,
	 _cod_subramo,
	 _documento,
	 _cod_contratante,
	 _vigencia_inic,
	 _vigencia_final,
	 _suma_asegurada,
	 _vigencia_real
FROM emipomae
WHERE no_poliza = v_no_poliza;


-- Lectura del contratante

SELECT nombre
  INTO v_contratante
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

-- Lectura del Subramo
 
SELECT nombre
  INTO v_subramo
  FROM prdsubra
 WHERE cod_ramo = _cod_ramo
   AND cod_subramo = _cod_subramo;

-- Transformar Vigencias

LET v_vigen_ini     = sp_sis20(_vigencia_inic);
LET v_vigen_final   = sp_sis20(_vigencia_final);
LET _hoy           	= sp_sis26();
LET v_hoy 			= sp_sis20(_hoy);
LET v_vigencia_real = sp_sis20(_vigencia_real);


-- Valor de Suma Asegurada
LET vs_suma_asegurada = _suma_asegurada;
LET v_valor_aseg = TRIM(sp_sis11(_suma_asegurada)) ||' ( B/.'||TRIM(vs_suma_asegurada)||' )';

-- Crear temporal de Fianzas

INSERT INTO tmp_fianza(	  
		no_poliza,
		no_documento,
		cod_cliente,
		cod_ramo,
		cod_subramo,
		nombre_contrat,
		nombre_subramo,
		vigen_ini,
		vigen_final,
		vigencia_real,
		hoy,
		suma_aseg,
		valor_aseg	)
	VALUES(
		v_no_poliza,
		_documento,
		_cod_contratante,
		_cod_ramo,
	    _cod_subramo,
		v_contratante,
		v_subramo,
		v_vigen_ini,
		v_vigen_final,
		v_vigencia_real,
		v_hoy,
		_suma_asegurada,
		v_valor_aseg
	);  

FOREACH	
  SELECT no_poliza,
		no_documento,
		cod_cliente,
		cod_ramo,
		cod_subramo,
		nombre_contrat,
		nombre_subramo,
		vigen_ini,
		vigen_final,
		vigencia_real,
		hoy,
		suma_aseg,
		valor_aseg
	INTO v_no_poliza,
		v_no_documento,
		v_cod_cliente,
		v_cod_ramo,
		v_cod_subramo,
		v_nombre_contrat,
		v_nombre_subramo,
		v_vigen_ini,
		v_vigen_final,
		v_vigencia_real,
		v_hoy,
		v_suma_aseg,
		v_valor_aseg
	FROM tmp_fianza

	RETURN v_no_poliza,
		_documento,
		_cod_contratante,
		_cod_ramo,
	    _cod_subramo,
		v_contratante,
		v_subramo,
		v_vigen_ini,
		v_vigen_final,
		v_vigencia_real,
		v_hoy,
		_suma_asegurada,
		v_valor_aseg
		WITH RESUME;   	

END FOREACH;


DROP TABLE tmp_fianza;
END PROCEDURE			   