-- Actualiza el Auxiliar de Proveedores de reclamos con los periodos que falta

-- Creado    : 10/02/2004 - Autor: Amado Perez  

--drop procedure sp_rec257;

create procedure "informix".sp_rec257(
a_transaccion 	char(10),
a_periodo		char(7)
) returning integer,
			 char(50);

define _cod_cliente	char(10);
define v_transaccion	char(10);
define v_numrecla	 	char(18);
define v_monto		 	dec(16,2);
define v_fecha		 	date;
define _cod_tipopago	char(3);
define v_proveedor   	char(100);
define v_tipopago    	char(50);
define _periodo       	char(7);
define _fecha_periodo	date;
define _cantidad		smallint;

define _mes_act		smallint;
define _ano_act		smallint;
define _periodo_ini	char(7);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

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
 where transaccion	= a_transaccion;

if _cod_cliente is null then
	return 1, "No Existe Transaccion " || a_transaccion;
end if
	
let _periodo_ini = _periodo;

while _periodo_ini <= a_periodo

	select count(*)
	  into _cantidad
	  from reccietr
	 where transaccion	= a_transaccion
	   and periodo		= _periodo_ini;

	if _cantidad = 0 then

		insert into reccietr (cod_cliente, numrecla, monto, fecha, cod_tipopago, transaccion, periodo, periodo_tr)  
		values (_cod_cliente, v_numrecla, v_monto, v_fecha, _cod_tipopago, v_transaccion, _periodo_ini, _periodo);

	end if

	let _ano_act = _periodo_ini[1,4];
	let _mes_act = _periodo_ini[6,7];

	if _mes_act = 12 then
		let _mes_act = 1;
		let _ano_act = _ano_act + 1;
	else
		let _mes_act = _mes_act + 1;
		let _ano_act = _ano_act;
	end if

	if _mes_act < 10 then
		let _periodo_ini = _ano_act || "-0" || _mes_act;
	else
		let _periodo_ini = _ano_act || "-" || _mes_act;
	end if		

end while

end 

return 0, "Actualizacion Exitosa";

end procedure;
