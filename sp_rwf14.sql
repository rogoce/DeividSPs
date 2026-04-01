-- Procedimiento para traer la ayuda saldo agentes
--
-- Creado    : 26/06/2003 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 26/06/2003 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rwf14;

CREATE PROCEDURE "informix".sp_rwf14(a_poliza CHAR(10))
	   RETURNING CHAR(50),
	             VARCHAR(30);

   DEFINE _cobra_poliza	 	CHAR(1);
   DEFINE v_cod_agente  	CHAR(5); 
   DEFINE v_agente      	CHAR(100);
   DEFINE v_cod_cobrador 	CHAR(3);
   DEFINE v_cobrador    	CHAR(50);
   DEFINE v_email           VARCHAR(30);
   define _nombre_agente	char(100);
   	
   LET v_cod_cobrador = '';
   LET v_cobrador     = '';
   LET v_cod_agente   = ''; 
   LET v_agente       = '';

   SET ISOLATION TO DIRTY READ;
	   
   SELECT cobra_poliza
     INTO _cobra_poliza
     FROM emipomae
    WHERE no_poliza = a_poliza;

	let _nombre_agente = "";

   FOREACH
    SELECT cod_agente
      INTO v_cod_agente
	  FROM emipoagt
	 WHERE no_poliza = a_poliza

	   SELECT nombre
		 INTO v_agente
		 FROM agtagent
		WHERE cod_agente = v_cod_agente;

		let _nombre_agente = trim(_nombre_agente) || trim(v_agente) || " \ ";
		   
   END FOREACH

	let v_agente = _nombre_agente;

   SELECT cod_cobrador
	 INTO v_cod_cobrador
	 FROM agtagent
	WHERE cod_agente = v_cod_agente;
    
   IF _cobra_poliza = 'E' THEN

	  LET v_cobrador     = 'ANGELA'; 
	  LET v_cod_cobrador = '';

   ELSE

      SELECT usuario 
	    INTO v_cobrador
		FROM cobcobra
	   WHERE cod_cobrador = v_cod_cobrador;

   END IF

   SELECT e_mail
     INTO v_email
	 FROM insuser
	WHERE usuario = v_cobrador;
	               
   RETURN v_cobrador,
		  trim(v_email);    

END PROCEDURE
