-- Procedimiento que Actualiza la Remesa de Cobros
-- 
-- Creado    : 14/01/2008 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--{
DROP PROCEDURE sp_cob208;		

CREATE PROCEDURE "informix".sp_cob208(a_no_remesa CHAR(10), a_usuario CHAR(8))
RETURNING INTEGER,
		  CHAR(100);
