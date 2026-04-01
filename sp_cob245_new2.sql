-- Procedimiento que Genera la Morosidad para un Documento hasta 180 dias
-- 
-- Creado    : 18/06/2010 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob245_new;

create procedure "informix".sp_cob245_new(
a_compania     char(3), 
a_sucursal     char(3), 
a_no_documento char(20),
a_periodo      char(7),
a_fecha        date     
) returning	dec(16,2),	-- por vencer
			dec(16,2),	-- exigible
			dec(16,2),	-- corriente
			dec(16,2),	-- 30 dias
			dec(16,2),	-- 60 dias
			dec(16,2),	-- 90 dias
			dec(16,2),	-- 120 dias
			dec(16,2),	-- 150 dias
			dec(16,2),	-- 180 dias
			dec(16,2);	-- saldo

define x_no_documento			char(20);
define _fecha_char				char(10);
define _no_factura				char(10);
define _no_requis         		char(10);
define _no_poliza				char(10);
define _periodo_cheque			char(7);
define _no_endoso				char(5);
define _cod_perpago				char(3);
define _cod_ramo				char(3);
define _tipo_periodo			char(1);
define _monto_devolucion		dec(16,2);
define v_prima_orig				dec(16,2);
define v_por_vencer				dec(16,2);
define v_exigible         		dec(16,2);
define v_corriente        		dec(16,2);
define _prima_bruta				dec(16,2);
define _monto_recibo			dec(16,2);
define _monto_cheque			dec(16,2);
define _monto_primero			dec(16,2);
define _monto_resto				dec(16,2);
define v_monto_180        		dec(16,2);
define v_monto_150        		dec(16,2);
define v_monto_120        		dec(16,2);
define v_monto_90         		dec(16,2);
define v_monto_60         		dec(16,2);
define v_monto_30         		dec(16,2);
define v_saldo            		dec(16,2);
define _monto             		dec(16,2);
define _mes_control				smallint;
define _mes_perpago				smallint;
define _no_pagos          		smallint;
define _cnt_dias				smallint;
define _dias_vig				smallint;
define _pagado            		smallint;
define _dias					integer;
define _ciclo					integer;
define _fecha_primer_pago_pol	date;
define _vigencia_inic_end		date;
define _fecha_primer_pago		date;     
define _fecha_impresion			date;
define _fecha_ult_letra			date;
define _vigencia_final			date;
define _fecha_emision			date;     
define _fecha_anulado			date;
define _vigencia_inic			date;
define _fecha_letra				date;

--SET DEBUG FILE TO "sp_cob245.trc";
--TRACE ON ;

set isolation to dirty read;

let v_prima_orig  = 0;
let v_saldo       = 0;
let v_por_vencer  = 0;    
let v_exigible    = 0;    
let v_corriente   = 0;   
let v_monto_30    = 0;    
let v_monto_60    = 0;    
let v_monto_90    = 0;
let v_monto_120   = 0;
let v_monto_150   = 0;
let v_monto_180   = 0;

let x_no_documento = a_no_documento;

let _prima_bruta  = 0;

-- facturas

let _prima_bruta  = 0;
let _monto        = 0;

foreach
 select prima_bruta
   into _monto
   from endedmae
  where no_documento   = a_no_documento	-- facturas de la poliza
    and actualizado    = 1			    -- factura este actualizada
	and periodo        <= a_periodo	    -- no incluye periodos futuros
	and activa         = 1
		let _prima_bruta = _prima_bruta + _monto;
end foreach

if _prima_bruta is null then
	let _prima_bruta = 0;
end if

let v_prima_orig = _prima_bruta;

-- Recibos

LET _monto_recibo = 0;
LET _monto        = 0;

FOREACH
 SELECT monto
   INTO _monto
   FROM cobredet
  WHERE doc_remesa   = a_no_documento	-- Recibos de la Poliza
    AND actualizado  = 1			    -- Recibo este actualizado
    AND tipo_mov     IN ('P', 'N', 'X')		-- Pago de Prima(P) y Notas de Credito(N)
	AND periodo     <= a_periodo	    -- No Incluye Periodos Futuros
		LET _monto_recibo = _monto_recibo + _monto;
END FOREACH

IF _monto_recibo IS NULL THEN
	LET _monto_recibo = 0;
END IF
 
-- Cheques de Devolucion de Primas

LET _monto_devolucion = 0;

FOREACH
 SELECT monto,
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
				IF _fecha_anulado <= a_fecha  THEN
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

LET _monto_recibo 	= _monto_recibo + _monto_devolucion;
LET _prima_bruta  	= _prima_bruta  - _monto_recibo;
LET v_saldo       		= _prima_bruta;    

IF v_saldo = 0 THEN
	
	RETURN  v_por_vencer,    
			v_exigible,      
			v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_monto_120,
			v_monto_150,
			v_monto_180,
			v_saldo;   
			
END IF

-- Inicio del Proceso de Determinar la Morosidad de las Facturas

foreach
	select prima_bruta,
		   fecha_primer_pago,
		   no_pagos,
		   cod_perpago,
		   no_factura,
		   fecha_emision,
		   no_poliza,
		   no_endoso,
		   vigencia_inic
	  into _prima_bruta,
		   _fecha_primer_pago,
		   _no_pagos,
		   _cod_perpago,
		   _no_factura,
		   _fecha_emision,
		   _no_poliza,
		   _no_endoso,
		   _vigencia_inic_end
	  from endedmae
	 where no_documento   = a_no_documento -- facturas de la poliza
	   and actualizado    = 1			 	-- factura este actualizada
	   and periodo       <= a_periodo	 	-- no incluye periodos futuros
	   and prima_bruta    > 0           	-- procesa la facturas de aumento de prima
	   and activa         = 1

	select meses,
		   tipo_periodo	
	  into _mes_perpago,
		   _tipo_periodo	
	  from cobperpa
	 where cod_perpago = _cod_perpago;
	
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

	{if _fecha_primer_pago >= _fecha_emision then
		let _fecha_letra       = _fecha_primer_pago;
	else
		let _fecha_letra       = _fecha_emision;
		let _fecha_primer_pago = _fecha_emision;
	end if}

	if _no_endoso = '00000' then
		let _fecha_primer_pago = _fecha_primer_pago_pol;
	else
		let _fecha_primer_pago = _vigencia_inic_end;
	end if

	-- Selecciona los periodos de pago
	let _fecha_letra   = _fecha_primer_pago;

	if _cod_ramo = '018' then
	else
		if _cod_perpago = '006' then
		else
			if day(_fecha_primer_pago_pol) = 31 then
				let _fecha_primer_pago_pol = _fecha_primer_pago_pol - 1 units day;
			end if

			if month(_fecha_primer_pago_pol) + (_no_pagos) - 12 in (2,-10) and day(_fecha_primer_pago_pol) > 28 then
				let _fecha_primer_pago_pol = mdy(month(_fecha_primer_pago_pol),28,year(_fecha_primer_pago_pol));
			end if

			let _fecha_ult_letra = _fecha_primer_pago_pol + (6) units month;
			-- Ajusta la Primera Letra por si se pierden centavos al momento de 
			-- hacer la division entre el numero de pagos

			if _cod_perpago = '001' then
				let _cnt_dias = 15;
			elif _cod_perpago = '002' then
				let _cnt_dias = 30;
			elif _cod_perpago = '003' then
				let _cnt_dias = 60;
			elif _cod_perpago = '004' then
				let _cnt_dias = 90;
			elif _cod_perpago in ('005','009') then
				let _cnt_dias = 120;
			elif _cod_perpago = '007' then
				let _cnt_dias = 180;
			elif _cod_perpago = '008' then
				let _cnt_dias = 365;
			end if

			begin
				on exception in(-1214)
					let _dias_vig = _fecha_ult_letra - _vigencia_inic;
				end exception

				let _dias_vig = _fecha_ult_letra - _fecha_letra;
			end
			
			if _dias_vig <= 0 or _dias_vig < _cnt_dias then
				let _no_pagos = 1;
			else
				let _no_pagos = trunc(_dias_vig/_cnt_dias);
				let _no_pagos = 2;
			end if
		end if
	end if
	-- FIN Cambio de Distribución de Morosidad por Facturas en Positivo
	
	-- Ajusta la Primera Letra por si se pierden centavos al momento de 
	-- hacer la division entre el numero de pagos

	LET _monto_resto   = _prima_bruta / _no_pagos;
	LET _monto_primero = _monto_resto + (_prima_bruta - (_monto_resto * _no_pagos));

	-- Inicia el ciclo para determinar la morosidad de cada factura

	FOR _ciclo = 1 TO _no_pagos
		
		LET _dias = a_fecha - _fecha_letra;

		IF _ciclo = 1 THEN
			LET _prima_bruta = _monto_primero;
		ELSE
			LET _prima_bruta = _monto_resto;
		END IF

		IF _dias < 0 THEN
			LET v_por_vencer = v_por_vencer + _prima_bruta;
		ELIF _dias >= 0 AND _dias <= 30 THEN
			LET v_corriente = v_corriente   + _prima_bruta;
		ELIF _dias > 30 AND _dias <= 60 THEN
			LET v_monto_30 = v_monto_30     + _prima_bruta;
		ELIF _dias > 60 AND _dias <= 90 THEN
			LET v_monto_60 = v_monto_60     + _prima_bruta;
		ELIF _dias > 90 AND _dias <= 120 THEN
			LET v_monto_90 = v_monto_90     + _prima_bruta;
		ELIF _dias > 120 AND _dias <= 150 THEN
			LET v_monto_120 = v_monto_120   + _prima_bruta;
		ELIF _dias > 150 AND _dias <= 180 THEN
			LET v_monto_150 = v_monto_150   + _prima_bruta;
		ELSE
			LET v_monto_180 = v_monto_180   + _prima_bruta;
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

LET _prima_bruta  = 0;
LET _monto        = 0;

FOREACH
 SELECT	prima_bruta
   INTO	_monto
   FROM	endedmae
  WHERE	no_documento   = a_no_documento -- Facturas de la Poliza
    AND actualizado    = 1			 	-- Factura este Actualizada
	AND periodo        <= a_periodo	 	-- No Incluye Periodos Futuros
	AND prima_bruta    < 0          	-- Procesa la Facturas de Disminucion de Prima
	AND activa         = 1
		LET _prima_bruta = _prima_bruta + _monto;
END FOREACH

IF _prima_bruta IS NULL THEN
	LET _prima_bruta = 0;
END IF

LET _prima_bruta  = _prima_bruta * -1;
LET _monto_recibo = _prima_bruta + _monto_recibo;

-- Realiza la Aplicacion de los Recibos y Facturas Negativas a los
-- Montos Mas Viejos de las Facturas

while _monto_recibo != 0 

	if v_monto_180 > 0 then
		
		if v_monto_180 > _monto_recibo then
		    let v_monto_180   = v_monto_180 - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_monto_180;
		    let v_monto_180   = 0;
		end if

	elif v_monto_150 > 0 then
		
		if v_monto_150 > _monto_recibo then
		    let v_monto_150   = v_monto_150 - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_monto_150;
		    let v_monto_150   = 0;
		end if

	elif v_monto_120 > 0 then
		
		if v_monto_120 > _monto_recibo then
		    let v_monto_120   = v_monto_120 - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_monto_120;
		    let v_monto_120   = 0;
		end if

	elif v_monto_90 > 0 then
		
		if v_monto_90 > _monto_recibo then
		    let v_monto_90    = v_monto_90 - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_monto_90;
		    let v_monto_90    = 0;
		end if

    elif v_monto_60 > 0 then

		if v_monto_60 > _monto_recibo then
		    let v_monto_60    = v_monto_60 - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_monto_60;
		    let v_monto_60    = 0;
		end if

    elif v_monto_30 > 0 then

		if v_monto_30 > _monto_recibo then
		    let v_monto_30    = v_monto_30 - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_monto_30;
		    let v_monto_30    = 0;
		end if

    elif v_corriente > 0 then

		if v_corriente > _monto_recibo then
		    let v_corriente   = v_corriente - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_corriente;
		    let v_corriente   = 0;
		end if

    elif v_por_vencer > 0 then

		if v_por_vencer > _monto_recibo then
		    let v_por_vencer  = v_por_vencer - _monto_recibo;
		    let _monto_recibo = 0;
		else 
		    let _monto_recibo = _monto_recibo - v_por_vencer;
		    let v_por_vencer  = 0;
		end if

	else

		let v_corriente    = v_corriente - _monto_recibo;
		let _monto_recibo  = 0; 

    end if

end while

let v_exigible = v_corriente + v_monto_30 + v_monto_60 + v_monto_90 + v_monto_120 + v_monto_150 + v_monto_180;

return v_por_vencer,    
	   v_exigible,      
	   v_corriente,    
	   v_monto_30,      
	   v_monto_60,      
	   v_monto_90,
	   v_monto_120,
	   v_monto_150,
	   v_monto_180,
	   v_saldo;   
		
end procedure;
