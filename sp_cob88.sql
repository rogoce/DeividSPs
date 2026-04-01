-- Procedimiento para el concurso de cobros
--
-- Creado    : 06/07/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 06/07/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob88;

CREATE PROCEDURE "informix".sp_cob88()
	   RETURNING   CHAR(100),
				   CHAR(20),
				   DATE,
				   DATE,
				   INT;
	               				 
 DEFINE _no_documento   CHAR(20);
 DEFINE _no_poliza      CHAR(10);
 DEFINE _fecha_ult_pago DATE;
 DEFINE _fecha          DATE;
 DEFINE _nombre         CHAR(100);
 DEFINE _cod_pagador    CHAR(10);
 DEFINE _flag           SMALLINT;
 DEFINE _cod_agente     CHAR(5);

 BEGIN
 FOREACH WITH HOLD

 	SELECT no_documento,
	       no_poliza,
 	       cod_pagador,  
	       fecha_ult_pago
	  INTO _no_documento,
	       _no_poliza,
	       _cod_pagador,
	       _fecha_ult_pago
	  FROM emipomae
	 WHERE fecha_ult_pago >= '01/07/2002'
	   AND cod_ramo NOT IN('018','019')
	   AND cod_grupo <> '00000'
	   AND cod_formapag <> '046'
	   AND cod_tipoprod <> '002'

   FOREACH
	SELECT a.fecha
	  INTO _fecha
	  FROM cobremae a, cobredet b
	 WHERE b.no_poliza = _no_poliza
	   AND a.no_remesa = b.no_remesa
	   AND a.fecha < '01/07/2002'
	 ORDER BY a.fecha DESC
	 EXIT FOREACH;
   END FOREACH

   LET _flag = 0;

   FOREACH
	 SELECT cod_agente
	   INTO _cod_agente
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza

	 IF _cod_agente = '00521' THEN
   		LET _flag = 1;
		EXIT FOREACH;
	 END IF

   END FOREACH

   IF _flag = 0 THEN

	   SELECT nombre 
	     INTO _nombre
		 FROM cliclien
		WHERE cod_cliente = _cod_pagador;

		RETURN _nombre,        
	           _no_documento,  
			   _fecha_ult_pago,
			   _fecha,
			   _fecha_ult_pago - _fecha         
	      WITH RESUME;

   END IF

 END FOREACH
 END
END PROCEDURE
