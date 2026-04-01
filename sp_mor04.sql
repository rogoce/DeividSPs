-- Procedimiento que Genera la Morosidad para un Documento hasta 180 dias
-- 
-- Creado    : 18/06/2010 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_mor04;
create procedure sp_mor04(
a_compania		char(3), 
a_sucursal		char(3), 
a_no_documento	char(20),
a_periodo		char(7),
a_fecha			date)
returning	dec(16,2)	as por_vencer,
			dec(16,2)	as exigible,
			dec(16,2)	as corriente,
			dec(16,2)	as monto_30,  
			dec(16,2)	as monto_60,
			dec(16,2)	as monto_90,
			dec(16,2)	as monto_120,
			dec(16,2)	as monto_150,
			dec(16,2)	as monto_180, 
			dec(16,2)	as saldo;	  

define x_no_documento			char(20);
define _no_factura				char(10);
define _no_poliza				char(10);
define _no_requis				char(10);
define _fecha_char				char(10);
define _periodo_cheque			char(7);
define _no_endoso				char(5);
define _cod_perpago				char(3);
define _cod_ramo				char(3);
define _tipo_periodo			char(1);
define _monto_devolucion		dec(16,2);
define _monto_primero			dec(16,2);
define _monto_cheque			dec(16,2);
define _monto_recibo			dec(16,2);
define _monto_resto				dec(16,2);
define v_por_vencer				dec(16,2);
define _prima_bruta				dec(16,2);
define v_corriente				dec(16,2);
define v_monto_180				dec(16,2);
define v_monto_150				dec(16,2);
define v_monto_120				dec(16,2);
define v_monto_90				dec(16,2);
define v_monto_60				dec(16,2);
define v_monto_30				dec(16,2);
define v_exigible				dec(16,2);
define _cnt_dias				dec(16,2);
define v_saldo					dec(16,2);
define _monto					dec(16,2);
define _mes_perpago				smallint;
define _mes_control				smallint;
define _no_pagos				smallint;
define _pagado					smallint;
define _ciclo					smallint;
define _dias					integer;
define _fecha_primer_pago		date;     
define _fecha_emision			date;     
define _fecha_impresion			date;
define _fecha_anulado			date;
define _fecha_letra				date;
define _estatus_poliza			smallint;
define _dias_vig				smallint;
define _fecha_primer_pago_pol	date;
define _vigencia_inic_end		date;
define _fecha_ult_letra			date;
define _vigencia_final			date;
define _vigencia_inic			date;

--set debug file to 'sp_cob245a.trc';
--trace on ;

set isolation to dirty read;

let v_por_vencer = 0;    
let v_corriente = 0;   
let v_monto_180 = 0;
let v_monto_150 = 0;
let v_monto_120 = 0;
let v_monto_90 = 0;
let v_monto_60 = 0;    
let v_monto_30 = 0;    
let v_exigible = 0;    
let v_saldo = 0;

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
	   and activa         = 1
    --and periodo        <= a_periodo	                -- no incluye periodos futuros
	let _prima_bruta = _prima_bruta + _monto;
end foreach

if _prima_bruta is null then
	let _prima_bruta = 0;
end if

-- Recibos
let _monto_recibo = 0;
let _monto        = 0;

foreach
	select monto
	  into _monto
	  from cobredet
	 where doc_remesa   = a_no_documento	-- recibos de la poliza
	   and actualizado  = 1			    -- recibo este actualizado
	   and tipo_mov     in ('P', 'N', 'X')		-- pago de prima(p) y notas de credito(n)
	   and periodo     <= a_periodo	    -- no incluye periodos futuros
	let _monto_recibo = _monto_recibo + _monto;
end foreach

if _monto_recibo is null then
	let _monto_recibo = 0;
end if
 
-- Cheques de Devolucion de Primas

let _monto_devolucion = 0;

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
end foreach

-- Realiza la Verificacion de Montos
let _monto_recibo = _monto_recibo + _monto_devolucion;
let _prima_bruta = _prima_bruta  - _monto_recibo;
let v_saldo = _prima_bruta;  

if v_saldo = 0 then	
	return  v_por_vencer,    
			v_exigible,      
			v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_monto_120,
			v_monto_150,
			v_monto_180,
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
	 where no_documento = a_no_documento -- facturas de la poliza
	   and actualizado = 1			 	-- factura este actualizada
	   and periodo <= a_periodo	 		-- no incluye periodos futuros
	   and activa = 1

	if _prima_bruta = 0.00 then
		continue foreach;
	end if

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

	if _no_endoso = '00000' then
		let _fecha_primer_pago = _fecha_primer_pago_pol;
	else
		let _fecha_primer_pago = _vigencia_inic_end;
	end if
	
	if _estatus_poliza in (2,4) then
		let _no_pagos = 1;
		let _fecha_primer_pago = _fecha_primer_pago_pol;
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

	let _monto_resto   = _prima_bruta / _no_pagos;
	let _monto_primero = _monto_resto + (_prima_bruta - (_monto_resto * _no_pagos));

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
		elif _dias > 90 and _dias <= 120 then
			let v_monto_90 = v_monto_90     + _prima_bruta;
		elif _dias > 120 and _dias <= 150 then
			let v_monto_120 = v_monto_120   + _prima_bruta;
		elif _dias > 150 and _dias <= 180 then
			let v_monto_150 = v_monto_150   + _prima_bruta;
		else
			let v_monto_180 = v_monto_180   + _prima_bruta;
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
	end for
	
	return v_por_vencer,v_corriente,v_monto_30,v_monto_60,v_monto_90,v_monto_120,v_monto_150,v_monto_180,_prima_bruta;
end foreach
{
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
LET _monto_recibo = _prima_bruta + _monto_recibo;}

-- Acumular los montos negativos en la morosidad junto con los pagos para rebajar los montos morosos.
if v_monto_180 < 0 then

	let _monto_recibo = _monto_recibo + v_monto_180;
	let v_monto_180 = 0.00;
elif v_monto_150 < 0 then
	
	let _monto_recibo = _monto_recibo + v_monto_150;
	let v_monto_150 = 0.00;
elif v_monto_120 < 0 then
	
	let _monto_recibo = _monto_recibo + v_monto_120;
	let v_monto_120 = 0.00;
elif v_monto_90 < 0 then
	
	let _monto_recibo = _monto_recibo + v_monto_90;
	let v_monto_90 = 0.00;
elif v_monto_60 < 0 then

	let _monto_recibo = _monto_recibo + v_monto_60;
	let v_monto_60 = 0.00;
elif v_monto_30 < 0 then

	let _monto_recibo = _monto_recibo + v_monto_30;
	let v_monto_30 = 0.00;
elif v_corriente < 0 then

	let _monto_recibo = _monto_recibo + v_corriente;
	let v_corriente = 0.00;
elif v_por_vencer < 0 then

	let _monto_recibo = _monto_recibo + v_por_vencer;
	let v_por_vencer = 0.00;
end if

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
