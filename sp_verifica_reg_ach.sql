-- Generacion del Archivo de clientes para Multi Credit Bank

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/12/2001 - Autor: Armando Moreno M. ref.  sp_cob44;

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_verifica_reg_ach;

CREATE PROCEDURE "informix".sp_verifica_reg_ach()
 RETURNING SMALLINT,
           CHAR(17),
           CHAR(20),
           CHAR(100);

DEFINE _campo			CHAR(100);
DEFINE _no_cuenta       CHAR(17);
DEFINE _nombre_pagador  CHAR(100);
DEFINE _cod_pagador		CHAR(10);
DEFINE _no_documento	CHAR(20);
DEFINE _aseg_primer_nom CHAR(30);
DEFINE _aseg_primer_ape CHAR(30);
DEFINE _aseg_resultado  CHAR(22);
DEFINE _error_code      SMALLINT;
DEFINE _once_blanks   	CHAR(11);


BEGIN


FOREACH
 SELECT cuenta
   INTO _no_cuenta
   FROM cobachre
  ORDER BY 1

  let _no_cuenta = trim(_no_cuenta);

  SELECT cod_pagador,
		 nombre
    INTO _cod_pagador,
	     _nombre_pagador
    FROM cobcuhab
   WHERE no_cuenta = _no_cuenta;


  IF _cod_pagador IS NOT NULL THEN
	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	let _nombre_pagador = trim(_nombre_pagador);

	foreach
		select no_documento
		  into _no_documento
		  from cobcutas
		 where no_cuenta = _no_cuenta

		RETURN 1,
		       _no_cuenta,
		       _no_documento,
		       _nombre_pagador with resume; 
	end foreach

  else
		RETURN 2,
		       _no_cuenta,
		       '',
		       '' with resume; 	
  END IF


END FOREACH

END 

END PROCEDURE;
			