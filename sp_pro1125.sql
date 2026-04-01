-- Actualizando los valores de las cartas de Salud en emicartasal
-- Creado    : 12/12/2011 - Autor: Henry Giron.
-- Modificado: 12/12/2011 - Autor: Henry Giron	  copia de sp_pro500
-- SIS v.2.0 -  - DEIVID, S.A.
DROP PROCEDURE sp_pro1125;
CREATE PROCEDURE sp_pro1125(a_periodo char(7), a_no_documento CHAR(20) default "%", a_opcion smallint)
RETURNING CHAR(20) 		as no_documento,
          VARCHAR(100) 	as pagador,
		  VARCHAR(100) 	as corredor,
		  VARCHAR(50)   as producto,
		  DEC(16,2)     as prima_actual,
		  DEC(16,2)     as prima_nueva;

DEFINE _error 				smallint; 
DEFINE _e_mail              varchar(50);
DEFINE v_e_mail             varchar(255);
DEFINE _no_poliza			CHAR(10);
DEFINE _cod_contratante     CHAR(10);
DEFINE _cod_agente       	CHAR(10);
DEFINE _no_documento        CHAR(20);
DEFINE _prima_act        	DEC(16,2);
DEFINE _prima_nvo        	DEC(16,2);
DEFINE _producto_nvo        CHAR(5);
DEFINE _contratante			VARCHAR(100);
DEFINE _producto			VARCHAR(50);
DEFINE _agente				VARCHAR(100);

--set debug file to "sp_pro4942.trc";
set isolation to dirty read;
BEGIN
ON EXCEPTION SET _error 
 	--RETURN _error, "Error al Actualizar"; 
END EXCEPTION 

FOREACH
	SELECT no_documento,
		   cod_contratante,
		   prima_act,
		   prima_nvo,
		   producto_nvo	
	  INTO _no_documento,
		   _cod_contratante,
		   _prima_act,
		   _prima_nvo,
		   _producto_nvo	
	  FROM emicartasal6
	 WHERE periodo = a_periodo
	   AND no_documento LIKE trim(a_no_documento)
	   AND opcion = a_opcion

	CALL sp_sis21(_no_documento) RETURNING _no_poliza;

	SELECT nombre
	  INTO _contratante
	  FROM cliclien 
	 WHERE cod_cliente = _cod_contratante;
	 
	SELECT nombre
	  INTO _producto
	  FROM prdprod 
	 WHERE cod_producto = _producto_nvo;
	 
	FOREACH
	  SELECT cod_agente 
		INTO _cod_agente
		FROM emipoagt
	   WHERE no_poliza = _no_poliza

	  SELECT nombre
		INTO _agente
		FROM agtagent
	   WHERE cod_agente = _cod_agente;

		EXIT FOREACH;

	END FOREACH	

	return _no_documento,
		   _contratante,
		   _agente,
		   _producto,
		   _prima_act,
		   _prima_nvo WITH RESUME;
	   
END FOREACH
END 

END PROCEDURE; 