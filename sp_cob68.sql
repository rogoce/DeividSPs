-- Listado de Direcciones de Cobros

-- Creado    : 01/06/2001 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_cob68;

CREATE PROCEDURE "informix".sp_cob68(
a_periodo  CHAR(7)
)RETURNING CHAR(20),	 -- No_documento
		  CHAR(50),	     -- Nombre del cliente
		  CHAR(50),	     -- Direccion_1
		  CHAR(50),	     -- Direccion_2
		  CHAR(20),      -- Apartado
		  CHAR(10);      -- telefono
		  			  		         
DEFINE _no_documento	  CHAR(20);
DEFINE _cod_contratante	  CHAR(10);
DEFINE _nombre_cliente    CHAR(50);
DEFINE _direccion_1		  CHAR(50);
DEFINE _direccion_2       CHAR(50);
DEFINE _apartado          CHAR(20);
DEFINE _telefono1         CHAR(10); 
DEFINE _no_poliza         CHAR(10);

FOREACH
 SELECT no_documento,
        cod_contratante,
		no_poliza
   INTO _no_documento,
        _cod_contratante,
		_no_poliza
   FROM emipomae
  WHERE cod_formapag = '004'
    AND periodo      = a_periodo

  SELECT nombre
    INTO _nombre_cliente
    FROM cliclien
   WHERE cod_cliente = _cod_contratante;

   SELECT direccion_1,
          direccion_2,
    	  apartado,
		  telefono1
	 INTO _direccion_1,
	      _direccion_2,
		  _apartado,
		  _telefono1
	 FROM emidirco
	WHERE no_poliza = _no_poliza;

		RETURN 
		 _no_documento,
		 _nombre_cliente,
		 _direccion_1,
		 _direccion_2,
		 _apartado,
		 _telefono1
		 WITH RESUME;

END FOREACH
END PROCEDURE;