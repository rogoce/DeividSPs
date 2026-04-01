-- Clientes en callcenter con 30 o mas dias sin gestion	y sin pagos
-- 
-- Creado    : 02/12/2003 - Autor:Armando Moreno
-- Modificado: 02/12/2003 - Autor:Armando Moreno
--

drop procedure sp_cas064;

create procedure sp_cas064()
returning char(50),
		  char(3),
		  char(100),
		  char(10),
          date,
          integer,
          integer,
          DEC(16,2),
          integer,
          integer,
          integer,
          integer,
          integer;

define _cod_cliente     char(10);
define _cod_cobrador    char(3);
define _cod_gestion     char(3);
define _nombre_cobrador	char(50);
define _nombre_pagador	char(100);
define _fecha_dt		datetime year to fraction(5);
define _cantidad_dias	integer;
define _tipo_cobrador,_pago_fijo   integer;
define _fecha_ult_pro,_fecha_ult_dia   date;
define _fecha_ult_pago date;
define _fecha_hoy   	date;
define v_documento 		CHAR(20);
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE v_por_vencer     DEC(16,2);	 
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo,v_saldo2	DEC(16,2);
define _ult_proc_flag   integer;
define _ult_pago_flag,_cantidad_dias_pago,_dia1,_dia2,_dia3   integer;
define _dia_cobros1,_dia_cobros2,_dia_cobros3 integer;

define _vigencia_inic	date;
define _fecha_1_pago	date;
define _no_poliza		char(10);
define _monto_ult_pago	dec(16,2);
define _dias_cant		smallint;

--set debug file to "sp_cas064.trc";
--trace on;

let _fecha_dt      = sp_sis40();
let _fecha_hoy     = date(_fecha_dt);
let _ult_proc_flag = 0;
let _ult_pago_flag = 0;
let _dias_cant     = 30;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;
 
foreach
 select cod_cobrador,
        cod_gestion,
		fecha_ult_pro,
		cod_cliente,
		pago_fijo,
		dia_cobros1,
		dia_cobros2,
		dia_cobros3
   into _cod_cobrador,
        _cod_gestion,
		_fecha_ult_pro,
		_cod_cliente,
		_pago_fijo,
		_dia_cobros1,
		_dia_cobros2,
		_dia_cobros3
   from cascliente
--  where cod_cliente = "48344"

	let _ult_pago_flag = 0;
	let v_saldo2       = 0.00;

	foreach
	 select no_documento
	   into v_documento
	   from caspoliza
	  where cod_cliente = _cod_cliente

		 CALL sp_cob33(
		 "001",
		 "001",
		 v_documento,
		 _periodo,
		 _fecha_ult_dia
		 ) RETURNING v_por_vencer,
				     v_exigible,  
				     v_corriente, 
				     v_monto_30,  
				     v_monto_60,  
				     v_monto_90,
				     v_saldo;

		let v_saldo2 = v_saldo2 + v_exigible;

		if v_exigible <= 0.0 then
			continue foreach;
		end if 

		SELECT max(fecha)
		  INTO _fecha_ult_pago
		  FROM cobredet
		 WHERE doc_remesa   = v_documento	-- Recibos de la Poliza
		   AND actualizado  = 1			    -- Recibo este actualizado
		   AND tipo_mov     = 'P';       	-- Pago de Prima(P)

		SELECT sum(monto)
		  INTO _monto_ult_pago
		  FROM cobredet
		 WHERE doc_remesa   = v_documento	-- Recibos de la Poliza
		   AND actualizado  = 1			    -- Recibo este actualizado
		   AND tipo_mov    in ('P', 'N')   	-- Pago de Prima(P)
		   and fecha       >= _fecha_ult_pro;

		let _no_poliza = sp_sis21(v_documento);
		
		select vigencia_inic,
		       fecha_primer_pago
		  into _vigencia_inic,
		       _fecha_1_pago
		  from emipomae
		 where no_poliza = _no_poliza;

		if _fecha_1_pago > _vigencia_inic then
			let _vigencia_inic = _fecha_1_pago;
		end if

	   	if _vigencia_inic > _fecha_hoy then
			continue foreach;
		end if

	   	if (_fecha_hoy - _vigencia_inic) < _dias_cant then
			continue foreach;
		end if

	   	if (_fecha_hoy - _fecha_ult_pago) >= _dias_cant then
			let _ult_pago_flag = 1;
			exit foreach;
		else
			if v_exigible > _monto_ult_pago then
				let _ult_pago_flag = 1;
				exit foreach;
			end if
	   	end if

	end foreach

	if _pago_fijo is null then
		let _pago_fijo = 0;
	end if

	if _pago_fijo = 1 and _ult_pago_flag = 0 then
  		continue foreach;
	end if

	if (_fecha_hoy - _fecha_ult_pro) >= _dias_cant then
		let _ult_proc_flag = 1;
	else
		let _ult_proc_flag = 0;
	end if

	if _ult_proc_flag = 0 and _ult_pago_flag = 0 then
		continue foreach;
	end if

	if v_saldo2  <= 0.00 then
		continue foreach;
	end if

	let _cantidad_dias      = _fecha_hoy - _fecha_ult_pro;
	let _cantidad_dias_pago = _fecha_hoy - _fecha_ult_pago;

	if _cantidad_dias_pago is null then
		continue foreach;
	end if

	if _cantidad_dias_pago < _dias_cant then
		continue foreach;
	end if

	select tipo_cobrador
	  into _tipo_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_cliente;

	return _nombre_cobrador,
		   _cod_cobrador,
		   _nombre_pagador,
		   _cod_cliente,
		   _fecha_ult_pro,
		   _cantidad_dias,
		   _tipo_cobrador,
		   v_saldo2,
		   _pago_fijo,
		   _cantidad_dias_pago,
		   _dia_cobros1,
		   _dia_cobros2,
		   _dia_cobros3
		   with resume;

end foreach

end procedure


				  