-- EXEL PARA ERRORES DE PRIMA SUSCRITA
-- 
-- Creado    : 06/01/2014 - Autor: Angel Tello M.
--
--
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_ttc04;

CREATE PROCEDURE "informix".sp_ttc04() 
       RETURNING   	    SMALLINT,
						CHAR(100),
						CHAR(25),
                        DEC(16,2), 
						DEC(16,2), 
						DEC(16,2),
						CHAR(25), 
						CHAR(25), 
						INTEGER, 
						SMALLINT,	
						CHAR(25),	
						CHAR(25),
						INTEGER,
						CHAR(1),
						CHAR(5),
						INTEGER; 

						
DEFINE v_id_poliza	    	 			 CHAR(25);    
DEFINE v_id_recibo		      			 CHAR(25);    
DEFINE v_id_certificado 				 CHAR(25);
DEFINE v_id_relac_productor_ancon   	 INTEGER;
DEFINE v_cod_ramorea_ancon 	 			 SMALLINT;		
DEFINE v_no_poliza    		 			 CHAR(25);		
DEFINE v_no_endoso	       	 			 CHAR(25);		
DEFINE v_flag			   	 			 SMALLINT;		
DEFINE v_monto_pri_ttco      			 DEC(16,2);		-- Monto prima de ttcorp
DEFINE v_monto_pri_deiv      			 DEC(16,2);		-- Monto prima de deivid
DEFINE v_monto_dif	         			 DEC(16,2);		-- diferencia monto_pri_deivid - monto_pri_deivid
DEFINE v_flag_desc					     CHAR(100);
DEFINE v_id_mov_reas					 INTEGER;
DEFINE v_tipo_contrato					 CHAR(1);
DEFINE v_cod_contrato				 	 CHAR(5);
DEFINE v_id_mov_tec						 INTEGER;


SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE temp_detalle
               (id_poliza     		 		 CHAR(25), 
			    id_recibo		     		 CHAR(25), 
			    id_certificado		 		 CHAR(25),
				id_relac_productor_ancon	 INTEGER,
				cod_ramorea_ancon 			 SMALLINT,	
				no_poliza			 		 CHAR(25),
			    no_endoso           		 CHAR(25),	
				flag						 SMALLINT,
				monto_pri_ttco				 DEC(16,2),
				monto_pri_deivid			 DEC(16,2),
				monto_diferencia		     DEC(16,2),
				id_mov_reas					 INTEGER,
				tipo_contrato				 CHAR(1),
				cod_contrato				 CHAR(5),
				id_mov_tecnico_anc			 INTEGER
				)WITH NO LOG;
	
--FLAG 2 Y 3
FOREACH 
	SELECT id_poliza,    		 	
	       id_recibo,		     	
	       id_certificado,		 	
	       id_relac_productor_ancon,
	       cod_ramorea_ancon, 		
           no_poliza,			 	
           no_endoso,           	
           flag,
		   id_mov_tecnico_anc
	  INTO v_id_poliza,	    	 		
	       v_id_recibo,		      		
	       v_id_certificado,			
	       v_id_relac_productor_ancon,   
	       v_cod_ramorea_ancon, 	 		
	       v_no_poliza,    		 		
	       v_no_endoso,	       	 		
	       v_flag,
		   v_id_mov_tec
	  FROM deivid_ttcorp:movim_tec_pri_ttco
	 WHERE flag in(2,4)	
	INSERT INTO temp_detalle(id_poliza,
							 id_recibo, 
							 id_certificado,
							 id_relac_productor_ancon, 
							 cod_ramorea_ancon, no_poliza, 
							 no_endoso,
							 flag, 
							 id_mov_tecnico_anc  )
					VALUES(  v_id_poliza,
							 v_id_recibo,
							 v_id_certificado,
							 v_id_relac_productor_ancon, 
							 v_cod_ramorea_ancon, 
							 v_no_poliza,
							 v_no_endoso, 
							 v_flag,
							 v_id_mov_tec  );
END FOREACH

--FLAG 1

FOREACH 	 
	SELECT SUM(mto_prima), 
			id_recibo
	  INTO 	v_monto_pri_ttco,
			v_id_recibo
	  FROM deivid_ttcorp:movim_tec_pri_ttco
	 WHERE flag = 1 
	 GROUP BY id_recibo
	 
	SELECT SUM(prima_neta)
	  INTO v_monto_pri_deiv
	  FROM endedmae
	 WHERE no_factura = v_id_recibo
	 GROUP BY no_factura;
	 
	 IF v_monto_pri_ttco > v_monto_pri_deiv THEN
		LET v_monto_dif = v_monto_pri_ttco - v_monto_pri_deiv;
	 ELSE 
		LET v_monto_dif = v_monto_pri_deiv - v_monto_pri_ttco;
	 END IF 
 
	INSERT INTO temp_detalle(id_recibo,
							 monto_pri_ttco,
							 monto_pri_deivid,
							 monto_diferencia, 
							 flag  )
					VALUES(  v_id_recibo,
							 v_monto_pri_ttco,
							 v_monto_pri_deiv,
							 v_monto_dif, 
							 1);
END FOREACH 	

FOREACH
	SELECT id_mov_reas_ancon, 
		   tip_contrato,
		   cod_contrato
     INTO  v_id_mov_reas, 
           v_tipo_contrato,
           v_cod_contrato
	 FROM deivid_ttcorp:movim_reaseguro_pr
	 WHERE FLAG = 3
	 
	INSERT INTO temp_detalle(id_mov_reas,
						     tipo_contrato, 
							 cod_contrato, 
							 flag  )
					  VALUES(v_id_mov_reas,
							 v_tipo_contrato,
							 v_cod_contrato, 
							 3);
	 
END FOREACH


FOREACH		

	SELECT id_poliza,    		 	
	       id_recibo,		     	
	       id_certificado,		 	
	       id_relac_productor_ancon,
	       cod_ramorea_ancon, 		
           no_poliza,			 	
           no_endoso,           	
           flag,
		   monto_pri_ttco, 
		   monto_pri_deivid,
		   monto_diferencia,
		   id_mov_reas,
		   tipo_contrato,
		   cod_contrato,
		   id_mov_tecnico_anc
	  INTO v_id_poliza,	    	 		
	       v_id_recibo,		      		
	       v_id_certificado,			
	       v_id_relac_productor_ancon,   
	       v_cod_ramorea_ancon, 	 		
	       v_no_poliza,    		 		
	       v_no_endoso,	       	 		
	       v_flag,
		   v_monto_pri_ttco,
		   v_monto_pri_deiv,
		   v_monto_dif,
		   v_id_mov_reas, 
		   v_tipo_contrato,
		   v_cod_contrato,
		   v_id_mov_tec
	  FROM temp_detalle	
	  ORDER BY flag 
	  
	  IF v_flag = 1 THEN  
		LET v_flag_desc = 'la sumatoria de las primas_neta en endedmae no coincide';
	   END IF
	   IF  v_flag = 2 THEN  
		LET v_flag_desc = 'los porcentage en el segundo nivel no coinciden';
		END IF
	   IF  v_flag = 3 THEN   
		LET v_flag_desc = 'Hay contratos en Y y Z que no estan en el Tercer nivel';
	  END IF
	  
	   IF  v_flag = 4 THEN   
		LET v_flag_desc = 'Faltan registros en el segundo nivel';
	  END IF
	  
	  RETURN v_flag,
			 v_flag_desc,
			 v_id_recibo,  
			 v_monto_pri_ttco,
			 v_monto_pri_deiv,
			 v_monto_dif,
			 v_id_poliza,
			 v_id_certificado,
			 v_id_relac_productor_ancon,
			 v_cod_ramorea_ancon,
			 v_no_poliza,
			 v_no_endoso,
			 v_id_mov_reas, 
			 v_tipo_contrato,
			 v_cod_contrato,
			 v_id_mov_tec
			 WITH RESUME;
END FOREACH

DROP TABLE temp_detalle;

END PROCEDURE
