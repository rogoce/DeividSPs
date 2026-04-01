-- Reporte de Primas Pendientes por Aplicar
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob16_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob16a;

CREATE PROCEDURE "informix".sp_cob16a(
a_compania CHAR(3), 
a_agencia  CHAR(3), 
a_periodo  CHAR(7)	DEFAULT '*'
) RETURNING DATE,		-- Fecha
			CHAR(30),	-- Documento
			DEC(16,2),	-- Monto
			CHAR(50),	-- Poliza
			CHAR(50),	-- Asegurado
			CHAR(50),	-- Coaseguro
			CHAR(50),	-- Ramo
			CHAR(50);	-- Compania

DEFINE v_doc_suspenso    CHAR(30); 
DEFINE v_fecha           DATE;     
DEFINE v_monto           DEC(16,2);
DEFINE v_poliza          CHAR(50); 
DEFINE v_asegurado       CHAR(50); 
DEFINE v_coaseguro       CHAR(50); 
DEFINE v_ramo            CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Seleccion de las Primas en Suspenso

IF a_periodo = '*' THEN

	FOREACH 
	 SELECT fecha,
			doc_suspenso,
			monto,
			poliza,
			asegurado,
			coaseguro,
			ramo
	   INTO	v_fecha,			
			v_doc_suspenso,	
			v_monto,			
			v_poliza,		
			v_asegurado, 	
			v_coaseguro, 	
			v_ramo	 		
	   FROM cobsuspe
	  WHERE cod_compania = a_compania
	    AND	actualizado = 0
	  ORDER BY fecha

	 delete from cobsuspe
	 where doc_suspenso = v_doc_suspenso
	  and actualizado = 0;

	END FOREACH

ELSE

	FOREACH 
	 SELECT fecha,
			doc_suspenso,
			monto,
			poliza,
			asegurado,
			coaseguro,
			ramo
	   INTO	v_fecha,			
			v_doc_suspenso,	
			v_monto,			
			v_poliza,		
			v_asegurado, 	
			v_coaseguro, 	
			v_ramo	 		
	   FROM cobsuspe
	  WHERE cod_compania = a_compania
	    AND YEAR(fecha)  = a_periodo[1,4]
	    AND MONTH(fecha) = a_periodo[6,7]	
	  ORDER BY fecha

		RETURN	v_fecha,			
				v_doc_suspenso,	
				v_monto,			
				v_poliza,		
				v_asegurado, 	
				v_coaseguro, 	
				v_ramo,
			    v_compania_nombre
				WITH RESUME;	 		

	END FOREACH

END IF
		RETURN	v_fecha,			
				v_doc_suspenso,	
				v_monto,			
				v_poliza,		
				v_asegurado, 	
				v_coaseguro, 	
				v_ramo,
			    v_compania_nombre
				WITH RESUME;
END PROCEDURE;