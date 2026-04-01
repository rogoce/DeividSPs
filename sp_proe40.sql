-- Procedimiento Verificar que no hay Valores en cedula y telefono de casa
--
-- Creado    : 
-- Modificado: 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe40;
CREATE PROCEDURE "informix".sp_proe40(a_poliza CHAR(10))
			RETURNING   SMALLINT,			 -- _error
						CHAR(10),			 -- ls_unidad
						VARCHAR(50);

DEFINE _no_unidad   	CHAR(10);
DEFINE _error			INTEGER;
DEFINE _cod_asegurado 	CHAR(10);
DEFINE _descrip 	    VARCHAR(50);
DEFINE _cedula			VARCHAR(30);
DEFINE _telefono1, _celular, _telefono2 CHAR(10);
DEFINE _tipo_persona    char(1);
DEFINE _e_mail          VARCHAR(50);
DEFINE _nueva_renov     CHAR(1);
DEFINE _cod_grupo       char(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _verificar       SMALLINT;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     
LET _descrip = NULL;
LET _verificar = 1;

SELECT nueva_renov,
       cod_grupo,
	   cod_ramo,
	   cod_subramo
  INTO _nueva_renov,
       _cod_grupo,
	   _cod_ramo,
	   _cod_subramo
  FROM emipomae
 WHERE no_poliza = a_poliza;

if a_poliza = '0001526377' then
	RETURN 0, "", _descrip;
end if

-- Excepciones x ramo para telefono y correo electronico
IF _cod_ramo = '004' THEN
	IF _cod_subramo IN ('006', '007', '001') THEN
		LET _verificar = 0;
	END IF
END IF

IF _cod_ramo = '016' AND _cod_subramo = '006' THEN
	LET _verificar = 0;
END IF

IF _cod_ramo = '018' AND _cod_subramo = '012' THEN
	LET _verificar = 0;
END IF	
	
FOREACH	
	SELECT no_unidad,
	       cod_asegurado
	  INTO _no_unidad,
	       _cod_asegurado
	  FROM emipouni
	 WHERE no_poliza = a_poliza
	ORDER BY no_unidad

    SELECT cedula,
	       telefono1,
		   telefono2,
		   tipo_persona,
		   e_mail,
		   celular
	  INTO _cedula,
	       _telefono1,
		   _telefono2,
		   _tipo_persona,
		   _e_mail,
		   _celular
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

    IF (_cedula IS NULL OR TRIM(_cedula) = "") and _tipo_persona <> "G" THEN
		LET _descrip = "Cedula";
	END IF

--    IF _telefono1 IS NULL OR TRIM(_telefono1) = "" THEN
--		IF _celular IS NULL OR TRIM(_celular) = "" THEN
		if (_telefono1 Is Null or _telefono1 = "" ) and (_telefono2 Is Null or _telefono2 = "" ) and (_celular Is Null or _celular = "" ) and _verificar = 1 then
			IF _descrip IS NOT NULL THEN
				LET _descrip = _descrip || " y el Telefono de Casa o Celular";
			ELSE
				LET _descrip = "Telefono de Casa o Celular";
			END IF
		END IF	
--	END IF

    IF (_e_mail IS NULL OR TRIM(_e_mail) = "") and _nueva_renov = "N" THEN
	    IF _verificar = 1 THEN
			IF _descrip IS NOT NULL THEN
				LET _descrip = _descrip || " y el Correo Electronico";
			ELSE
				LET _descrip = "Correo Electronico";
			END IF
		END IF
		
		if _cod_grupo = '77850' then
			update cliclien
			   set e_mail = 'EMAIL_PENDIENTE@UNITYDUCRUET.COM'
			 where cod_cliente = _cod_asegurado;
			 let _descrip = null;
		end if
	END IF
	
	IF _descrip IS NOT NULL THEN
		RETURN 1, _no_unidad, _descrip;
	END IF
END FOREACH
RETURN 0, "", _descrip;
END
END PROCEDURE;