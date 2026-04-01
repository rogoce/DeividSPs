----------------------------------------------------------
--Procedure que retorna el cod_cliente de cliclien en base del id_relac_cliente de ttcorp
--Creado    : 04/09/2015 - Autor: Román Gordón
----------------------------------------------------------

drop procedure sp_sis435;
create procedure sp_sis435(a_cod_cliente_int integer)
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _cod_cliente			char(10);
define _error				integer;
define _error_isam			integer;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

--set debug file to "sp_sis435.trc";
--trace on;

select cod_cliente
  into _cod_cliente
  from cliclien
 where cast(trim(cod_cliente) as integer) = a_cod_cliente_int;

if _cod_cliente is null then
	let _cod_cliente = '';
end if

return 0,_cod_cliente;

end
end procedure;