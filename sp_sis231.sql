-- Procedimiento actualiza la información de cheques devueltos desde la pantalla única.
-- Creado: 02/02/2017 - Autor: Román Gordón

drop procedure sp_sis231;
create procedure sp_sis231(a_cod_cliente char(10), a_usuario char(8))
returning	smallint		as cod_error,
			varchar(100)	as error_desc;

define _mensaje				varchar(100);
define _cnt_existe			smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to "sp_sis231.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error, _mensaje;
end exception

return 0,'Inhabilitado Temporalmente';

select count(*)
  into _cnt_existe
  from clichdev
 where cod_cliente = a_cod_cliente;

if _cnt_existe is null then
	let _cnt_existe = 0;
end if

if _cnt_existe = 0 then
	insert into clichdev(
			cod_cliente,
			cantidad,
			date_added,
			date_changed,
			date_quito,
			user_added,
			user_changed,
			user_quito)
	values(	a_cod_cliente,
			1,
			current,
			null,
			null,
			a_usuario,
			null,
			null);
else
	update clichdev
	   set cantidad = cantidad + 1,
		   user_changed = a_usuario,
		   date_changed = current
	 where cod_cliente = a_cod_cliente;
end if

return 0,'Verificación Exitosa';
end
end procedure;