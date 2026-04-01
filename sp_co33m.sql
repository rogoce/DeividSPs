-- Procedimiento que Genera la Morosidad para un Documento
 
-- Creado    : 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 04/07/2002 - Autor: Marquelda Valdelamar
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co33m;

CREATE PROCEDURE "informix".sp_co33m(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_no_documento CHAR(20),
a_fecha        DATE     
) RETURNING	CHAR(50),	-- nombre_cliente
			CHAR(100),	-- direccion1
			CHAR(100),  -- direccion2
			CHAR(20),   -- telefono1
			CHAR(20),	-- telefono2
			CHAR(10),   -- apartado
			CHAR(20),	-- no_documento
			DATE,       -- vigencia_inic
			DATE,       -- vigencia_final
			CHAR(50),   -- nombre_agente
			CHAR(50),   -- nombre_ramo
			CHAR(50),   -- nombre_subramo
			DATE,       -- fecha_aviso
			DATE,       -- fecha_efectiva
			CHAR(30),   -- estatus_poliza
			DATE,       -- fecha cancelacion
			DEC(16,2),	-- Por Vencer
			DEC(16,2),	-- Exigible
			DEC(16,2),	-- Corriente
			DEC(16,2),	-- 30 Dias
			DEC(16,2),	-- 60 Dias
			DEC(16,2),	-- 90 Dias
			DEC(16,2);	-- Saldo
  	
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
DEFINE _monto             DEC(16,2);

DEFINE _fecha_primer_pago DATE;     
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

DEFINE _no_factura       CHAR(10);
DEFINE _nombre_cliente   CHAR(50);
DEFINE _direccion1       CHAR(100);
DEFINE _direccion2       CHAR(100);
DEFINE _telefono1        CHAR(20);
DEFINE _telefono2        CHAR(20);
DEFINE _apartado         CHAR(10);
DEFINE _no_documento     CHAR(20);

DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final    DATE;
DEFINE _nombre_agente     CHAR(50);
DEFINE _nombre_ramo       CHAR(50);
DEFINE _nombre_subramo    CHAR(50);
DEFINE _cod_agente        CHAR(5);
DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_cliente       CHAR(10);						
DEFINE _cod_subramo       CHAR(3);
DEFINE _no_poliza         CHAR(10);
DEFINE _fecha_aviso_canc  DATE;
DEFINE _fecha_efectiva    DATE;
DEFINE _estatus_poliza    INTEGER;
DEFINE _estatus           CHAR(30);
DEFINE _fecha_cancelacion DATE;
define _cnt_dias				smallint;
define _dias_vig				smallint;
define _fecha_primer_pago_pol	date;
define _fecha_ult_letra			date;

LET _estatus = "";
LET _estatus_poliza = 0;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob33.trc";
--TRACE ON ;

LET v_prima_orig  = 0;
LET v_saldo       = 0;
LET v_por_vencer  = 0;    
LET v_exigible    = 0;    
LET v_corriente   = 0;   
LET v_monto_30    = 0;    
LET v_monto_60    = 0;    
LET v_monto_90    = 0;

LET _prima_bruta  = 0;

-- Facturas

LET _prima_bruta  = 0;
LET _monto        = 0;

-- Datos de la Poliza
	FOREACH
	 SELECT vigencia_inic,
	        vigencia_final,
			cod_ramo,
			cod_subramo,
			cod_contratante,
			no_poliza,
			fecha_aviso_canc,
			estatus_poliza,
			fecha_cancelacion
	   INTO _vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_cod_subramo,
			_cod_cliente,
			_no_poliza,
			_fecha_aviso_canc,
			_estatus_poliza,
			_fecha_cancelacion
	   FROM emipomae
	  WHERE no_documento = a_no_documento
	    AND actualizado  = 1
	  ORDER BY vigencia_inic DESC
			EXIT FOREACH;
	END FOREACH

--Estatus de la poliza.
IF _estatus_poliza = 1 then
	LET _estatus = 'Vigente';
ELIF _estatus_poliza = 2 then
    LET _estatus = 'Cancelada';
ELIF _estatus_poliza = 3 then
    LET _estatus = 'Vencida';
ELSE
    LET _estatus = 'Anulada';
END IF

LET _fecha_efectiva = (_fecha_aviso_canc + 10);

-- Datos del Cliente
	SELECT nombre,
	       direccion_1,
		   direccion_2,
		   telefono1,
		   telefono2,
		   apartado
	 INTO  _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _telefono1,
		   _telefono2,
		   _apartado
	FROM  cliclien
	WHERE cod_cliente = _cod_cliente;

-- Ramo y Subramo
	SELECT nombre
	INTO   _nombre_ramo
	FROM  prdramo
	WHERE cod_ramo = _cod_ramo;	

	SELECT nombre
	INTO   _nombre_subramo
	FROM  prdsubra
	WHERE cod_ramo = _cod_ramo
	AND   cod_subramo = _cod_subramo;

-- Agente de la Poliza
	FOREACH
	 SELECT cod_agente
	 INTO   _cod_agente
	 FROM   emipoagt
	 WHERE  no_poliza = _no_poliza
	 
	 SELECT nombre
	   INTO _nombre_agente
	   FROM agtagent
	  WHERE cod_agente = _cod_agente;
	EXIT FOREACH;
	END FOREACH

FOREACH
 SELECT prima_bruta
   INTO _monto
   FROM endedmae
  WHERE no_documento   = a_no_documento	-- Facturas de la Poliza
    AND actualizado    = 1			    -- Factura este Actualizada
	AND activa         = 1
		LET _prima_bruta = _prima_bruta + _monto;
END FOREACH

IF _prima_bruta IS NULL THEN
	LET _prima_bruta = 0;
END IF

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
    AND tipo_mov     IN ('P', 'N')		-- Pago de Prima(P) y Notas de Credito(N)
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
				IF _fecha_anulado > a_fecha	THEN
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
	
	RETURN  _nombre_cliente,
			_direccion1,
			_direccion2,
			_telefono1,
			_telefono2,
			_apartado,
			a_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_nombre_agente,
			_nombre_ramo,
			_nombre_subramo,
			_fecha_aviso_canc,
			_fecha_efectiva,
			_estatus,
			_fecha_cancelacion,
			v_por_vencer,    
			v_exigible,      
			v_corriente,    
			v_monto_30,      
			v_monto_60,      
			v_monto_90,
			v_saldo;   
			
END IF

-- Inicio del Proceso de Determinar la Morosidad de las Facturas
FOREACH
 SELECT	prima_bruta,
		fecha_primer_pago,
		no_pagos,
		cod_perpago,
		no_factura,
		no_poliza
   INTO	_prima_bruta,
		_fecha_primer_pago,
		_no_pagos,
		_cod_perpago,
		_no_factura,
		_no_poliza
   FROM	endedmae
  WHERE	no_documento   = a_no_documento -- Facturas de la Poliza
    AND actualizado    = 1			 	-- Factura este Actualizada
	AND prima_bruta    > 0           	-- Procesa la Facturas de Aumento de Prima
	AND activa         = 1

		-- Selecciona los periodos de pago
		SELECT meses,
		 	   tipo_periodo	
		  INTO _mes_perpago,
			   _tipo_periodo	
		  FROM cobperpa
		 WHERE cod_perpago = _cod_perpago;

	LET _fecha_letra   = _fecha_primer_pago;
	
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

			let _fecha_ult_letra = _fecha_primer_pago_pol + (_no_pagos) units month;
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

LET _prima_bruta  = 0;
LET _monto        = 0;

FOREACH
 SELECT	prima_bruta
   INTO	_monto
   FROM	endedmae
  WHERE	no_documento   = a_no_documento -- Facturas de la Poliza
    AND actualizado    = 1			 	-- Factura este Actualizada
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


RETURN  _nombre_cliente,
		_direccion1,
		_direccion2,
		_telefono1,
		_telefono2,
		_apartado,
		a_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_nombre_agente,
		_nombre_ramo,
		_nombre_subramo,
		_fecha_aviso_canc,
		_fecha_efectiva,
		_estatus,
		_fecha_cancelacion,
		v_por_vencer,    
		v_exigible,      
		v_corriente,    
		v_monto_30,      
		v_monto_60,      
		v_monto_90,
		v_saldo;   
		
END PROCEDURE;

	