-- Inserta en el auxiliar de reclamos por pagar para una transaccion

-- Creado    : 10/02/2004 - Autor: Amado Perez  

drop procedure sp_rec256;

create procedure "informix".sp_rec256(a_transaccion char(10)) 
returning integer,
		  char(50);

define _cod_cliente	char(10);
define v_transaccion	char(10);
define v_numrecla	 	char(18);
define v_monto		 	dec(16,2);
define v_fecha		 	date;
define _cod_tipopago	char(3);
define v_proveedor   	char(100);
define v_tipopago    	char(50);
define _periodo        char(7);
define _fecha_periodo	date;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


-- Transacciones NO Pagadas

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
  where cod_compania 	= "001"
    and actualizado  	= 1
    and cod_tipotran 	= "004"
--	and pagado       	= 0
	and monto        	<> 0
	and transaccion	= a_transaccion

	insert into reccietr (cod_cliente, numrecla, monto, fecha, cod_tipopago, transaccion, periodo,periodo_tr)  
	values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion, _periodo,_periodo);

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure;
