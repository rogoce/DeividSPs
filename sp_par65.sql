-- Procedimiento que genera solo los errores de produccion
-- 
-- Creado     : 07/01/2003 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par65;		

CREATE PROCEDURE "informix".sp_par65()
		  	
DEFINE _no_poliza        CHAR(10); 
DEFINE _no_endoso        CHAR(5);
DEFINE _cod_tipoprod     CHAR(3);


Set Isolation To Dirty Read;

-- Actualizacion de cod_tipoprod en Endedmae

Foreach
 Select no_poliza,
        no_endoso
   Into _no_poliza,
        _no_endoso
   From	endedmae

 Select cod_tipoprod
   Into _cod_tipoprod
   From	emipomae
  Where no_poliza = _no_poliza;

	UPDATE endedmae
	   SET cod_tipoprod	= _cod_tipoprod
	 WHERE no_poliza	= _no_poliza
	   AND no_endoso    = _no_endoso;

End Foreach
 
END PROCEDURE;
