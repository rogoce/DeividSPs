-- CONSULTA DE PRIMAS POR COBRAR
-- Creado    : 07/04/2009 - Autor: Armando Moreno

--DROP PROCEDURE sp_pro28n;

CREATE PROCEDURE "informix".sp_pro28n(a_tipo_ramo char(1))
 RETURNING	integer; -- cant. reg.

DEFINE _cant_reg         INTEGER;
DEFINE a_usuario         char(8);
define _cant_reg_tot     integer;

SET ISOLATION TO DIRTY READ;

let _cant_reg_tot = 0;

foreach

	select distinct(usuario)
	  into a_usuario
	  from emiredis
	 where cod_sucursal = '001'
	   and tipo_ramo    = a_tipo_ramo

	SELECT count(*)
	  INTO _cant_reg
	  FROM emirepo
	 WHERE user_added = a_usuario;

	let _cant_reg_tot = _cant_reg_tot + _cant_reg;

end foreach

RETURN _cant_reg_tot;

END PROCEDURE
