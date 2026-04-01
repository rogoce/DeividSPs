-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_rwf72;
CREATE PROCEDURE "informix".sp_rwf72(a_no_tranrec char(10))
returning char(10);

define v_cod_asignacion	   	char(10);
define _no_reclamo			char(10);

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;
 	SELECT cod_asignacion, no_reclamo
      INTO v_cod_asignacion, _no_reclamo
	  FROM rectrmae
	 WHERE no_tranrec = a_no_tranrec;

    if v_cod_asignacion is null then
		select cod_asignacion
		  into v_cod_asignacion
		  from recrcmae
		 where no_reclamo = _no_reclamo;
	end if
	  
	RETURN v_cod_asignacion;
end procedure