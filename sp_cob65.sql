-- Armar ruta (AREA) polizas
-- 
-- Creado    : 14/03/2001 - Autor: Armando Moreno M.
-- Modificado: 19/03/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_cob65;

CREATE PROCEDURE "informix".sp_cob65(a_compania CHAR(3), a_sucursal CHAR(3), a_cobrador CHAR(3), a_dia INT) 
       RETURNING   		SMALLINT,  	-- Orden2
					    CHAR(20),   -- poliza
						CHAR(100),	-- asegurado
						CHAR(100),  -- direccion
						DEC(16,2),	-- saldo
						DEC(16,2),	-- a_pagar
						CHAR(10),	-- no_poliza
						CHAR(25),	-- telefono
						CHAR(50),	-- corredor
						CHAR(50),	-- ejecutiva
						CHAR(100),	-- observacion
						CHAR(30),	-- ciudad
						CHAR(30),	-- distrito
						CHAR(100),	-- area
						CHAR(50),	-- cobrador calle
						CHAR(50),	-- cia
						INTEGER,	-- dia
						DEC(16,2),	-- por_vencer
						DEC(16,2),	-- exigible
						DEC(16,2),	-- corriente
						DEC(16,2),	-- monto 30
						DEC(16,2),	-- monto 60
						DEC(16,2);	-- monto 90

DEFINE v_orden2,v_orden1 SMALLINT;
DEFINE _ramo_sis         SMALLINT;
DEFINE v_asegurado       CHAR(100);
DEFINE v_descripcion     CHAR(100);
DEFINE v_correg 		 CHAR(100);
DEFINE v_documento  	 CHAR(20);
DEFINE v_direccion		 CHAR(100);
DEFINE v_direccion1		 CHAR(50);
DEFINE v_direccion2		 CHAR(50);
DEFINE v_corredor		 CHAR(50);
DEFINE v_nom_cobrador	 CHAR(4);
DEFINE v_compania	     CHAR(50);
DEFINE v_cobrador_calle  CHAR(50);
DEFINE v_saldo     		 DEC(16,2);
DEFINE v_a_pagar	 	 DEC(16,2);
DEFINE v_no_poliza	     CHAR(10);
DEFINE _cod_cliente      CHAR(10);
DEFINE _cod_agente,_code_agente  CHAR(5);
DEFINE v_telefono1       CHAR(10);
DEFINE v_telefono2       CHAR(10);
DEFINE v_telefono        CHAR(25);
DEFINE _cod_cobrador_o	 CHAR(3);
DEFINE _code_pais,_cod_ramo	 CHAR(3);
DEFINE v_ciudad          CHAR(30);
DEFINE v_distrito        CHAR(30);
DEFINE _code_provincia 	 CHAR(2);
DEFINE _code_ciudad		 CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_correg	     CHAR(5);
DEFINE v_dia			 INTEGER;
DEFINE v_por_vencer	 	 DEC(16,2);
DEFINE v_exigible	 	 DEC(16,2);
DEFINE v_corriente	 	 DEC(16,2);
DEFINE v_monto_30	 	 DEC(16,2);
DEFINE v_monto_60	 	 DEC(16,2);
DEFINE v_monto_90	 	 DEC(16,2);
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);
DEFINE _periodo          CHAR(7);

--SET ISOLATION TO DIRTY READ;
LET  v_compania = sp_sis01(a_compania);
LET  v_dia = a_dia;

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;
FOREACH
-- Lectura de Cobruter	
		SELECT no_poliza,
			   saldo,
			   a_pagar,
			   orden_2,
			   orden_1,
			   descripcion,
			   code_pais,
			   code_provincia,
			   code_distrito,
			   code_ciudad,
			   code_correg,
			   cod_agente,
			   direccion
		  INTO v_no_poliza,
			   v_saldo,
			   v_a_pagar,     
			   v_orden2,
			   v_orden1,
			   v_descripcion,
			   _code_pais,
			   _code_provincia,
			   _code_distrito,
			   _code_ciudad,
			   _code_correg,
			   _code_agente,
			   v_direccion
		  FROM cobruter
		 WHERE cod_cobrador = a_cobrador
		   AND (dia_cobros1 = a_dia
		    OR dia_cobros2  = a_dia)
	  ORDER BY orden_2,orden_1

IF v_no_poliza IS NOT NULL THEN
	 SELECT no_documento,
			cod_contratante,
			cod_ramo
	   INTO v_documento,
			_cod_cliente,
			_cod_ramo
	   FROM emipomae
	  WHERE no_poliza = v_no_poliza
	    AND actualizado = 1;

	 FOREACH 
	  SELECT cod_agente
	    INTO _cod_agente
	    FROM emipoagt
	   WHERE no_poliza = v_no_poliza
	    EXIT FOREACH;
	 END FOREACH

	SELECT cod_cobrador,
		   nombre	
	  INTO _cod_cobrador_o,
		   v_corredor	
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	  SELECT nombre
	    INTO v_nom_cobrador
	    FROM cobcobra
	   WHERE cod_cobrador = _cod_cobrador_o;
	  
	  SELECT nombre
	    INTO v_asegurado
		FROM cliclien
	   WHERE cod_cliente = _cod_cliente;

	  IF v_direccion IS NULL OR v_direccion = "" THEN
		  SELECT direccion_1,
				 direccion_2,
				 telefono1,
				 telefono2
		    INTO v_direccion1,
				 v_direccion2,
				 v_telefono1,
				 v_telefono2
			FROM emidirco
		   WHERE no_poliza = v_no_poliza;

		   IF v_direccion1 IS NULL THEN
			LET v_direccion1 = " ";
		   END IF
		   IF v_direccion2 IS NULL THEN
			LET v_direccion2 = " ";
		   END IF
		   LET v_direccion = v_direccion1 || v_direccion2;
	  ELSE
		  SELECT telefono1,
				 telefono2
		    INTO v_telefono1,
				 v_telefono2
			FROM emidirco
		   WHERE no_poliza = v_no_poliza;
	  END IF

	  IF v_telefono1 IS NULL THEN
		 LET v_telefono1 = " ";
	  END IF

	  IF v_telefono2 IS NULL THEN
		 LET v_telefono2 = " ";
	  END IF

	  LET v_telefono  = v_telefono1 || "/" || v_telefono2;

	 	CALL sp_cob33(
		a_compania,
		a_sucursal,
		v_documento,
		_periodo,
		today
		) RETURNING v_por_vencer,
				    v_exigible,  
				    v_corriente, 
				    v_monto_30,  
				    v_monto_60,  
				    v_monto_90,
				    v_saldo
				    ;
		SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		IF v_saldo <= 0 THEN 
			IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
				CONTINUE FOREACH;
			END IF
		END IF
--		LET v_a_pagar = v_exigible;
ELSE
	   LET v_documento    = " ";
	   LET v_asegurado    = " ";
	   LET v_no_poliza    = " ";
       LET v_telefono     = " ";
       LET v_nom_cobrador = " ";
       LET v_descripcion  = " ";
	   LET v_saldo        = 0;
	   LET v_a_pagar      = 0;

 	   LET v_por_vencer   = 0;
	   LET v_exigible     = 0;
	   LET v_corriente	  = 0;
	   LET v_monto_30     = 0;
	   LET v_monto_60  	  =	0;
	   LET v_monto_90	  =	0;

	   SELECT nombre,
			  direccion_1,
			  direccion_2	
	     INTO v_corredor,
			  v_direccion1,
			  v_direccion2
	     FROM agtagent
	    WHERE cod_agente = _code_agente;

		LET v_asegurado = v_corredor;

		IF v_direccion1 IS NULL THEN
		   LET v_direccion1 = " ";
		END IF

		IF v_direccion2 IS NULL THEN
		   LET v_direccion2 = " ";
		END IF

	    LET v_direccion = v_direccion1 ||  v_direccion2;
END IF

	    SELECT nombre
	      INTO v_cobrador_calle
	      FROM cobcobra
	     WHERE cod_cobrador = a_cobrador;

		SELECT nombre
		  INTO v_ciudad
		  FROM genciud
		 WHERE code_pais      = _code_pais
		   AND code_provincia = _code_provincia
		   AND code_ciudad    = _code_ciudad;

		SELECT nombre
		  INTO v_distrito
		  FROM gendtto
		 WHERE code_pais      = _code_pais
		   AND code_provincia = _code_provincia
		   AND code_ciudad    = _code_ciudad
		   AND code_distrito  = _code_distrito;

		SELECT nombre
		  INTO v_correg
		  FROM gencorr
		 WHERE code_pais      = _code_pais
		   AND code_provincia = _code_provincia
		   AND code_ciudad    = _code_ciudad
		   AND code_distrito  = _code_distrito
		   AND code_correg    = _code_correg;

	RETURN v_orden2,
		   v_documento,      
		   v_asegurado,
	       v_direccion,
		   v_saldo,
		   v_a_pagar,
		   v_no_poliza,
		   v_telefono,
		   v_corredor,
		   v_nom_cobrador,
		   v_descripcion,
		   v_ciudad,
		   v_distrito,
		   v_correg,
		   v_cobrador_calle,
		   v_compania,
		   v_dia,
	 	   v_por_vencer,
		   v_exigible,
		   v_corriente,
		   v_monto_30,
		   v_monto_60,
		   v_monto_90
		   WITH RESUME;
END FOREACH;
END PROCEDURE