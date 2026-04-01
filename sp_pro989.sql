-- Procedimiento para crear la carta del suntracs -- 
-- Creado    : 10/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro989;
CREATE PROCEDURE "informix".sp_pro989(a_poliza CHAR(10)) 
RETURNING   CHAR(10),   -- v_no_poliza 
 			CHAR(20),   -- v_no_documento  
			CHAR(10),   -- v_cod_cliente
			CHAR(100),	-- v_nombre_contrat
			DATE,	    -- v_hoy
			CHAR(15);   -- v_hoy_mes

DEFINE _no_poliza        CHAR(10); 
DEFINE _documento		 CHAR(20);
DEFINE _cod_contratante  CHAR(10);
DEFINE _nombre_contrat   CHAR(100);
DEFINE _hoy    			 DATE;
DEFINE _mes_hoy           CHAR(15);
-- Crear la tabla temporal del documento

CREATE TEMP TABLE tmp_suntracs(
		no_poliza        CHAR(10),
		no_documento     CHAR(20),
		cod_cliente      CHAR(10),
		nombre_contrat   CHAR(100),
		hoy				 DATE,
		mes              CHAR(15)
		) WITH NO LOG;   

SET ISOLATION TO DIRTY READ;
LET _no_poliza = a_poliza;

-- Lectura de emipomae
SELECT no_documento,
	   cod_contratante	   
  INTO _documento,
       _cod_contratante
  FROM emipomae
 WHERE no_poliza = _no_poliza 
   AND cod_grupo = "01016"
   AND nueva_renov = "R" 
   AND actualizado = 1;

-- Lectura del contratante
SELECT nombre
  INTO _nombre_contrat
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

-- Dia
LET _hoy   = sp_sis26();

IF MONTH(_hoy) = 1 THEN
  LET _mes_hoy = 'enero';
ELIF MONTH(_hoy) = 2 THEN
  LET _mes_hoy = 'febrero';
ELIF MONTH(_hoy) = 3 THEN
  LET _mes_hoy = 'marzo';
ELIF MONTH(_hoy) = 4 THEN
  LET _mes_hoy = 'abril';
ELIF MONTH(_hoy) = 5 THEN
  LET _mes_hoy = 'mayo';
ELIF MONTH(_hoy) = 6 THEN
  LET _mes_hoy = 'junio';
ELIF MONTH(_hoy) = 7 THEN
  LET _mes_hoy = 'julio';
ELIF MONTH(_hoy) = 8 THEN
  LET _mes_hoy = 'agosto';
ELIF MONTH(_hoy) = 9 THEN
  LET _mes_hoy = 'septiembre';
ELIF MONTH(_hoy) = 10 THEN
  LET _mes_hoy = 'octubre';
ELIF MONTH(_hoy) = 11 THEN
  LET _mes_hoy = 'noviembre';
ELIF MONTH(_hoy) = 12 THEN
  LET _mes_hoy = 'diciembre';
END IF

-- Crear temporal de Fianzas
INSERT INTO tmp_suntracs(	  
		no_poliza,
		no_documento,
		cod_cliente,
		nombre_contrat,
		hoy,
		mes)
	VALUES(
		_no_poliza,
		_documento,
		_cod_contratante,
		_nombre_contrat,
		_hoy,
		_mes_hoy);  

FOREACH	
  SELECT no_poliza,
		 no_documento,
		 cod_cliente,
		 nombre_contrat,
		 hoy,
		 mes
	INTO _no_poliza,
		 _documento,
		 _cod_contratante,
		 _nombre_contrat,
		 _hoy,
		 _mes_hoy
	FROM tmp_suntracs

	RETURN _no_poliza,
		   _documento,
		   _cod_contratante,
		   _nombre_contrat,
		   _hoy,
		   _mes_hoy
		   WITH RESUME;   	

END FOREACH;

DROP TABLE tmp_suntracs;
END PROCEDURE			   