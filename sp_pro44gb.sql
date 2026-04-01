-- Procedimiento para buscar beneficiarios
-- Creado    : 26/12/2017    - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.  d_prod_benefact_dw1/sis_emision4
  
DROP PROCEDURE sp_pro44gb;
CREATE PROCEDURE "informix".sp_pro44gb(a_poliza CHAR(10), a_unidad CHAR(5))
RETURNING   CHAR(50),			 -- _beneficiario
			DEC(16,2),			 -- _participacion
			CHAR(50);			 -- _parentesco

define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _porc_partic_ben dec(5,2);
define _beneficiario	char(50);
define _cod_parentesco	char(3);
define _parentesco		char(50);

BEGIN

SET ISOLATION TO DIRTY READ;
LET _beneficiario = null;
LET _parentesco = null;
LET _porc_partic_ben = null;

	select cod_ramo,
		   cod_subramo		   
	  into _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = a_poliza;	 
	 
 if _cod_ramo in ('004') and _cod_subramo in ('001') then 
 else
	if _cod_ramo not in ('019') then 
		RETURN _beneficiario,_porc_partic_ben,_parentesco; 
	end if
 end if

FOREACH
 SELECT porc_partic_ben,		
		cod_parentesco,
		nombre
   INTO _porc_partic_ben,		
		_cod_parentesco,
		_beneficiario
   FROM emibenef
  WHERE no_poliza = a_poliza
    AND no_unidad = a_unidad
	
		SELECT nombre  
		  INTO _parentesco
	      FROM emiparen   	
		 WHERE cod_parentesco = _cod_parentesco;

	RETURN _beneficiario,_porc_partic_ben,_parentesco
	  WITH RESUME;   	
end FOREACH


END
END PROCEDURE;