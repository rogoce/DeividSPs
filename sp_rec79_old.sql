-- Procedimiento que Realiza la Busqueda de las Transacciones de pago no pagadas, a proveedor y taller

-- Creado    : 10/02/2004 - Autor: Amado Perez  

drop procedure sp_rec79;

create procedure "informix".sp_rec79(a_periodo char(7)) 
returning char(100), 
		  char(18), 
		  dec(16,2), 
		  date, 
		  char(50), 
		  char(10);

define _cod_cliente	 	char(10);
define v_transaccion 	char(10);
define v_numrecla	 	char(18);
define v_monto		 	dec(16,2);
define v_fecha		 	date;
define _cod_tipopago	char(3);
define v_proveedor   	char(100);
define v_tipopago    	char(50);

define _fecha_periodo	date;

define _cantidad		smallint;

set isolation to dirty read;

create temp table tmp_transac(
cod_cliente		char(10),
numrecla		char(20),
monto			dec(16,2),
fecha			date,
cod_tipopago	char(3),
transaccion		char(10)
) with no log;

let _fecha_periodo = sp_sis36(a_periodo);

-- Transacciones NO Pagadas

foreach

 select cod_cliente,
        numrecla,
	    monto,
		fecha,
		cod_tipopago,
		transaccion
   into _cod_cliente,
	    v_numrecla,
		v_monto,
	   	v_fecha,
		_cod_tipopago,
		v_transaccion
   from rectrmae
  where cod_compania = "001"
    and actualizado  = 1
    and cod_tipotran = "004"
    and periodo      <= a_periodo
	and pagado       = 0
	and monto        <> 0

--	and transaccion  = "01-576553"

{  	select count(*)
	  into _cantidad
	  from chqchrec r, chqchmae m
	 where r.transaccion   = v_transaccion
	   and m.pagado        = 1
	   and m.anulado       = 1
	   and r.no_requis     = m.no_requis
	   and m.fecha_impresion <= _fecha_periodo        
	   and m.fecha_anulado > _fecha_periodo;  --28/02/2010

	if _cantidad >= 0 then}
		insert into tmp_transac
		values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion);
   --	end if	  

end foreach

-- Transacciones SI Pagadas

foreach
 select cod_cliente,
        numrecla,
	    monto,
		fecha,
		cod_tipopago,
		transaccion
   into _cod_cliente,
	    v_numrecla,
		v_monto,
	   	v_fecha,
		_cod_tipopago,
		v_transaccion
   from rectrmae
  where cod_compania = "001"
    and actualizado  = 1
    and cod_tipotran = "004"
    and periodo      <= a_periodo
	and pagado       = 1 
	and fecha_pagado > _fecha_periodo
	and monto        <> 0

	insert into tmp_transac
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion);

end foreach


-- Transacciones No Pagadas	pero anuladas despues del periodo

foreach
 select cod_cliente,
        numrecla,
	    monto,
		fecha,
		cod_tipopago,
		transaccion
   into _cod_cliente,
	    v_numrecla,
		v_monto,
	   	v_fecha,
		_cod_tipopago,
		v_transaccion
   from rectrmae
  where cod_compania = "001"
    and actualizado  = 1
    and cod_tipotran = "004"
    and periodo      <= a_periodo
	and pagado       = 1 
	and fecha_anulo  > _fecha_periodo
	and anular_nt	 IS NOT NULL
	and trim(anular_nt) <> ""
	and (no_requis    IS NULL
	or trim(no_requis) = "")
	and monto        <> 0

	insert into tmp_transac
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion);

end foreach

foreach
 select cod_cliente,	
		numrecla,	
		monto,		
		fecha,		
		cod_tipopago,
		transaccion	
   into _cod_cliente,
		v_numrecla,
		v_monto,
		v_fecha,
		_cod_tipopago,
		v_transaccion
   from tmp_transac

	select nombre
	  into v_proveedor
	  from cliclien
	 where cod_cliente = _cod_cliente;

    select nombre
	  into v_tipopago
	  from rectipag
	 where cod_tipopago = _cod_tipopago;

	return v_proveedor,
		   v_numrecla,
		   v_monto,
		   v_fecha,
		   v_tipopago,
		   v_transaccion
		   with resume;

end foreach

drop table tmp_transac;

end procedure;
