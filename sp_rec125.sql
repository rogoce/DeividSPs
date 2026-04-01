-- Actualizar en tabla atcdocde/atcdocma

-- Creado    : 02/08/2006 - Autor: Armando Moreno.

DROP PROCEDURE sp_rec125;

CREATE PROCEDURE sp_rec125(a_cod_asignacion char(10))
returning integer,char(100);

define _fecha_time       datetime year to fraction(5);
define _error_code		 smallint;
define _cod_entrada      char(10);
define _cantidad         integer;
define _suspenso		 smallint;
define _monto_tot        decimal(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec125.trc";
--trace on;

let _fecha_time = CURRENT;
let _cantidad   = 0;

BEGIN

ON EXCEPTION SET _error_code
 	RETURN _error_code, 'Error al Actualizar la Asignacion'; 
END EXCEPTION

SELECT suspenso
  INTO _suspenso
  FROM atcdocde
 WHERE cod_asignacion = a_cod_asignacion;

if _suspenso is null then
	let _suspenso = 0;
elif _suspenso = 1 then	--asignacion en suspenso, no se puede salvar.
	RETURN 1, 'Asignacion esta en Suspenso, no se puede Salvar...'; 
end if

SELECT count(*)
  INTO _cantidad
  FROM rectrmae
 WHERE cod_asignacion = a_cod_asignacion;

if _cantidad = 0 then

	RETURN 1, 'Esta Asignacion no tiene transacciones creadas, no se puede Salvar...'; 

end if

update atcdocde
   set completado       = 1,
       fecha_completado = _fecha_time
 where cod_asignacion 	= a_cod_asignacion;

SELECT count(*)
  INTO _cantidad
  FROM recrcmae
 WHERE cod_asignacion = a_cod_asignacion;

{if _cantidad = 0 then

	RETURN 1, 'Esta Asignacion no tiene reclamos creados, no se puede Salvar...'; 

end if}

foreach

	SELECT cod_entrada
	  INTO _cod_entrada
	  FROM atcdocde
	 WHERE cod_asignacion = a_cod_asignacion

exit foreach;
end foreach

SELECT count(*)			--busca si se completo todo el bloque.
  INTO _cantidad
  FROM atcdocde
 WHERE cod_entrada = _cod_entrada
   AND completado  = 0;

if _cantidad > 0 then	--no se ha completado
else
	SELECT sum(monto)
	  INTO _monto_tot
	  FROM atcdocde
	 WHERE cod_entrada = _cod_entrada
	   AND completado  = 1;

	update atcdocma
	   set completado  = 1,
	       monto       = _monto_tot
	 where cod_entrada = _cod_entrada;
end if

RETURN 0, 'Actualizacion Exitosa ...'; 

END
END PROCEDURE
