-- Procedimiento que Verifica los Valores de las Polizas

-- Creado    : 11/06/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/04/2002 - Autor: Amado Perez
-- Modificado: 30/08/2002 Mi cumpleaños - se condiciona que cuando sea coaseguro mayoritario
                                       -- pregunte si la diferencia de primas es mayor de 0.20 cts
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis25a;			

CREATE PROCEDURE sp_sis25a(
a_no_poliza		CHAR(10)
) RETURNING SMALLINT,
		    CHAR(100);

DEFINE _tipo_mov		SMALLINT;
DEFINE _prima_neta      DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(7,4);
DEFINE _cod_coasegur	CHAR(3);
DEFINE _cod_compania	CHAR(3);
define _no_poliza       char(10);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_bruta     DEC(16,2);

DEFINE _prima_sus_sum	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);

DEFINE _error			SMALLINT;
DEFINE _mensaje         CHAR(100);
DEFINE a_no_endoso     	CHAR(5);

DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);

SET ISOLATION TO DIRTY READ;

LET _mensaje = '';
LET _prima_sus_sum = 0.00;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, 'Error al Verificar Informacion de la Poliza ...';         
END EXCEPTION           

--SET DEBUG FILE TO "sp_sis25a.trc";
--trace on;

LET a_no_endoso = '00000';

let _no_poliza = a_no_poliza;

SELECT prima_neta,
	   prima_suscrita,
	   prima_retenida,
	   cod_tipoprod,
	   cod_compania,
	   impuesto,
	   prima_bruta
  INTO _prima_neta,
	   _prima_suscrita,
	   _prima_retenida,
	   _cod_tipoprod,
	   _cod_compania,
	   _impuesto,
	   _prima_bruta
  FROM emipomae
 WHERE no_poliza   = a_no_poliza;

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = _cod_compania;

SELECT tipo_produccion
  INTO _tipo_produccion
  FROM emitipro
 WHERE cod_tipoprod = _cod_tipoprod;

LET _porcentaje = 1;

IF _tipo_produccion = 2 THEN
	SELECT porc_partic_coas
	  INTO _porcentaje
	  FROM emicoama
	 WHERE cod_coasegur = _cod_coasegur
	   AND no_poliza    = a_no_poliza;

	IF _porcentaje IS NULL THEN
		LET _porcentaje = 0;
	ELSE
		LET _prima_sus_sum = _prima_neta * _porcentaje; 
		LET _prima_sus_sum = _prima_sus_sum / 100;
	END IF

ELSE
	LET _prima_sus_sum = _prima_neta * _porcentaje;
END IF

IF _tipo_produccion <> 2 THEN
	IF abs(_prima_sus_sum - _prima_suscrita) > 0.03 THEN
		LET _mensaje = 'Prima Suscrita por Calculo Diferente de Prima Suscrita, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
Else
	IF abs(_prima_sus_sum - _prima_suscrita) > 0.50 THEN
		LET _mensaje = 'Prima Suscrita por Calculo Diferente de Prima Suscrita, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	END IF
End If

-- Verificacion de Prima Neta Vs Prima Suscrita

IF ABS(_prima_suscrita) > ABS(_prima_neta) THEN
	LET _mensaje = 'Prima Suscrita No Puede Ser Mayor que Prima Neta, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Verificacion de Prima Retenida Vs Prima Suscrita

IF ABS(_prima_retenida) > ABS(_prima_suscrita) THEN
	LET _mensaje = 'Prima Retenida No Puede Ser Mayor que Prima Suscrita, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Sumatoria de la Distribucion de Reaseguro

SELECT SUM(prima)
  INTO _prima_sus_sum
  FROM emifacon
 WHERE no_poliza = a_no_poliza
   AND no_endoso = a_no_endoso;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

IF ABS(_prima_suscrita) <> ABS(_prima_sus_sum) THEN
	LET _mensaje = 'Sumatoria de Primas de Reaseguro Diferente de Prima Suscrita, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Verificacion de Prima Retenida

SELECT SUM(e.prima)
  INTO _prima_sus_sum
  FROM emifacon	e, reacomae r
 WHERE e.no_poliza     = a_no_poliza
   AND e.no_endoso     = a_no_endoso
   AND e.cod_contrato  = r.cod_contrato
   AND r.tipo_contrato = 1;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

IF abs(_prima_sus_sum) <> abs(_prima_retenida) THEN
	LET _mensaje = 'Sumatoria de Prima de Retencion Diferente a Prima Retenida, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Verificacion de Prima Retenida de las Unidades

{
SELECT SUM(prima_retenida)
  INTO _prima_sus_sum
  FROM emipouni
 WHERE no_poliza = a_no_poliza;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

IF ABS(_prima_retenida) <> ABS(_prima_sus_sum) THEN
	LET _mensaje = 'Primas Retenidas de Unidades Diferente a Prima Retenida de la Poliza, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF
}

-- Verificacion de Impuestos de las Unidades

SELECT SUM(impuesto)
  INTO _prima_sus_sum
  FROM emipouni
 WHERE no_poliza = a_no_poliza;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

IF ABS(_impuesto - _prima_sus_sum) > 1 THEN
	LET _mensaje = 'Impuesto de Unidades Diferente a Impuesto de la Poliza, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Verificacion de Prima Bruta de las Unidades

SELECT SUM(prima_bruta)
  INTO _prima_sus_sum
  FROM emipouni
 WHERE no_poliza = a_no_poliza;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

--****************SE QUITA TEMPORALMENTE

--IF ABS(_prima_bruta - _prima_sus_sum) > 1 THEN
--	LET _mensaje = 'Prima Bruta de Unidades Diferente a Prima Bruta de la Poliza, Por Favor Verifique ...';
--	RETURN 1, _mensaje;
--END IF

-- Verificacion de Primas de Coberturas 

SELECT SUM(prima_neta)
  INTO _prima_sus_sum
  FROM emipocob
 WHERE no_poliza = a_no_poliza;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

IF ABS(_prima_neta) <> ABS(_prima_sus_sum) THEN
	LET _mensaje = 'Sumatoria de Primas de Coberturas Diferente de Prima Neta, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Verificacion de Facultativos

SELECT COUNT(*)
  INTO _cantidad
  FROM emifacon	e, reacomae r
 WHERE e.no_poliza     = a_no_poliza
   AND e.no_endoso     = a_no_endoso
   AND e.cod_contrato  = r.cod_contrato
   AND r.tipo_contrato = 3;

IF _cantidad IS NULL THEN
	LET _cantidad = 0;
END IF

IF _cantidad <> 0 THEN

   FOREACH	
	SELECT no_unidad,
	       cod_cober_reas,
		   prima
	  INTO _no_unidad,
	       _cobertura,
		   _prima_sus_cal
	  FROM emifacon	e, reacomae r
	 WHERE e.no_poliza     = a_no_poliza
	   AND e.no_endoso     = a_no_endoso
	   AND e.cod_contrato  = r.cod_contrato
	   AND r.tipo_contrato = 3

		SELECT COUNT(*)
		  INTO _prima_sus_sum
		  FROM emifafac
		 WHERE no_poliza      = a_no_poliza
		   AND no_endoso      = a_no_endoso
		   AND no_unidad      = _no_unidad
		   AND cod_cober_reas = _cobertura;

		IF _prima_sus_sum IS NULL THEN
			LET _prima_sus_sum = 0;
		END IF

		IF _prima_sus_sum = 0 THEN
			LET _mensaje = 'No Existe Distribucion de Facultativos, Unidad ' || _no_unidad;
			RETURN 1, _mensaje;
		END IF

		SELECT SUM(prima)
		  INTO _prima_sus_sum
		  FROM emifafac
		 WHERE no_poliza      = a_no_poliza
		   AND no_endoso      = a_no_endoso
		   AND no_unidad      = _no_unidad
		   AND cod_cober_reas = _cobertura;

		IF abs(_prima_sus_cal - _prima_sus_sum) > 0.02 THEN
			LET _mensaje = 'Sumatoria de Prima de Facultativos Diferente a Prima del Contrato, Unidad ' || _no_unidad;
			RETURN 1, _mensaje;
		END IF
	
		SELECT SUM(porc_partic_reas)
		  INTO _prima_sus_cal
		  FROM emifafac
		 WHERE no_poliza      = a_no_poliza
		   AND no_endoso      = a_no_endoso
		   AND no_unidad      = _no_unidad
		   AND cod_cober_reas = _cobertura;

		IF _prima_sus_cal IS NULL THEN
			LET _prima_sus_cal = 0;
		END IF

		IF _prima_sus_cal <> 100 THEN
			LET _mensaje = 'Sumatoria de Porcentajes de Facultativos Diferente de 100, Unidad ' || _no_unidad;
			RETURN 1, _mensaje;
		END IF

	END FOREACH

END IF

LET _mensaje = 'Verificacion Exitosa ...';
RETURN 0, _mensaje;

END

END PROCEDURE;

