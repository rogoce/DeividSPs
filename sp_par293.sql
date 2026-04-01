-- Generacion de Asientos de Suministros - Entrada de Mercancia
-- 
-- Creado    : 27/11/2009 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par293;

create procedure "informix".sp_par293(a_cod_entrada CHAR(10))
returning integer,
          char(100);

define _renglon			smallint;
define _monto			dec(16,2);

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

-- Entrada de Suministro

select fecha_ent
  into _fecha
  from psuminentm
 where cod_entrada = a_cod_entrada;

let _periodo = sp_sis39(_fecha);

let _contador = 0;

foreach 
 select renglon,
        total
   into _renglon,
        _monto
   from psuminentd
  where cod_entrada = a_cod_entrada

	-- Inventario de Compras

	let _cuenta = sp_sis15("SAINVCOM");

	if _monto > 0 then 
		let _debito  = _monto;
		let _credito = 0.00;
	else
		let _debito  = 0.00;
		let _credito = _monto * -1;
	end if
	
	let _contador = _contador + 1;

	insert into socentcta (cod_entrada, renglon, cuenta, cod_auxiliar, debito, credito, tipo, fecha, centro_costo, sac_notrx, periodo)
	values (a_cod_entrada, _contador, _cuenta, '', _debito, _credito, 2, _fecha, _centro_costo, null, _periodo);

	-- Proveedor por Pagar

	let _cuenta = sp_sis15("SAINVCXP");

	if _monto > 0 then 
		let _debito  = 0.00;
		let _credito = _monto;
	else
		let _debito  = _monto * -1;
		let _credito = 0.00;
	end if
	
	let _contador = _contador + 1;

	insert into socentcta (cod_entrada, renglon, cuenta, cod_auxiliar, debito, credito, tipo, fecha, centro_costo, sac_notrx, periodo)
	values (a_cod_entrada, _contador, _cuenta, '', _debito, _credito, 2, _fecha, _centro_costo, null, _periodo);

end foreach

update psuminentm
   set sac_asientos = 1
 where cod_entrada = a_cod_entrada;

end

return 0, "Actualizacion Exitosa";

end procedure