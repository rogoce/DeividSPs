-- Procedimiento Verificar las exclusiones de Conoce a tu Cliente 
--
-- Creado    : 02/12/2009 - Autor: Amado Perez.
-- Modificado: 02/12/2009 - Autor: Amado Perez.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob221;
CREATE PROCEDURE "informix".sp_cob221(a_poliza VARCHAR(10))
			RETURNING   CHAR(5),
						CHAR(10),
						DEC(5,2),
						DEC(5,2),
						VARCHAR(50);

DEFINE v_cod_agente         CHAR(5);
DEFINE v_no_poliza          CHAR(10);
DEFINE v_porc_partic_agt	DEC(5,2);
DEFINE v_porc_comis_agt     DEC(5,2);
DEFINE v_nombre             VARCHAR(50);

SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
	SELECT a.cod_agente,   
	       a.no_poliza,   
	       a.porc_partic_agt,   
	       a.porc_comis_agt,   
	       b.nombre
	  INTO v_cod_agente,   
	  	   v_no_poliza,   
	  	   v_porc_partic_agt,
	  	   v_porc_comis_agt, 
	  	   v_nombre
	  FROM emipoagt a,agtagent b  
	 WHERE b.cod_agente = a.cod_agente 
	   and a.no_poliza = a_poliza     

	RETURN v_cod_agente,    
		   v_no_poliza,   
		   v_porc_partic_agt,
		   v_porc_comis_agt, 
		   v_nombre
		   WITH RESUME;
END FOREACH
END PROCEDURE;