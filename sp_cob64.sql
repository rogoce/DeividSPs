-- Armar ruta (AREA) polizas
-- 
-- Creado    : 14/03/2001 - Autor: Armando Moreno M.
-- Modificado: 15/03/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob64;

CREATE PROCEDURE "informix".sp_cob64(a_compania CHAR(3), a_cobrador CHAR(3), a_dia INT) 
       RETURNING   		SMALLINT,  	-- Orden2
					    CHAR(20),   -- poliza
						CHAR(100),	-- asegurado
						CHAR(100),  -- direccion
						DEC(16,2),	-- saldo
						DEC(16,2),	-- a_pagar
						DATETIME YEAR TO FRACTION(5),	-- fecha
						CHAR(100);	-- area

DEFINE v_orden2,v_orden1,_estatus SMALLINT;
DEFINE _ramo_sis         SMALLINT;
DEFINE v_asegurado       CHAR(100);
DEFINE v_documento  	 CHAR(20);
DEFINE v_direccion		 CHAR(100);
DEFINE v_direccion1		 CHAR(50);
DEFINE v_direccion2		 CHAR(50);
DEFINE v_saldo,_saldo_vig     		 DEC(16,2);
DEFINE v_a_pagar	 	 DEC(16,2);
DEFINE v_no_poliza	     CHAR(10);
DEFINE _cod_cliente      CHAR(10);
DEFINE _fecha_dt         DATETIME YEAR TO FRACTION(5);	-- fecha
DEFINE _cod_agente	     CHAR(5);
DEFINE v_correg 		 CHAR(100);
DEFINE _code_provincia 	 CHAR(2);
DEFINE _code_ciudad		 CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_correg	     CHAR(5);
DEFINE _periodo  	     CHAR(7);
DEFINE _code_pais,_cod_ramo  CHAR(3);
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);
DEFINE _cia		          CHAR(3);
DEFINE _suc		          CHAR(3);
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente		  DEC(16,2);
DEFINE v_monto_30		  DEC(16,2);
DEFINE v_monto_60		  DEC(16,2);
DEFINE v_monto_90		  DEC(16,2);
DEFINE v_apagar           DEC(16,2);

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
			   fecha,
			   cod_agente,
			   code_pais,
			   code_provincia,
			   code_ciudad,
			   code_distrito,
			   code_correg
		  INTO v_no_poliza,
			   v_saldo,
			   v_a_pagar,     
			   v_orden2,
			   v_orden1,
			   _fecha_dt,
			   _cod_agente,
   			   _code_pais,
			   _code_provincia,
			   _code_ciudad,
			   _code_distrito,
			   _code_correg
		  FROM cobruter
		 WHERE cod_cobrador = a_cobrador
		   AND (dia_cobros1 = a_dia
		   OR  dia_cobros2 = a_dia)
		 ORDER BY orden_2,orden_1

 IF v_no_poliza IS NOT NULL THEN
	 SELECT no_documento,
			cod_contratante,
			cod_ramo,
		    cod_compania,
		    cod_sucursal,
			saldo,
			estatus_poliza
	   INTO v_documento,
			_cod_cliente,
			_cod_ramo,
			_cia,
			_suc,
			_saldo_vig,
			_estatus
	   FROM emipomae
	  WHERE no_poliza = v_no_poliza
	    AND actualizado = 1;

		SELECT ramo_sis
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		IF _saldo_vig <= 0 THEN 
			IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
				CONTINUE FOREACH;
			END IF
			IF _estatus = 2 THEN --Cancelada
				DELETE FROM cobruter WHERE no_poliza = _no_poliza;
				CONTINUE FOREACH;
			END IF
		END IF

		CALL sp_cob33(
		_cia,
		_suc,
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
					IF _estatus = 2 THEN --Cancelada
						DELETE FROM cobruter WHERE no_poliza = _no_poliza;
						CONTINUE FOREACH;
					END IF
				END IF
				LET v_apagar = v_exigible;

	  SELECT nombre
	    INTO v_asegurado
		FROM cliclien
	   WHERE cod_cliente = _cod_cliente;

	  SELECT direccion_1,
			 direccion_2
	    INTO v_direccion1,
			 v_direccion2
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
	   LET v_documento = "";
	   LET v_asegurado = "";
	   LET v_direccion = "";
	   LET v_saldo = 0;
	   LET v_a_pagar = 0;

	   SELECT nombre,
			  direccion_1,
	   		  direccion_2
	     INTO v_asegurado,
			  v_direccion1,
			  v_direccion2	
	     FROM agtagent
	    WHERE cod_agente = _cod_agente;

		IF v_direccion1 IS NULL THEN
		   LET v_direccion1 = " ";
		END IF
		IF v_direccion2 IS NULL THEN
		   LET v_direccion2 = " ";
		END IF
	   LET v_direccion = v_direccion1 || v_direccion2;
END IF

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
		   _fecha_dt,
		   v_correg
		   WITH RESUME;
END FOREACH;

END PROCEDURE