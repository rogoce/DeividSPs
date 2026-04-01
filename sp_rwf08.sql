-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf08;

CREATE PROCEDURE sp_rwf08(a_no_poliza CHAR(10), a_no_unidad char(5))
RETURNING CHAR(50),
		  VARCHAR(255),
		  CHAR(3), 
		  CHAR(50),
		  dec(16,2),
		  char(30); 

DEFINE v_nombre_corredor	CHAR(50); 
define v_email_corredor		VARCHAR(255);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_suma_asegurada		DEC(16,2);
define _no_motor			char(30);
DEFINE _ramo_sis            smallint;
DEFINE _email               VARCHAR(50);

SET ISOLATION TO DIRTY READ;

SELECT cod_ramo
  INTO v_cod_ramo
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

SELECT nombre
  INTO v_nombre_ramo
  FROM prdramo
 WHERE cod_ramo = v_cod_ramo;

FOREACH
 SELECT	cod_agente
   INTO	v_cod_agente
   FROM	emipoagt
  WHERE no_poliza = a_no_poliza
	EXIT FOREACH;
END FOREACH

LET v_email_corredor = "";

SELECT nombre,
       email_reclamo
  INTO v_nombre_corredor,
	   v_email_corredor	
  FROM agtagent
 WHERE cod_agente = v_cod_agente;
 
IF v_email_corredor is null THEN
	LET v_email_corredor = "";
END IF
 
LET _email = "";
 
FOREACH
	SELECT email
	  INTO _email
	  FROM agtmail
	 WHERE cod_agente = v_cod_agente
	   AND tipo_correo = "REC"
	
	IF TRIM(_email) <> "" OR _email IS NOT NULL THEN
		IF TRIM(v_email_corredor) <> "" THEN
			LET v_email_corredor = TRIM(v_email_corredor) || ";" || TRIM(_email);
		ELSE
			LET v_email_corredor = TRIM(_email);
		END IF
	END IF
END FOREACH

select suma_asegurada
  into v_suma_asegurada
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

let _no_motor = "";

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = v_cod_ramo;


if _ramo_sis = 1 then

	select no_motor
	  into _no_motor
	  from emiauto
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad;

	if _no_motor is null then

		foreach
		 select no_motor
		   into _no_motor
		   from endmoaut
	      where no_poliza = a_no_poliza
	        and no_unidad = a_no_unidad
			exit foreach;
		end foreach

	end if

	if _no_motor is null then
		let _no_motor = "";
	end if

end if

RETURN  v_nombre_corredor,
		v_email_corredor,
		v_cod_ramo,
		v_nombre_ramo,
		v_suma_asegurada,
		_no_motor
		WITH RESUME;

END PROCEDURE;