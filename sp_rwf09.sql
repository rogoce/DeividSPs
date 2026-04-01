-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf09;

CREATE PROCEDURE sp_rwf09(a_no_documento CHAR(20), a_no_unidad char(5))
RETURNING DATE,
          DATE,
		  SMALLINT,
		  CHAR(10),
          CHAR(50),
		  CHAR(50),
		  CHAR(3), 
		  CHAR(50),
		  CHAR(5),
		  DEC(16,2),
		  CHAR(10),
		  VARCHAR(100),
		  VARCHAR(30),
		  SMALLINT; 


DEFINE v_vigencia_inic 		DATE;
DEFINE v_vigencia_final     DATE;
DEFINE v_estatus_poliza     SMALLINT;
DEFINE v_no_poliza          CHAR(10);
DEFINE v_email_corredor		char(50);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_suma_asegurada		DEC(16,2);
DEFINE v_cod_contratante    CHAR(10);
DEFINE v_nombre_asegurado   VARCHAR(100);
DEFINE v_cedula             VARCHAR(30);
DEFINE v_error              SMALLINT;

SET ISOLATION TO DIRTY READ;

LET	v_vigencia_inic = null;
LET	v_vigencia_final = null;
LET	v_estatus_poliza = 0;
LET	v_no_poliza  = null;   
LET v_email_corredor = '';
LET v_nombre_ramo = '';
LET v_cod_ramo = '';
LET v_nombre_corredor = '';
LET v_cod_agente = '';
LET v_suma_asegurada = 0;
LET v_cod_contratante = '';
LET v_nombre_asegurado = '';
LET v_cedula = '';          
LET v_error = 0;

SELECT no_poliza,
       cod_ramo,
       estatus_poliza,
       vigencia_inic,
       vigencia_final
  INTO v_no_poliza,
       v_cod_ramo,
	   v_estatus_poliza,
	   v_vigencia_inic,
	   v_vigencia_final
  FROM emipomae
 WHERE no_documento = a_no_documento;

IF v_no_poliza IS NULL THEN
	RETURN  v_vigencia_inic, 	
			v_vigencia_final, 
			v_estatus_poliza, 
			v_no_poliza,      
			v_email_corredor,	
			v_nombre_ramo,	
			v_cod_ramo,		
			v_nombre_corredor,
			v_cod_agente,	 	
			v_suma_asegurada,
			v_cod_contratante,
			v_nombre_asegurado,
			v_cedula,
			1
			WITH RESUME;
ELSE

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

	FOREACH
	 SELECT	cod_agente
	   INTO	v_cod_agente
	   FROM	emipoagt
	  WHERE no_poliza = v_no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT nombre,
	       email_reclamo
	  INTO v_nombre_corredor,
		   v_email_corredor	
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	select suma_asegurada,
	       cod_asegurado
	  into v_suma_asegurada,
	       v_cod_contratante
	  from emipouni
	 where no_poliza = v_no_poliza
	   and no_unidad = a_no_unidad;

	SELECT nombre,
	       cedula
	  INTO v_nombre_asegurado,
	       v_cedula
	  FROM cliclien
	 WHERE cod_cliente = v_cod_contratante;

	RETURN  v_vigencia_inic, 	
			v_vigencia_final, 
			v_estatus_poliza, 
			v_no_poliza,      
			v_email_corredor,	
			v_nombre_ramo,	
			v_cod_ramo,		
			v_nombre_corredor,
			v_cod_agente,	 	
			v_suma_asegurada,
			v_cod_contratante,
			v_nombre_asegurado,
			v_cedula,
			v_error
			WITH RESUME;
 END IF
END PROCEDURE;