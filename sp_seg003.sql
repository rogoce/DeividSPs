-- Lista de Cambios de Usuarios
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.  
 drop procedure sp_seg003;

create procedure sp_seg003() 
returning CHAR(8),CHAR(30),DATE,CHAR(5),CHAR(3),CHAR(50),CHAR(255),SMALLINT,SMALLINT,CHAR(100),CHAR(30),CHAR(1),INTEGER,char(1);
																					 
define _usuario   		CHAR(8)  ;	
define _descripcion     CHAR(30) ;	
define _fecha_cambio    DATE	 ;	
define _cia_depto   	CHAR(5)  ;	
define _codigo_agencia	CHAR(3)  ;	
define _ubicacion   	CHAR(50) ;	
define _observ   		CHAR(255);	
define _equipo   		SMALLINT ;	
define _tipo_equipo  	SMALLINT ;	
define _codigo_compania	CHAR(3)  ;
define _desc_depto    	CHAR(100);	
define _desc_agencia    CHAR(30) ;	
define _status			CHAR(1)  ;
DEFINE _registro		integer  ;
define _inactivo        integer;
define _tipo_usuario    char(1);
											   	
set isolation to dirty read;
let _codigo_compania = '001';
let _status = "";

foreach
  select usuario,   
         descripcion,   
         fecha_cambio,   
         cia_depto,   
         codigo_agencia,   
         ubicacion,   
         observ,   
         equipo,   
         tipo_equipo,
         status,
         registro,
		 tipo_usuario
    into _usuario,   
         _descripcion,   
         _fecha_cambio,   
         _cia_depto,   
         _codigo_agencia,   
         _ubicacion,   
         _observ,   
         _equipo,   
         _tipo_equipo,
         _status,
		 _registro,
		 _tipo_usuario
    from cambio_user  
   order by status asc, usuario asc, registro desc, fecha_cambio desc
--   where status in ("C") -- in ("C","R")

  select descripcion  
    into _desc_agencia 
    from insagen  
   where codigo_agencia = _codigo_agencia; 

  select nombre 
    into _desc_depto 
    from insdepto 
   where cod_depto = _cia_depto;

	if _status in ('C') then 
	   let _status = 'P';	 --> Henry: Para identificar los procesados antes de hacer efectivo el cambio. Maque: 09/05/2012
	end if
	   let _inactivo = 0;

    {select count(*) 
	  into _inactivo
      from insuser 
     where usuario = _usuario 
       and status = 'I';    --> Henry: Si ya no trabaja el registro de cambio no se visualizara. Maque: 09/05/2012

		if _inactivo > 0 then
			continue foreach;
		end if}

	return _usuario,   
		   _descripcion,   
		   _fecha_cambio,  
		   _cia_depto,   
		   _codigo_agencia,
		   _ubicacion,   
		   _observ,   
		   _equipo,   
		   _tipo_equipo,
		   _desc_depto,
		   _desc_agencia,
		   _status,     --"C" 
		   _registro,
		   _tipo_usuario
		   with resume;

end foreach
end procedure


  