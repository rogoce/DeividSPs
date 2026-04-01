-- Procedimiento para traer la ayuda saldo agentes
--
-- Creado    : 26/06/2003 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 26/06/2003 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob116;

CREATE PROCEDURE "informix".sp_cob116(a_poliza CHAR(10))
	   RETURNING CHAR(5),
	             CHAR(100),
	             CHAR(3),
	             CHAR(50),
	             SMALLINT;

   DEFINE _cobra_poliza	 	CHAR(1);
   DEFINE v_cod_agente  	CHAR(5); 
   DEFINE v_agente      	CHAR(100);
   DEFINE v_cod_cobrador 	CHAR(3);
   DEFINE v_cobrador    	CHAR(50);
   define _nombre_agente	char(100);
   DEFINE _cod_tipoprod 	CHAR(3);
   DEFINE _tipo_produccion  smallint;
   DEFINE v_leasing         SMALLINT;
   	
   LET v_cod_cobrador = '';
   LET v_cobrador     = '';
   LET v_cod_agente   = ''; 
   LET v_agente       = '';

   SET ISOLATION TO DIRTY READ;
	   
   SELECT cobra_poliza,
          cod_tipoprod,
		  leasing
     INTO _cobra_poliza,
	      _cod_tipoprod,
		  v_leasing
     FROM emipomae
    WHERE no_poliza = a_poliza;

  SELECT tipo_produccion
    INTO _tipo_produccion
	FROM emitipro
   WHERE cod_tipoprod = _cod_tipoprod;

   If _tipo_produccion = 3 Then	 -- Coaseguro Minoritario
	LET _cobra_poliza = "Z";
   End If

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

	  LET v_cobrador     = 'CALL CENTER'; 
	  LET v_cod_cobrador = '';

   ELIF _cobra_poliza = 'G' THEN            

	  LET v_cobrador     = 'GERENCIA'; 
      LET v_cod_cobrador = '';

   ELIF _cobra_poliza = 'I' THEN            

	  LET v_cobrador     = 'INCOBRABLES'; 
      LET v_cod_cobrador = '';

   ELIF _cobra_poliza = 'T' THEN

	  LET v_cobrador     = 'TARJETA CREDITO'; 
      LET v_cod_cobrador = '';

   ELIF _cobra_poliza = 'H' THEN            

	  LET v_cobrador     = 'ACH'; 
      LET v_cod_cobrador = '';

   ELIF _cobra_poliza = 'P' THEN            

	  LET v_cobrador     = 'POR CANCELAR'; 
      LET v_cod_cobrador = '';

   ELIF _cobra_poliza = 'Z' THEN            

	  LET v_cobrador     = 'COASEGURO MINORITARIO'; 
      LET v_cod_cobrador = '';
 
   ELSE

      SELECT nombre 
	    INTO v_cobrador
		FROM cobcobra
	   WHERE cod_cobrador = v_cod_cobrador;

   END IF
	               
   RETURN v_cod_agente,  
		  v_agente,      
		  v_cod_cobrador,
		  v_cobrador,
		  v_leasing;    

END PROCEDURE
