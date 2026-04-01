
drop procedure sp_cob33prueba;
CREATE PROCEDURE sp_cob33prueba(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_periodo      CHAR(7),
a_fecha        DATE,
a_no_factura char(10)     
)
RETURNING	DEC(16,2)	as prima_bruta,
			DEC(16,2)	as por_vencer,	-- Por Vencer
			DEC(16,2)	as corriente,	-- Corriente
			DEC(16,2)	as monto_30,	-- 30 Dias
			DEC(16,2)	as monto_60,	-- 60 Dias
			DEC(16,2)	as monto_90,	-- 90 Dias
			date        as fecha,
			smallint    as no_pagos,
			integer     as dias,
			date        as afecha,
			date        as fecha_letra,
			char(10)    as factura;
DEFINE v_prima_orig       DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);
DEFINE _prima_bruta       DEC(16,2);
DEFINE _monto_recibo      DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_devolucion  DEC(16,2);
DEFINE v_saldo_control  DEC(16,2);
DEFINE _monto             DEC(16,2);
DEFINE _fecha_primer_pago DATE;     
DEFINE _fecha_emision     DATE;     
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
DEFINE _no_endoso         CHAR(5);
DEFINE x_no_documento	  CHAR(20);

define _no_poliza				char(10);
define _cod_endomov				char(3);
define _cod_ramo				char(3);
define _cnt_dias				dec(16,2);
define _anio					smallint;
define _dia						smallint;
define _mes						smallint;
define _estatus_poliza			smallint;
define _dias_vig				smallint;
define _fecha_primer_pago_pol	date;
define _vigencia_inic_end		date;
define _fecha_ult_letra			date;
define _vigencia_final			date;
define _vigencia_inic			date;

SET ISOLATION TO DIRTY READ;

LET v_prima_orig  = 0;
LET v_saldo       = 0;
LET v_por_vencer  = 0;    
LET v_exigible    = 0;    
LET v_corriente   = 0;   
LET v_monto_30    = 0;    
LET v_monto_60    = 0;    
LET v_monto_90    = 0;
LET x_no_documento = a_no_documento;

LET _prima_bruta  = 0;

-- Facturas

LET _prima_bruta  = 0;
LET _monto        = 0;

foreach
	select prima_bruta
	  into _monto
	  from endedmae
	 where no_documento   = a_no_documento	    -- facturas de la poliza
	   and actualizado    = 1			        -- factura este actualizada
	   and activa         = 1

	let _prima_bruta = _prima_bruta + _monto;
end foreach

if _prima_bruta is null then
	let _prima_bruta = 0;
end if

LET v_prima_orig = _prima_bruta;

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

LET _monto_recibo = _monto_recibo + _monto_devolucion;
LET _prima_bruta  = _prima_bruta  - _monto_recibo;
LET v_saldo       = _prima_bruta;

IF v_saldo = 0 THEN
	return _prima_bruta,v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_saldo,
			"",0,0,'','','';  
END IF
-- Inicio del Proceso de Determinar la Morosidad de las Facturas
let _no_poliza = sp_sis21(a_no_documento);

select estatus_poliza
  into _estatus_poliza
  from emipomae
 where no_poliza = _no_poliza;

foreach
	select prima_bruta,
		   fecha_primer_pago,
		   cod_endomov,
		   no_pagos,
		   cod_perpago,
		   no_factura,
		   fecha_emision,
		   no_poliza,
		   no_endoso,
		   vigencia_inic
	  into _prima_bruta,
		   _fecha_primer_pago,
		   _cod_endomov,
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
	   and activa         = 1

	if _prima_bruta = 0.00 then
		continue foreach;
	end if

	select meses,
		   tipo_periodo	
	  into _mes_perpago,
		   _tipo_periodo	
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	-- Cambio de DistribuciÃ³n de Morosidad por Facturas en Positivo
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
	
	if _estatus_poliza in (2,4) then -- or _cod_endomov = '019' then --Si esta cancelada o anulada se debe, todas las facturas se hacen efectivas desde la vigencia inicial de la pÃ³liza
		let _no_pagos = 1;
		let _fecha_primer_pago = _fecha_primer_pago_pol;
	else
		if _no_endoso = '00000' then --El endoso 0 debe llevar la fecha de primer pago de emisiÃ³n
			let _fecha_primer_pago = _fecha_primer_pago_pol;
		else
			let _dia = day(_fecha_primer_pago_pol);
			let _mes = month(_vigencia_inic_end);
			let _anio = year(_vigencia_inic_end);

			if _dia < day(_vigencia_inic_end) then --Si el dÃ­a de la vigencia inicial del endoso es mayor que el de la fecha de primer pago, la primera letra se pasa al siguiente mes.
				if _mes = 12 then
					let _mes = 1;
					let _anio = _anio + 1;
				else
					let _mes = _mes + 1;
				end if
			end if

			if _mes = 2 and _dia > 28 then	--Si es Febrero se coloca 28
				let _dia = 28;
			elif _mes in (4,6,9,11) and _dia > 30 then --Si el mes solo tiene 30 dÃ­as
				let _dia = 30;
			end if

			let _fecha_primer_pago = mdy(_mes ,_dia,_anio);
		end if
	end if

	-- Selecciona los periodos de pago
	let _fecha_letra = _fecha_primer_pago;
	let _cnt_dias = _mes_perpago;

	if _cod_ramo = '018' then
	else
		if _cod_perpago = '006' then
		else
			if day(_fecha_primer_pago_pol) = 31 then
				let _fecha_primer_pago_pol = _fecha_primer_pago_pol + 1 units day;
			end if

			if _cod_perpago = '001' then
				let _cnt_dias = 0.5;
			elif _cod_perpago = '008' then
				let _cnt_dias = 1;
			end if
			
			if _cod_perpago in ('001','002','008') then
				if month(_fecha_primer_pago_pol) + ((_no_pagos ) * _cnt_dias)  - 12 in (2,-10) and day(_fecha_primer_pago_pol) > 28 then
					let _fecha_primer_pago_pol = mdy(month(_fecha_primer_pago_pol),28,year(_fecha_primer_pago_pol));
					let _fecha_ult_letra = _fecha_primer_pago_pol + ((_no_pagos ) * _cnt_dias) units month;
					let _fecha_ult_letra = mdy(3,1,year(_fecha_ult_letra));
				else
					let _fecha_ult_letra = _fecha_primer_pago_pol + ((_no_pagos ) * _cnt_dias) units month;
				end if
				
				let _no_pagos = MONTHS_BETWEEN(_fecha_ult_letra,_fecha_letra)/_cnt_dias;	
			else
				if month(_fecha_primer_pago_pol) + ((_no_pagos - 1 ) * _cnt_dias) - 12 in (2,-10) and day(_fecha_primer_pago_pol) > 28 then
					let _fecha_primer_pago_pol = mdy(month(_fecha_primer_pago_pol),28,year(_fecha_primer_pago_pol));
					let _fecha_ult_letra = _fecha_primer_pago_pol + ((_no_pagos ) * _cnt_dias) units month;
					let _fecha_ult_letra = mdy(3,1,year(_fecha_ult_letra));
				else
					let _fecha_ult_letra = _fecha_primer_pago_pol + ((_no_pagos - 1 ) * _cnt_dias) units month;
				end if

				let _no_pagos = MONTHS_BETWEEN(_fecha_ult_letra,_fecha_letra)/_cnt_dias + 1;
			end if

			if _no_pagos <= 0 then
				let _no_pagos = 1;
			end if
			
			let _no_pagos = round(_no_pagos,1);	
		end if
	end if
	
	-- Ajusta la Primera Letra por si se pierden centavos al momento de 
	-- hacer la division entre el numero de pagos

	let _monto_resto   = _prima_bruta / _no_pagos;
	let _monto_primero = _monto_resto + (_prima_bruta - (_monto_resto * _no_pagos));
	
	--return _monto_recibo,v_por_vencer,v_corriente,v_monto_30,v_monto_60,v_monto_90,_fecha_primer_pago,_no_pagos,0,a_fecha,_fecha_letra,'' with resume;
	-- Inicia el ciclo para determinar la morosidad de cada factura
	for _ciclo = 1 to _no_pagos
		
		let _dias = a_fecha - _fecha_letra;

		if _ciclo = 1 then
			let _prima_bruta = _monto_primero;
		else
			let _prima_bruta = _monto_resto;
		end if

		if _dias < 0 then
			let v_por_vencer = v_por_vencer + _prima_bruta;
		elif _dias >= 0 and _dias <= 30 then
			let v_corriente = v_corriente   + _prima_bruta;
		elif _dias > 30 and _dias <= 60 then
			let v_monto_30 = v_monto_30     + _prima_bruta;
		elif _dias > 60 and _dias <= 90 then
			let v_monto_60 = v_monto_60     + _prima_bruta;
		else
			let v_monto_90 = v_monto_90     + _prima_bruta;
		end if

		if _tipo_periodo = 'M' then -- periodo mensual				

			let _mes_control = month(_fecha_letra) + _mes_perpago;

			if _mes_control > 12 then
				let _mes_control = _mes_control - 12;
			end if

			if _mes_control = 2 then -- verificaciones para febrero
				if day(_fecha_primer_pago) = 29 or
				   day(_fecha_primer_pago) = 30 or
				   day(_fecha_primer_pago) = 31 then
						let _fecha_char      = _fecha_primer_pago;
						let _fecha_char[1,2] = '28';	-- formato dd/mm/yyyy
						let _fecha_letra     = _fecha_char;
						let _fecha_letra     = _fecha_letra + (_ciclo * _mes_perpago) units month;
				else
						let _fecha_letra     = _fecha_primer_pago + (_ciclo * _mes_perpago) units month;
				end if
			elif _mes_control = 4  or	-- verificaciones para abril
				 _mes_control = 6  or	-- verificaciones para junio
				 _mes_control = 9  or	-- verificaciones para septiembre
				 _mes_control = 11 then	-- verificaciones para noviembre
					if day(_fecha_primer_pago) = 31 then
							let _fecha_char      = _fecha_primer_pago;
							let _fecha_char[1,2] = '30';	-- formato dd/mm/yyyy
							let _fecha_letra     = _fecha_char;
							let _fecha_letra     = _fecha_letra + (_ciclo * _mes_perpago) units month;
					else
							let _fecha_letra     = _fecha_primer_pago + (_ciclo * _mes_perpago) units month;
					end if
			else
				let _fecha_letra = _fecha_primer_pago + (_ciclo * _mes_perpago) units month;
			end if
		else						-- periodo quincenal
			let _fecha_letra = _fecha_primer_pago + (_ciclo * 15) units day;
		end if
		return _prima_bruta,v_por_vencer,v_corriente,v_monto_30,v_monto_60,v_monto_90,_fecha_primer_pago,_no_pagos,_dias,a_fecha,_fecha_letra,_no_factura with resume;
	end for
	
end foreach

let v_por_vencer = v_por_vencer;
let v_corriente = v_corriente;
let v_monto_30 = v_monto_30;
let v_monto_60 = v_monto_60;
let v_monto_90 = v_monto_90;

--return _monto_recibo,v_por_vencer,v_corriente,v_monto_30,v_monto_60,v_monto_90,_fecha_primer_pago,_no_pagos,_dias,a_fecha,_fecha_letra,'';

while _monto_recibo != 0
	if v_monto_90 > 0 then		
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

let v_exigible = v_corriente + v_monto_30 + v_monto_60 + v_monto_90;

return _monto_recibo,v_por_vencer,    
	   v_corriente,    
	   v_monto_30,      
	   v_monto_60,      
	   v_monto_90,
	   _fecha_primer_pago,_no_pagos,_dias,'01/01/1900','01/01/1900','';
end procedure