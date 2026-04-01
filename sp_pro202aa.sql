-- No Aprobacion de de uno de los aspirantes

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro202aa;

CREATE PROCEDURE "informix".sp_pro202aa(a_no_eval char(10))
returning varchar(100),varchar(255),varchar(50);


define _nombre	 	 	varchar(100);
define _declinacion_obs	varchar(255);
define _cod_asegurado   char(10);
define _cod_parent      char(5);
define _n_paren			varchar(50);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202bb.trc";
--trace on;

BEGIN

foreach

	select cod_asegurado,
		   requisitos_obs,
		   cod_parentesco
	  into _cod_asegurado,
		   _declinacion_obs,
		   _cod_parent
	  from emievade
	 where no_evaluacion = a_no_eval

	select nombre
	  into _nombre
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _n_paren
	  from emiparen
	 where cod_parentesco = _cod_parent;

	if _declinacion_obs is null or _declinacion_obs = "" then
		continue foreach;
	end if

	return _nombre,
		   _declinacion_obs,
		   _n_paren
		    WITH RESUME;


end foreach

END
END PROCEDURE
