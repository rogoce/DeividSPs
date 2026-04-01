-- Generacion del Archivo de clientes para Multi Credit Bank

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/12/2001 - Autor: Armando Moreno M. ref.  sp_cob44;

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob79;

CREATE PROCEDURE "informix".sp_cob79(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_periodo		CHAR(1)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _campo			CHAR(100);
DEFINE _no_cuenta       CHAR(17);
DEFINE _nombre_pagador  CHAR(100);
DEFINE _cod_pagador		CHAR(10);
DEFINE _cedula   		CHAR(15);
DEFINE _aseg_primer_nom CHAR(30);
DEFINE _aseg_primer_ape CHAR(30);
DEFINE _aseg_resultado  CHAR(22);
DEFINE _error_code      SMALLINT;
DEFINE _once_blanks   	CHAR(11);


BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Clientes';
END EXCEPTION           

DELETE FROM cobcucli;

FOREACH
 SELECT h.no_cuenta
   INTO _no_cuenta
   FROM cobcutas c, cobcuhab h
  WHERE c.no_cuenta = h.no_cuenta
    AND c.periodo   in (a_periodo, "3")
	AND c.procesar  = 1
	AND c.excepcion = 0
  GROUP BY h.no_cuenta
  ORDER BY h.no_cuenta

  SELECT cod_pagador,
		 nombre
    INTO _cod_pagador,
	     _nombre_pagador
    FROM cobcuhab
   WHERE no_cuenta = _no_cuenta;

  LET _cedula          = null;
  LET _aseg_primer_nom = null;
  LET _aseg_primer_ape = null;

  SELECT cedula,
		 aseg_primer_nom,
		 aseg_primer_ape
    INTO _cedula,
		 _aseg_primer_nom,
		 _aseg_primer_ape
    FROM cliclien
   WHERE cod_cliente = _cod_pagador;

  IF _cedula IS NULL THEN
	RETURN 1, 'No existe cedula del pagador para la cuenta: ' || _no_cuenta; 
  END IF

  IF _aseg_primer_nom IS NULL THEN
	RETURN 1, 'No existe Nombre del pagador para la cuenta: ' || _no_cuenta; 
  END IF

  IF _aseg_primer_ape IS NULL THEN
	RETURN 1, 'No existe Apellido del pagador para la cuenta: ' || _no_cuenta; 
  END IF

  let _aseg_resultado = _aseg_primer_nom || _aseg_primer_ape;

  LET _campo = 'L' || _cedula || _aseg_primer_nom ||  || ;

  INSERT INTO cobcucli
  VALUES (_campo);

END FOREACH

RETURN 0, 'Actualizacion Exitosa ...';

END 

END PROCEDURE;
			