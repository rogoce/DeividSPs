-- Detalle de Facturas/Fianzas (Cumulos) por Asegurado y por subramo
--
-- Creado    : 16/01/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/01/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_pro57_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro90;

CREATE PROCEDURE "informix".sp_pro90(
a_compania  CHAR(3), 
a_sucursal  CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_asegurado CHAR(255)
) RETURNING CHAR(20),  --poliza
            DATE,	   --vig_ini
            DATE,	   --vig_fin
			DEC(16,2), --suma aseg.
			CHAR(100), --aseg.
			CHAR(50),  --cia.           
			CHAR(255), --filtros
			CHAR(10),  --cod_cte
            CHAR(50);  --subramo

DEFINE _cod_cliente      CHAR(10);
DEFINE _no_poliza        CHAR(10);
DEFINE _no_documento     CHAR(20);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _suma             DEC(16,2);
DEFINE _nombre           CHAR(100);
DEFINE _vigencia_inic    DATE;     
DEFINE _vigencia_final   DATE;     

DEFINE v_compania_nombre CHAR(50);
DEFINE _nombre_subramo   CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro57.trc";
--TRACE ON;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_fianzas(
nombre         CHAR(100),
no_documento   CHAR(20), 
suma           DEC(16,2),
vigencia_inic  DATE,     
vigencia_final DATE,
cod_cliente    CHAR(10),
cod_ramo	   CHAR(3),	
cod_subramo	   CHAR(3),	
seleccionado   SMALLINT     
) WITH NO LOG;

FOREACH
 SELECT	p.cod_contratante,
		p.no_documento,
		p.vigencia_inic,
		p.vigencia_final,
		p.cod_ramo,
		p.cod_subramo,
		p.no_poliza
   INTO	_cod_cliente,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_cod_ramo,
		_cod_subramo,
		_no_poliza
   FROM	emipomae p, prdramo r
  WHERE p.cod_ramo  = r.cod_ramo
    AND r.ramo_sis  = 3
    AND p.actualizado = 1
	AND p.nueva_renov = "N"
    AND p.periodo     >= a_periodo1	
    AND p.periodo     <= a_periodo2
	AND p.cod_compania = a_compania

	SELECT nombre
	  INTO _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	FOREACH

		 SELECT	suma_asegurada
		   INTO	_suma
		   FROM	endedmae
		  WHERE actualizado = 1
			AND no_poliza   = _no_poliza
		    AND periodo     >= a_periodo1	
		    AND periodo     <= a_periodo2


		 INSERT INTO tmp_fianzas
		 VALUES(
		 _nombre,
		 _no_documento,
		 _suma,
		 _vigencia_inic,     
		 _vigencia_final,
		 _cod_cliente,
		 _cod_ramo,
		 _cod_subramo,
		 1
		 ); 	
	END FOREACH

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_asegurado <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Asegurado: " ||  TRIM(a_asegurado);

	LET _tipo = sp_sis04(a_asegurado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_fianzas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_fianzas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre,
        no_documento,
		suma,
	    vigencia_inic,     
	    vigencia_final,
		cod_cliente,
		cod_ramo,
		cod_subramo
   INTO	_nombre,
        _no_documento,
		_suma,
	    _vigencia_inic,     
	    _vigencia_final,
		_cod_cliente,
		_cod_ramo,
		_cod_subramo
   FROM	tmp_fianzas
  WHERE seleccionado = 1
  ORDER BY nombre

	SELECT nombre
	  INTO _nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	RETURN _no_documento,
	       _vigencia_inic,     
	       _vigencia_final,
		   _suma,
		   _nombre,
		   v_compania_nombre,
		   v_filtros,
		   _cod_cliente,
		   _nombre_subramo
		   WITH RESUME;

END FOREACH

END PROCEDURE;
