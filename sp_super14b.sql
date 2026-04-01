-- Informe de Reclamos por Ramo
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec03a_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_super14b;
CREATE PROCEDURE "informix".sp_super14b() 
RETURNING CHAR(18),CHAR(20),DATE; 

DEFINE v_numrecla        		CHAR(18);
DEFINE v_fecha_reclamo   		DATE; 
define _no_documento            char(20);
define _cnt                     smallint;

SET ISOLATION TO DIRTY READ;

FOREACH 
 	SELECT numrecla,
           no_documento,
		   fecha_reclamo
	  INTO v_numrecla,
	       _no_documento,
		   v_fecha_reclamo
	  FROM recrcmae
	 WHERE actualizado = 1
	   AND periodo >= '2016-01'
	   AND periodo <= '2016-12'
	   AND cod_sucursal = a_cod_sucursal

	select count(*)
	  into _cnt
	  from recpanasi
	 where no_documento = _no_documento;

	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then
		continue foreach;
	end if	

	RETURN v_numrecla,        
		   _no_documento,
		   v_fecha_reclamo   
		   WITH RESUME;

END FOREACH
END PROCEDURE;




