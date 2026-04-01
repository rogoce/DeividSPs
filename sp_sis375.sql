-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  

drop procedure sp_sis375;

create procedure "informix".sp_sis375(a_poliza CHAR(10)) RETURNING CHAR(25),CHAR(20);
--}
DEFINE _firma  CHAR(25);
DEFINE _ls_autoriza CHAR(20);
DEFINE _ls_cotizacion CHAR(10);
DEFINE _li_cotizacion int;	 
DEFINE _cod_ramo CHAR(3);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;


FOREACH WITH HOLD
	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = a_poliza

	SELECT TRIM(usuario)
	  INTO _ls_autoriza
	  FROM prdfirma
	 WHERE cod_ramo = _cod_ramo;

	SELECT firma
	  INTO _firma
	  FROM wf_firmas
	 WHERE usuario = _ls_autoriza;
	 
	   LET _firma = "C:\DEIVID\" || _firma;

	   IF _ls_autoriza IS NULL THEN
		LET _ls_autoriza = ""; 
	   END IF

	RETURN _firma,
	       _ls_autoriza
		   WITH RESUME;

END FOREACH
end procedure;
