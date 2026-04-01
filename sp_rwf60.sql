-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  

drop procedure sp_rwf60;

create procedure "informix".sp_rwf60(a_no_tranrec CHAR(10)) 
RETURNING CHAR(25),
          CHAR(25),
          CHAR(25),
          CHAR(30),
          CHAR(30),
          CHAR(30);
--}
DEFINE _firma        CHAR(25);
DEFINE _firma2       CHAR(25);
DEFINE _firma3       CHAR(25);
DEFINE _descripcion  CHAR(30);
DEFINE _descripcion2 CHAR(30);
DEFINE _descripcion3 CHAR(30);
DEFINE _wf_aprobado  SMALLINT;
DEFINE _user_added   CHAR(8);
DEFINE _wf_apr_j     CHAR(8);
DEFINE _wf_apr_jt    CHAR(8);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

--FOREACH WITH HOLD
	SELECT wf_aprobado,
	       user_added,
		   wf_apr_j,
		   wf_apr_jt
	  INTO _wf_aprobado,
		   _user_added,
		   _wf_apr_j,
		   _wf_apr_jt
	  FROM rectrmae
	 WHERE no_tranrec = a_no_tranrec;

    SELECT descripcion,
	       windows_user
      INTO _descripcion,
	       _firma
      FROM insuser
     WHERE usuario = _user_added;  

    SELECT descripcion,
	       windows_user
      INTO _descripcion2,
	       _firma2
      FROM insuser
     WHERE usuario = _wf_apr_j;  

    SELECT descripcion,
	       windows_user
      INTO _descripcion3,
	       _firma3
      FROM insuser
     WHERE usuario = _wf_apr_jt;  

     IF _user_added IS NULL THEN
		LET _user_added = "";
	 END IF

     IF _wf_apr_j IS NULL THEN
		LET _wf_apr_j = "";
	 END IF

     IF _wf_apr_jt IS NULL THEN
		LET _wf_apr_jt = "";
	 END IF

     IF _firma IS NULL THEN
		LET _firma = "";
	 END IF

     IF _firma2 IS NULL THEN
		LET _firma2 = "";
	 END IF

     IF _firma3 IS NULL THEN
		LET _firma3 = "";
	 END IF

	RETURN _firma,
		   _firma2,
		   _firma3,
		   _descripcion, 
		   _descripcion2,
		   _descripcion3;
--		   WITH RESUME;

--END FOREACH
end procedure;
