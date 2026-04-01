-- Procedimiento que Genera la Morosidad para un Documento especial para salud
-- 
-- Creado    : 15/12/2009 - Autor: Armando Moreno
-- modificado: 15/12/2009 - Autor: Armando Moreno
-- 
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_cob33c;
create procedure "informix".sp_cob33c(
a_compania     char(3), 
a_sucursal     char(3), 
a_no_documento char(20),
a_periodo      char(7),
a_fecha        date)
returning	dec(16,2)	as por_vencer,
			dec(16,2)	as exigible,
			dec(16,2)	as corriente,
			dec(16,2)	as monto_30,
			dec(16,2)	as monto_60,
			dec(16,2)	as monto_90,
			dec(16,2)	as saldo;

define _fecha_char				char(10);
define _no_factura				char(10);
define _no_poliza				char(10);
define _no_requis				char(10);
define _periodo_cheque			char(7);
define _no_endoso				char(5);
define _cod_perpago				char(3);
define _cod_ramo				char(3);
define _tipo_periodo			char(1);
define _monto_devolucion		dec(16,2);
define _monto_primero			dec(16,2);
define _monto_cheque			dec(16,2);
define _monto_recibo			dec(16,2);
define v_prima_orig				dec(16,2);
define v_por_vencer				dec(16,2);
define _prima_bruta				dec(16,2);
define _monto_resto				dec(16,2);
define v_corriente				dec(16,2);
define v_exigible				dec(16,2);
define v_monto_30				dec(16,2);
define v_monto_60				dec(16,2);
define v_monto_90				dec(16,2);
define _cnt_dias				dec(16,2);
define v_saldo					dec(16,2);
define _monto					dec(16,2);
define _fecha_primer_pago_pol	date;
define _fecha_primer_pago		date;
define _vigencia_inic_end		date;
define _fecha_ult_letra			date;
define _fecha_impresion			date;
define _vigencia_final			date;
define _fecha_anulado			date;
define _fecha_emision			date;
define _vigencia_inic			date;
define _fecha_letra				date;
define _estatus_poliza			smallint;
define _mes_perpago				smallint;
define _mes_control				smallint;
define _no_pagos				smallint;
define _pagado					smallint;
define _dias_vig				smallint;
define _anio					smallint;
define _dia						smallint;
define _mes						smallint;
define _ciclo					integer;
define _dias					integer;

--set debug file to "sp_cob33.trc";
--trace on ;

set isolation to dirty read;

let _monto_devolucion = 0;
let _monto_recibo = 0;
let _prima_bruta = 0;
let v_prima_orig = 0;
let v_por_vencer = 0;    
let v_corriente = 0;   
let v_exigible = 0;    
let v_monto_30 = 0;    
let v_monto_60 = 0;    
let v_monto_90 = 0;
let v_saldo = 0;

-- Facturas

let _prima_bruta = 0;
let _monto = 0;


select sum(prima_bruta)
  into _prima_bruta
  from endedmae
 where no_documento   = a_no_documento	-- facturas de la poliza
   and actualizado    = 1			    -- factura este actualizada
   and activa         = 1;
   --and periodo        <= a_periodo	    -- no incluye periodos futuros
   --and fecha_emision <= a_fecha        -- hechas durante y antes de la fecha seleccionada

if _prima_bruta is null then
	let _prima_bruta = 0.00;
end if

let v_prima_orig = _prima_bruta;

-- recibos
select sum(monto)
  into _monto_recibo
  from cobredet
 where doc_remesa   = a_no_documento	-- recibos de la poliza
   and actualizado  = 1			    -- recibo este actualizado
   and tipo_mov     in ('P', 'N', 'X')		-- Pago de Prima(P) y Notas de Credito(N)
   and periodo     <= a_periodo;	    -- no incluye periodos futuros

if _monto_recibo is null then
	let _monto_recibo = 0.00;
end if

select sum(p.monto * -1)
  into _monto_devolucion
  from chqchpol p,chqchmae c
 where p.no_requis = c.no_requis
   and p.no_documento = a_no_documento
   and c.pagado = 1
   and fecha_impresion <= a_fecha
   and (fecha_anulado is null or fecha_anulado > a_fecha);

if _monto_devolucion is null then
	let _monto_devolucion = 0.00;
end if
{
-- Cheques de Devolucion de Primas
foreach
	select monto,
		   no_requis
	  into _monto_cheque,
		   _no_requis	
	  from chqchpol
	 where no_documento   = a_no_documento

	select pagado,
		   periodo,
		   fecha_impresion,
		   fecha_anulado
	  into _pagado,
	       _periodo_cheque,
		   _fecha_impresion,
		   _fecha_anulado
	  from chqchmae
	 where no_requis = _no_requis;

	if _pagado = 1 then
		if _fecha_impresion > a_fecha then
			let _monto_cheque = 0;
		else
			if _fecha_anulado is not null then
				if _fecha_anulado <= a_fecha  then
					let _monto_cheque = 0;
				end if
			end if
		end if				
	else
		let _monto_cheque = 0;
	end if	
	
	if _monto_cheque is null then
		let _monto_cheque = 0;
	end if		

	let _monto_devolucion = _monto_devolucion - _monto_cheque;
end foreach}

-- Realiza la Verificacion de Montos
let _monto_recibo = _monto_recibo + _monto_devolucion;
let _prima_bruta  = _prima_bruta  - _monto_recibo;
let v_saldo       = _prima_bruta;    

if v_saldo = 0 then
	return  v_por_vencer,    
			v_exigible,      
			v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_saldo;
end if

-- Inicio del Proceso de Determinar la Morosidad de las Facturas

let _no_poliza = sp_sis21(a_no_documento);

select estatus_poliza
  into _estatus_poliza
  from emipomae
 where no_poliza = _no_poliza;

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
	   --and periodo       <= a_periodo	 	-- no incluye periodos futuros
	   and prima_bruta    <> 0           	-- procesa la facturas de aumento de prima
	   and activa         = 1

	{if _fecha_primer_pago >= _fecha_emision then
		let _fecha_letra       = _fecha_primer_pago;
	else
		let _fecha_letra       = _fecha_emision;
		let _fecha_primer_pago = _fecha_emision;
	end if}

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

	{if _no_endoso = '00000' then
		let _fecha_primer_pago = _fecha_primer_pago_pol;
	else
		let _fecha_primer_pago = _vigencia_inic_end;
	end if}

	if _estatus_poliza in (2,4) then -- or _cod_endomov = '019' then --Si esta cancelada o anulada se debe, todas las facturas se hacen efectivas desde la vigencia inicial de la póliza
		let _no_pagos = 1;
		let _fecha_primer_pago = _fecha_primer_pago_pol;
	else
		if _no_endoso = '00000' then --El endoso 0 debe llevar la fecha de primer pago de emisión
			let _fecha_primer_pago = _fecha_primer_pago_pol;
		else
			let _dia = day(_fecha_primer_pago_pol);
			let _mes = month(_vigencia_inic_end);
			let _anio = year(_vigencia_inic_end);

			if _dia < day(_vigencia_inic_end) then --Si el día de la vigencia inicial del endoso es mayor que el de la fecha de primer pago, la primera letra se pasa al siguiente mes.
				if _mes = 12 then
					let _mes = 1;
					let _anio = _anio + 1;
				else
					let _mes = _mes + 1;
				end if
			end if

			if _mes = 2 and _dia > 28 then	--Si es Febrero se coloca 28
				let _dia = 28;
			elif _mes in (4,6,9,11) and _dia > 30 then --Si el mes solo tiene 30 días
				let _dia = 30;
			end if

			let _fecha_primer_pago = mdy(_mes ,_dia,_anio);
		end if
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
			ELIF _dias > 31 AND _dias <= 60 THEN
			    LET v_monto_30 = v_monto_30     + _prima_bruta;
			ELIF _dias > 60 AND _dias <= 90 THEN
	            LET v_monto_60 = v_monto_60     + _prima_bruta;
			ELSE
		        LET v_monto_90 = v_monto_90     + _prima_bruta;
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
LET _prima_bruta  = 0;
LET _monto        = 0;

FOREACH
 SELECT	prima_bruta
   INTO	_monto
   FROM	endedmae
  WHERE	no_documento   = a_no_documento -- Facturas de la Poliza
    AND actualizado    = 1			 	-- Factura este Actualizada
	--AND periodo        <= a_periodo	 	-- No Incluye Periodos Futuros
	AND prima_bruta    < 0          	-- Procesa la Facturas de Disminucion de Prima
	AND activa         = 1
		LET _prima_bruta = _prima_bruta + _monto;
END FOREACH

IF _prima_bruta IS NULL THEN
	LET _prima_bruta = 0;
END IF

LET _prima_bruta  = _prima_bruta * -1;
LET _monto_recibo = _prima_bruta + _monto_recibo;}

-- Acumular los montos negativos en la morosidad junto con los pagos para rebajar los montos morosos.
if v_monto_90 < 0.00 then
	
	let _monto_recibo = _monto_recibo - v_monto_90;
	let v_monto_90 = 0.00;
end if
if v_monto_60 < 0.00 then

	let _monto_recibo = _monto_recibo - v_monto_60;
	let v_monto_60 = 0.00;
end if
if v_monto_30 < 0.00 then

	let _monto_recibo = _monto_recibo - v_monto_30;
	let v_monto_30 = 0.00;
end if
if v_corriente < 0.00 then

	let _monto_recibo = _monto_recibo - v_corriente;
	let v_corriente = 0.00;
end if
if v_por_vencer < 0.00 then

	let _monto_recibo = _monto_recibo - v_por_vencer;
	let v_por_vencer = 0.00;
end if

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

RETURN v_por_vencer,    
	   v_exigible,      
	   v_corriente,    
	   v_monto_30,      
	   v_monto_60,      
	   v_monto_90,
	   v_saldo;   
		
END PROCEDURE;
