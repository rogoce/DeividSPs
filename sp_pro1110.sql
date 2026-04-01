-- Actualizando los valores de las cartas de Salud en emicartasal
-- Creado    : 12/12/2011 - Autor: Henry Giron.
-- Modificado: 12/12/2011 - Autor: Henry Giron	  copia de sp_pro500
-- SIS v.2.0 -  - DEIVID, S.A.
DROP PROCEDURE sp_pro1110;
CREATE PROCEDURE sp_pro1110(a_no_documento CHAR(20), a_emails lvarchar(500), a_enviado_a smallint default 0)
RETURNING smallint, char(25);

DEFINE _error 				smallint; 
DEFINE _e_mail              varchar(50);
DEFINE v_e_mail             varchar(255);
DEFINE _no_poliza			CHAR(10);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _cod_agente       	CHAR(10);

--set debug file to "sp_pro4942.trc";
set lock mode to wait;
BEGIN
ON EXCEPTION SET _error 
 	RETURN _error, "Error al Actualizar"; 
END EXCEPTION 
 
UPDATE emicartasal5 
   SET enviado_email = 1, 
       fecha_email   = current, 
	   emails        = a_emails, 
	   enviado_a     = a_enviado_a 
 WHERE no_documento  = trim(a_no_documento); 
END 
RETURN 0,"Proceso Exitoso"; 
END PROCEDURE; 