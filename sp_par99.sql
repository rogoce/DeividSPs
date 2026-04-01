--- Procedure que realiza el cambio de promotorias y crea el historico

-- Creado    : 19/05/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par99;

create procedure "informix".sp_par99(
a_cod_agente	char(5),
a_cod_vend_v	char(3),
a_cod_vend_n	char(3),
a_user_added	char(8),
a_cod_tiporamo	char(3),
a_cod_agencia	char(3)
) returning integer,
			char(50);

define _error		integer;
define _cod_agente	char(5);
define _cod_ramo	char(3);

begin
on exception set _error
	return _error, "Error al Actualizar las Promotorias";
end exception

create temp table tmp_cambio(
cod_agente	char(5)
) with no log;

foreach
 select cod_agente
   into _cod_agente
   from parpromo
  where cod_vendedor = a_cod_vend_v
    and cod_agente   matches a_cod_agente
  group by cod_agente
	
	insert into tmp_cambio
	values (_cod_agente);

end foreach

if a_cod_tiporamo is null then
	let a_cod_tiporamo = "*";
end if

if a_cod_agencia is null then
	let a_cod_agencia = "*";
end if

If a_cod_tiporamo <> "*" Then
	foreach
	 select cod_agente
	   into _cod_agente
	   from tmp_cambio

		foreach
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo matches a_cod_tiporamo 
		
			update parpromo
			   set cod_vendedor = a_cod_vend_n
			 where cod_agente   = _cod_agente
			   and cod_agencia  matches a_cod_agencia
			   and cod_ramo     = _cod_ramo
			   and cod_vendedor = a_cod_vend_v;


			if a_cod_agencia = "001" then

				update parpromo
				   set cod_vendedor = a_cod_vend_n
				 where cod_agente   = _cod_agente
				   and cod_agencia  = "004"
				   and cod_ramo     = _cod_ramo
				   and cod_vendedor = a_cod_vend_v;

			end if

			{
			insert into parprohi(
			cod_agente,
			cod_vend_viejo,
			cod_vend_nuevo,
			user_added,
			date_added
			)
			values(
			_cod_agente,
			a_cod_vend_v,
			a_cod_vend_n,
			a_user_added,
			today
			);
			}

		end foreach

	end foreach
else
	foreach
	 select cod_agente
	   into _cod_agente
	   from tmp_cambio

		foreach
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo matches a_cod_tiporamo 

        if _cod_ramo = "008" or _cod_ramo = "080" then -- Cuando no se filtre por ramo no cambiar promo de fianza David 08/02/2008
			continue foreach;  
		end if
		
			update parpromo
			   set cod_vendedor = a_cod_vend_n
			 where cod_agente   = _cod_agente
			   and cod_agencia  matches a_cod_agencia
			   and cod_ramo     = _cod_ramo
			   and cod_vendedor = a_cod_vend_v;


			if a_cod_agencia = "001" then

				update parpromo
				   set cod_vendedor = a_cod_vend_n
				 where cod_agente   = _cod_agente
				   and cod_agencia  = "004"
				   and cod_ramo     = _cod_ramo
				   and cod_vendedor = a_cod_vend_v;

			end if

			{
			insert into parprohi(
			cod_agente,
			cod_vend_viejo,
			cod_vend_nuevo,
			user_added,
			date_added
			)
			values(
			_cod_agente,
			a_cod_vend_v,
			a_cod_vend_n,
			a_user_added,
			today
			);
			}

		end foreach

	end foreach
end if

end

drop table tmp_cambio;
 
return 0,
 	   "Actualizacion Exitosa ...";

end procedure