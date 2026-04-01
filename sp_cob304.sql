-- Reporte de Diferencia de Comision
-- 
-- Creado    : 02/12/2008 - Autor: Henry Giron
-- Modificado: 02/12/2008 - Autor: Henry Giron
--
-- SIS v.2.0 - d_cobr_sp_cob16_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob304;

CREATE PROCEDURE "informix".sp_cob304(a_compania CHAR(3)) 
RETURNING CHAR(30),	    -- Documento
			DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima_neta	
			CHAR(10),	-- No_remesa	
			SMALLINT,	-- Renglon	
			CHAR(5),	-- cod_agente	
			DEC(16,2),	-- monto_calc	
			DEC(16,2),	-- monto_man
			DEC(5,2),	-- porc_comis_agt
			DEC(5,2),	-- porc_partic_agt
			CHAR(7);    -- periodo

DEFINE v_doc_remesa 	char(30);
DEFINE v_monto 			dec(16,2);
DEFINE v_prima_neta 	dec(16,2);
DEFINE v_no_remesa  	char(10);
DEFINE v_renglon 		smallint;
DEFINE v_cod_agente 	char(5);
DEFINE v_monto_calc 	dec(16,2);
DEFINE v_monto_man  	dec(16,2); 
DEFINE v_porc_comis		dec(5,2);
DEFINE v_porc_partic	dec(5,2);
DEFINE v_compania_nombre CHAR(50); 
define _periodo			char(7);

set isolation to dirty read;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Busca la diferencias de comisiones
FOREACH 
  SELECT cobredet.doc_remesa,
         cobredet.monto,
         cobredet.prima_neta,
         cobredet.no_remesa,  
         cobredet.renglon, 
         cobreagt.cod_agente,
         cobreagt.monto_calc,   
         cobreagt.monto_man,  
         cobreagt.porc_comis_agt,
         cobreagt.porc_partic_agt,
		 cobredet.periodo
	INTO v_doc_remesa,
		 v_monto,
		 v_prima_neta,
		 v_no_remesa,
		 v_renglon,
		 v_cod_agente,
		 v_monto_calc,
		 v_monto_man,
		 v_porc_comis,
		 v_porc_partic,
		 _periodo 
    FROM cobreagt,   
         cobredet  
   WHERE cobredet.no_remesa  = cobreagt.no_remesa 
     and cobredet.renglon    = cobreagt.renglon
	 and cobreagt.monto_calc <>  cobreagt.monto_man
	 and cobredet.periodo    >= "2012-01"
	 and cobredet.periodo    <= "2012-12"
	 and cobredet.actualizado = 1
	 and cobreagt.cod_agente  = "00875"
   order by cobredet.periodo, cobredet.doc_remesa, cobredet.no_remesa, cobredet.renglon

	RETURN	v_doc_remesa,
		    v_monto,
		    v_prima_neta,
		    v_no_remesa,
		    v_renglon,
		    v_cod_agente,
		    v_monto_calc,
		    v_monto_man,
		    v_porc_comis,
		    v_porc_partic,
			_periodo
		 	WITH RESUME;	 		

END FOREACH

END PROCEDURE;

