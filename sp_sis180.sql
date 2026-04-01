-- Busqueda del tipo que paga el ajustador

-- Creado    : 08/04/2013 - Autor: Armando Moreno.

DROP PROCEDURE sp_sis180;

CREATE PROCEDURE "informix".sp_sis180(a_cod_ajustador char(3))
returning integer, char(2);

define _cod_tipo	   char(3);
define _cantidad       integer;

--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_sis180.trc";
--trace on;

SET LOCK MODE TO WAIT;

let _cod_tipo = null;

BEGIN

foreach

	select cod_tipo
	  into _cod_tipo
	  from recsatiu
	 where cod_ajustador = a_cod_ajustador
	 
	 
	 select count(*)
	   into _cantidad
	   from atcdocde
	  WHERE ajustador_asignado = 0
	    AND completado         = 0
		AND ajustador_asignar  = 1
	    AND suspenso           <> 1
		AND en_mora            <> 1
		AND titulo is not null
		AND cod_tipo           = _cod_tipo;
	
	if _cantidad > 0 then
		exit foreach;
	end if
end foreach

if _cod_tipo is null or _cod_tipo = "" then

	return -4,"";

end if

Return 0,_cod_tipo;

END
END PROCEDURE
