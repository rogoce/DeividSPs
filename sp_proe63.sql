-- Cartas de  Corredor SALE (1),  Corredor SALE (2) y Acreedor (3)
-- Creado    : 10/02/2012 
-- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
--DROP PROCEDURE sp_proe63;
CREATE PROCEDURE "informix".sp_proe63(a_carta CHAR(1) DEFAULT "1", a_desde DATE, a_hasta DATE, a_user  CHAR(15))
RETURNING   CHAR(100),	  --	desc_cia 
			CHAR(1),	  --	carta				
			CHAR(100),	  --	title_carta			
			CHAR(20),	  --	poliza				
			CHAR(3),	  --	compania			
			CHAR(5),	  --	valor				
			DATE,	      --	fecha_actual      
			VARCHAR(100), --	name_asegurado		
			VARCHAR(100), --	agente_saliente		
			VARCHAR(100), --	agente_nombrado		
			VARCHAR(100), --	fecha_aniversario	
			VARCHAR(100), --    name_acredor		
			VARCHAR(100), --    fecha_aviso										 
			VARCHAR(100), --	name_ramo			
			VARCHAR(50),  --	Nombre1				
			CHAR(50),	  --	Cargo1				
			CHAR(15);	  --	Usuario Ingreso				

DEFINE _no_poliza       		 CHAR(10);
DEFINE _desc_cia				 CHAR(100);
DEFINE _carta					 CHAR(1);
DEFINE _compania  				 CHAR(3);
DEFINE _valor     				 CHAR(5);
DEFINE _title_carta				 CHAR(100);
DEFINE _poliza					 CHAR(10);
DEFINE _name_asegurado			 VARCHAR(100);
DEFINE _agente_saliente			 VARCHAR(100);
DEFINE _agente_nombrado			 VARCHAR(100);
DEFINE _fecha_aniversario		 VARCHAR(100);
DEFINE _name_acredor			 VARCHAR(100);
DEFINE _fecha_aviso				 VARCHAR(100);
DEFINE _name_ramo				 VARCHAR(100);
DEFINE _Nombre1					 VARCHAR(50);	
DEFINE _Cargo1					 CHAR(50);		
DEFINE _contratante	    		 CHAR(10);
DEFINE _cod_ramo				 CHAR(3);
DEFINE _cod_agente_pol           CHAR(5);
DEFINE _fecha       	 		 DATE;
DEFINE _vig_salud   	 		 DATE;
DEFINE _vigencia_inic      		 DATE;
DEFINE _vigencia_final     		 DATE;
DEFINE _fecha_actual             DATE;
DEFINE _fecha_15dh               DATE;
DEFINE _ramo_sis                 SMALLINT;
DEFINE _windows_user             CHAR(15);
DEFINE _documento			     CHAR(20);

SET ISOLATION TO DIRTY READ;

-- Crear la tabla													
{CREATE TEMP TABLE tmp_proe62(										
		desc_cia				 CHAR(100),							
		carta					 CHAR(1),							
		title_carta				 CHAR(100),							
		poliza					 CHAR(20),							
		compania				 CHAR(3),							
		valor					 CHAR(5),							
		fecha_actual             DATE, 
		name_asegurado			 VARCHAR(100), 
		agente_saliente			 VARCHAR(100), 
		agente_nombrado			 VARCHAR(100), 
		fecha_aniversario		 VARCHAR(100), 
		name_acredor			 VARCHAR(100), 
		fecha_aviso				 VARCHAR(100),
		name_ramo				 VARCHAR(100), 
	    Nombre1					 VARCHAR(50),
	    Cargo1					 CHAR(50)		     				
		) WITH NO LOG;}

--SET DEBUG FILE TO "sp_proe62.trc"; 
--TRACE ON; 

	SET ISOLATION TO DIRTY READ; 

	LET _no_poliza         = "";
    LET _desc_cia          = "";
	LET _fecha_actual      = "";
	LET _carta             = "";         
	LET _compania          = "";
	LET _valor             = "";
	LET _title_carta       = "";
	LET _name_asegurado    = "";
	LET _agente_saliente   = "";
	LET _agente_nombrado   = "";
	LET _fecha_aniversario = "";
	LET _name_acredor      = "";
	LET _fecha_aviso       = "";
	LET _name_ramo         = ""; 		
	LET _Nombre1           = "";
	LET _Cargo1            = "";

FOREACH WITH HOLD
 SELECT desc_cia,			
		carta,				
		title_carta,			
		poliza,				
		compania,			
		valor,				
		fecha_actual,     
		name_asegurado,		
		agente_saliente,		
		agente_nombrado,		
		fecha_aniversario,
		name_acredor,		
		fecha_aviso,			
		name_ramo,			
		Nombre1,				
		Cargo1				
   INTO _desc_cia,			
   		_carta,				
   		_title_carta,		
   		_documento,			
   		_compania,			
		_valor,				
		_fecha_actual,     	
		_name_asegurado,		
   		_agente_saliente,	
   		_agente_nombrado,	
   		_fecha_aniversario,	
   		_name_acredor,		
   		_fecha_aviso, 		
   		_name_ramo,	 		
   		_Nombre1,		 	
   		_Cargo1    
   FROM bitcarta
  WHERE fecha_actual >= a_desde
    and fecha_actual <= a_hasta
    and carta = a_carta


	RETURN _desc_cia,			
		   _carta,				
		   _title_carta,		
		   _documento,				
		   _compania,			
		   _valor,				
		   _fecha_actual,     		
		   _name_asegurado,		
		   _agente_saliente,	
		   _agente_nombrado,	
	 	   _fecha_aniversario,	
		   _name_acredor,			
		   _fecha_aviso, 			
		   _name_ramo,	 		
		   _Nombre1,		 	
		   _Cargo1,
		   a_user	  
		   WITH RESUME;	

END FOREACH

END PROCEDURE 			