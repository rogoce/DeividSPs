-- Reporte Datos de Filtros de Aviso de Cancelacion Automatica
-- Creado    : 14/04/2011 - Autor: Henry Giron
DROP PROCEDURE sp_cob761;
CREATE PROCEDURE "informix".sp_cob761(a_cod_avican char(10))
returning char(20), 		--  no_documento   
			char(10), 		--  cod_avican  	
			char(3), 		-- 	cod_ramo  		
			char(3), 		-- 	cod_formapag	
			char(3), 		--  cod_zona   		
			char(5), 		--  cod_agente   	
			char(3), 		-- 	cod_sucursal   
			char(5), 		-- 	cod_area   		
			char(1), 		--  cod_status   	
			char(5), 		--  cod_grupo   	
			char(10), 		-- 	cod_pagador   	
			Smallint,		-- 	dia_cobros1   	
			Smallint,		--  dia_cobros2   	
			date,			--  vigencia_inic  
			date,			-- 	vigencia_fin   
			DEC(16,2),		-- 	exigible   		
			DEC(16,2),		--  por_vencer   	
			DEC(16,2),		--  corriente   	
			DEC(16,2),		-- 	monto_30   		
			DEC(16,2),		-- 	monto_60   		
			DEC(16,2),		--  monto_90   		
			DEC(16,2),		--  monto_120   	
			DEC(16,2),		-- 	monto_150   	
			DEC(16,2),		-- 	monto_180   	
			DEC(16,2),		--  saldo   		
			Smallint,		--  cod_acreencia  
			char(3),		-- 	cod_corriente  
			char(3),		-- 	cod_monto_30   
			char(3),		--  cod_monto_60   
			char(3),		--  cod_monto_90   
			char(3),		-- 	cod_monto_120  
			char(3),		-- 	cod_monto_150  
			char(3),		--  cod_monto_180  
			DEC(16,2),		--  prima_bruta   	
			date,			-- 	hora   			
			char(3),		-- 	cod_pagos  		
			char(100),		--  nombre_cliente	
			CHAR(50),		--  nombre_formapag
			char(50),		-- 	nombre_agente	
			CHAR(50),		-- 	nombre_zona    
			char(50);	  	--	nombre_ramo 	

define _no_documento   	char(20); 
define _cod_avican  	char(10); 
define _cod_ramo  		char(3); 
define _cod_formapag	char(3); 
define _cod_zona   		char(3); 
define _cod_agente   	char(5); 
define _cod_sucursal   	char(3); 
define _cod_area   		char(5); 
define _cod_status   	char(1); 
define _cod_grupo   	char(5); 
define _cod_pagador   	char(10); 
define _dia_cobros1   	Smallint;
define _dia_cobros2   	Smallint;
define _vigencia_inic   date;
define _vigencia_fin   	date;
define _exigible   		DEC(16,2);
define _por_vencer   	DEC(16,2);
define _corriente   	DEC(16,2);
define _monto_30   		DEC(16,2);
define _monto_60   		DEC(16,2);
define _monto_90   		DEC(16,2);
define _monto_120   	DEC(16,2);
define _monto_150   	DEC(16,2);
define _monto_180   	DEC(16,2);
define _saldo   		DEC(16,2);
define _cod_acreencia   Smallint;
define _cod_corriente   char(3);
define _cod_monto_30   	char(3);
define _cod_monto_60   	char(3);
define _cod_monto_90   	char(3);
define _cod_monto_120   char(3);
define _cod_monto_150   char(3);
define _cod_monto_180   char(3);
define _prima_bruta   	DEC(16,2);
define _hora   			date;
define _cod_pagos  		char(3);
define _nombre_cliente	char(100);
DEFINE _nombre_formapag CHAR(50);								  
define _nombre_agente	char(50);
DEFINE _nombre_zona     CHAR(50);								  
define _nombre_ramo 	char(50);


SET ISOLATION TO DIRTY READ;

foreach
  SELECT no_documento,   
         cod_avican,   
         cod_ramo,   
         cod_formapag,   
         cod_zona,   
         cod_agente,   
         cod_sucursal,   
         cod_area,   
         cod_status,   
         cod_grupo,   
         cod_pagador,   
         dia_cobros1,   
         dia_cobros2,   
         vigencia_inic,   
         vigencia_fin,   
         exigible,   
         por_vencer,   
         corriente,   
         monto_30,   
         monto_60,   
         monto_90,   
         monto_120,   
         monto_150,   
         monto_180,   
         saldo,   
         cod_acreencia,   
         cod_corriente,   
         cod_monto_30,   
         cod_monto_60,   
         cod_monto_90,   
         cod_monto_120,   
         cod_monto_150,   
         cod_monto_180,   
         prima_bruta,   
         hora,   
         cod_pagos  
    into _no_documento, 
		 _cod_avican, 
		 _cod_ramo, 	
		 _cod_formapag, 
		 _cod_zona, 	
		 _cod_agente, 
		 _cod_sucursal, 
		 _cod_area, 	
		 _cod_status, 
		 _cod_grupo, 
		 _cod_pagador, 	
		 _dia_cobros1, 	
		 _dia_cobros2, 	
		 _vigencia_inic, 
		 _vigencia_fin, 
		 _exigible, 	
		 _por_vencer, 
		 _corriente, 
		 _monto_30, 	
		 _monto_60, 	
		 _monto_90, 	
		 _monto_120, 
		 _monto_150, 
		 _monto_180, 
		 _saldo, 
		 _cod_acreencia, 
		 _cod_corriente, 
		 _cod_monto_30, 
		 _cod_monto_60, 
		 _cod_monto_90, 
		 _cod_monto_120, 
		 _cod_monto_150, 
		 _cod_monto_180, 
		 _prima_bruta, 	
		 _hora, 	
		 _cod_pagos  	  	
    FROM avicanpoliza  
   WHERE cod_avican = a_cod_avican  
   order by cod_agente,cod_ramo


	  SELECT nombre
	    INTO _nombre_cliente
	    FROM cliclien
	   WHERE cod_cliente = _cod_pagador;


	  SELECT nombre
	    INTO _nombre_formapag
	    FROM cobforpa
	   WHERE cod_formapag = _cod_formapag;  

	  SELECT nombre
	    INTO _nombre_agente
	    FROM agtagent
	   WHERE cod_agente = _cod_agente;

	  SELECT nombre
	    INTO _nombre_zona
	    FROM cobcobra
	   WHERE cod_cobrador = _cod_zona;

	  SELECT nombre
	    INTO _nombre_ramo
	    FROM prdramo
	   WHERE cod_ramo = _cod_ramo;             

   return _no_documento, 
		  _cod_avican, 
		  _cod_ramo, 	
		  _cod_formapag, 
		  _cod_zona, 	
		  _cod_agente, 
		  _cod_sucursal, 
		  _cod_area, 	
		  _cod_status, 
		  _cod_grupo, 
		  _cod_pagador, 	
		  _dia_cobros1, 	
		  _dia_cobros2, 	
		  _vigencia_inic, 
		  _vigencia_fin, 
		  _exigible, 	
		  _por_vencer, 
		  _corriente, 
		  _monto_30, 	
		  _monto_60, 	
		  _monto_90, 	
		  _monto_120, 
		  _monto_150, 
		  _monto_180, 
		  _saldo, 
		  _cod_acreencia, 
		  _cod_corriente, 
		  _cod_monto_30, 
		  _cod_monto_60, 
		  _cod_monto_90, 
		  _cod_monto_120, 
		  _cod_monto_150, 
		  _cod_monto_180, 
		  _prima_bruta, 	
		  _hora, 	
		  _cod_pagos,
		  _nombre_cliente,
		  _nombre_formapag,
		  _nombre_agente,
		  _nombre_zona,
		  _nombre_ramo  	                      		  	  		   		  
          with resume;

end foreach

END PROCEDURE	


   