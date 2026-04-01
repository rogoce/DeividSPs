-- Procedimiento que Genera la Morosidad para un Documento hasta 180 dias
-- Creado    : 20/07/2017 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob398;
create procedure sp_cob398(
a_no_documento		char(20),
a_periodo			char(7),
a_fecha				date,
a_control_periodo	smallint default 0,
a_control_fecha		smallint default 0)
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

define _no_factura				char(10);
define _no_poliza				char(10);
define _no_requis				char(10);
define _fecha_char				char(10);
define _periodo_cheque			char(7);
define _periodo					char(7);
define _no_endoso				char(5);
define _cod_perpago				char(3);
define _cod_ramo				char(3);
define _tipo_periodo			char(1);
define _monto_devolucion		dec(16,2);
define _monto_primero			dec(16,2);
define _monto_cheque			dec(16,2);
define _monto_recibo			dec(16,2);
define _monto_resto				dec(16,2);
define _prima_bruta				dec(16,2);
define _por_vencer				dec(16,2);
define _corriente				dec(16,2);
define _monto_180				dec(16,2);
define _monto_150				dec(16,2);
define _monto_120				dec(16,2);
define _monto_90				dec(16,2);
define _monto_60				dec(16,2);
define _monto_30				dec(16,2);
define _exigible				dec(16,2);
define _cnt_dias				dec(16,2);
define _saldo					dec(16,2);
define _monto					dec(16,2);
define _estatus_poliza			smallint;
define _mes_perpago				smallint;
define _mes_control				smallint;
define _no_pagos				smallint;
define _dias_vig				smallint;
define _pagado					smallint;
define _ciclo					smallint;
define _anio					smallint;
define _mes						smallint;
define _dia						smallint;
define _dias					integer;
define _fecha_primer_pago		date;     
define _fecha_emision			date;     
define _fecha_impresion			date;
define _fecha_anulado			date;
define _fecha_letra				date;
define _fecha_primer_pago_pol	date;
define _vigencia_inic_end		date;
define _fecha_ult_letra			date;
define _vigencia_final			date;
define _vigencia_inic			date;

--set debug file to 'sp_cob398.trc';
--trace on ;

set isolation to dirty read;

let _monto_recibo = 0.00;
let _prima_bruta = 0.00;
let _prima_bruta = 0.00;
let _por_vencer = 0.00;    
let _corriente = 0.00;   
let _monto_180 = 0.00;
let _monto_150 = 0.00;
let _monto_120 = 0.00;
let _monto_90 = 0.00;
let _monto_60 = 0.00;    
let _monto_30 = 0.00;    
let _exigible = 0.00;    
let _saldo = 0.00;

-- facturas
let _fecha_emision = null;
let _periodo = null;
let _monto = 0.00;

foreach
	select periodo,
		   fecha_emision,
		   prima_bruta
	  into _periodo,
		   _fecha_emision,
		   _monto
	  from endedmae
	 where no_documento = a_no_documento	-- facturas de la poliza
	   and actualizado = 1			    -- factura este actualizada
	   and activa = 1

	if a_control_periodo = 1 and _periodo > a_periodo then
		continue foreach;
	end if
	
	if a_control_fecha = 1 and _fecha_emision > a_fecha then
		continue foreach;
	end if

	let _prima_bruta = _prima_bruta + _monto;
end foreach

if _prima_bruta is null then
	let _prima_bruta = 0.00;
end if

-- Recibos
let _fecha_emision = null;
let _periodo = null;
let _monto = 0.00;

foreach
	select periodo,
		   fecha,
		   monto
	  into _periodo,
		   _fecha_emision,
		   _monto
	  from cobredet
	 where doc_remesa = a_no_documento	-- recibos de la poliza
	   and actualizado = 1			    -- recibo este actualizado
	   and tipo_mov in ('P', 'N', 'X')		-- pago de prima(p) y notas de credito(n)
	   and periodo <= a_periodo	    -- no incluye periodos futuros

	if a_control_periodo = 1 and _periodo > a_periodo then
		continue foreach;
	end if
	
	if a_control_fecha = 1 and _fecha_emision > a_fecha then
		continue foreach;
	end if

	let _monto_recibo = _monto_recibo + _monto;
end foreach

if _monto_recibo is null then
	let _monto_recibo = 0.00;
end if
 
-- Cheques de Devolucion de Primas
let _monto_devolucion = 0.00;

foreach
	select no_requis,
		   monto
	  into _no_requis,
		   _monto_cheque
	  from chqchpol
	 where no_documento = a_no_documento

	select pagado,
		   fecha_impresion,
		   fecha_anulado
	  into _pagado,
		   _fecha_impresion,
		   _fecha_anulado
	  from chqchmae
	 where no_requis = _no_requis;

	if _pagado = 1 then
		if _fecha_impresion > a_fecha then
			let _monto_cheque = 0.00;
		else
			if _fecha_anulado is not null then
				if _fecha_anulado <= a_fecha  then
					let _monto_cheque = 0.00;
				end if
			end if
		end if				
	else
		let _monto_cheque = 0.00;
	end if	
	
	if _monto_cheque is null then
		let _monto_cheque = 0.00;
	end if		

	let _monto_devolucion = _monto_devolucion - _monto_cheque;
end foreach

-- Realiza la Verificacion de Montos
let _monto_recibo = _monto_recibo + _monto_devolucion;
let _prima_bruta = _prima_bruta  - _monto_recibo;
let _saldo = _prima_bruta;  

if _saldo = 0.00 then	
	return  _por_vencer,    
			_exigible,      
			_corriente,    
			_monto_30,      
			_monto_60,      
			_monto_90,
			_monto_120,
			_monto_150,
			_monto_180,
			_saldo;
end if

-- Inicio del Proceso de Determinar la Morosidad de las Facturas

let _no_poliza = sp_sis21(a_no_documento);

select cod_ramo,
	   estatus_poliza
  into _cod_ramo,
	   _estatus_poliza
  from emipomae
 where no_poliza = _no_poliza;

foreach
	select prima_bruta,
		   fecha_emision,
		   no_pagos,
		   cod_perpago,
		   no_factura,
		   no_poliza,
		   no_endoso,
		   vigencia_inic
	  into _prima_bruta,
		   _fecha_emision,
		   _no_pagos,
		   _cod_perpago,
		   _no_factura,
		   _no_poliza,
		   _no_endoso,
		   _vigencia_inic_end
	  from endedmae
	 where no_documento = a_no_documento -- facturas de la poliza
	   and actualizado = 1			 	-- factura este actualizada
	   and activa = 1

	if _prima_bruta = 0.00 then
		continue foreach;
	end if

	if a_control_periodo = 1 and _periodo > a_periodo then	--No Incluye Periodos Futuros
		continue foreach;
	end if
	
	if a_control_fecha = 1 and _fecha_emision > a_fecha then --No Incluye Fechas Futuras
		continue foreach;
	end if

	select meses,
		   tipo_periodo	
	  into _mes_perpago,
		   _tipo_periodo	
	  from cobperpa
	 where cod_perpago = _cod_perpago;
	
	-- Cambio de Distribución de Morosidad por Facturas en Positivo
	select fecha_primer_pago,
		   vigencia_inic,
		   vigencia_final
	  into _fecha_primer_pago_pol,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fecha_primer_pago_pol not between _vigencia_inic and _vigencia_final then -- Si la fecha de Primer Pago esta fuera de la vigencia, se coloca la vigencia inicial de la póliza
		let _fecha_primer_pago_pol = _vigencia_inic;
	end if

	if _estatus_poliza in (2,4) then --Si esta cancelada o anulada se debe, todas las facturas se hacen efectivas desde la vigencia inicial de la póliza
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

	if _cod_ramo = '018' then --Para Salud no se calcula los pagos que quedan hasta el último pago pactado.
	else
		if _cod_perpago = '006' then --Se excluye el periodo de pagos Inmediato
		else
			if day(_fecha_primer_pago_pol) = 31 then
				let _fecha_primer_pago_pol = _fecha_primer_pago_pol - 1 units day;
			end if

			if _cod_perpago = '001' then
				let _cnt_dias = 0.5;
			elif _cod_perpago = '008' then
				let _cnt_dias = 1;
			end if
			
			if _cod_perpago in ('001','002','008') then --Cada 15 días, Cada 30 días y Anual
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
	
	-- Ajusta la Primera Letra por si se pierden centavos al momento de hacer la division entre el numero de pagos
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
			let _por_vencer = _por_vencer + _prima_bruta;
		elif _dias >= 0 and _dias <= 30 then
			let _corriente = _corriente   + _prima_bruta;
		elif _dias > 30 and _dias <= 60 then
			let _monto_30 = _monto_30     + _prima_bruta;
		elif _dias > 60 and _dias <= 90 then
			let _monto_60 = _monto_60     + _prima_bruta;
		elif _dias > 90 and _dias <= 120 then
			let _monto_90 = _monto_90     + _prima_bruta;
		elif _dias > 120 and _dias <= 150 then
			let _monto_120 = _monto_120   + _prima_bruta;
		elif _dias > 150 and _dias <= 180 then
			let _monto_150 = _monto_150   + _prima_bruta;
		else
			let _monto_180 = _monto_180   + _prima_bruta;
		end if

		if _tipo_periodo = 'M' then -- periodo mensual				

			let _mes_control = month(_fecha_letra) + _mes_perpago;

			if _mes_control > 12 then
				let _mes_control = _mes_control - 12;
			end if

			if _mes_control = 2 then -- verificaciones para febrero
				if day(_fecha_primer_pago) >= 29 then
						let _fecha_char = _fecha_primer_pago;
						let _fecha_char[1,2] = '28';	-- formato dd/mm/yyyy
						let _fecha_letra = _fecha_char;
						let _fecha_letra = _fecha_letra + (_ciclo * _mes_perpago) units month;
				else
						let _fecha_letra     = _fecha_primer_pago + (_ciclo * _mes_perpago) units month;
				end if
			elif _mes_control in (4,6,9,11) then	-- Verificación de meses con 30 días
				if day(_fecha_primer_pago) = 31 then
					let _fecha_char = _fecha_primer_pago;
					let _fecha_char[1,2] = '30';	-- formato dd/mm/yyyy
					let _fecha_letra = _fecha_char;
					let _fecha_letra = _fecha_letra + (_ciclo * _mes_perpago) units month;
				else
					let _fecha_letra = _fecha_primer_pago + (_ciclo * _mes_perpago) units month;
				end if
			else
				let _fecha_letra = _fecha_primer_pago + (_ciclo * _mes_perpago) units month;
			end if
		else -- periodo quincenal
			let _fecha_letra = _fecha_primer_pago + (_ciclo * 15) units day;
		end if
	end for
end foreach

-- Acumular los montos negativos en la morosidad junto con los pagos para rebajar los montos morosos.
if _monto_180 < 0.00 then

	let _monto_recibo = _monto_recibo - _monto_180;
	let _monto_180 = 0.00;
end if
if _monto_150 < 0.00 then
	
	let _monto_recibo = _monto_recibo - _monto_150;
	let _monto_150 = 0.00;
	end if
if _monto_120 < 0.00 then
	
	let _monto_recibo = _monto_recibo - _monto_120;
	let _monto_120 = 0.00;
end if
if _monto_90 < 0.00 then
	
	let _monto_recibo = _monto_recibo - _monto_90;
	let _monto_90 = 0.00;
end if
if _monto_60 < 0.00 then

	let _monto_recibo = _monto_recibo - _monto_60;
	let _monto_60 = 0.00;
end if
if _monto_30 < 0.00 then

	let _monto_recibo = _monto_recibo - _monto_30;
	let _monto_30 = 0.00;
end if
if _corriente < 0.00 then

	let _monto_recibo = _monto_recibo - _corriente;
	let _corriente = 0.00;
end if
if _por_vencer < 0.00 then

	let _monto_recibo = _monto_recibo - _por_vencer;
	let _por_vencer = 0.00;
end if

-- Montos Mas Viejos de las Facturas
while _monto_recibo != 0.00
	if _monto_180 > 0.00 then
		
		if _monto_180 > _monto_recibo then
		    let _monto_180   = _monto_180 - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _monto_180;
		    let _monto_180   = 0.00;
		end if
	elif _monto_150 > 0.00 then
		
		if _monto_150 > _monto_recibo then
		    let _monto_150   = _monto_150 - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _monto_150;
		    let _monto_150   = 0.00;
		end if
	elif _monto_120 > 0.00 then
		
		if _monto_120 > _monto_recibo then
		    let _monto_120   = _monto_120 - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _monto_120;
		    let _monto_120   = 0.00;
		end if
	elif _monto_90 > 0.00 then
		
		if _monto_90 > _monto_recibo then
		    let _monto_90    = _monto_90 - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _monto_90;
		    let _monto_90    = 0.00;
		end if
    elif _monto_60 > 0.00 then

		if _monto_60 > _monto_recibo then
		    let _monto_60    = _monto_60 - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _monto_60;
		    let _monto_60 = 0.00;
		end if
    elif _monto_30 > 0.00 then

		if _monto_30 > _monto_recibo then
		    let _monto_30    = _monto_30 - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _monto_30;
		    let _monto_30 = 0.00;
		end if
    elif _corriente > 0.00 then

		if _corriente > _monto_recibo then
		    let _corriente   = _corriente - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _corriente;
		    let _corriente = 0.00;
		end if
    elif _por_vencer > 0.00 then

		if _por_vencer > _monto_recibo then
		    let _por_vencer  = _por_vencer - _monto_recibo;
		    let _monto_recibo = 0.00;
		else 
		    let _monto_recibo = _monto_recibo - _por_vencer;
		    let _por_vencer = 0.00;
		end if
	else
		let _corriente = _corriente - _monto_recibo;
		let _monto_recibo = 0.00; 
    end if
end while

let _exigible = _corriente + _monto_30 + _monto_60 + _monto_90 + _monto_120 + _monto_150 + _monto_180;

return	_por_vencer,    
		_exigible,      
		_corriente,    
		_monto_30,      
		_monto_60,      
		_monto_90,
		_monto_120,
		_monto_150,
		_monto_180,
		_saldo;		
end procedure;