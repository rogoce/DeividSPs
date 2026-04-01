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
   from reccietr
  where periodo = a_periodo

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

end procedure;
