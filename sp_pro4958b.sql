-- Reporte de impresas de eminocartsal 
-- Creado    : 01/11/2017 - Autor: Henry Giron
-- SIS v.2.0 -  - DEIVID, S.A.
-- execute procedure sp_pro4958b('001','2017-12')

drop procedure sp_pro4958b;
create procedure sp_pro4958b(a_cia char(3), a_periodo char(7)) 
returning char(20) as poliza,
          char(100) as cliente,          
		  char(5) as cod_producto_ant,		  
		  varchar(50) as nombre_producto_ant,    
          char(5) as cod_agente,
          varchar(50) as nombre_agente,
          date as fecha_aniv,		  
		  char(50) as descr_cia; 
		  
define _no_documento         char(20);
define _cod_producto_ant     char(5);
define _vigencia_inic        date;
define _vigencia_final       date;
define _cod_agente           char(5);
define _nombre_agente        varchar(50);
define _no_poliza            char(10);
define _nombre_producto_ant  varchar(50);
define _nombre_cliente	     char(100);
define _fecha_aniv           date;
define _descr_cia	         char(50);	
define _enviado_email        smallint;
define _fecha_email	         date;

drop table if exists tmp_csalud;
CREATE TEMP TABLE tmp_csalud
   (no_documento         char(20),
    nombre_cliente       char(100),    
	cod_producto_ant     char(5),
    cod_agente           char(5),
	nombre_agente        varchar(50),    
	nombre_producto_ant  varchar(50),
	fecha_aniv           date,
    seleccionado         SMALLINT DEFAULT 1 NOT NULL) 
	WITH NO LOG; 

--set debug file to "sp_pro4958a.trc";
--trace on;
LET _descr_cia       = NULL;
LET _descr_cia       = sp_sis01(a_cia);
set isolation to dirty read;
--  póliza, asegurado, fecha aniversario, producto anterior 
begin
foreach
	SELECT no_documento,   
	       nombre_cliente,	 
		   cod_producto_ant,
		   fecha_aniv		   
	  INTO _no_documento,
	       _nombre_cliente,	       
		   _cod_producto_ant,
		   _fecha_aniv		   
	  FROM eminocartsal 
	 WHERE periodo = a_periodo
  ORDER BY no_documento ASC
	
    LET _no_poliza   = sp_sis21(_no_documento);    	

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	select nombre
	  into _nombre_producto_ant
	  from prdprod
	 where cod_producto = _cod_producto_ant;	 

    insert into tmp_csalud
    values(_no_documento,    
	       _nombre_cliente,		   
		   _cod_producto_ant,     
		   _cod_agente,      
		   _nombre_agente,		   
		   _nombre_producto_ant,
		   _fecha_aniv,
		   1);

end foreach

foreach
	select no_documento,     
	       nombre_cliente,		     
		   cod_producto_ant,      
		   cod_agente,      
		   nombre_agente,   		   
           nombre_producto_ant,
		   fecha_aniv
	  into _no_documento, 
           _nombre_cliente,	  		   
		   _cod_producto_ant,
		   _cod_agente,      
           _nombre_agente,		   
           _nombre_producto_ant,
		   _fecha_aniv
	  from tmp_csalud
	 where seleccionado = 1					   

    return _no_documento,    
	       _nombre_cliente,  		   
		   _cod_producto_ant,		   
		   _nombre_producto_ant,
		   _cod_agente,      
		   _nombre_agente,
		   _fecha_aniv,
           _descr_cia		   
		   with resume;   

end foreach

DROP TABLE tmp_csalud;

end

end procedure  