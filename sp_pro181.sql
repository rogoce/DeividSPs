-- devuelve la comision

-- Creado    : 19/04/2007 - Autor: Armando Moreno M

--DROP PROCEDURE sp_pro181;

CREATE PROCEDURE sp_pro181(a_producto    char(5))
RETURNING DEC(5,2);  -- Deuda 
			
DEFINE v_comision       DEC(5,2);

SET ISOLATION TO DIRTY READ;

LET v_comision = 0;

FOREACH
 SELECT	porc_comis_agt
   INTO	v_comision
   FROM	prdcoprd
  WHERE cod_producto = a_producto

	exit foreach;

END FOREACH

if v_comision is null then
	let v_comision = 0;
end if

RETURN v_comision;

END PROCEDURE;