-- Depuracion promotorias plaza edison

-- Creado    : 07/07/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par225;

create procedure "informix".sp_par225()
returning integer,
          char(50);

define _cod_agente		char(5);
define _cod_agencia		char(3);
define _cod_ramo		char(3);
define _cod_tiporamo	char(3);
define _cod_vendedor    char(3);

define _vida			smallint;
define _general			smallint;

define _cantidad		integer;

let _cantidad = 0;

-- Verificaciones para Promotor Daños Plaza Edison

-- Lilibeth Fernandez (043) (07/07/2006)

foreach
 select	cod_ramo,
        cod_agencia,
		cod_vendedor,
		cod_agente
   into	_cod_ramo,
        _cod_agencia,
		_cod_vendedor,
		_cod_agente
   from	parpromo
  where cod_agencia  = "004"

	select cod_tiporamo
	  into _cod_tiporamo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cod_tiporamo = "002" then

		if _cod_vendedor <> "043" then

			select general
			  into _general
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			 if _general = 1 then
			  			
				let _cantidad     = _cantidad + 1;

				update parpromo
				   set cod_vendedor = "043"	-- Personas Plaza Edison
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

			end if

		end if

	end if
		
end foreach

-- Licencia Pendiente Personas

{
foreach
 select cod_agente 
   into _cod_agente
   from agtagent
  where vida = 0

	foreach
	 select cod_agencia,
	        cod_ramo,
			cod_vendedor
	   into _cod_agencia,
	        _cod_ramo,
			_cod_vendedor
	   from parpromo
	  where cod_agente = _cod_agente

		select cod_tiporamo
		  into _cod_tiporamo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _cod_tiporamo in ("001") then

			if _cod_vendedor <> "030" then

				let _cantidad     = _cantidad + 1;

				update parpromo
				   set cod_vendedor = "030"	-- Pendientes Danos
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

			end if

		end if

	end foreach

end foreach
}

-- Licencia Pendiente Danos

{
foreach
 select cod_agente 
   into _cod_agente
   from agtagent
  where general = 0

	foreach
	 select cod_agencia,
	        cod_ramo,
			cod_vendedor
	   into _cod_agencia,
	        _cod_ramo,
			_cod_vendedor
	   from parpromo
	  where cod_agente = _cod_agente

		select cod_tiporamo
		  into _cod_tiporamo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _cod_tiporamo in ("002", "003") then

			if _cod_vendedor <> "031" then

				let _cantidad     = _cantidad + 1;

				update parpromo
				   set cod_vendedor = "031"	-- Pendientes Danos
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

			end if

		end if

	end foreach

end foreach
}
{
let _cod_vendedor = "043";

foreach
 select	cod_ramo,
        cod_agencia,
		cod_agente
   into	_cod_ramo,
        _cod_agencia,
		_cod_agente
   from	parpromo
  where cod_vendedor = _cod_vendedor

	select cod_tiporamo
	  into _cod_tiporamo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cod_tiporamo = "001" then -- Personas

		if _cod_agencia in ("001", "004") then -- PE, CM

			let _cantidad     = _cantidad + 1;
	
			update parpromo
			   set cod_vendedor = "028"	-- Oficina Salud
		     where cod_agente   = _cod_agente
			   and cod_agencia  = _cod_agencia
			   and cod_ramo     = _cod_ramo;

		end if

	end if
		
end foreach
}
{
foreach
 select codigo
   into _cod_agente
   from deivid_tmp:pepromo

	foreach
	 select cod_ramo,
	        cod_agencia
	   into _cod_ramo,
	        _cod_agencia
	   from parpromo
	  where cod_agente   = _cod_agente
		and cod_agencia  = "001"       -- Casa Matriz

		select cod_tiporamo
		  into _cod_tiporamo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _cod_tiporamo = "002" then

			let _cod_vendedor = "043"; 
			let _cantidad     = _cantidad + 1;

			update parpromo
			   set cod_vendedor = "043"
		     where cod_agente   = _cod_agente
			   and cod_agencia  = _cod_agencia
			   and cod_ramo     = _cod_ramo;

		end if

	end foreach

end foreach
}

return _cantidad, " Registros Procesados, Actualizacion Exitosa";

end procedure