------------------------------------------------
--      EMICARTASAL2          --
--         CONTRATO DE REASEGURO              --
---  Henry Giron - 10/12/2011 --
------------------------------------------------
DROP PROCEDURE sp_pro4939;
CREATE PROCEDURE sp_pro4939(a_periodo CHAR(7),a_imp1 SMALLINT DEFAULT 0, a_imp2 SMALLINT DEFAULT 0, a_envi1 SMALLINT DEFAULT 0, a_envi2 SMALLINT DEFAULT 0, a_envi3 SMALLINT DEFAULT 0, a_envi4 SMALLINT DEFAULT 0,a_poliza CHAR(20) DEFAULT "%")
RETURNING char(100) ,char(100) ,char(10)  ,char(10)  ,char(10)  ,char(20)  ,char(3)   ,char(3)   ,char(3)   ,date      ,char(50)  ,char(5)   ,decimal(16,2),char(7)   ,char(100), DEC(16,2), DEC(16,2), CHAR(100), DEC(16,2), CHAR(100) ;
																																												  
--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4																												  
--string ls_periodo,ls_poliza
   BEGIN
      DEFINE _nombre_cliente  	   char(100);
      DEFINE _no_documento	  	   char(100);
      DEFINE _direccion    	  	   char(10);
      DEFINE _telefono1    	  	   char(10);
      DEFINE _telefono2    	  	   char(10);
      DEFINE _celular      	  	   char(20);
      DEFINE _cod_subramo  	  	   char(3);
      DEFINE _cod_formapag 	  	   char(3);
      DEFINE _cod_perpago  	  	   char(3);
      DEFINE _fecha_aniv   	  	   date;
      DEFINE _nombre_agente	  	   char(50);
      DEFINE _cod_producto 	  	   char(5);
      DEFINE _prima      	   	   decimal(16,2);
      DEFINE _periodo    	  	   char(7);
      DEFINE _name_cliclien   	   char(100);
	  DEFINE _deducible			   DEC(16,2);
	  DEFINE _deducible_int		   DEC(16,2);
	  DEFINE _co_pago  			   DEC(16,2);
	  DEFINE _nombre_plan          CHAR(100);
	  DEFINE _deducible_txt        CHAR(100);
	  DEFINE _deducible_din        CHAR(18);

--	set debug file to "sp_pro4939.trc";
--	trace on;

     CREATE TEMP TABLE temp_carta2012
			  (nombre_cliente	char(100), 
			   direccion    	char(100), 
			   telefono1    	char(10),	
			   telefono2    	char(10),	
			   celular      	char(10),	
			   no_documento		char(20),	
			   cod_subramo  	char(3),	
			   cod_formapag 	char(3),	
			   cod_perpago  	char(3),	
			   fecha_aniv   	date,	
			   nombre_agente	char(50),	
			   cod_producto 	char(5), 
			   prima      		decimal(16,2),
			   periodo    		char(7), 
			   name_cliclien    char(100),
			   deducible		DEC(16,2),	
			   co_pago  		DEC(16,2),	
			   nombre_plan      CHAR(100),
			   deducible_int	DEC(16,2),
			   deducible_txt    CHAR(100)		      	
            ) WITH NO LOG;
										 
	CREATE INDEX idx1_temp_carta2012 ON temp_carta2012(no_documento);
	CREATE INDEX idx2_temp_carta2012 ON temp_carta2012(cod_subramo);
	CREATE INDEX idx3_temp_carta2012 ON temp_carta2012(periodo);	       

FOREACH
  SELECT DISTINCT emicartasal2.nombre_cliente,   
         emicartasal2.direccion,   
         emicartasal2.telefono1,   
         emicartasal2.telefono2,   
         emicartasal2.celular,   
         emicartasal2.no_documento,   
         emicartasal2.cod_subramo,   
         emicartasal2.cod_formapag,   
         emicartasal2.cod_perpago,   
         emicartasal2.fecha_aniv,   
         emicartasal2.nombre_agente,   
         emicartasal2.cod_producto,   
         emicartasal2.prima,   
         emicartasal2.periodo,   
         cliclien.nombre,
		 emicartasal2.deducible,   
		 emicartasal2.co_pago,
         emicartasal2.nombre_plan,
		 emicartasal2.deducible_int
    INTO _nombre_cliente, 
		 _no_documento, 
		 _direccion, 
		 _telefono1, 
		 _telefono2, 
		 _celular, 
		 _cod_subramo, 
		 _cod_formapag, 
		 _cod_perpago, 
		 _fecha_aniv, 
		 _nombre_agente, 
		 _cod_producto, 
		 _prima, 
		 _periodo, 
		 _name_cliclien,
		 _deducible,		
		 _co_pago,  		
		 _nombre_plan,
		 _deducible_int	 		   
    FROM emicartasal2,   
         emipomae,   
         cliclien  
   WHERE ( emicartasal2.no_documento = emipomae.no_documento ) and  
         ( emipomae.cod_contratante = cliclien.cod_cliente ) and  
         ( ( emicartasal2.periodo = a_periodo ) AND  
         (emicartasal2.impreso = a_imp1 OR  
         emicartasal2.impreso = a_imp2) AND  
         emicartasal2.enviado_a in (a_envi1,a_envi2,a_envi3,a_envi4) AND  
--         emicartasal2.cod_subramo in ('007','009') AND  
         emicartasal2.no_documento like a_poliza )   
ORDER BY emicartasal2.nombre_agente ASC,   
         emicartasal2.no_documento ASC   	 

		 let _deducible_din = _deducible_int ;

		 if _cod_subramo = "009" then  -- Para Global se adiciona el deducible intenacinal
			LET _deducible_txt = " LOCAL B/. "||_deducible||" / Internacional B/. "||_deducible_din; --_deducible_int;
	   else
			LET _deducible_txt = " B/. "||_deducible;
		 end if

			INSERT INTO temp_carta2012(nombre_cliente,
			                        direccion,    	
									telefono1,    	
									telefono2,    	
									celular,      	
									no_documento,		
									cod_subramo, 	
									cod_formapag, 	
									cod_perpago,	
									fecha_aniv,	
									nombre_agente,	
									cod_producto,	
									prima,	
						            periodo,	
									name_cliclien,
									deducible,		
									co_pago,  		
									nombre_plan,
									deducible_int,
									deducible_txt									
									  )  
			    	     VALUES(    _nombre_cliente, 
							  		_direccion, 
							  		_telefono1, 
							  		_telefono2, 
							  		_celular, 
							  		_no_documento, 
							  		_cod_subramo, 
							  		_cod_formapag, 
							  		_cod_perpago, 
			    			  		_fecha_aniv, 
			    			  		_nombre_agente, 
			    			  		_cod_producto, 
			    			  		_prima, 
			    			  		_periodo, 
			     			  	  	_name_cliclien,
			     			  	  	_deducible,		
			     			  	  	_co_pago,  		
			     			  	  	_nombre_plan,
									_deducible_int,
									_deducible_txt	
			     			  	  	 );	    			    			    			    
			    
END FOREACH


FOREACH
     SELECT nombre_cliente,
			direccion,    	
			telefono1,    	
			telefono2,    	
			celular,      	
			no_documento,	
			cod_subramo, 	
			cod_formapag, 	
			cod_perpago,	
			fecha_aniv,	
			nombre_agente,	
			cod_producto,	
			prima,	
			periodo,	
			name_cliclien,
	  	  	deducible,		
	  	  	co_pago,  		
	  	  	nombre_plan,
	  	  	deducible_int,
	  	  	deducible_txt					  								
       INTO _nombre_cliente,
	        _no_documento, 
			_direccion, 
			_telefono1, 
			_telefono2, 
			_celular, 
			_cod_subramo, 
			_cod_formapag, 
			_cod_perpago, 
			_fecha_aniv, 
			_nombre_agente, 
			_cod_producto, 
			_prima, 
			_periodo, 
			_name_cliclien,
	  	  	_deducible,		
	  	  	_co_pago,  		
	  	  	_nombre_plan,
	  	  	_deducible_int,
	  	  	_deducible_txt					  						 													
       FROM temp_carta2012	
	  ORDER BY nombre_agente ASC,   
               no_documento ASC   

	         RETURN _nombre_cliente,--01
			        _no_documento,--02
					_direccion,--03
					_telefono1,--04
					_telefono2,--05
					_celular,--06
					_cod_subramo,--07
					_cod_formapag,--08
					_cod_perpago,--09
					_fecha_aniv,--10
					_nombre_agente,--11
					_cod_producto,--12
					_prima,--13
					_periodo,--14
					_name_cliclien,--15
			  	  	_deducible,--16		
			  	  	_co_pago,--17  		
			  	  	_nombre_plan, --18
					_deducible_int,	--19
					_deducible_txt --20	
	                WITH RESUME;


END FOREACH

DROP TABLE temp_carta2012;
END

END PROCEDURE  

 
		