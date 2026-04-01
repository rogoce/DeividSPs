-- Procedimiento que Segmenta la morosidad de las facturas.
-- 
-- Creado    : 28/11/2000 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_cob405;
create procedure "informix".sp_cob405(
a_compania     char(3), 
a_sucursal     char(3), 
a_no_documento char(20),
a_periodo      char(7),
a_fecha        date)
returning	char(20)	as poliza,
			char(10)	as factura,
			smallint	as letra_poliza,
			smallint	as letra_factura,
			date		as vigencia_inic,
			date		as vigencia_final,
			date		as fecha_efectiva,
			dec(16,2)	as monto_letra,
			dec(16,2)	as monto_pendiente;

define _no_documento			char(20);
define _fecha_char				char(10);
define _no_requis				char(10);
define _no_factura				char(10);
define _no_poliza				char(10);
define _periodo_cheque			char(7);
define _no_endoso				char(5);
define _cod_perpago				char(3);
define _cod_ramo				char(3);
define _tipo_periodo			char(1);
define _monto_devolucion		dec(16,2);
define v_saldo_control			dec(16,2);
define _monto_primero			dec(16,2);
define _monto_cheque			dec(16,2);
define _monto_recibo			dec(16,2);
define _prima_bruta				dec(16,2);
define v_por_vencer				dec(16,2);
define v_prima_orig				dec(16,2);
define v_corriente				dec(16,2);
define v_exigible				dec(16,2);
define v_monto_90				dec(16,2);
define v_monto_60				dec(16,2);
define v_monto_30				dec(16,2);
define v_saldo					dec(16,2);
define _monto					dec(16,2);
define _prima_pendiente			dec(16,2);
define _monto_resto				dec(16,2);
define _cnt_dias				dec(16,2);
define _estatus_poliza			smallint;
define _no_letra_pol			smallint;
define _mes_perpago				smallint;
define _mes_control				smallint;
define _dias_vig				smallint;
define _no_pagos				smallint;
define _pagado					smallint;
define _anio					smallint;
define _dia						smallint;
define _mes						smallint;
define _ciclo					integer;
define _dias					integer;
define _fecha_primer_pago_pol	date;
define _vigencia_final_end		date;
define _fecha_primer_pago		date;
define _vigencia_inic_end		date;
define _fecha_ult_letra			date;
define _fecha_impresion			date;
define _vigencia_final			date;
define _fecha_anulado			date;
define _fecha_emision			date;
define _vigencia_inic			date;
define _fecha_letra				date;

--SET DEBUG FILE TO "sp_cob33.trc";
--TRACE ON ;

set isolation to dirty read;

let v_prima_orig = 0;
let v_por_vencer = 0;    
let _prima_bruta = 0;
let v_corriente = 0;   
let v_exigible = 0;    
let v_monto_30 = 0;    
let v_monto_60 = 0;    
let v_monto_90 = 0;
let v_saldo = 0;
let _monto = 0;

drop table if exists tmp_morosidad;
create temp table tmp_morosidad(
no_documento		char(20),
no_poliza			char(10),
no_endoso			char(5),
no_letra_poliza		smallint,
no_letra_factura	smallint,
vigencia_inic		date,
vigencia_final		date,
fecha_efectiva		date,
prima_bruta			dec(16,2),
monto_pagado		dec(16,2) default 0.00,
monto_pendiente		dec(16,2),
fecha_pagado		date,
primary key (no_poliza,no_endoso,no_letra_factura)) with no log;

{
-- facturas
foreach
	select prima_bruta
	  into _monto
	  from endedmae
	 where no_documento   = a_no_documento	    -- facturas de la poliza
	   and actualizado    = 1			        -- factura este actualizada
	   and activa         = 1
--    and periodo        <= a_periodo	    -- no incluye periodos futuros
--    and fecha_emision <= a_fecha          -- hechas durante y antes de la fecha seleccionada
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
--    AND periodo     <= a_periodo	    			-- No Incluye Periodos Futuros

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
	
	RETURN  v_por_vencer,    
			v_exigible,      
			v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_saldo;   
			
END IF
}
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
		   vigencia_inic,
		   vigencia_final
	  into _prima_bruta,
		   _fecha_primer_pago,
		   _no_pagos,
		   _cod_perpago,
		   _no_factura,
		   _fecha_emision,
		   _no_poliza,
		   _no_endoso,
		   _vigencia_inic_end,
		   _vigencia_final_end
	  from endedmae
	 where no_documento   = a_no_documento -- facturas de la poliza
	   and actualizado    = 1			 	-- factura este actualizada
	   and activa         = 1
--	and periodo       <= a_periodo	 	-- no incluye periodos futuros
	--and no_poliza = '1015167'

		{if _fecha_primer_pago >= _fecha_emision then
			let _fecha_letra       = _fecha_primer_pago;
		else
			let _fecha_letra       = _fecha_emision;
			let _fecha_primer_pago = _fecha_emision;
		end if}

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

	-- Inicia el ciclo para determinar la morosidad de cada factura
	for _ciclo = 1 to _no_pagos
		
		--let _dias = a_fecha - _fecha_letra;

		if _ciclo = 1 then
			let _prima_bruta = _monto_primero;
		else
			let _prima_bruta = _monto_resto;
		end if

		{if _dias < 0 then
			let v_por_vencer = v_por_vencer + _prima_bruta;
		elif _dias >= 0 and _dias <= 30 then
			let v_corriente = v_corriente   + _prima_bruta;
		elif _dias > 30 and _dias <= 60 then
			let v_monto_30 = v_monto_30     + _prima_bruta;
		elif _dias > 60 and _dias <= 90 then
			let v_monto_60 = v_monto_60     + _prima_bruta;
		else
			let v_monto_90 = v_monto_90     + _prima_bruta;
		end if}

		if _no_endoso = '00000' then
			let _no_letra_pol = _ciclo;
		else
			select no_letra_factura
			  into _no_letra_pol
			  from tmp_morosidad
			 where no_poliza = _no_poliza
			   and no_endoso = '00000'
			   and fecha_efectiva = _fecha_letra;
			end if
		
		insert into tmp_morosidad(
				no_documento,
				no_poliza,
				no_endoso,
				no_letra_poliza,
				no_letra_factura,
				vigencia_inic,
				vigencia_final,
				fecha_efectiva,
				prima_bruta,
				monto_pendiente)
		values(	a_no_documento,
				_no_poliza,
				_no_endoso,
				_no_letra_pol,
				_ciclo,
				_vigencia_inic_end,
				_vigencia_final_end,
				_fecha_letra,
				_prima_bruta,
				_prima_bruta);
				

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
end foreach

foreach
	select t.no_documento,
		   e.no_factura,
		   t.no_endoso,
		   t.no_letra_poliza,
		   t.no_letra_factura,
		   t.vigencia_inic,
		   t.vigencia_final,
		   t.fecha_efectiva,
		   t.prima_bruta,
		   t.monto_pendiente
	  into a_no_documento,
		   _no_factura,
		   _no_endoso,
		   _no_letra_pol,
		   _ciclo,
		   _vigencia_inic_end,
		   _vigencia_final_end,
		   _fecha_letra,
		   _prima_bruta,
		   _prima_pendiente
	  from tmp_morosidad t, endedmae e
	 where t.no_poliza = e.no_poliza
	   and t.no_endoso = e.no_endoso
	 order by fecha_efectiva,no_letra_poliza,no_endoso,no_letra_factura

	return a_no_documento,
		   _no_factura,
		   _no_letra_pol,
		   _ciclo,
		   _vigencia_inic_end,
		   _vigencia_final_end,
		   _fecha_letra,
		   _prima_bruta,
		   _prima_pendiente with resume;
end foreach

{RETURN v_por_vencer,    
	   v_exigible,      
	   v_corriente,    
	   v_monto_30,      
	   v_monto_60,      
	   v_monto_90,
	   v_saldo with resume; }
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
--	AND periodo        <= a_periodo	 	-- No Incluye Periodos Futuros
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
{if v_monto_90 < 0.00 then
	
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

return v_por_vencer,    
	   v_exigible,      
	   v_corriente,    
	   v_monto_30,      
	   v_monto_60,      
	   v_monto_90,
	   v_saldo;}
end procedure;