-- Procedimiento para calculo de tarifas y primas por cobertura
-- Creado    : 22/01/2009 - Autor: Ricardo Jim‚nez B.
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro51c;

CREATE PROCEDURE "informix".sp_pro51c(a_poliza CHAR(10), a_producto CHAR(5), a_ramo CHAR(3), a_unidad CHAR(5), a_cobertura CHAR(5), a_suma DECIMAL(16,2))
RETURNING DECIMAL(16,2);  -- Tarifa por cobertura

--declaracion de variables

DEFINE _factor_division        SMALLINT;
DEFINE _valor_asignar           CHAR(1);
DEFINE _tipo_valor              CHAR(1);
DEFINE _busqueda 	            CHAR(1);
DEFINE _ld_tarifa         DECIMAL(20,4);
DEFINE _ld_ded_min        DECIMAL(20,4);
DEFINE _ld_limite_1       DECIMAL(20,4);
DEFINE _ld_limite_2	      DECIMAL(20,4);
DEFINE _ld_prima_neta     DECIMAL(20,4);
DEFINE _ld_prima_bruta    DECIMAL(20,4);
DEFINE _ld_descuento_max  DECIMAL(20,4);
DEFINE _ld_suma           DECIMAL(20,4);
DEFINE _ld_prima          DECIMAL(20,4);
DEFINE _ld_prima_resta    DECIMAL(20,4);
DEFINE _ld_recargo        DECIMAL(20,4);
DEFINE _ld_descuento      DECIMAL(20,4);
DEFINE _ldv_tar_unica     DECIMAL(20,4);
DEFINE _ld_valor          DECIMAL(20,4);
DEFINE _tipo_deduc             SMALLINT;
DEFINE _acepta_desc            SMALLINT;
DEFINE _fact_vigencia      DECIMAL(9,6);
DEFINE _ramo_sis               SMALLINT;
DEFINE _no_motor               CHAR(30);
DEFINE _ld_anos                SMALLINT;

SET ISOLATION TO DIRTY READ;


LET _ld_suma 	     = a_suma;
LET _ld_tarifa       =  00.00;
LET _ld_ded_min      =  00.00;
LET _ld_limite_1     =  00.00;
LET _ld_limite_2     =  00.00;
LET _ld_prima_neta   =  00.00;
LET _ld_prima_bruta  =  00.00;
LET _ld_descuento_max=  00.00;
LET _ld_descuento    =  00.00;
LET _ld_prima        =  00.00;
LET _ld_prima_resta  =  00.00;
LET _ld_descuento    =  00.00;
LET _ld_recargo      =  00.00;
LET _ldv_tar_unica   =  00.00;
LET _ramo_sis        =      0;
LET _ld_anos         =      0;
LET _fact_vigencia   =      0;  

IF _ld_suma IS NULL THEN
   LET _ld_suma = 00.00;
END IF

SELECT d.valor_asignar,
	   d.tipo_valor,
	   d.factor_division,
	   d.busqueda,
	   d.deducible_min,
	   d.tipo_deducible,
       d.acepta_desc,
       d.descuento_max,
	   d.valor_tar_unica
  INTO _valor_asignar,
	   _tipo_valor,
	   _factor_division,
	   _busqueda,
	   _ld_ded_min,
	   _tipo_deduc,
	   _acepta_desc,
	   _ld_descuento_max,
	   _ldv_tar_unica
  FROM prdcobpd d, prdcober c
 WHERE d.cod_cobertura = c.cod_cobertura
   AND c.cod_ramo      = a_ramo
   AND d.cod_producto  = a_producto
   AND c.cod_cobertura = a_cobertura;

SELECT factor_vigencia
  INTO _fact_vigencia
  FROM emipomae
 WHERE no_poliza = a_poliza;

SELECT prima_neta,
       prima_anual,
       descuento,
       limite_1,
	   limite_2
  INTO _ld_prima_neta,
	   _ld_prima_bruta, 
	   _ld_descuento,
	   _ld_limite_1,
	   _ld_limite_2
  FROM emipocob
 WHERE no_poliza     = a_poliza
   AND no_unidad     = a_unidad
   AND cod_cobertura = a_cobertura;

IF _busqueda = "1" THEN      --Secuencial
    SELECT valor
      INTO _ld_valor
      FROM prdtasec
 	 WHERE cod_cobertura = a_cobertura
   	   AND cod_producto  = a_producto
   	   AND rango_monto1  = _ld_limite_1
       AND rango_monto2  = _ld_limite_2;

	IF _tipo_valor = "T" THEN--Tarifa
	   IF _factor_division > 0 AND _ld_suma <> 0 THEN
		  LET _ld_tarifa = (_ld_valor * _factor_division) / _ld_suma;
		  LET _ld_tarifa = _ld_tarifa /  _factor_division;
		  LET _ld_tarifa = _ld_tarifa *  _ld_suma;
	   ELSE
		  LET _ld_tarifa = 00.00;
	   END IF
	ELIF _tipo_valor = "P" THEN
		 LET _ld_tarifa =  _ld_valor;
	END IF

ELIF _busqueda = "2" THEN   --Unica

	IF _tipo_valor = "P" THEN --Prima
	   LET _ld_tarifa = _ldv_tar_unica;
	ELIF _tipo_valor = "T" THEN --Tarifa
	  IF _factor_division > 0 AND _ld_suma <> 0 THEN
	     LET _ld_tarifa = _ldv_tar_unica / _factor_division;
		 LET _ld_tarifa = _ld_tarifa *  _ld_suma;
	  ELSE
		 LET _ld_suma = 00.00;
	  END IF
	END IF

ELIF _busqueda in ("3", "4") THEN --llave ¢ rango
	 SELECT ramo_sis
       INTO _ramo_sis
       FROM prdramo
      WHERE cod_ramo = a_ramo;

   	 IF _ramo_sis = 1 THEN
	 	SELECT no_motor
	      INTO _no_motor
	   	  FROM emiauto
	   	 WHERE no_poliza = a_poliza
	       AND no_unidad = a_unidad;

	    CALL  sp_sis61e(_no_motor, a_poliza) RETURNING _ld_anos;
   	 ELSE
	   LET _ld_anos = 0;
   	 END IF

     CALL sp_sis51c(_busqueda, a_producto, a_cobertura, _ld_anos, _ld_suma) RETURNING _ld_valor;

	 IF _tipo_valor = "P" THEN  --Prima
	   	IF _ld_valor > 0  THEN
	   	  LET _ld_tarifa = _ld_valor;
	    END IF
	 ElIF _tipo_valor = "T" THEN --Tarifa
	   	  IF _factor_division > 0 THEN
	   	     IF _ld_valor     > 0 THEN
	   		    LET _ld_tarifa = _ld_valor / _factor_division;
	   	        LET _ld_tarifa = _ld_tarifa * _ld_suma;
	   		 END IF
	   	  END IF
	 END IF

END IF															

--Calculo de prima y descuento
  
LET _ld_prima       = _fact_vigencia * _ld_tarifa;
LET _ld_prima_resta = _ld_prima;
LET _ld_descuento   = 00.00;
LET _ld_descuento   = 00.00;

IF _acepta_desc = 1 THEN --Calcula descuento
   CALL sp_proe21(a_poliza, a_unidad, _ld_prima) RETURNING _ld_descuento;

   IF _ld_descuento IS NULL THEN
      LET _ld_descuento = 00.00;
   END IF

END IF

IF _ld_descuento > 00.00 THEN
   LET _ld_prima_resta = _ld_prima - _ld_descuento;
END IF

LET _ld_recargo = 00.00;

IF _acepta_desc = 1 THEN --Calcula recargo
   CALL sp_proe22(a_poliza, a_unidad, _ld_prima_resta) RETURNING _ld_recargo;
   --LET _ld_recargo = 00.00;
END IF

-- Calcular Prima Neta

IF _ld_prima_neta <> 00.00 THEN
   LET _ld_prima_neta = _ld_prima + _ld_recargo - _ld_descuento;
END IF

RETURN _ld_prima_neta;


END PROCEDURE