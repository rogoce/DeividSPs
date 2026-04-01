-- Proceso que despliega la informacion de tab en aviso de cancelacion.
-- Realizado : Henry Giron 28/08/2010
 													   
Drop procedure sp_cob752a;
create procedure sp_cob752a(a_referencia char(15), a_tab smallint, a_proceso smallint, a_usuario char(15) )
returning  CHAR(20)		   ,			-- no_documento  	-- : ; ,	
		   CHAR(20)		   ,			-- nombre_cliente	-- : ; ,	
		   CHAR(50)		   ,			-- nombre_agente	-- : ; ,	
		   CHAR(7)		   ,			-- periodo			-- : ; ,	
		   DATE 		   ,			-- vigencia_inic 	-- : ; ,	
		   DATE			   ,			-- vigencia_final	-- : ; ,	
		   CHAR(50) 	   ,			-- nombre_ramo		-- : ; ,	
		   DECIMAL(16,2)   ,			-- saldo   			-- : ; ,	
		   DECIMAL(16,2)   ,			-- por_vencer		-- : ; ,	
		   DECIMAL(16,2)   ,			-- exigible			-- : ; ,	
		   DECIMAL(16,2)   ,			-- dias_30			-- : ; ,	
		   DECIMAL(16,2)   ,			-- dias_60			-- : ; ,	
		   DECIMAL(16,2)   ,			-- dias_90			-- : ; ,	
		   DECIMAL(16,2)   ,			-- dias_120			-- : ; ,	
		   CHAR(10)   	   ,			-- no_poliza		-- : ; ,	
		   CHAR(15)   	   ,			-- no_aviso			-- : ; ,	
		   CHAR(1)   	   ,			-- estatus			-- : ; ,	
		   DATE   		   ,			-- fecha_vence		-- : ; ,	
		   CHAR(15)  	   ,			-- user_proceso		-- : ; ,	
		   CHAR(50)   	   ,			-- email_cli		-- : ; ,	
		   CHAR(20)  	   ,			-- apart_cli		-- : ; ,	
		   CHAR(50)   	   ,			-- nombre_acreedor	-- : ; ,	
		   CHAR(1)  	   ,			-- clase        
		   CHAR(1)  	   ,			-- marcar_entrega
		   CHAR(15) 	   ,			-- user_marcar  
		   DATE   		   ;			-- fecha_marcar 
										
DEFINE _no_documento       CHAR(20)		;							 	 
DEFINE _nombre_cliente     CHAR(20)		;							 	 
DEFINE _nombre_agente	   CHAR(50)		;							     
DEFINE _periodo			   CHAR(7)		;							 	 
DEFINE _vigencia_inic      DATE 		;						     
DEFINE _vigencia_final	   DATE			;							 
DEFINE _nombre_ramo		   CHAR(50) 	;						     
DEFINE _saldo   		   DECIMAL(16,2);						     
DEFINE _por_vencer		   DECIMAL(16,2); 							 	 
DEFINE _exigible		   DECIMAL(16,2); 							     
DEFINE _dias_30			   DECIMAL(16,2); 							 	 
DEFINE _dias_60			   DECIMAL(16,2); 							 	 
DEFINE _dias_90			   DECIMAL(16,2); 							 	 
DEFINE _dias_120		   DECIMAL(16,2); 							     
DEFINE _no_poliza		   CHAR(10)   	;						     
DEFINE _no_aviso		   CHAR(15)   	;						     
DEFINE _estatus			   CHAR(1)   	;							 
DEFINE _fecha_vence		   DATE   		;							 
DEFINE _user_proceso	   CHAR(15)  	;							 
DEFINE _email_cli		   CHAR(50)   	;						     
DEFINE _apart_cli		   CHAR(20)  	;							 
DEFINE _nombre_acreedor	   CHAR(50)   	;
DEFINE _cod_acreedor	   CHAR(5)  	;	
DEFINE _clase              CHAR(1)   	;
DEFINE _marcar_entrega     CHAR(1)   	;
DEFINE _user_marcar        CHAR(15)   	;
DEFINE _fecha_marcar       DATE   		;

-- RETURN 1,'SOLICITAR AUTORIZACION A COMPUTO';	  -- Quitar cuando se desee eliminar la carga
-- SET DEBUG FILE TO "sp_cob752.trc";
-- TRACE ON;

begin

FOREACH
	SELECT a.no_documento	,   
	     a.nombre_cliente	,   
	     a.nombre_agente	,   
	     a.periodo			,   
	     a.vigencia_inic	,   
	     a.vigencia_final	,   
	     a.nombre_ramo		,   
	     a.saldo			,   
	     a.por_vencer		,   
	     a.exigible			,   
	     a.dias_30			,   
	     a.dias_60			,   
	     a.dias_90			,   
	     a.dias_120			,   
	     a.no_poliza		,   
	     a.no_aviso			,   
	     a.estatus			,   
	     a.fecha_vence		,   
	     a.user_proceso		,   
	     a.email_cli		,   
	     a.apart_cli  		,
		 a.nombre_acreedor 	,
		 a.cod_acreedor		,
		 a.clase            ,
		 a.marcar_entrega   ,
		 a.user_marcar      ,
		 a.fecha_marcar     
	INTO _no_documento   	,
		 _nombre_cliente 	,
		 _nombre_agente		,
		 _periodo			,
		 _vigencia_inic  	,
		 _vigencia_final	,
		 _nombre_ramo		,
		 _saldo   			,
		 _por_vencer		,
		 _exigible			,
		 _dias_30			,
		 _dias_60			,
		 _dias_90			,
		 _dias_120			,
		 _no_poliza			,
		 _no_aviso			,
		 _estatus			,
		 _fecha_vence		,
		 _user_proceso		,
		 _email_cli			,
		 _apart_cli			,
		 _nombre_acreedor	,
		 _cod_acreedor		,
		 _clase             , 
		 _marcar_entrega    , 
		 _user_marcar       , 
		 _fecha_marcar      
	FROM avisocanc a 
   WHERE a.no_aviso = a_referencia       

	  IF a_tab = 1 THEN     -- x Corredores
		 --CONTINUE FOREACH;
     END IF

	  IF a_tab = 2 THEN     -- x Acreedores
		  IF trim(_cod_acreedor) = "" THEN
		     CONTINUE FOREACH;
		 END IF
     END IF
	  IF a_tab = 3 then		-- x Procesos
		  IF _estatus not in ('I','R') THEN
			 CONTINUE FOREACH;
	     END IF

		  IF a_proceso <> _clase THEN
			 CONTINUE FOREACH;
	     END IF
		 let _marcar_entrega = 0;
     END IF 
	  IF a_tab = 4 THEN     -- x Entregado
		  IF _estatus not in ('M') THEN
			 CONTINUE FOREACH;
	     END IF

		  IF a_proceso <> _clase THEN
			 CONTINUE FOREACH;
	     END IF
     END IF
	  IF a_tab = 5 THEN     -- x Conservacion de cartera
		  IF _estatus not in ('E') THEN
			 CONTINUE FOREACH;
	     END IF
		 let _marcar_entrega = 0;
     END IF
	  IF a_tab = 6 THEN     -- x Seleccionar cancelado	  sp_cob753 X-Acancelar
		  IF _estatus  not in ('X') THEN
			 CONTINUE FOREACH;
	     END IF
		 let _marcar_entrega = 0;
     END IF
	  IF a_tab = 7 THEN     -- x Seleccionar cancelado	  sp_cob753 Z-canceladas Y-desmarcardas
		  IF _estatus  not in ('Z','Y') THEN
			 CONTINUE FOREACH;
	     END IF
		 let _marcar_entrega = 0;
		  IF a_proceso = 1 THEN
			  IF _estatus  not in ('Z') THEN
				 CONTINUE FOREACH;
		     END IF
		 ELSE
			  IF _estatus  not in ('Y') THEN
				 CONTINUE FOREACH;
		     END IF
	     END IF

     END IF


  RETURN _no_documento   	,	
	   	 _nombre_cliente 	,
	   	 _nombre_agente	    ,
	   	 _periodo			,
	   	 _vigencia_inic  	,
	   	 _vigencia_final	,
	   	 _nombre_ramo		,
	   	 _saldo   		    ,
	   	 _por_vencer		,
	   	 _exigible		    ,
	   	 _dias_30			,
	   	 _dias_60			,
	   	 _dias_90			,
	   	 _dias_120		    ,
	   	 _no_poliza		    ,
	   	 _no_aviso		    ,
	   	 _estatus			,
	   	 _fecha_vence		,
	   	 _user_proceso	    ,
	   	 _email_cli		    ,
	   	 _apart_cli			,
		 _nombre_acreedor	,
		 _clase             ,
		 _marcar_entrega    ,
		 _user_marcar       ,
		 _fecha_marcar      
	   	         WITH RESUME;


END FOREACH

end
end procedure

	 




