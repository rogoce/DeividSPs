-- Actualizando los valores de las cartas de Salud en emicartasal2
-- Creado    : 12/12/2010 - Autor: Henry Giron.
-- Modificado: 12/12/2010 - Autor: Henry Giron.
-- SIS v.2.0 -  - DEIVID, S.A.	 copia sp_pro501

DROP PROCEDURE sp_pro4943;
CREATE PROCEDURE sp_pro4943(a_no_documento CHAR(20), a_periodo CHAR(7), a_subramos varchar(15) default null)
RETURNING smallint, char(25);
DEFINE _error 				smallint; 
DEFINE _e_mail              varchar(50);
DEFINE v_e_mail             varchar(255);
DEFINE _no_poliza			CHAR(10);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _cod_agente       	CHAR(10);

--set debug file to "sp_pro172.trc";
set lock mode to wait;

BEGIN
ON EXCEPTION SET _error    		
 	RETURN _error, "Error al Actualizar";         
END EXCEPTION 

IF trim(a_no_documento) = "*" THEN
	UPDATE emicartasal2
	   SET impreso = 1
	 WHERE periodo  = trim(a_periodo)
	   AND cod_subramo in (a_subramos);
ELSE 
	UPDATE emicartasal2
	   SET impreso = 1
	 WHERE no_documento  = trim(a_no_documento);
END IF   

END

RETURN 0,"Proceso Exitoso";

END PROCEDURE;