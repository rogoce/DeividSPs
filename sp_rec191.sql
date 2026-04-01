-- Validacion para el auxiliar de contabilidad vs reclamos pendientes de pago

-- Creado    : 14/03/2012 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea025;

create procedure "informix".sp_rea025()

define _cod_cliente	 	char(10);
define v_transaccion 	char(10);
define v_numrecla	 	char(18);
define v_monto		 	dec(16,2);
define v_fecha		 	date;
define _cod_tipopago	char(3);
define v_proveedor   	char(100);
define v_tipopago    	char(50);
define _periodo         char(7);
define _fecha_periodo	date;
define _cantidad		smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

foreach
 select cod_cliente,
        numrecla,
	    monto,
		fecha,
		cod_tipopago,
		transaccion,
		periodo
   into _cod_cliente,
	    v_numrecla,
		v_monto,
	   	v_fecha,
		_cod_tipopago,
		v_transaccion,
		_periodo
   from rectrmae
  where cod_compania = "001"
    and actualizado  = 1
    and cod_tipotran = "004"
    and periodo      >= "2011-01"
    and periodo      <= "2011-12"
	and monto        <> 0


end foreach

end procedure