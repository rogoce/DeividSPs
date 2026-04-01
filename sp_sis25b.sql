-- Procedimiento que Verifica los Valores de las Polizas

-- Creado    : 11/06/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/04/2002 - Autor: Amado Perez
-- Modificado: 30/08/2002 Mi cumpleaños - se condiciona que cuando sea coaseguro mayoritario
                                       -- pregunte si la diferencia de primas es mayor de 0.20 cts
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis25b;			
CREATE PROCEDURE sp_sis25b(
a_no_poliza		CHAR(10)
) RETURNING SMALLINT,
		    CHAR(100);

DEFINE _tipo_mov		SMALLINT;
DEFINE _prima_neta,_prima_neta_uni      DEC(16,2);
DEFINE _prima_suscrita,_prima_sus  DEC(16,2);
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

DEFINE _error			SMALLINT;
DEFINE _mensaje         CHAR(100);
DEFINE a_no_endoso     	CHAR(5);

DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
define _porc_partic_suma  decimal(9,6);
define _porc_partic_prima decimal(9,6);
define _suma_asegurada  DEC(16,2);
define _orden           smallint;

SET ISOLATION TO DIRTY READ;

LET _mensaje = '';
LET _prima_sus_sum = 0.00;
let _orden = 0;
BEGIN

ON EXCEPTION SET _error 
 	RETURN _error, 'Error al Verificar Informacion de la Poliza ...';         
END EXCEPTION           

--SET DEBUG FILE TO "sp_sis25b.trc";
--trace on;

LET a_no_endoso = '00000';

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
	SELECT e.no_unidad,
	       e.cod_cober_reas,
		   e.prima,
		   e.porc_partic_prima,
		   e.porc_partic_suma,
		   e.suma_asegurada,
		   e.orden
	  INTO _no_unidad,
	       _cobertura,
		   _prima_sus_cal,
		   _porc_partic_prima,
		   _porc_partic_suma,
		   _suma_asegurada,
		   _orden
	  FROM emifacon	e, reacomae r
	 WHERE e.no_poliza     = a_no_poliza
	   AND e.no_endoso     = a_no_endoso
	   AND e.cod_contrato  = r.cod_contrato
	   AND r.tipo_contrato = 3


	if (_suma_asegurada = 0 and _prima_sus_cal = 0) and (_porc_partic_prima = 0 and _porc_partic_suma = 0) then
		delete from emifacon
		 where no_poliza      = a_no_poliza
		   and no_endoso      = '00000'
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cobertura
		   and orden          = _orden;

		continue foreach;
	end if

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
else
		SELECT prima_neta,
			   prima_suscrita,
			   prima_retenida,
			   cod_tipoprod,
			   cod_compania,
			   prima_bruta
		  INTO _prima_neta,
			   _prima_suscrita,
			   _prima_retenida,
			   _cod_tipoprod,
			   _cod_compania,
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

		-- Verificacion de Prima Neta Vs Prima Suscrita
		let _prima_neta_uni = 0.00;
		let _prima_sus      = 0.00;
		IF ABS(_prima_suscrita) > ABS(_prima_neta) THEN  -- se copia igual del sp_sis25 para correguir diferencias menor .5
			if abs(_prima_suscrita - _prima_neta) > 0.50 then
				foreach
				    select prima_neta,
				           no_unidad
					  into _prima_neta_uni,
                           _no_unidad					 
				      from emipouni
					 where no_poliza = a_no_poliza
					 order by no_unidad
					
					select sum(prima)
					  into _prima_sus
  			          from emifacon
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad;
					   
					if _prima_neta_uni <> _prima_sus THEN    
						LET _mensaje = 'Verifique el reaseguro de la unidad: '|| _no_unidad;
						RETURN 2, _mensaje;
					end if
				end foreach
				LET _mensaje = 'Prima Suscrita No Puede Ser Mayor que Prima Neta, Por Favor Verifique ...';
				RETURN 2, _mensaje;
			END IF
		END IF
END IF

LET _mensaje = 'Verificacion Exitosa ...';
RETURN 0, _mensaje;

END

END PROCEDURE;

