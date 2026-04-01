-- Procedimiento para actualizar en Parpromo para el ramo de Fianzas el ejecutivo que corresponde.

-- Creado    : 05/12/2018 - Autor: Armando Moreno M.

--drop procedure sp_sis243;
create procedure "informix".sp_sis243()
returning integer, char(250);

define _mensaje				char(250);
define _cod_agente			char(5);
define _cod_vendedor		char(3);
define _cod_compania		char(3);

set isolation to dirty read;

foreach
	select distinct cod_agente,
	       cod_vendedor
	  into _cod_agente,
	       _cod_vendedor
	  from parpromo
	 where cod_ramo <> '008'

	update parpromo
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente
	   and cod_ramo     = '008';
	 
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end procedure;