-- Procedure que graba los logs de cambios importantes

-- Creado: 03/02/2007 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_par243;

create procedure "informix".sp_par243(
a_usuario		char(8),
a_tabla			char(50),
a_campo			char(50),
a_valor_orig	char(50),
a_valor_nuevo	char(50)
) returning integer,
            char(100);

define _no_log		integer;
define _fecha		datetime year to second;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _no_log = sp_sis13("001", "PAR", "02", "PAR_CONT_LOG");
let _no_log = _no_log + 1;
let _fecha  = current;

insert into parlogs(
no_log,
fecha,
usuario,
tabla,
campo,
valor_orig,
valor_nuevo
)
values(
_no_log,
_fecha,
a_usuario,
a_tabla,
a_campo,
a_valor_orig,
a_valor_nuevo
);

end

return 0, "Actualizacion Exitosa";

end procedure