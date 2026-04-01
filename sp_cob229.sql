-- Creacion de la Caja

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob229;

create procedure sp_cob229(
a_cod_chequera char(3), 
a_fecha        date, 
a_tipo_remesa  char(1) default "A"
) returning integer,
            char(100);

define _cantidad	smallint;
define _no_caja		char(10);
define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

select count(*)
  into _cantidad
  from cobcieca
 where fecha        = a_fecha
   and cod_chequera = a_cod_chequera
   and tipo_remesa  = a_tipo_remesa;

if a_cod_chequera = '042' then
	let _cantidad = 0;
end if
if _cantidad = 0 then

	let _no_caja = sp_sis13("001", 'COB', '02', 'cob_no_caja');

	insert into cobcieca (fecha, cod_chequera, no_caja, tipo_remesa)
	values (a_fecha, a_cod_chequera, _no_caja, a_tipo_remesa);
end if

end

return 0, "Actualizacion Exitosa";

end procedure
