-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- modificado: 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par78b;

CREATE PROCEDURE "informix".sp_par78b(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE,
a_no_poliza    CHAR(10)
) RETURNING	DEC(16,2),	-- Por Vencer
			DEC(16,2),	-- Exigible
			DEC(16,2),	-- Corriente
			DEC(16,2),	-- 30 Dias
			DEC(16,2),	-- 60 Dias
			DEC(16,2),	-- 90 Dias
			DEC(16,2),	-- Saldo
			DEC(16,2);	-- PRIMA NETA ORIG
		  	
DEFINE v_prima_orig       DEC(16,2);
DEFINE _prima_neta2       DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);

DEFINE _prima_neta        DEC(16,2);
DEFINE _monto_recibo      DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_devolucion  DEC(16,2);
DEFINE _monto             DEC(16,2);

DEFINE _fecha_primer_pago DATE;
DEFINE _fecha_emision	  DATE;
DEFINE _no_pagos          SMALLINT; 

DEFINE _no_requis         CHAR(10);
DEFINE _periodo_cheque    CHAR(7);
DEFINE _pagado            SMALLINT;
DEFINE _fecha_impresion   DATE;
DEFINE _fecha_anulado     DATE;

DEFINE _cod_perpago       CHAR(3);
DEFINE _mes_perpago       SMALLINT;
DEFINE _tipo_periodo      CHAR(1);
DEFINE _dias              INTEGER;
DEFINE _ciclo             INTEGER;
DEFINE _mes_control       SMALLINT;
DEFINE _fecha_char        CHAR(10);
DEFINE _fecha_letra       DATE;
DEFINE _monto_primero     DEC(16,2);
DEFINE _monto_resto       DEC(16,2);

DEFINE _no_factura        CHAR(10);

define _no_poliza				char(10);
define _no_endoso				char(5);
define _cod_ramo				char(3);
define _cnt_dias				dec(16,2);
define _dias_vig				smallint;
define _fecha_primer_pago_pol	date;
define _vigencia_inic_end		date;
define _fecha_ult_letra			date;
define _vigencia_final			date;
define _vigencia_inic			date;


--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON ;

SET ISOLATION TO DIRTY READ;

LET v_prima_orig  = 0;
LET v_saldo       = 0;
LET v_por_vencer  = 0;    
LET v_exigible    = 0;    
LET v_corriente   = 0;   
LET v_monto_30    = 0;    
LET v_monto_60    = 0;    
LET v_monto_90    = 0;
let _prima_neta2  = 0;
LET _prima_neta  = 0;

-- Facturas

LET _prima_neta   = 0;
LET _monto        = 0;

--Prima neta de la ultima vigencia
FOREACH
 SELECT prima_neta
   INTO _monto
   FROM endedmae
  WHERE no_poliza      = a_no_poliza	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1
		LET _prima_neta2 = _prima_neta2 + _monto;
END FOREACH

FOREACH
 SELECT prima_neta
   INTO _monto
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
    AND periodo       <= a_periodo	    -- No Incluye Periodos Futuros
	AND activa         = 1
		LET _prima_neta  = _prima_neta + _monto;
END FOREACH

IF _prima_neta IS NULL THEN
	LET _prima_neta = 0;
END IF
IF _prima_neta2 IS NULL THEN
	LET _prima_neta2 = 0;
END IF

LET v_prima_orig = _prima_neta;

-- Recibos

LET _monto_recibo = 0;
LET _monto        = 0;

FOREACH
 SELECT prima_neta
   INTO _monto
   FROM cobredet
  WHERE doc_remesa   = a_no_documento	-- Recibos de la Poliza
    AND actualizado  = 1			    -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N')		-- Pago de Prima(P) y Notas de Credito(N)
    AND periodo     <= a_periodo	    -- No Incluye Periodos Futuros
		LET _monto_recibo = _monto_recibo + _monto;
END FOREACH

IF _monto_recibo IS NULL THEN
	LET _monto_recibo = 0;
END IF
 
-- Cheques de Devolucion de Primas

LET _monto_devolucion = 0;

FOREACH
 SELECT prima_neta,
        no_requis
   INTO _monto_cheque,
	   _no_requis	
   FROM chqchpol
  WHERE no_documento   = a_no_documento

	SELECT pagado,
		   periodo,
		   fecha_impresion,
		   fecha_anulado
	  INTO _pagado,
	       _periodo_cheque,
		   _fecha_impresion,
		   _fecha_anulado
	  FROM chqchmae
	 WHERE no_requis = _no_requis;

	IF _pagado = 1 THEN
		IF _fecha_impresion > a_fecha THEN
			LET _monto_cheque = 0;
		ELSE
			IF _fecha_anulado IS NOT NULL THEN
				IF _fecha_anulado <= a_fecha	THEN
					LET _monto_cheque = 0;
				END IF
			END IF
		END IF				
	ELSE
		LET _monto_cheque = 0;
	END IF	
	
	IF _monto_cheque IS NULL THEN
		LET _monto_cheque = 0;
	END IF		

	LET _monto_devolucion = _monto_devolucion - _monto_cheque;	

END FOREACH

-- Realiza la Verificacion de Montos

LET _monto_recibo = _monto_recibo + _monto_devolucion;
LET _prima_neta   = _prima_neta   - _monto_recibo;
LET v_saldo       = _prima_neta;    

IF v_saldo >= -0.08 and v_saldo <= 0.08 THEN
	
	RETURN  v_por_vencer,    
			v_exigible,      
			v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_saldo,
			_prima_neta2;   
			
END IF

-- Inicio del Proceso de Determinar la Morosidad de las Facturas

FOREACH
 SELECT	prima_neta,
		fecha_primer_pago,
		no_pagos,
		cod_perpago,
		no_factura,
		fecha_emision,
		no_poliza,
		no_endoso,
		vigencia_inic
   INTO	_prima_neta,
		_fecha_primer_pago,
		_no_pagos,
		_cod_perpago,
		_no_factura,
		_fecha_emision,
		_no_poliza,
		_no_endoso,
		_vigencia_inic_end
   FROM	endedmae
  WHERE	no_documento   = a_no_documento -- Facturas de la Poliza
    AND actualizado    = 1			 	-- Factura este Actualizada
	AND periodo       <= a_periodo	 	-- No Incluye Periodos Futuros
	AND prima_neta    <> 0           	-- Procesa la Facturas de Aumento de Prima
	AND activa         = 1

	{if _fecha_primer_pago >= _fecha_emision then
		let _fecha_letra       = _fecha_primer_pago;
	else
		let _fecha_letra       = _fecha_emision;
		let _fecha_primer_pago = _fecha_emision;
	end if}
		
	SELECT meses,
		   tipo_periodo	
	  INTO _mes_perpago,
		   _tipo_periodo	
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;
	
	-- Cambio de Distribución de Morosidad por Facturas en Positivo
	select cod_ramo,
		   fecha_primer_pago,
		   vigencia_inic,
		   vigencia_final
	  into _cod_ramo,
		   _fecha_primer_pago_pol,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fecha_primer_pago_pol not between _vigencia_inic and _vigencia_final then
		let _fecha_primer_pago_pol = _vigencia_inic;
	end if

	if _no_endoso = '00000' then
		let _fecha_primer_pago = _fecha_primer_pago_pol;
	else
		let _fecha_primer_pago = _vigencia_inic_end;
	end if

	-- Selecciona los periodos de pago
	let _fecha_letra   = _fecha_primer_pago;

	let _cnt_dias = _mes_perpago;

	if _cod_ramo = '018' then
	else
		if _cod_perpago = '006' then
		else
			if day(_fecha_primer_pago_pol) = 31 then
				let _fecha_primer_pago_pol = _fecha_primer_pago_pol - 1 units day;
			end if

			if _cod_perpago = '001' then
				let _cnt_dias = 0.5;
			elif _cod_perpago = '008' then
				let _cnt_dias = 1;
			end if
			
			if _cod_perpago in ('002','008','001') then
				if month(_fecha_primer_pago_pol) + ((_no_pagos ) * _cnt_dias)  - 12 in (2,-10) and day(_fecha_primer_pago_pol) > 28 then
					let _fecha_primer_pago_pol = mdy(month(_fecha_primer_pago_pol),28,year(_fecha_primer_pago_pol));
				end if

				let _fecha_ult_letra = _fecha_primer_pago_pol + ((_no_pagos ) * _cnt_dias) units month;
				let _no_pagos = MONTHS_BETWEEN(_fecha_ult_letra,_fecha_letra)/_cnt_dias;	
			else
				if month(_fecha_primer_pago_pol) + ((_no_pagos - 1 ) * _cnt_dias) - 12 in (2,-10) and day(_fecha_primer_pago_pol) > 28 then
					let _fecha_primer_pago_pol = mdy(month(_fecha_primer_pago_pol),28,year(_fecha_primer_pago_pol));
				end if

				let _fecha_ult_letra = _fecha_primer_pago_pol + ((_no_pagos - 1 ) * _cnt_dias) units month;
				let _no_pagos = MONTHS_BETWEEN(_fecha_ult_letra,_fecha_letra)/_cnt_dias + 1;
			end if
			
			if _no_pagos <= 0 then
				let _no_pagos = 1;
			end if
			
			let _no_pagos = round(_no_pagos,1);
	
		end if
	end if
	-- FIN Cambio de Distribución de Morosidad por Facturas en Positivo
	
		-- Ajusta la Primera Letra por si se pierden centavos al momento de 
		-- hacer la division entre el numero de pagos

		LET _monto_resto   = _prima_neta / _no_pagos;
		LET _monto_primero = _monto_resto + (_prima_neta - (_monto_resto * _no_pagos));
		--LET _fecha_letra   = _fecha_primer_pago;

		-- Inicia el ciclo para determinar la morosidad de cada factura

		FOR _ciclo = 1 TO _no_pagos
			
			LET _dias = a_fecha - _fecha_letra;

			IF _ciclo = 1 THEN
				LET _prima_neta = _monto_primero;
			ELSE
				LET _prima_neta = _monto_resto;
			END IF

			IF _dias < 0 THEN
		        LET v_por_vencer = v_por_vencer + _prima_neta;
			ELIF _dias >= 0 AND _dias <= 30 THEN
		        LET v_corriente = v_corriente   + _prima_neta;
			ELIF _dias > 30 AND _dias <= 60 THEN
			    LET v_monto_30 = v_monto_30     + _prima_neta;
			ELIF _dias > 60 AND _dias <= 90 THEN
	            LET v_monto_60 = v_monto_60     + _prima_neta;
			ELSE
		        LET v_monto_90 = v_monto_90     + _prima_neta;
			END IF

			IF _tipo_periodo = 'M' THEN -- Periodo Mensual				

				LET _mes_control = MONTH(_fecha_letra) + _mes_perpago;

				IF _mes_control > 12 THEN
					LET _mes_control = _mes_control - 12;
				END IF

				IF _mes_control = 2 THEN -- Verificaciones para Febrero
					IF DAY(_fecha_primer_pago) = 29 OR
					   DAY(_fecha_primer_pago) = 30 OR
					   DAY(_fecha_primer_pago) = 31 THEN
							LET _fecha_char      = _fecha_primer_pago;
							LET _fecha_char[1,2] = '28';	-- Formato dd/mm/yyyy
							LET _fecha_letra     = _fecha_char;
							LET _fecha_letra     = _fecha_letra + (_ciclo * _mes_perpago) UNITS MONTH;
					ELSE
							LET _fecha_letra     = _fecha_primer_pago + (_ciclo * _mes_perpago) UNITS MONTH;
					END IF
				ELIF _mes_control = 4  OR	-- Verificaciones para Abril
					 _mes_control = 6  OR	-- Verificaciones para Junio
					 _mes_control = 9  OR	-- Verificaciones para Septiembre
					 _mes_control = 11 THEN	-- Verificaciones para Noviembre
						IF DAY(_fecha_primer_pago) = 31 THEN
								LET _fecha_char      = _fecha_primer_pago;
								LET _fecha_char[1,2] = '30';	-- Formato dd/mm/yyyy
								LET _fecha_letra     = _fecha_char;
								LET _fecha_letra     = _fecha_letra + (_ciclo * _mes_perpago) UNITS MONTH;
						ELSE
								LET _fecha_letra     = _fecha_primer_pago + (_ciclo * _mes_perpago) UNITS MONTH;
						END IF
				ELSE
					LET _fecha_letra = _fecha_primer_pago + (_ciclo * _mes_perpago) UNITS MONTH;
				END IF

			ELSE						-- Periodo Quincenal
				LET _fecha_letra = _fecha_primer_pago + (_ciclo * 15) UNITS DAY;
			END IF

		END FOR

END FOREACH

-- Suma las Facturas Negativas
{
LET _prima_neta   = 0;
LET _monto        = 0;

FOREACH
 SELECT	prima_neta
   INTO	_monto
   FROM	endedmae
  WHERE	no_documento   = a_no_documento -- Facturas de la Poliza
    AND actualizado    = 1			 	-- Factura este Actualizada
	AND periodo        <= a_periodo	 	-- No Incluye Periodos Futuros
	AND prima_neta     < 0          	-- Procesa la Facturas de Disminucion de Prima
	AND activa         = 1
		LET _prima_neta = _prima_neta + _monto;
END FOREACH

IF _prima_neta IS NULL THEN
	LET _prima_neta = 0;
END IF

LET _prima_neta  = _prima_neta * -1;
LET _monto_recibo = _prima_neta + _monto_recibo;}

-- Realiza la Aplicacion de los Recibos y Facturas Negativas a los
-- Montos Mas Viejos de las Facturas

WHILE _monto_recibo != 0 

	IF v_monto_90 > 0 THEN
		
		IF v_monto_90 > _monto_recibo THEN
		    LET v_monto_90    = v_monto_90 - _monto_recibo;
		    LET _monto_recibo = 0;
		ELSE 
		    LET _monto_recibo = _monto_recibo - v_monto_90;
		    LET v_monto_90    = 0;
		END IF

    ELIF v_monto_60 > 0 THEN

		IF v_monto_60 > _monto_recibo THEN
		    LET v_monto_60    = v_monto_60 - _monto_recibo;
		    LET _monto_recibo = 0;
		ELSE 
		    LET _monto_recibo = _monto_recibo - v_monto_60;
		    LET v_monto_60    = 0;
		END IF

    ELIF v_monto_30 > 0 THEN

		IF v_monto_30 > _monto_recibo THEN
		    LET v_monto_30    = v_monto_30 - _monto_recibo;
		    LET _monto_recibo = 0;
		ELSE 
		    LET _monto_recibo = _monto_recibo - v_monto_30;
		    LET v_monto_30    = 0;
		END IF

    ELIF v_corriente > 0 THEN

		IF v_corriente > _monto_recibo THEN
		    LET v_corriente   = v_corriente - _monto_recibo;
		    LET _monto_recibo = 0;
		ELSE 
		    LET _monto_recibo = _monto_recibo - v_corriente;
		    LET v_corriente   = 0;
		END IF

    ELIF v_por_vencer > 0 THEN

		IF v_por_vencer > _monto_recibo THEN
		    LET v_por_vencer  = v_por_vencer - _monto_recibo;
		    LET _monto_recibo = 0;
		ELSE 
		    LET _monto_recibo = _monto_recibo - v_por_vencer;
		    LET v_por_vencer  = 0;
		END IF

	ELSE

		LET v_corriente    = v_corriente - _monto_recibo;
		LET _monto_recibo  = 0; 

    END IF

END WHILE

LET v_exigible = v_corriente + v_monto_30 + v_monto_60 + v_monto_90;

RETURN  v_por_vencer,    
		v_exigible,      
		v_corriente,    
		v_monto_30,      
		v_monto_60,      
		v_monto_90,
		v_saldo,
		_prima_neta2;
		
END PROCEDURE;
