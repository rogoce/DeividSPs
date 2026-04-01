--- Procedure que realiza el cambio de promotorias y crea el historico

-- Creado    : 19/05/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par99;

create procedure "informix".sp_par99(
a_cod_agente	char(5),
a_cod_vend_v	char(3),
a_cod_vend_n	char(3),
a_user_added	char(8)
) returning integer,
			char(50);

define _error	integer;

begin
on exception set _error
	return _error, "Error al Actualizar las Promotorias";
end exception

update parpromo
   set cod_vendedor = a_cod_vend_n
 where cod_vendedor = a_cod_vend_v
   and cod_agente   = a_cod_agente
   and cod_agencia  = "001";

insert into parprohi(
cod_agente,
cod_vend_viejo,
cod_vend_nuevo,
user_added,
date_added
)
values(
a_cod_agente,
a_cod_vend_v,
a_cod_vend_n,
a_user_added,
today
);

end

return 0,
 	   "Actualizacion Exitosa ...";

end procedure