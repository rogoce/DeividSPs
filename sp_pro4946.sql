-- Insertando los valores de las cartas de Salud en emicartasal
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.
-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro4946;
CREATE PROCEDURE sp_pro4946()
RETURNING varchar(255), smallint;

DEFINE _error 				smallint; 
DEFINE _e_mail              varchar(50);
DEFINE v_e_mail             varchar(255);

DEFINE _no_poliza			CHAR(10);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _cod_agente       	CHAR(10);
DEFINE _enviado_a           smallint;
DEFINE _asegurado           smallint;
DEFINE _corredor            smallint;
DEFINE a_no_documento       CHAR(20);

--set debug file to "sp_pro172.trc";

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 

-- and enviado_email = 1 

select * from emicartasal2 where periodo = '2012-07' and enviado_a = '9'  INTO temp emi3;

let _enviado_a   = "0";
let v_e_mail     = "." ;


FOREACH
	select distinct no_documento
	  into a_no_documento  
	  from emi3
 
	 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;

	 
	 LET v_e_mail = "";  
	 LET _e_mail = "";  
	 LET _asegurado = 0;
	 LET _corredor = 0;

	  FOREACH
		  SELECT cod_asegurado 
		    INTO _cod_asegurado
			FROM emipouni
		   WHERE no_poliza = _no_poliza

	         LET _e_mail = ""; 

		  SELECT trim(e_mail)
		    INTO _e_mail
			FROM cliclien
		   WHERE cod_cliente = _cod_asegurado;

	      IF _e_mail IS NOT NULL OR trim(_e_mail) <> "" THEN
			UPDATE emicartasal2 
			   SET enviado_email = 1, 
			       fecha_email   = current, 
				   emails        = _e_mail, 
				   enviado_a     = '9'
			 WHERE no_documento  = trim(a_no_documento); 
		  ELSE
			LET _asegurado = 0;
		  END IF
		  let _enviado_a   = "2";
		  let v_e_mail     = _e_mail;
	  END FOREACH

END FOREACH

END



RETURN trim(v_e_mail), _enviado_a;

END PROCEDURE;