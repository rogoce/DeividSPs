-- Procedimiento para actualizar en Parpromo 

-- Creado    : 05/12/2018 - Autor: Armando Moreno M.

drop procedure sp_sis243a;
create procedure "informix".sp_sis243a()
returning integer, char(250);

define _mensaje		char(250);
define _cod_agente	char(5);
define _cod_vendedor	char(3);
define _cod_zona_per	char(3);
define _cod_compania	char(3);
define _error			integer;

set isolation to dirty read;

--set debug file to "sp_sis243a.trc";      
--trace on;

foreach
	select cod_agente,
			cod_vendedor,
			cod_vendedor2
	  into _cod_agente,
	       _cod_vendedor,
		   _cod_zona_per
	  from agtagent

	if _cod_zona_per is null then
		let _cod_zona_per = _cod_vendedor;
	end if

	call sp_par83a(_cod_agente,_cod_zona_per,_cod_vendedor,_cod_vendedor) returning _error,_mensaje;
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end procedure;