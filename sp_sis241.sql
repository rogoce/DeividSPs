-- Procedimiento Verifica los Clientes VOCEM
-- Creado: 26/07/2017 - Autor: Henry Giron

drop procedure sp_sis241;
create procedure sp_sis241(a_cod_cliente char(10))
returning	smallint		as cod_error,
			varchar(100)	as error_desc;

define _mensaje				varchar(100);
define _cnt_vocem			smallint;
define _error_isam			integer;
define _error				integer;
define _date_added			date;

set isolation to dirty read;

--set debug file to "sp_sis241.trc";
--trace on;


begin
on exception set _error,_error_isam,_mensaje
 	return _error, _mensaje;
end exception

let _mensaje = ' '; 

select count(*)
  into _cnt_vocem
  from caspoliza 
 where cod_cliente = a_cod_cliente
   and cod_campana = '01656';       -- Campaña VOCEM   

if _cnt_vocem is null then
	let _cnt_vocem = 0;
end if

if _cnt_vocem > 0 then
	let _cnt_vocem = 1;
	let _mensaje = 'GESTADO POR: VOCEM'; --'CLIENTE VOCEM';
end if

return _cnt_vocem,_mensaje;

end
end procedure;