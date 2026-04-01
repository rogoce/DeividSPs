-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_wfh01;
CREATE PROCEDURE "informix".sp_wfh01(a_no_caso char(10), a_user CHAR(8) DEFAULT NULL)
returning smallint,
          VARCHAR(30),
          VARCHAR(10);

define _cant			integer;
define _windows_user    VARCHAR(30);
define _tel_extenci     VARCHAR(10);

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;
SET ISOLATION TO DIRTY READ;

SELECT count(*)
  INTO _cant
  FROM helpdesk2
 WHERE no_caso = a_no_caso
   AND atendiendo = 1;

If a_user Is Null Then
	let _windows_user = null;
Else
	SELECT descripcion, tel_extenci
	  INTO _windows_user, _tel_extenci
	  FROM insuser
	 WHERE usuario = a_user;
End If 

If _cant > 0 Then
	return 1,
	       TRIM(_windows_user),
	       TRIM(_tel_extenci);
Else	
	return 0,
	       TRIM(_windows_user),
	       TRIM(_tel_extenci);
End If

end procedure