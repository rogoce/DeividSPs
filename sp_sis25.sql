-- Procedimiento que Verifica los Valores de las Polizas

-- Creado    : 11/06/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/04/2002 - Autor: Amado Perez
-- Modificado: 30/08/2002 Mi cumpleaños - se condiciona que cuando sea coaseguro mayoritario
                                       -- pregunte si la diferencia de primas es mayor de 0.20 cts
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis25;

CREATE PROCEDURE sp_sis25(a_no_poliza CHAR(10))
RETURNING SMALLINT, CHAR(100);

DEFINE _tipo_mov		SMALLINT;
DEFINE _prima_neta      DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(7,4);
DEFINE _cod_coasegur	CHAR(3);
DEFINE _cod_compania	CHAR(3);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_bruta     DEC(16,2);

DEFINE _prima_sus_sum	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
define _prima			DEC(16,2);
define _suma_asegurada  DEC(16,2);

DEFINE _error			SMALLINT;
DEFINE _mensaje         CHAR(100);
DEFINE a_no_endoso     	CHAR(5);

DEFINE _cantidad		  INTEGER;
DEFINE _no_unidad		  CHAR(5);
DEFINE _cobertura		  CHAR(5);
define _porc_partic_suma  decimal(9,6);
define _porc_partic_prima decimal(9,6);
define _cod_cober_reas    char(3);
define _orden             smallint;
define _cant_uni		  INTEGER;
define _dif_impuesto      DEC(16,2);
define _no_documento      char(20);

SET ISOLATION TO DIRTY READ;

LET _mensaje = '';
LET _prima_sus_sum = 0.00;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, 'Error al Verificar Informacion de la Poliza ...';         
END EXCEPTION           

{SET DEBUG FILE TO "sp_sis25.trc";
if a_no_poliza = '2998697' THEN
	trace on;
end if}

LET a_no_endoso = '00000';
let _no_documento = '';

SELECT prima_neta,
	   prima_suscrita,
	   prima_retenida,
	   cod_tipoprod,
	   cod_compania,
	   impuesto,
	   prima_bruta,
	   no_documento
  INTO _prima_neta,
	   _prima_suscrita,
	   _prima_retenida,
	   _cod_tipoprod,
	   _cod_compania,
	   _impuesto,
	   _prima_bruta,
	   _no_documento
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
		--if _no_documento = '0210-01044-01' then
		--else
			LET _mensaje = 'Prima Suscrita por Calculo Diferente de Prima Suscrita, Por Favor Verifique ...';
			RETURN 1, _mensaje;
		--end if	
	END IF
Else
	IF abs(_prima_sus_sum - _prima_suscrita) > 0.50 THEN
		LET _mensaje = 'Prima Suscrita por Calculo Diferente de Prima Suscrita, Por Favor Verifique ....';
		RETURN 1, _mensaje;
	END IF
End If

-- Verificacion de Prima Neta Vs Prima Suscrita

IF ABS(_prima_suscrita) > ABS(_prima_neta) THEN
    --if _no_documento = '0210-01044-01' then
	--else
	if abs(_prima_suscrita - _prima_neta) > 0.50 then
		LET _mensaje = 'Prima Suscrita No Puede Ser Mayor que Prima Neta, Por Favor Verifique ...';
		RETURN 1, _mensaje;
	end if
	--end if
END IF

-- Verificacion de Prima Retenida Vs Prima Suscrita

IF ABS(_prima_retenida) > ABS(_prima_suscrita) THEN
	LET _mensaje = 'Prima Retenida No Puede Ser Mayor que Prima Suscrita, Por Favor Verifique ...';
	RETURN 1, _mensaje;
END IF

-- Eliminacion de reg de reaseguro cuando % y valores en prima y suma son cero.
foreach
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emipouni
	 WHERE no_poliza = a_no_poliza

	foreach
		SELECT cod_cober_reas,
		       orden,
			   porc_partic_prima,
			   porc_partic_suma,
			   prima,
			   suma_asegurada
		  INTO _cod_cober_reas,
		       _orden,
			   _porc_partic_prima,
			   _porc_partic_suma,
			   _prima,
			   _suma_asegurada
		  FROM emifacon
		 WHERE no_poliza = a_no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad

		IF _porc_partic_prima IS NULL THEN
			LET _porc_partic_prima = 0;
		END IF
		IF _porc_partic_suma IS NULL THEN
			LET _porc_partic_suma = 0;
		END IF
		IF _prima IS NULL THEN
			LET _prima = 0;
		END IF
		IF _suma_asegurada IS NULL THEN
			LET _suma_asegurada = 0;
		END IF

		if (_suma_asegurada = 0 and _prima = 0) and (_porc_partic_prima = 0 and _porc_partic_suma = 0) then
			delete from emifacon
			 where no_poliza      = a_no_poliza
			   and no_endoso      = '00000'
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and orden          = _orden;
		end if
	end foreach

end foreach

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

LET _cant_uni = 0;

SELECT count(*)
  INTO _cant_uni
  FROM emipouni
 WHERE no_poliza = a_no_poliza;

IF _cant_uni >= 1200 THEN
	LET _dif_impuesto = 9.91;
ELIF _cant_uni >= 350 AND _cant_uni < 1200 THEN
	LET _dif_impuesto = 5.40;
ELSE
	LET _dif_impuesto = 1.65;
END IF

IF a_no_poliza = '1907821' or a_no_poliza = '0001417487' or a_no_poliza = '1433796' or a_no_poliza = '0001741427' THEN
	let _dif_impuesto = 9;
END IF

SELECT SUM(impuesto)
  INTO _prima_sus_sum
  FROM emipouni
 WHERE no_poliza = a_no_poliza;

IF _prima_sus_sum IS NULL THEN
	LET _prima_sus_sum = 0;
END IF

--IF ABS(_impuesto - _prima_sus_sum) > 1.65 THEN

IF ABS(_impuesto - _prima_sus_sum) > _dif_impuesto THEN	 -- CASO: 15993 USER: KSAAVEDR PC: CMEMIS03	-- Amado 29-10-2013 la suma de impuesto esta dando una diferencia de 1.96 entre las 393 unidades y la poliza
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

