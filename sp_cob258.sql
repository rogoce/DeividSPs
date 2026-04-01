-- Creado    : 10/12/2010 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cob258;

CREATE PROCEDURE "informix".sp_cob258() 
RETURNING CHAR(5),	-- _cod_corredor
		  CHAR(4),	-- _tipo_archivo        
		  CHAR(30),	-- _nom_archivo		
		  CHAR(30), -- _nom_archivo2		
		  CHAR(30), -- _nom_agente	
		  smallint, -- _separador_archivo
		  smallint, -- _cantidad_archivos
		  smallint	-- _tipo_formato
					   
DEFINE _cod_corredor 		CHAR(5);
DEFINE _tipo_archivo     	CHAR(4);
DEFINE _tipo_separador		CHAR(1);
DEFINE _nom_archivo			CHAR(30);
DEFINE _nom_archivo2		CHAR(30);
DEFINE _cod_agente			CHAR(10);
DEFINE _nom_agente			CHAR(30);
DEFINE _separador_archivo	smallint; 
DEFINE _cantidad_archivos	smallint;
DEFINE _tipo_formato		smallint;


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob258.trc";
--trace on;

let _cod_corredor		= '';	
let	_tipo_archivo   	= '';  
let	_tipo_separador 	= '';		
let	_nom_archivo		= '';		
let	_nom_archivo2		= '';	
let	_cod_agente			= '';	
let	_separador_archivo	= 0;
let	_cantidad_archivos 	= 0;
let	_tipo_formato	   	= 0;

foreach
	Select cod_corredor,		 
		   tipo_archivo,   	
		   tipo_separador, 	
		   nom_archivo,		
		   nom_archivo2,		
		   cod_agente,			
		   separador_archivo,
		   cantidad_archivos,
		   tipo_formato
	  into _cod_corredor,			  
		   _tipo_archivo,   	
		   _tipo_separador, 	
		   _nom_archivo,		
		   _nom_archivo2,		
		   _cod_agente,			
		   _separador_archivo,
		   _cantidad_archivos,
		   _tipo_formato
	  from cobforpaexm
	 
	 if _tipo_formato = 1 then
		Select nombre
		  into _nom_agente
		  from agtagent
		 where cod_agente = _cod_agente;
	 elif _tipo_formato = 2 then
		Select nombre
		  into _nom_agente
		  from emicoase
		 where cod_coasegur = _cod_agente;
	 elif _tipo_formato = 3 then
		Select nombre
		  into _nom_agente
		  from cliclien
		 where cod_cliente  = _cod_agente;
	 end if
	return _cod_corredor, 		 
		   _tipo_archivo,     
		   _nom_archivo,			
		   _nom_archivo2,		
		   _nom_agente,			
		   _separador_archivo,
		   _cantidad_archivos,
		   _tipo_formato with resume;

end foreach
end procedure  