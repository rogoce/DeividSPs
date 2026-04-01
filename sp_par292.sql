-- Generacion de Asientos de Suministros (Salida)
--  
-- Creado    : 24/11/2009 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par292;

create procedure "informix".sp_par292(a_cod_salida CHAR(10))
returning integer,
          char(100);

define _renglon			smallint;
define _monto			dec(16,2);
define _cod_suministro	char(10);
define _cod_concepto	char(10);

define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _centro_costo	char(3);
define _fecha			date;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

define _periodo			char(7);

define _contador		integer;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _centro_costo = "001";

--SET DEBUG FILE TO "sp_par293.trc"; 
--trace on;

-- Salida de Suministro

select fecha
  into _fecha
  from socsalm
 where cod_salida = a_cod_salida;
 
let _periodo = sp_sis39(_fecha);

select max(renglon)
into _contador 
from socsalcta
where cod_salida = a_cod_salida;

if _contador is null then
	let _contador = 0;
end if

foreach
 select renglon,
        total,
		cod_suministro
   into _renglon,
        _monto,
		_cod_suministro
   from socsald
  where cod_salida = a_cod_salida
	and procesado = 0

	-- Gasto de Suministro

	select cod_concepto
	  into _cod_concepto
	  from parsumin
	 where cod_suministro = _cod_suministro;

	select cuenta
	  into _cuenta
	  from socconcep
	 where cod_concepto = _cod_concepto;

	if _monto > 0 then
		let _debito  = _monto;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = _monto * -1;
	end if

	let _contador = _contador + 1;

	insert into socsalcta (cod_salida, renglon, cuenta, cod_auxiliar, debito, credito, tipo, fecha, centro_costo, sac_notrx, periodo)
	values (a_cod_salida, _contador, _cuenta, '', _debito, _credito, 1, _fecha, _centro_costo, null, _periodo);

	-- Inventario de Compras

	let _cuenta = sp_sis15("SAINVCOM");

	if _monto > 0 then
		let _debito  = 0.00;
		let _credito = _monto;
	else
		let _debito  = _monto * -1;
		let _credito = 0.00;
	end if
	
	let _contador = _contador + 1;
	
	insert into socsalcta (cod_salida, renglon, cuenta, cod_auxiliar, debito, credito, tipo, fecha, centro_costo, sac_notrx, periodo)
	values (a_cod_salida, _contador, _cuenta, '', _debito, _credito, 1, _fecha, _centro_costo, null, _periodo);
	
	  UPDATE socsald  
		SET procesado = 1  
	   WHERE ( socsald.cod_salida = a_cod_salida ) AND  
			 ( socsald.renglon = renglon )   ;

end foreach

update socsalm
   set sac_asientos = 1
 where cod_salida   = a_cod_salida;

end

return 0, "Actualizacion Exitosa";

end procedure
