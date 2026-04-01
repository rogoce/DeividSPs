-- Busqueda del caso mas viejo cuando le dan nuevo programa de consulta de reclamos.

-- Creado    : 17/10/2006 - Autor: Armando Moreno.

DROP PROCEDURE sp_rec124a;

CREATE PROCEDURE "informix".sp_rec124a(a_user char(8))
returning integer;

define _cod_asignacion	 char(10);
define _date_added       datetime year to fraction(5);
define _fecha_time       datetime year to fraction(5);
define _cod_ajustador    char(3);
define _cantidad	     integer;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec124.trc";
--trace on;

let _fecha_time = CURRENT;
let _cantidad   = 0;
let a_user      = trim(a_user);

select cod_ajustador	--busca el codigo de ajustador del usuario que entro.
  into _cod_ajustador
  from recajust
 where usuario = a_user
   and activo  = 1;

SELECT count(*)			--busca si hay uno pendiente.
  INTO _cantidad
  FROM atcdocde
 WHERE cod_ajustador      = _cod_ajustador
   AND ajustador_asignado = 1
   AND completado         = 0
   AND suspenso           <> 1;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   foreach
	SELECT cod_asignacion,
		   date_added
	  INTO _cod_asignacion,
	       _date_added
	  FROM atcdocde
	 WHERE cod_ajustador      = _cod_ajustador
	   AND ajustador_asignado = 1
	   AND completado         = 0
       AND suspenso           <> 1
	 ORDER BY date_added

	exit foreach;
   end foreach

	update atcdocde
	   set ajustador_fecha = _fecha_time
	 where cod_asignacion  = _cod_asignacion;

end if

Return 0;

END PROCEDURE
