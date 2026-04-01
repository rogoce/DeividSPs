-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_wfh01;

	INSERT INTO emicarnet(
	cod_carnet,
	nombre
	)
	SELECT cod_subramo,
		   nombre
	  FROM prdsubra
	 WHERE cod_ramo = "018";


--CREATE PROCEDURE "informix".sp_wfh01(a_no_caso char(10))
--returning smallint;

--define _cant			integer;

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;


--SELECT count(*)
{  INTO _cant
  FROM helpdesk2
 WHERE no_caso = a_no_caso
   AND atendiendo = 1;

If _cant > 0 Then
	return 1;
Else	
	return 0;
End If

end procedure}