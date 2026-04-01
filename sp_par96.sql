-- Procedimiento que crea los diferentes valores para
-- las promotorias de los corredores
-- Por Agencia y Ramo

-- Creado    : 29/08/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 29/08/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_agentes - DEIVID, S.A.

drop procedure sp_par96;

create procedure "informix".sp_par96() returning smallint, char(100);

define _cod_agente 		char(5);
define _cod_ramo		char(3);
define _cod_agencia		char(3);
define _cod_vendedor	char(3);

define _vida			smallint;
define _general			smallint;
define _ramo_afecta		smallint;
define _error			integer;
define _cantidad		smallint;
define _nombre			char(100);

set isolation to dirty read;

--set debug file to "sp_par96.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Actualizar las Promotorias ...";
end exception

-- Cambios para la Sucursal de Panama y los Ramos de Vida y Danos
-- Excluyendo las Sucursales y el Ramo de Fianzas

let _cod_agencia = "001";

-- Inicializar todos los vendedores a Oficina de Daños y de Salud
{

foreach
 select vida,
        general,
		cod_agente
   into _vida,
        _general,
		_cod_agente
   from agtagent

	-- Ramos de Vida

	if _vida = 1 then

		let _cod_vendedor = "028";

		foreach
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo = "001"

		    update parpromo
			   set cod_vendedor = _cod_vendedor
			 where cod_agente   = _cod_agente
			   and cod_agencia  = _cod_agencia
			   and cod_ramo     = _cod_ramo;

		end foreach

	end if

	-- Ramos Generales

	if _general = 1 then

		let _cod_vendedor = "018";

		foreach
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo = "002"

		    update parpromo
			   set cod_vendedor = _cod_vendedor
			 where cod_agente   = _cod_agente
			   and cod_agencia  = _cod_agencia
			   and cod_ramo     = _cod_ramo;

		end foreach

	end if

end foreach
}

-- Actualizar la informacion con los nuevos Valores

foreach
 select codigo,
        vida
   into _cod_agente,
        _cod_vendedor
   from parpro04
	
	select vida
	  into _vida
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nombre
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	if _nombre is not null then

		if _vida = 1 then

			foreach
			 select cod_ramo
			   into _cod_ramo
			   from prdramo
			  where cod_tiporamo = "001"

			    update parpromo
				   set cod_vendedor = _cod_vendedor
				 where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

			end foreach

		end if
		
	end if

end foreach

foreach
 select codigo,
        danos
   into _cod_agente,
        _cod_vendedor
   from parpro04
	
	select general
	  into _general
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nombre
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	if _nombre is not null then

		if _general = 1 then

			foreach
			 select cod_ramo
			   into _cod_ramo
			   from prdramo
			  where cod_tiporamo = "002"

			    update parpromo
				   set cod_vendedor = _cod_vendedor
				 where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

			end foreach

		end if
		
	end if

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure;