-- Fuente de Reclamos en Proceso Penal - Solicitado: Leyri
-- Creado    : 10/03/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_aud22;
CREATE PROCEDURE "informix".sp_aud22(a_compania char(3), a_periodo1 date, a_periodo2 date) 
RETURNING CHAR(18),						-- no_reclamo         
		  CHAR(20),						-- no_poliza          
		  CHAR(100),					-- nombre_asegurado   
		  DATE,							-- fecha_siniestro    
		  DATE,							-- fecha_reclamo      
		  DATE,							-- fecha_audiencia    
		  CHAR(50),						-- nombre_lugar       
		  CHAR(50),						-- nombre_ramo        
		  CHAR(50),						-- nombre_conductor   
		  datetime hour to second,		-- Hora_audiencia 		
		  CHAR(10),						-- no_recobro      	
		  CHAR(15),						-- Estatus_reclamo		
		  CHAR(50),						-- Abogado      		
		  CHAR(50);						-- Compania

DEFINE _no_reclamo   	  CHAR(10); 
DEFINE _doc_reclamo	      CHAR(18); 
DEFINE _no_poliza   	  CHAR(10); 
DEFINE _doc_poliza   	  CHAR(20); 
DEFINE _no_recobro		  CHAR(10);
DEFINE _nombre_asegurado  CHAR(100);
DEFINE _nombre_conductor  CHAR(100);
DEFINE _nombre_lugar      CHAR(50); 
DEFINE _nombre_abogado    CHAR(50); 
DEFINE _nombre_ramo       CHAR(50);     
DEFINE _compania_nombre   CHAR(50); 
DEFINE _fecha_siniestro   DATE; 
DEFINE _fecha_reclamo     DATE; 
DEFINE _fecha_audiencia   DATE; 
DEFINE _hora_audiencia	  datetime hour to second;
DEFINE _cod_cliente   	  CHAR(10); 
DEFINE _cod_ramo          CHAR(3);  
DEFINE _cod_lugci         CHAR(3);  
DEFINE _cod_conductor     CHAR(10);
DEFINE _cod_abogado       CHAR(3);
DEFINE _estatus_reclamo   CHAR(1);
DEFINE _estatus           CHAR(15);

SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT;
--set debug file to "sp_aud22.trc";
--trace on;

-- Nombre de la Compania
LET  _compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_Rec_Penal(
		no_reclamo         	CHAR(18),
		no_poliza          	CHAR(20),
		nombre_asegurado   	CHAR(100),
		fecha_siniestro    	DATE,
		fecha_reclamo      	DATE,
		fecha_audiencia    	DATE,
		nombre_lugar        CHAR(50),
		nombre_ramo         CHAR(50),
		nombre_conductor    CHAR(50),
		Hora_audiencia 		datetime hour to second,
		no_recobro      	CHAR(10),
		estatus_reclamo		CHAR(15),
		nombre_abogado 		CHAR(50)
		) WITH NO LOG;   
					   	
FOREACH WITH HOLD
 SELECT numrecla,
		no_poliza,
		fecha_siniestro,
		fecha_reclamo,
		fecha_audiencia,
		cod_lugci,
		cod_conductor,
		hora_audiencia,
		no_reclamo,
		cod_abogado,
		estatus_reclamo
   INTO	_doc_reclamo,
   		_no_poliza,
		_fecha_siniestro,
		_fecha_reclamo,
		_fecha_audiencia,
		_cod_lugci,
		_cod_conductor,
		_hora_audiencia,
		_no_reclamo,
		_cod_abogado,
		_estatus_reclamo
   FROM recrcmae
  WHERE estatus_audiencia = 3   -- Proceso Penal
    AND actualizado  = 1
--    AND fecha_audiencia >= a_periodo1 
--    AND fecha_audiencia <= a_periodo2
	AND cod_compania = a_compania

    IF _estatus_reclamo = 'A' THEN
	  LET _estatus = "ABIERTO";
	ELIF _estatus_reclamo = 'C' THEN
	  LET _estatus = "CERRADO";
	ELIF _estatus_reclamo = 'R' THEN
	  LET _estatus = "RE-ABIERTO";
	ELIF _estatus_reclamo = 'T' THEN
	  LET _estatus = "EN TRAMITE";
	ELIF _estatus_reclamo = 'D' THEN
	  LET _estatus = "DECLINADO";
	ELSE
	  LET _estatus = "NO APLICA";
	END IF
  
  	SELECT cod_ramo,
		   no_documento,
		   cod_contratante
	  INTO _cod_ramo,
		   _doc_poliza,
		   _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT nombre
	  INTO _nombre_conductor
	  FROM cliclien
	 WHERE cod_cliente = _cod_conductor;

   	SELECT no_recupero
   	  INTO _no_recobro
   	  FROM recrecup
   	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO _nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO _nombre_lugar
	  FROM reclugci
	 WHERE cod_lugci = _cod_lugci;

  	SELECT nombre_abogado
	  INTO _nombre_abogado 
  	  FROM recaboga 
   	 WHERE cod_abogado = _cod_abogado;

	INSERT INTO tmp_Rec_Penal(
	no_reclamo,         	
	no_poliza,          	
	nombre_asegurado,   	
	fecha_siniestro,    	
	fecha_reclamo,      	
	fecha_audiencia,    	
	nombre_lugar,        
	nombre_ramo,         
	nombre_conductor,    
	Hora_audiencia, 		
	no_recobro,      	
	estatus_reclamo,		
	nombre_abogado)    
	VALUES(  		
	_doc_reclamo,
	_doc_poliza,   	
	_nombre_asegurado,
	_fecha_siniestro,  
	_fecha_reclamo,    
	_fecha_audiencia, 
	_nombre_lugar,
	_nombre_ramo, 
	_nombre_conductor,
	_hora_audiencia, 		
	_no_recobro,      	
	_estatus,		
	_nombre_abogado
	);
		 
END FOREACH


FOREACH 
 SELECT no_reclamo,       
		no_poliza,        
		nombre_asegurado, 
		fecha_siniestro,  
		fecha_reclamo,    
		fecha_audiencia,  
		nombre_lugar,     
		nombre_ramo,      
		nombre_conductor, 
		Hora_audiencia, 	
		no_recobro,      	
		estatus_reclamo,	
		nombre_abogado		
   INTO	_doc_reclamo,
		_doc_poliza,   	
		_nombre_asegurado,
		_fecha_siniestro,  
		_fecha_reclamo,    
		_fecha_audiencia, 
		_nombre_lugar,
		_nombre_ramo, 
		_nombre_conductor,
		_hora_audiencia, 	
		_no_recobro,      	
		_estatus,		       
		_nombre_abogado   		
   FROM tmp_Rec_Penal

	RETURN	_doc_reclamo,
			_doc_poliza,   	
			_nombre_asegurado,
			_fecha_siniestro,  
			_fecha_reclamo,    
			_fecha_audiencia, 
			_nombre_lugar,
			_nombre_ramo, 
			_nombre_conductor,
			_hora_audiencia, 	
			_no_recobro,      	
			_estatus,		      
			_nombre_abogado,
			_compania_nombre   								
			WITH RESUME;

END FOREACH

DROP TABLE tmp_Rec_Penal;

END PROCEDURE;
