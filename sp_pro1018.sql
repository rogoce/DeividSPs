-- POLIZAS VIGENTES POR RAMO
-- Creado    : 09/08/2018 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.  

   DROP procedure sp_pro1018;
   CREATE procedure "informix".sp_pro1018(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE, a_codramo char(255) default "*")
   RETURNING CHAR(20) as POLIZA,   -- _no_documento
             CHAR(3) as COD_FORPAG,    -- _cod_formapag
             CHAR(30) as FORMA_PAGO,    -- _formapag
			 DATE as VIGENCIA_INICIAL ,  -- _vigencia_inic
			 DATE as VIGENCIA_FINAL ,	  -- _vigencia_final		 
             CHAR(5) as COD_AGENTE,    -- _cod_agente
             CHAR(50) as NOMBRE_AGENTE,    --  _nombre
             CHAR(5) as COD_ZONA,      -- _cod_cobrador
             CHAR(50) as NOMBRE_ZONA,    -- _zona
             DECIMAL(16,2) AS PORC_PARTIC, --  _porc_partic_agt
             CHAR(10) as COD_ASEGURADO,    -- _cod_agente
             CHAR(50) as NOMBRE_ASEGURADO;    --  _nombre			 
    
    DEFINE _no_documento               			 CHAR(20);    
    DEFINE _tipo              					 CHAR(1);
	define _no_poliza							 CHAR(10);
	define _porc_partic_agt						 dec(16,2);
	define _cantidad		                     smallint;
	DEFINE _cod_agente                           CHAR(5);
	DEFINE _nombre                               CHAR(50);
	DEFINE _zona                                 CHAR(50);
	DEFINE _cod_cobrador                         CHAR(3);	
	DEFINE _cod_formapag  		                 CHAR(3);
	DEFINE _formapag                             CHAR(30);
	DEFINE _vigencia_inic  		                 DATE;
	DEFINE _vigencia_final 		                 DATE;
    DEFINE v_filtros          					 CHAR(255);    
	define _cod_asegurado                        char(10);	 
	define _nombre_aseg	                         char(50);  
      
    LET _no_documento    = NULL;    
    LET _tipo            = NULL;

    SET ISOLATION TO DIRTY READ;    
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

    FOREACH
       SELECT y.no_documento,  
              y.vigencia_inic,
              y.vigencia_final,
			  y.no_poliza,
			  Y.cod_contratante
         INTO _no_documento,
              _vigencia_inic,
              _vigencia_final,			  
			  _no_poliza,
			  _cod_asegurado
         FROM temp_perfil y
        WHERE y.seleccionado = 1
     ORDER BY y.no_documento	 
	
		   let _cantidad = 0;
		
		 select count(*)
		   into _cantidad
		   from emipoagt
		  where no_poliza = _no_poliza and porc_partic_agt > 0 ;	
		  
			if _cantidad is null then
				let  _cantidad = 0;
			end if		  
		  
			if _cantidad > 1 then			
			
			   SELECT cod_formapag
				 INTO _cod_formapag  
				 FROM emipomae
				WHERE no_poliza = _no_poliza;
				
			   SELECT nombre
				 INTO _formapag
				 FROM cobforpa
				WHERE cod_formapag = _cod_formapag;
		
				FOREACH					       
					 select cod_agente,porc_partic_agt --, _porc_comis_agt
					   into _cod_agente,_porc_partic_agt --, _porc_comis_agt
					   from emipoagt
					  where no_poliza = _no_poliza
					  
							select nombre, cod_cobrador
							  into _nombre, _cod_cobrador
							  from agtagent
							 where cod_agente = _cod_agente;					  							 
							 
							select nombre 
							  into _zona
							  from cobcobra 
							 where cod_cobrador = _cod_cobrador;					  
							 
							 select nombre
							   into _nombre_aseg			
							   from cliclien 
							  where cod_cliente = _cod_asegurado;	 

							let _nombre_aseg     = trim(_nombre_aseg);	
							 
							RETURN _no_documento,
								_cod_formapag,
								_formapag,
								_vigencia_inic,
								_vigencia_final,		 
								_cod_agente,
								_nombre,
								_cod_cobrador,
								_zona,
								_porc_partic_agt,
								_cod_asegurado,								
								_nombre_aseg
								WITH RESUME;								 
							 

				END FOREACH			  
            end if		  

    END FOREACH

DROP TABLE temp_perfil;

END PROCEDURE;
