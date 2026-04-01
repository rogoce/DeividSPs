-- Consulta de Reclamo

-- Creado    : 17/08/2021 - Autor: Amado Perez M.
-- Modificado: 17/08/2021 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf175;

CREATE PROCEDURE sp_rwf175(a_no_motor CHAR(30))
RETURNING char(50),
		  char(50),
		  smallint,
		  char(10),
		  char(30),
		  char(50),
		  char(30);	   

define v_marca			char(50);
define v_modelo			char(50);
define v_ano_auto		smallint;
define v_placa			char(10);
define v_no_motor       char(30);
define v_color			char(50);
define v_chasis			char(30);

define _cod_marca		char(5);
define _cod_color		char(5);
define _cod_modelo		char(5);


SET ISOLATION TO DIRTY READ;

    LET v_no_motor = TRIM(a_no_motor);

    SELECT cod_marca,
	       cod_color,
	       no_chasis,
	       cod_modelo,
		   placa,
		   ano_auto
	  INTO _cod_marca,
	       _cod_color,
           v_chasis,
	       _cod_modelo,
		   v_placa,
		   v_ano_auto
	  FROM emivehic
	 WHERE no_motor = v_no_motor;

    IF v_chasis IS NULL THEN
		LET v_chasis = "";
	END IF

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre
	  INTO v_modelo
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF

    SELECT nombre
	  INTO v_color
	  FROM emicolor
	 WHERE cod_color = _cod_color;
    

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF
	
	IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF

    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = 0;
	END IF

    IF v_placa IS NULL THEN
		LET v_placa = "";
	END IF

    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_color IS NULL THEN
		LET v_color = "";
	END IF

    IF v_chasis IS NULL THEN
		LET v_chasis = "";
	END IF
	

	
	RETURN v_marca,					 --14
		   v_modelo,				 --15
		   v_ano_auto,				 --16
		   v_placa,					 --17
		   v_no_motor,      		 --18
		   v_color,					 --19
		   v_chasis	
		   WITH RESUME;   --36	 --35

END PROCEDURE;