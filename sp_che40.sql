-- Impresion del Cheque
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_che40;

CREATE PROCEDURE "informix".sp_che40(a_no_requis CHAR(10) DEFAULT '*') RETURNING CHAR(50), CHAR(25);

DEFINE _desc_cta	  CHAR(50);     
DEFINE _cuenta		  CHAR(25);


--SET DEBUG FILE TO "sp_che01.trc";
--TRACE ON;

-- Lectura del Numero de Cheque
set isolation to dirty read;

	-- Registros Contables del Banco
	
foreach
	SELECT cuenta
	  INTO _cuenta
	  FROM chqchcta
	 WHERE no_requis = a_no_requis
	 order by 1

	SELECT cta_nombre
	  INTO _desc_cta
	  FROM cglcuentas
	 WHERE cta_cuenta = _cuenta;


	RETURN _desc_cta,_cuenta WITH RESUME;

END FOREACH

END PROCEDURE;
