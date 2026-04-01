-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cwf22;
CREATE PROCEDURE "informix".sp_cwf22()
returning DEC(16,2);

define _monto			dec(16,2);

SET DEBUG FILE TO "sp_cwf22.trc"; 
trACE ON;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION 
 	RETURN 'ERROR';         
END EXCEPTION           


SELECT limite_2
  INTO _monto
  FROM wf_aprodet
 WHERE cod_aprobacion = '005'
   AND grupo = "USUARIO";

return _monto;	
END
end procedure