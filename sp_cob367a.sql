-- Procedimiento que crear una gestion en Ccobgesti
-- Creado    : 29/05/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cob367a;

CREATE PROCEDURE "informix".sp_cob367a(a_no_documento varchar(20),
								   a_no_poliza    char(10),
								   a_cod_campana  char(3),
								   a_user_proceso char(15))
RETURNING integer,
          char(100); 
		      
DEFINE _cod_pagador		 	char(10);
DEFINE _bitacora		 	char(255);
DEFINE _nombre              CHAR(50);
DEFINE _hay_pago		 	integer;
DEFINE _fecha_actual		date;
DEFINE _fecha_gestion    	datetime year to second;
DEFINE _fecha_gestion2	 	datetime year to second;


LET _fecha_actual	= sp_sis26();
LET _fecha_gestion2	= _fecha_actual;

LET _fecha_gestion  = current year to second;
LET _fecha_gestion  = _fecha_gestion + 1 units second;		

If _fecha_gestion = _fecha_gestion2 Then
	LET _fecha_gestion  = _fecha_gestion + 1 units second;
End If

LET _fecha_gestion2 = _fecha_gestion;	

SELECT nombre
  INTO _nombre 
FROM cobcampa
WHERE cod_campana = a_cod_campana;


LET _bitacora = "CONVERSION DE CARTERA ELECTRONICA:  "|| _nombre;

SELECT cod_pagador
  INTO _cod_pagador
  FROM emipomae
 WHERE trim(no_poliza) = a_no_poliza;

SELECT count(*)
  INTO _hay_pago
  FROM cobgesti
 WHERE no_poliza = a_no_poliza
   AND fecha_gestion = _fecha_gestion;

If _hay_pago = 0 Then
	INSERT INTO cobgesti(
		   no_poliza,
		   fecha_gestion,
		   desc_gestion,
		   user_added,
		   no_documento,
		   fecha_aviso,
		   tipo_aviso,
		   cod_gestion,
		   cod_pagador)
	VALUES(
		   a_no_poliza,
		   _fecha_gestion,
		   _bitacora,
		   a_user_proceso,
		   a_no_documento,
		   '',
		   0,
		   null,
		   _cod_pagador);
End If

return 0, "Actualizacion Exitosa ...";
	  
END PROCEDURE;