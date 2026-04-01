-- Inclusion de los Registros de Coaseguro en endcoama

--DROP PROCEDURE sp_par16;

CREATE PROCEDURE "informix".sp_par16(
a_no_poliza CHAR(10),
a_no_endoso CHAR(5) 
)

DEFINE _no_cambio CHAR(3); 

BEGIN

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par16.trc";      
--TRACE ON;                                                                     

SET ISOLATION TO DIRTY READ;

SELECT MAX(no_cambio)
  INTO _no_cambio
  FROM emihcmm
 WHERE no_poliza  = a_no_poliza
   AND no_endoso <= a_no_endoso;

BEGIN 
ON EXCEPTION IN(-268)
END EXCEPTION

	INSERT INTO endcoama
	SELECT 
	no_poliza,
	a_no_endoso,
	cod_coasegur,
	porc_partic_coas,
	porc_gastos
	FROM emihcmd
    WHERE no_poliza = a_no_poliza
      AND no_cambio = _no_cambio;

END 

END

END PROCEDURE;