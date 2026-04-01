-- Procedimiento que crea los diferentes valores para
-- las promotorias de los corredores
-- Por Agencia y Ramo

-- Creado    : 29/08/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 29/08/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_agentes - DEIVID, S.A.

drop procedure sp_par82;
create procedure sp_par82(
a_cod_agente 	char(5),
a_user_added	char(8)
) returning smallint, char(100);

define _cod_ramo		char(3);
define _cod_agencia		char(3);
define _cod_vendedor	char(3);
define _cod_zona		char(3);
define _vend_fianzas	char(3);

define _vida			smallint;
define _general			smallint;
define _ramo_afecta		smallint;

define _error			integer;
define _cantidad		smallint;

set isolation to dirty read;

--set debug file to "sp_par82.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Actualizar las Promotorias ...";
end exception

--let _vend_fianzas  = "024";	-- Zona 8 se pone en comentario Armando 05/12/2018, debido a que Fianzas debe llevar el vendedor que tiene asignado el corredor.

select vida,
       general,
	   cod_vendedor,
	   cod_vendedor2
  into _vida,
       _general,
	   _cod_vendedor,
	   _cod_zona
  from agtagent
 where cod_agente = a_cod_agente;

delete from parpromo where cod_agente = a_cod_agente;

let _vend_fianzas  = _cod_vendedor;

foreach
 select sucursal_promotoria
   into _cod_agencia
   from insagen
  group by 1
  order by 1

	-- Insercion de los Ramos de Vida

{
	if _vida = 1 then

		let _cod_vendedor = null;

	   foreach
		select cod_vendedor
		  into _cod_vendedor
		  from agtvende
		 where cod_sucursal = _cod_agencia
		   and activo       = 1
		   and ramo_afecta  in (0)
			exit foreach;
		end foreach
					
	else

		let _cod_vendedor = "030";

	end if
}

	foreach
	 select cod_ramo
	   into _cod_ramo
	   from prdramo
	  where cod_tiporamo = "001"

		select count(*)
		  into _cantidad
		  from parpromo
		 where cod_agente  = a_cod_agente
		   and cod_agencia = _cod_agencia
		   and cod_ramo    = _cod_ramo;

		if _cantidad = 0 then

			insert into parpromo(
			cod_agente,
			cod_agencia,
			cod_ramo,
			cod_vendedor,
			date_added,
			user_added
			)
			values(
			a_cod_agente,
			_cod_agencia,
			_cod_ramo,
			_cod_zona,
			current,
			a_user_added
			);

		end if

	end foreach

	-- Insercion de los Ramos Generales

{
	if _general = 1 then

		let _cod_vendedor = null;

	   foreach
		select cod_vendedor
		  into _cod_vendedor
		  from agtvende
		 where cod_sucursal = _cod_agencia
		   and activo       = 1
		   and ramo_afecta  in (0)
			exit foreach;
		end foreach

	else

		let _cod_vendedor = "031";

	end if
}

	foreach
	 select cod_ramo
	   into _cod_ramo
	   from prdramo
	  where cod_tiporamo = "002"

		select count(*)
		  into _cantidad
		  from parpromo
		 where cod_agente  = a_cod_agente
		   and cod_agencia = _cod_agencia
		   and cod_ramo    = _cod_ramo;

		if _cantidad = 0 then

			insert into parpromo(
			cod_agente,
			cod_agencia,
			cod_ramo,
			cod_vendedor,
			date_added,
			user_added
			)
			values(
			a_cod_agente,
			_cod_agencia,
			_cod_ramo,
			_cod_vendedor,
			current,
			a_user_added
			);

		end if

	end foreach

	-- Insercion de las Fianzas

{
	if _general = 1 then

		let _cod_vendedor = null;

	   foreach
		select cod_vendedor
		  into _cod_vendedor
		  from agtvende
		 where activo       = 1
		   and ramo_afecta  in (3)
			exit foreach;
		end foreach

	else

		let _cod_vendedor = "031";

	end if
}

	foreach
	 select cod_ramo
	   into _cod_ramo
	   from prdramo
	  where cod_tiporamo = "003"

		select count(*)
		  into _cantidad
		  from parpromo
		 where cod_agente  = a_cod_agente
		   and cod_agencia = _cod_agencia
		   and cod_ramo    = _cod_ramo;

		if _cantidad = 0 then

			insert into parpromo(
			cod_agente,
			cod_agencia,
			cod_ramo,
			cod_vendedor,
			date_added,
			user_added
			)
			values(
			a_cod_agente,
			_cod_agencia,
			_cod_ramo,
			_vend_fianzas,
			current,
			a_user_added
			);

		end if

	end foreach

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure;