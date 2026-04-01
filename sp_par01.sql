-- Verificacion de la Informacion de Reclamos

--DROP PROCEDURE sp_par01;

CREATE PROCEDURE "informix".sp_par01(
a_compania CHAR(3), 
a_agencia  CHAR(3),
a_periodo  CHAR(7)
) RETURNING CHAR(20),
			CHAR(10),
			CHAR(10),
			CHAR(5),
			CHAR(100),
			SMALLINT,
			CHAR(20);

DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE _cod_coasegur    CHAR(3);
DEFINE _no_reclamo      CHAR(10);
DEFINE _numrecla        CHAR(20);
DEFINE _contador_int    INT;
DEFINE _contador_char   CHAR(5);
DEFINE _contador_ret    INT;
DEFINE _no_poliza       CHAR(10);
DEFINE _no_unidad       CHAR(5);
DEFINE _no_documento    CHAR(20);
DEFINE _no_tranrec      CHAR(10);

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

LET _contador_int = 0;

FOREACH
 SELECT no_reclamo,
        no_tranrec
   INTO _no_reclamo,
        _no_tranrec	
   FROM rectrmae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
	AND periodo[1,4] = a_periodo
  ORDER BY no_reclamo

	SELECT numrecla,
		   no_poliza,
		   no_unidad
	  INTO _numrecla,
		   _no_poliza,
		   _no_unidad	   
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
  	
	SELECT no_documento
	  INTO _no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET _contador_int = _contador_int + 1;

	-- Informacion de Coseguro

 	 SELECT porc_partic_coas                                                                                     
 	   INTO _porc_coas                                                                                           
       FROM reccoas                                                                                             
      WHERE no_reclamo   = _no_reclamo                                                                          
        AND cod_coasegur = _cod_coasegur;                                                                       
                                                                                                                
 	IF _porc_coas IS NULL THEN                                                                                  
 		RETURN _numrecla, _no_reclamo, _no_poliza, _no_unidad, 'No Existe Coaseguradora Lider ...', 1, _no_documento WITH RESUME; 
 	END IF                                                                                                      

 	SELECT SUM(porc_partic_coas)                                                                                           
 	  INTO _porc_coas                                                                                                      
       FROM reccoas                                                                                                        
      WHERE no_reclamo   = _no_reclamo;                                                                                    
                                                                                                                           
 	IF _porc_coas IS NULL THEN                                                                                             
 		LET _porc_coas = 0;     
 	END IF;                                                                                                                

 	IF _porc_coas <> 100 THEN                                                                                              
 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'Sumatoria de Coaseguro no es 100% ...', 2, _no_documento  WITH RESUME;       
 	END IF                                                                                                                 

 	-- Sumatoria de Distribucion de Reaseguro (% Suma)
                                                                                                                             
 	LET _porc_reas = 0;                                                                                                    
                                                                                                                           
  	SELECT SUM(porc_partic_suma)                                                                                  
  	  INTO _porc_reas                                                                                                      
  	  FROM rectrrea                                                                                                        
  	 WHERE no_tranrec = _no_tranrec;                                                                              
                                                                                                                           
 	IF _porc_reas IS NULL THEN                                                                                             
 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'No Existe Distribucion de Reaseguro ...', 3, _no_documento  WITH RESUME;     
 	END IF;                                                                                                                
                                                                                                                           
 	IF _porc_reas <> 100 THEN                                                                                              
 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'La Distribucion de Reaseguro no es 100% ...', 4, _no_documento  WITH RESUME; 
 	END IF;                                                                                                                
                                                                                                                           
 	-- Sumatoria de Distribucion de Reaseguro (% Prima)
                                                                                                                             
 	LET _porc_reas = 0;                                                                                                    
                                                                                                                           
  	SELECT SUM(porc_partic_prima)                                                                                  
  	  INTO _porc_reas                                                                                                      
  	  FROM rectrrea
  	 WHERE no_tranrec = _no_tranrec;                                                                              
                                                                                                                           
 	IF _porc_reas IS NULL THEN                                                                                             

 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'No Existe Distribucion de Reaseguro ...', 3, _no_documento  WITH RESUME;     

 	END IF;                                                                                                                
                                                                                                                           
 	IF _porc_reas <> 100 THEN                                                                                              
 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'La Distribucion de Reaseguro no es 100% ...', 4, _no_documento  WITH RESUME; 
 	END IF;                                                                                                                

	-- Verificacion del Contrato de Retencion

   	SELECT COUNT(*)                                                                                                        
   	  INTO _contador_ret                                                                                                   
   	  FROM rectrrea
   	 WHERE no_tranrec    = _no_tranrec
   	   AND tipo_contrato = 1;                                                                                     
   	                                                                                                                       
	IF _contador_ret IS NULL THEN                                                                                      
   		LET _contador_ret = 0;                                                                                         
   	END IF                                                                                                             
   	                                                                                                                   
   	IF _contador_ret > 1 THEN                                                                                          
		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'Existe Mas de Una Retencion ...', 5, _no_documento  WITH RESUME;         
	END IF;                                                                                                            

	-- Verificacion del Contrato Facultativo
                                                                                                                          
  	SELECT COUNT(*)                                                                                                        
   	  INTO _contador_ret                                                                                                   
   	  FROM rectrrea
   	 WHERE no_tranrec    = _no_tranrec
   	   AND tipo_contrato = 3;                                                                                     
   	                                                                                                                       
	IF _contador_ret IS NULL THEN                                                                                      
   		LET _contador_ret = 0;                                                                                         
   	END IF                                                                                                             

	IF _contador_ret >= 1 THEN

	  	SELECT COUNT(*)
	  	  INTO _contador_ret
	  	  FROM rectrref
	  	 WHERE no_tranrec = _no_tranrec;                                                                              

		IF _contador_ret IS NULL THEN                                                                                      
			LET _contador_ret = 0;                                                                                         
		END IF                                                                                                             

	   	IF _contador_ret = 0 THEN                                                                                          
			RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'No Existe Distribucion de Facultativo ...', 5, _no_documento  WITH RESUME;         
		END IF;                                                                                                            

	  	SELECT SUM(porc_partic_reas)                                                                                  
	  	  INTO _porc_reas                                                                                                      
	  	  FROM rectrref
	  	 WHERE no_tranrec = _no_trnarec;

	 	IF _porc_reas IS NULL THEN                                                                                             
	 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'No Existe Distribucion de Facultativo ...', 3, _no_documento  WITH RESUME;     
	 	END IF;                                                                                                                
	                                                                                                                           
	 	IF _porc_reas <> 100 THEN                                                                                              
	 		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'La Distribucion de Reaseguro Facultativo no es 100% ...', 4, _no_documento  WITH RESUME; 
	 	END IF;                                                                                                                

	END IF 

	-- Verificacion de si Existe Distribucion de Reaseguro

   	SELECT COUNT(*)                                                                                                        
   	  INTO _contador_ret                                                                                                   
   	  FROM rectrrea
   	 WHERE no_tranrec = _no_tranrec;
   	                                                                                                                       
	IF _contador_ret IS NULL THEN                                                                                      
   		LET _contador_ret = 0;                                                                                         
   	END IF                                                                                                             
   	                                                                                                                   
   	IF _contador_ret = 0 THEN                                                                                          
		RETURN _numrecla, _no_reclamo,  _no_poliza, _no_unidad, 'No Existe Distribucion de Reaseguro ...', 5, _no_documento  WITH RESUME;         
	END IF;                                                                                                            

END FOREACH

LET _contador_char = _contador_int;

RETURN '', '', '', '', 'Se Procesaron ' || _contador_char || ' Registros', 1000, '';

END PROCEDURE;
