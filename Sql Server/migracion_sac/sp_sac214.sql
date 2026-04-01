-- **********************************
-- Procedimiento que Genera el listado de cuentas permitida por usuarios
-- Creado : Henry Giron Fecha : 28/03/2012
-- d_sac_sp_sac214_dw1
-- *********************************
DROP PROCEDURE sp_sac214; 
CREATE PROCEDURE sp_sac214(a_db char(18), a_usuario CHAR(15)) 
RETURNING char(50),
	      char(12),
	      char(1);

define _cta_nombre   char(50);
define _cta_cuenta   char(12);
define _cta_recibe   char(1);

define _error		 integer;
define _error_desc	 char(50);
 
SET ISOLATION TO DIRTY READ;

 
	FOREACH 
	  SELECT cta_nombre,   
	         cta_cuenta,   
	         cta_recibe
	    INTO _cta_nombre,
	    	 _cta_cuenta,
	    	 _cta_recibe     
	    FROM cglcuentas  
	   WHERE cglcuentas.cta_recibe <> 'N'    
	  
	  RETURN _cta_nombre,
	         _cta_cuenta,
	         _cta_recibe  
	    WITH RESUME;	      

	END FOREACH

--drop table tmp_cglcuentas;

END PROCEDURE
  