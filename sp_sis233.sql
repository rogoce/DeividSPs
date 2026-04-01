-- Procedimiento Verifica los Clientes VIP
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_sis233;
create procedure sp_sis233(a_cod_cliente char(10))
returning	smallint		as cod_error,
			varchar(100)	as error_desc;

define _mensaje				varchar(100);
define _cnt_vip				smallint;
define _cant_dev			smallint;
define _error_isam			integer;
define _error				integer;
define _date_added			date;

set isolation to dirty read;

--set debug file to "sp_sis232.trc";
--trace on;


begin
on exception set _error,_error_isam,_mensaje
 	return _error, _mensaje;
end exception

let _mensaje = 'Cliente Regular';

select count(*)
  into _cnt_vip
  from clivip
 where cod_cliente = a_cod_cliente;

if _cnt_vip is null then
	let _cnt_vip = 0;
end if

if _cnt_vip > 0 then
	let _cnt_vip = 1;
	let _mensaje = 'Cliente VIP';
end if

return _cnt_vip,_mensaje;

end
end procedure;