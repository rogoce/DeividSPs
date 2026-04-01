-- Endoso especial, sacar los dependientes

-- Creado    : 13/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro1007a;

CREATE PROCEDURE "informix".sp_pro1007a(a_no_poliza char(10))
returning varchar(100),char(5);


define _nombre			 varchar(100);

define _cod_asegurado 	 char(10);
define _cod_depen	 	 char(10);
define _no_unidad		 char(5);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202e.trc";
--trace on;

BEGIN


let _nombre = "";

foreach

	select cod_asegurado,
		   no_unidad
	  into _cod_asegurado,
		   _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

	foreach
		
		select cod_cliente
		  into _cod_depen
		  from emidepen
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and activo    = 1
		   and cont_beneficios = 1

		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_depen;

		return _nombre,_no_unidad with resume;

	end foreach

end foreach
END
END PROCEDURE
