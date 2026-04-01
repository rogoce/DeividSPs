-- Reporte de la Gestion de Cobros

-- Creado    : 09/10/2000 - Autor: Marquelda Valdelamar
-- Modificado: 23/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_sp_cob28_dw1 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_cob28;

CREATE PROCEDURE "informix".sp_cob28(a_no_documento CHAR(20)
) RETURNING CHAR(20),	   				-- No_documento
			CHAR(50),	   				-- Nombre del cliente
		    DATE, 	       				-- Vigencia Inicial
		    DATE, 	       				-- Vigencia Final
		    CHAR(50),	   				-- Nombre Corredor
		    CHAR(512),  				-- Descripcion de la Gestion de cobros
		    DATETIME YEAR TO SECOND, 	-- fecha_gestion
			CHAR(8),					-- User
			CHAR(50);					-- Compania

DEFINE _no_poliza  		  CHAR(10);
DEFINE _cod_contratante   CHAR(10);
DEFINE _nombre_cliente    CHAR(50);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final	  DATE;
DEFINE _fecha_cancelacion DATE;
DEFINE _nombre_corredor   CHAR(50);
DEFINE _descripcion       CHAR(512);
DEFINE _cod_agente        CHAR(5);
DEFINE _fecha_gestion     DATETIME YEAR TO SECOND;
DEFINE _user			  CHAR(8);
DEFINE v_compania_nombre  CHAR(50); 
DEFINE _cod_compania      CHAR(3);
DEFINE _estatus_poliza	  CHAR(1);

SET ISOLATION TO DIRTY READ;

LET _no_poliza = sp_sis21(a_no_documento);

-- Nombre de la Compania

SELECT vigencia_inic,
       vigencia_final,
	   cod_contratante,
	   cod_compania,
	   fecha_cancelacion,
	   estatus_poliza
  INTO _vigencia_inic,
       _vigencia_final,
	   _cod_contratante,
	   _cod_compania,
	   _fecha_cancelacion,
	   _estatus_poliza
  FROM emipomae
 WHERE no_poliza = _no_poliza;

 IF _estatus_poliza = 2 THEN --cancelada
	IF _fecha_cancelacion IS NOT NULL THEN
	   LET _vigencia_final = _fecha_cancelacion;
   END IF
 END IF

 LET v_compania_nombre = sp_sis01(_cod_compania); 

SELECT nombre 
  INTO _nombre_cliente
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

FOREACH
 SELECT cod_agente
   INTO _cod_agente
   FROM emipoagt
  WHERE no_poliza = _no_poliza
	EXIT FOREACH;
END FOREACH

SELECT nombre
  INTO _nombre_corredor
  FROM agtagent
 WHERE cod_agente = _cod_agente;

FOREACH
 SELECT fecha_gestion, 
        desc_gestion,
		user_added
   INTO _fecha_gestion,
        _descripcion,
		_user
   FROM cobgesti
  WHERE no_documento = a_no_documento
  ORDER BY fecha_gestion DESC

	  RETURN a_no_documento,
			 _nombre_cliente,
			 _vigencia_inic,
			 _vigencia_final,
			 _nombre_corredor,
			 _descripcion,
			 _fecha_gestion,
			 _user,
			 v_compania_nombre
			 WITH RESUME;
	  
END FOREACH

END PROCEDURE;
