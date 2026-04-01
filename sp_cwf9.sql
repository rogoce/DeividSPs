-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_cwf3;
CREATE PROCEDURE "informix".sp_cwf9(a_cod_cliente char(10))
returning varchar(100);


define v_nombre			varchar(100);
--define _error			char(25);

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION 
 	RETURN 'ERROR';         
END EXCEPTION           


SELECT nombre
  INTO v_nombre
  FROM recprove
 WHERE cod_cliente    =  a_cod_cliente;

return trim(v_nombre);	

END
end procedure