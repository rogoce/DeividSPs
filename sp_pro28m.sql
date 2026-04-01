-- CONSULTA DE PRIMAS POR COBRAR
-- Creado    : 07/04/2009 - Autor: Armando Moreno

DROP PROCEDURE sp_pro28m;

CREATE PROCEDURE "informix".sp_pro28m(a_usuario CHAR(8), a_estatus smallint)
 RETURNING	integer; -- cant. reg.

DEFINE _cant_reg         INTEGER;
define _cant             integer;
define _tipo_ramo        char(1);
define _gerarquia        smallint;

SET ISOLATION TO DIRTY READ;

let _cant = 0;
LET _tipo_ramo = null;
let _gerarquia = null;

if a_usuario <> 'AUTOMATI' THEN

	foreach

		select tipo_ramo,
		       gerarquia
		  into _tipo_ramo,
		       _gerarquia
		  from emiredis
		 where usuario = a_usuario

	exit foreach;
	end foreach

	foreach

		select distinct(usuario)
		  into a_usuario
		  from emiredis
		 where tipo_ramo = _tipo_ramo
		   and gerarquia = _gerarquia

		 SELECT count(*)
		   INTO _cant_reg
		   FROM emirepo
		  WHERE user_added = a_usuario
		    AND estatus    = a_estatus;

		 let _cant = _cant + _cant_reg;

	end foreach

else
	 SELECT count(*)
	   INTO _cant_reg
	   FROM emirepo
	  WHERE user_added = a_usuario
	    AND estatus    = a_estatus;

	 let _cant = _cant_reg;

end if

RETURN _cant;

END PROCEDURE
