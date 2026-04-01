-- Armar ruta (AREA) clientes
-- 
-- Creado    : 30/05/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob110;

CREATE PROCEDURE "informix".sp_cob110(a_compania CHAR(3), a_cobrador CHAR(3), a_dia INT) 
       RETURNING   		SMALLINT,  	-- Orden2
						CHAR(100),	-- asegurado
						CHAR(100),  -- direccion
						DEC(16,2),	-- saldo
						DEC(16,2),	-- a_pagar
						DATETIME YEAR TO FRACTION(5),	-- fecha
						CHAR(100),	-- area
						SMALLINT;  	-- Orden1

DEFINE v_orden2,v_orden1 SMALLINT;
DEFINE v_asegurado       CHAR(100);
DEFINE v_direccion		 CHAR(100);
DEFINE v_saldo     		 DEC(16,2);
DEFINE v_a_pagar	 	 DEC(16,2);
DEFINE _cod_pagador      CHAR(10);
DEFINE _fecha_dt         DATETIME YEAR TO FRACTION(5);	-- fecha
DEFINE _cod_agente	     CHAR(5);
DEFINE v_correg 		 CHAR(100);
DEFINE _code_provincia 	 CHAR(2);
DEFINE _code_ciudad		 CHAR(2);
DEFINE _code_distrito    CHAR(2);
DEFINE _code_correg	     CHAR(5);
DEFINE _periodo  	     CHAR(7);
DEFINE _code_pais  CHAR(3);
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
		SELECT cod_pagador,
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
		  INTO _cod_pagador,
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
		  FROM cobruter1
		 WHERE cod_cobrador = a_cobrador
		   AND (dia_cobros1 = a_dia
		   OR  dia_cobros2 = a_dia)
		 ORDER BY orden_2,orden_1

		if _cod_pagador is null then

		  SELECT nombre
		    INTO v_asegurado
			FROM agtagent
		   WHERE cod_agente = _cod_agente;
		else
		  SELECT nombre
		    INTO v_asegurado
			FROM cliclien
		   WHERE cod_cliente = _cod_pagador;
		end if

	   LET v_direccion = '';

	SELECT nombre
	  INTO v_correg
	  FROM gencorr
	 WHERE code_pais      = _code_pais
	   AND code_provincia = _code_provincia
	   AND code_ciudad    = _code_ciudad
	   AND code_distrito  = _code_distrito
	   AND code_correg    = _code_correg;

	RETURN v_orden2,
		   v_asegurado,
	       v_direccion,
		   v_saldo,
		   v_a_pagar,
		   _fecha_dt,
		   v_correg,
		   v_orden1
		   WITH RESUME;
END FOREACH;

END PROCEDURE