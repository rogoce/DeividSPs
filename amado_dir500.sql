-- Reporte de Cobros Legales
-- 
-- Creado    : 18/01/2013 - Autor: Amado Perez M. 
-- Modificado: 18/01/2013 - Autor: Amado Perez M.
--
-- SIS v.2.0 - d_cobr_sp_cob316_dw1 - DEIVID, S.A.

DROP PROCEDURE apmdir500;

CREATE PROCEDURE "informix".apmdir500()
 RETURNING char(5),						 
 		   varchar(50),					 
 		   char(3),						 
 		   varchar(30),					 
 		   char(20),					 
 		   char(10),					 
 		   char(3),						 
 		   varchar(30),					 
 		   date,						 
 		   date,						 
 		   char(5),						 
 		   char(10),					 
  		   varchar(100),				 
		   varchar(30),					 
		   decimal(16,2),				 
		   char(2),						 
		   char(50),					 
		   char(3),						 
		   char(50),					 
		   char(3),						 
		   char(50),					 
		   char(4),						 
		   char(50),					 
		   varchar(81),					 
		   varchar(81),					 
		   varchar(81),					 
		   varchar(81),					 
		   varchar(81),
		   decimal(16,2),
		   decimal(16,2),
		   char(3);	
			


DEFINE _cod_producto		char(5);
DEFINE _producto       		varchar(50);
DEFINE _sucursal_origen     char(3);
DEFINE _sucursal            varchar(30);
DEFINE _no_documento        char(20);
DEFINE _no_factura  		char(10);
DEFINE _cod_formapag  		char(3);
DEFINE _formapag            varchar(30);
DEFINE _vigencia_inic  		date;
DEFINE _vigencia_final 		date;
DEFINE _no_unidad   		char(5);
DEFINE _cod_asegurado  		char(10);
DEFINE _asegurado  		    varchar(100);
DEFINE _cedula  		    varchar(30);
DEFINE _suma_asegurada		decimal(16,2);
DEFINE _prima       		decimal(16,2);
DEFINE _cod_manzana   		char(15);
DEFINE _numero      		char(3);
DEFINE _referencia   		char(50);
DEFINE _cod_provincia   	char(2);
DEFINE _provincia   		char(50);
DEFINE _cod_distrito   		char(3);
DEFINE _distrito   	     	char(50);
DEFINE _cod_correg   		char(3);
DEFINE _correg      		char(50);
DEFINE _cod_barrio   		char(4);
DEFINE _barrio   		    char(50);
DEFINE _no_poliza   		char(10);
DEFINE _porc_comis_agt      decimal(5,2);
DEFINE _comision       		decimal(16,2);
DEFINE _cod_ramo   		    char(3);

DEFINE _descripcion         varchar(81);
DEFINE _dir1                varchar(81);
DEFINE _dir2                varchar(81);
DEFINE _dir3                varchar(81);
DEFINE _dir4                varchar(81);
DEFINE _dir5                varchar(81);

DEFINE _renglon             smallint;


SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania


FOREACH 
  SELECT emipouni.cod_producto,   
         prdprod.nombre,   
         emipomae.sucursal_origen,   
         insagen.descripcion,   
         emipomae.no_documento,   
         emipomae.no_factura,   
         emipomae.cod_formapag,   
         cobforpa.nombre,   
         emipomae.vigencia_inic,   
         emipomae.vigencia_final,   
         emipouni.no_unidad,   
         emipouni.cod_asegurado,   
         cliclien.nombre,   
         cliclien.cedula,   
         emipouni.suma_asegurada,
         emipouni.prima,   
         emipouni.cod_manzana,   
         emipomae.no_poliza,
         emipomae.cod_ramo 
    INTO _cod_producto,	
    	 _producto,      
    	 _sucursal_origen,
    	 _sucursal,      
    	 _no_documento,  
    	 _no_factura,  	
    	 _cod_formapag,  
    	 _formapag,      
    	 _vigencia_inic, 
    	 _vigencia_final,
    	 _no_unidad,   	
    	 _cod_asegurado, 
    	 _asegurado,  		
    	 _cedula,  		
    	 _suma_asegurada,
		 _prima,
    	 _cod_manzana,   
    	 _no_poliza,
    	 _cod_ramo   	
    FROM emipomae,   
         emipouni,   
         cliclien,   
         prdprod,   
         insagen,   
         cobforpa   
   WHERE ( emipomae.no_poliza = emipouni.no_poliza ) and  
         ( emipouni.cod_asegurado = cliclien.cod_cliente ) and  
         ( emipouni.cod_producto = prdprod.cod_producto ) and  
         ( emipomae.sucursal_origen = insagen.codigo_agencia ) and  
         ( emipomae.cod_compania = insagen.codigo_compania ) and  
         ( emipomae.cod_formapag = cobforpa.cod_formapag ) and  
         ( ( emipomae.cod_ramo in ("001","003","021","010","011") ) AND  
         ( emipomae.estatus_poliza = 1 ) AND  
         ( emipomae.actualizado = 1 ) AND  
         ( emipomae.vigencia_inic <= "29/01/2013" ) AND  
         ( emipomae.vigencia_final >= "29/01/2013" ) )   
  
  
  SELECT emiman05.numero,   
         emiman05.referencia,   
         emiman05.cod_provincia,   
         emiman01.nombre,   
         emiman05.cod_distrito,   
         emiman02.nombre,   
         emiman05.cod_correg,   
         emiman03.nombre,   
         emiman05.cod_barrio,   
         emiman04.nombre
    INTO _numero,      	
    	 _referencia,   	
    	 _cod_provincia, 
    	 _provincia,   	
    	 _cod_distrito,  
    	 _distrito,   	  
    	 _cod_correg,   	
    	 _correg,      	
    	 _cod_barrio,   	
    	 _barrio   		
	FROM emiman05,
		 emiman04,
		 emiman03,
		 emiman02,
		 emiman01
   WHERE ( emiman05.cod_manzana = _cod_manzana ) and
         ( emiman05.cod_barrio = emiman04.cod_barrio ) and  
         ( emiman02.cod_provincia = emiman01.cod_provincia ) and  
         ( emiman05.cod_provincia = emiman04.cod_provincia ) and  
         ( emiman05.cod_distrito = emiman04.cod_distrito ) and  
         ( emiman05.cod_correg = emiman04.cod_correg ) and  
         ( emiman04.cod_provincia = emiman03.cod_provincia ) and  
         ( emiman04.cod_distrito = emiman03.cod_distrito ) and  
         ( emiman04.cod_correg = emiman03.cod_correg ) and  
         ( emiman03.cod_provincia = emiman02.cod_provincia ) and  
         ( emiman03.cod_distrito = emiman02.cod_distrito );  

         
   LET _renglon = 1;       

   FOREACH
    SELECT blobuni.descripcion 
	  INTO _descripcion
      FROM blobuni 
     WHERE blobuni.no_poliza = _no_poliza
       AND blobuni.no_unidad = _no_unidad
       AND TRIM(blobuni.descripcion) <> "" 

    IF _renglon = 1 THEN
		LET _dir1 = TRIM(_descripcion);
    ELIF _renglon = 2 THEN
		LET _dir2 = TRIM(_descripcion);
    ELIF _renglon = 3 THEN
		LET _dir3 = TRIM(_descripcion);
    ELIF _renglon = 4 THEN
		LET _dir4 = TRIM(_descripcion);
    ELIF _renglon = 5 THEN
		LET _dir5 = TRIM(_descripcion);
	END IF

    LET _renglon = _renglon + 1;
   END FOREACH

   FOREACH
	SELECT porc_comis_agt
	  INTO _porc_comis_agt
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza

    exit foreach;
   END FOREACH

   let _comision = _prima *  _porc_comis_agt / 100;
    
  RETURN  _cod_producto,	
		  _producto,      
		  _sucursal_origen,
		  _sucursal,      
		  _no_documento,  
		  _no_factura,  	
		  _cod_formapag,  
		  _formapag,      
		  _vigencia_inic, 
		  _vigencia_final,
	      _no_unidad,   	 
		  _cod_asegurado,  
		  _asegurado,  	    --1	 
		  _cedula,  		 
		  _suma_asegurada, 
		  _cod_provincia,  
		  _provincia,   	 
		  _cod_distrito,   
		  _distrito,   	  
		  _cod_correg,   	 
		  _correg,      	 
		  _cod_barrio,   	 
		  _barrio,   
		  _dir1,
		  _dir2,
		  _dir3,
		  _dir4,
		  _dir5,
		  _prima,
		  _comision,
		  _cod_ramo
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

