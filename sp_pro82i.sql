-- verificar si la unidad ya tiene una opcion escogida

-- CREADO: 17/02/2005 POR: Armando Moreno.

--drop procedure sp_pro82i;

create procedure "informix".sp_pro82i(
a_unidad 			char(5),
a_poliza 			char(10)
)
returning integer, char(50);

define r_error        SMALLINT;
define r_descripcion  CHAR(50);
define _opcion        SMALLINT;

BEGIN

SET ISOLATION TO DIRTY READ;
LET r_error = 0;
LET r_descripcion = '';

  SELECT opcion_final
	INTO _opcion
    FROM emireaut
   WHERE no_poliza = a_poliza
     AND no_unidad = a_unidad; 

  if _opcion is null or _opcion = 9 then
 	RETURN 1, "NO HA SELECCIONADO LA OPCION PARA LA UNIDAD: " || a_unidad;
  end if

return 0,r_descripcion;
END
end procedure;
