-- Buscar numero de solicitud dada un numero de documento

-- Creado    : 11/04/2011 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro208;

CREATE PROCEDURE "informix".sp_pro208(a_no_doc char(20))
returning char(10);


define _nombre			 varchar(100);

define _no_poliza 	  char(10);
define _no_evaluacion char(10);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202e.trc";
--trace on;

BEGIN

let _no_evaluacion = "";

foreach

	select no_poliza
	  into _no_poliza
	  from emipomae
	 where no_documento = a_no_doc
	   and actualizado = 1

   foreach
	select no_evaluacion
	  into _no_evaluacion
	  from emievalu
	 where no_poliza = _no_poliza


	 if _no_evaluacion is not null then
		exit foreach;
	 end if


   end foreach

end foreach

return _no_evaluacion;

END
END PROCEDURE
