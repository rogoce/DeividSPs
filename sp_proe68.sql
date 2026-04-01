-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/05/2012 - Autor: Amado Perez M.
-- SIS v.2.0 -  - DEIVID, S.A.
-- execute procedure sp_proe68("")

DROP PROCEDURE sp_proe68;
CREATE PROCEDURE sp_proe68( a_no_documento1 CHAR(20))
RETURNING CHAR(7),CHAR(20),varchar(255),varchar(50), smallint;

DEFINE _error 				smallint; 
DEFINE _e_mail              varchar(50);
DEFINE v_e_mail             varchar(255);
DEFINE _email2              varchar(50);

DEFINE _no_poliza			CHAR(10);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _cod_agente       	CHAR(10);
DEFINE _periodo             CHAR(7);
DEFINE _enviado_a           smallint;
DEFINE _asegurado           smallint;
DEFINE _corredor            smallint;
DEFINE a_no_documento       CHAR(20);

--set debug file to "sp_proe68.trc";

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 

foreach
 select no_documento,emails,periodo
   into a_no_documento,_email2,_periodo
   from emicartasal2   
  where periodo = '2012-07'  
    and enviado_a <> '2'
 
 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
 
 LET v_e_mail = "";  
 LET _e_mail = "";  
 LET _asegurado = 0;
 LET _corredor = 0;

  FOREACH
	  SELECT cod_asegurado 
	    INTO _cod_asegurado
		FROM emipouni
	   WHERE no_poliza = _no_poliza

         LET _e_mail = ""; 

	  SELECT e_mail
	    INTO _e_mail
		FROM cliclien
	   WHERE cod_cliente = _cod_asegurado;

      IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
		LET v_e_mail = v_e_mail || trim(_e_mail) || ";";
		LET _asegurado = 1;
	  ELSE
		LET _asegurado = 0;
	  END IF
  END FOREACH

 LET _e_mail = "";  

  {FOREACH		        	-- Se puso en comentario mientras se como arreglar los correos de los corredores. En espera de la solicitud de Fany -- Amado
	  SELECT cod_agente 
	    INTO _cod_agente
		FROM emipoagt
	   WHERE no_poliza = _no_poliza

	  SELECT e_mail
	    INTO _e_mail
		FROM agtagent
	   WHERE cod_agente = _cod_agente;

      IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
		LET v_e_mail = v_e_mail || trim(_e_mail) || ";";
		LET _corredor = 1;
	  ELSE
		LET _corredor = 0;
	  END IF
  END FOREACH}

IF _asegurado = 1 AND _corredor = 1 THEN
	LET _enviado_a = 1;
ELIF _asegurado = 1 AND _corredor = 0 THEN  
	LET _enviado_a = 2;
ELIF _asegurado = 0 AND _corredor = 1 THEN  
	LET _enviado_a = 3;
ELSE
	LET _enviado_a = 0;
END IF

RETURN _periodo,trim(a_no_documento),trim(v_e_mail),trim(_email2), _enviado_a WITH RESUME;

END FOREACH
END


END PROCEDURE;