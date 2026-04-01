-- Polizas para Cartas de Aumento de Primas
--
-- Creado    : 22/01/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_sp_pro62_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro62;

CREATE PROCEDURE "informix".sp_pro62(a_periodo CHAR(7))
RETURNING CHAR(18),
          CHAR(50),
          CHAR(100),
		  INTEGER,	
		  DEC(16,2),
		  DEC(16,2),
          CHAR(50),
          CHAR(50),
          CHAR(50),
          DATE,
          DATE,
          CHAR(20),
          DEC(5,2);

DEFINE _no_poliza       CHAR(10); 
DEFINE _no_documento    CHAR(18); 
DEFINE _cod_asegurado   CHAR(10); 
DEFINE _prima_asegurado DEC(16,2);
DEFINE _prima_total     DEC(16,2);
DEFINE _cod_producto    CHAR(10); 
DEFINE _cod_agente      CHAR(10); 
DEFINE _nombre_producto CHAR(50); 
DEFINE _nombre_cliente  CHAR(100); 
DEFINE _nombre_agente   CHAR(50); 
DEFINE _direccion_1     CHAR(50); 
DEFINE _direccion_2     CHAR(50); 
DEFINE _fecha			DATE;
DEFINE _edad			INTEGER;
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_fin    DATE;

DEFINE _cod_ramo        CHAR(3); 
DEFINE _cod_subramo     CHAR(3); 
DEFINE _nombre_subramo  CHAR(50); 
DEFINE _ano_vigencia    INTEGER;
DEFINE _apartado		CHAR(20);
DEFINE _porc_recargo    DEC(5,2);
DEFINE _ano_proceso     SMALLINT;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\demrep41.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET _ano_proceso = a_periodo[1,4] - 1;
    
FOREACH
 SELECT no_poliza,
		no_documento,
		cod_ramo,
		cod_subramo,
		vigencia_inic,
		vigencia_final,
		YEAR(vigencia_inic)
   INTO _no_poliza,
		_no_documento,
		_cod_ramo,
		_cod_subramo,
		_vigencia_inic,
		_vigencia_fin,
		_ano_vigencia
   FROM emipomae
  WHERE actualizado           = 1
    AND cod_ramo              = '018'
	AND cod_subramo           IN ('007', '008')
--	AND periodo               = a_periodo
	AND MONTH(vigencia_inic) = a_periodo[6,7]
	AND YEAR(vigencia_inic)  = _ano_proceso
	AND estatus_poliza        IN (1,3)
--	AND vigencia_final        >= '01/01/2001'
  ORDER BY 7, 2

	SELECT nombre
	  INTO _nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

--	LET _nombre_subramo = _nombre_subramo[5,7];

--	IF _nombre_subramo[5,7] <> 'PA1' OR
--	   _nombre_subramo[5,7] <> 'PA2' THEN
--		CONTINUE FOREACH;
--	END IF 

   FOREACH	
	SELECT cod_asegurado,
		   prima_asegurado,
		   prima_total,
		   cod_producto
	  INTO _cod_asegurado,
		   _prima_asegurado,
		   _prima_total,
		   _cod_producto	   		
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT nombre
	  INTO _nombre_producto
	  FROM prdprod
	 WHERE cod_producto = _cod_producto;

	SELECT nombre,
		   direccion_1,
		   direccion_2,
		   fecha_aniversario,
		   apartado
	  INTO _nombre_cliente,
		   _direccion_1,
		   _direccion_2,
		   _fecha,
		   _apartado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	LET _edad = YEAR(TODAY) - YEAR(_fecha);

	IF MONTH(TODAY) < MONTH(_fecha) THEN
		LET _edad = _edad - 1;
	ELIF MONTH(_fecha) = MONTH(TODAY) THEN
		IF DAY(TODAY) < DAY(_fecha) THEN
			LET _edad = _edad - 1;
		END IF
	END IF
	
	LET _cod_agente    = '';
	LET _nombre_agente = '';

   FOREACH	
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH
	
	SELECT nombre
	  INTO _nombre_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT SUM(porc_recargo)
	  INTO _porc_recargo
	  FROM emiunire
	 WHERE no_poliza = _no_poliza;
	       
	RETURN _no_documento,
		   _nombre_producto,
		   _nombre_cliente,
		   _edad,
		   _prima_asegurado,
		   _prima_total,
		   _direccion_1,
		   _direccion_2,
		   _nombre_agente,
		   _vigencia_inic,
		   _vigencia_fin,
		   _apartado,
		   _porc_recargo
		   WITH RESUME;

END FOREACH

END PROCEDURE;
