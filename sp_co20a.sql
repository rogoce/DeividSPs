-- Cartas de Avisos 
-- Creado    : 02/10/2000 - Autor: Marquelda Valdelamar
-- Modificado: 06/11/2000
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_co20a;

CREATE PROCEDURE "informix".sp_co20a(a_cod_agente CHAR(5))
RETURNING CHAR(20);
 			  		         
DEFINE _no_poliza    CHAR(10);
DEFINE _cod_agente   CHAR(10);
DEFINE _no_documento CHAR(20);

FOREACH
 SELECT no_poliza,
        no_documento             
   INTO _no_poliza,
        _no_documento             
   FROM emipomae
  WHERE fecha_aviso_canc = '06/02/2001'

	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE cod_agente = a_cod_agente 
	   AND no_poliza  = _no_poliza;

	IF _cod_agente IS NOT NULL THEN
	
		RETURN _no_documento
		       WITH RESUME;

  		UPDATE emipomae                                 
  		   SET emipomae.carta_aviso_canc = 0,           
  			   emipomae.fecha_aviso_canc = null         
  		 WHERE emipomae.no_poliza        = _no_poliza;  

	END IF
END FOREACH
END PROCEDURE;