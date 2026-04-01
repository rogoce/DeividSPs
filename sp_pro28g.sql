-- CONSULTA DE PRIMAS POR COBRAR
-- Creado    : 22/04/2005 - Autor: Armando Moreno

--DROP PROCEDURE sp_pro28g;

CREATE PROCEDURE "informix".sp_pro28g(a_usuario CHAR(8)
) RETURNING	integer; -- cant. reg.

DEFINE _cant_reg         INTEGER;

SET ISOLATION TO DIRTY READ;


 SELECT count(*)
   INTO _cant_reg
   FROM emirepol
  WHERE user_added = a_usuario;

RETURN _cant_reg;

END PROCEDURE
