-- Procedimiento que Realiza la insercion a la tabla de Eminotas la obs. de la renovacion automatica

-- Creado    : 26/08/2011 - Autor: Armando Moreno

drop procedure sp_sis157;

create procedure "informix".sp_sis157(
v_no_poliza      char(10), 
v_no_poliza_vjo  char(10),
v_no_documento   char(20),
v_usuario        char(8)
)
RETURNING INTEGER;

--}

--- Actualizacion de Polizas


define _error        smallint;
define _observacion  char(255);
define _no_notas     char(10);
define _fecha        date;


--SET DEBUG FILE TO "sp_sis157.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

let _observacion = null;
let _fecha = current;

select observacion
  into _observacion
  from emirepo
 where no_poliza = v_no_poliza_vjo;

if _observacion is not null then

   let _observacion = trim(_observacion);

   if _observacion <> "" then

		LET _no_notas = sp_sis158("001", 'PRO', '02', 'par_notas');
		 
		 insert into eminotas(
		 no_notas,
		 no_documento,
		 no_poliza,
		 date_added,
		 user_added,
		 descripcion,
		 procesado,
		 user_proceso,
		 date_proceso
	     )	
         values (
         _no_notas,
         v_no_documento,
         v_no_poliza,		
         _fecha,       		
		 v_usuario,
		 _observacion,
		 1,
		 v_usuario,
		 _fecha
		 );
   end if

end if

END
RETURN 0;
end procedure;
