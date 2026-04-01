-- datos de venezuela - generados de prima suscrita 
-- creado    : 29/05/2011      -- autor: henry giron 
-- execute procedure sp_aud30("001","001",'31/05/2012',"001,003,014;")
drop procedure sp_aud30;
create procedure "informix".sp_aud30(a_cia char(03),a_agencia char(3),a_fecha date,a_codramo char(255) default "*")
returning char(45),			-- asegurado	
		  char(20),     	-- cedula	
		  char(20),			-- no_documento	
		  date,				-- vigencia_inic	
		  date, 			-- vigencia_final	
		  decimal(16,2),	-- suma_asegurada	
		  char(5),			-- no_unidad	
		  char(50), 		-- tipo_asegurado	
		  decimal(16,2),	-- suma_asegurada	
		  decimal(16,2),	-- prima_suscrita	
		  char(50),			-- ubicacion  	
		  char(3),			-- cod_ramo	
		  char(50),			-- desc_ramo       	
		  decimal(16,2),	-- prima_suscrita	
		  char(255),		-- filtros	
		  char(50),			-- descr_cia	
		  char(10);			-- no_poliza	

    define v_cod_ramo,v_cod_sucursal  			 char(3);
    define v_saber					  			 char(2);
    define v_cod_grupo,_cod_acreedor,_limite	 char(5);
    define v_contratante,v_codigo,_temp_poliza	 char(10);
    define v_asegurado                			 char(45);
    define v_desc_ramo,v_descr_cia,v_desc_agente char(50);
    define v_desc_grupo               			 char(40);
    define v_no_documento             			 char(20);
    define v_vigencia_inic,v_vigencia_final   	 date;
    define v_cant_polizas             			 integer;
    define v_prima_suscrita,v_suma_asegurada   	 decimal(16,2);
    define _tipo              					 char(1);
    define v_filtros          					 char(255);
	define v_no_poliza							 char(10);
    define _cod_agente                           char(5); 
    define _nombre_agente                        char(50); 
    define u_no_unidad                           char(5);
    define u_suma_asegurada  					 decimal(16,2);
	define u_prima_suscrita					     decimal(16,2);
    define u_tipo_incendio                       integer;
    define u_cod_manzana                         char(15); 
    define u_tipo_asegurado                      char(50); 
    define u_referencia                          char(50); 
    define u_zona_libre                          integer;
	define _cod_ubica                            char(3);
    define v_ubicacion                           char(50); 
	define v_porc_ubicacion					     decimal(9,4);
	define _cedula                               char(20);
	define v_aseg_lider                          char(03);     
	define _cod_tipoprod                         char(03);     
	define _tipo_produccion                      smallint;     
	define _porc_coas_aa						 dec(16,5);
	define _porc_coas_ced						 dec(16,5);

         
create temp table tmp_vigentes
    ( cod_ramo		   	char(3),		 
	  desc_ramo		   	char(50),		 
	  no_documento	   	char(20),		 
	  asegurado		   	char(45),		 
	  vigencia_inic	   	date,			 
	  vigencia_final   	date,			 
	  suma_asegurada   	dec(16,2),		 
	  prima_suscrita   	dec(16,2),		 
	  filtros		   	char(255),		 
	  descr_cia		   	char(50),		 
	  no_poliza        	char(10),		 
	  tipo_asegurado   	char(50),		 
	  no_unidad        	char(5),		 
	  usuma_asegurada   dec(16,2),		 
	  uprima_suscrita   dec(16,2),		 
	  ubicacion			char(50),
	  cedula			char(20),
      primary key (no_poliza,no_unidad)         
     )with no log;

create index idx1_tmp_vigentes on tmp_vigentes(no_poliza);
create index idx2_tmp_vigentes on tmp_vigentes(no_unidad);

    let v_cod_ramo       = null;
    let v_cod_sucursal   = null;
    let v_cod_grupo      = null;
    let v_contratante    = null;
    let v_no_documento   = null;
    let v_desc_ramo      = null;
    let v_descr_cia      = null;
    let v_cant_polizas   = 0;
    let v_prima_suscrita = 0;
    let _tipo            = null;
	let u_tipo_asegurado  = '';
	let u_referencia      = '';
	let u_zona_libre      = 0;
	let v_porc_ubicacion  = 0;
	let v_ubicacion       = '';
	let _cedula           = '';

    set isolation to dirty read;
--    set debug file to "sp_aud30.trc";
--    trace on;

     let v_descr_cia = sp_sis01(a_cia);
    call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;

  SELECT par_ase_lider
    INTO v_aseg_lider
    FROM parparam
   WHERE cod_compania = a_cia;

    foreach 
       select y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,y.vigencia_final,y.suma_asegurada,y.prima_suscrita,y.no_poliza
         into v_no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,v_vigencia_final,v_suma_asegurada,v_prima_suscrita,v_no_poliza
         from temp_perfil y
        where y.seleccionado = 1
        order by y.cod_ramo,y.no_documento

		SELECT cod_tipoprod
		  INTO _cod_tipoprod
		  FROM emipomae
		 WHERE emipomae.no_poliza  = v_no_poliza;

       	select a.nombre 
       	  into v_desc_ramo 
       	  from prdramo a 
       	 where a.cod_ramo  = v_cod_ramo; 

       	select nombre ,cedula
       	  into v_asegurado ,_cedula
       	  from cliclien 
       	 where cod_cliente = v_contratante; 

           let u_suma_asegurada = 0;
           let u_prima_suscrita = 0;				 
		   let _porc_coas_aa  = 0;
		   let _porc_coas_ced = 0;

       foreach 
          select no_unidad,
          		 suma_asegurada,
				 prima_suscrita,
				 tipo_incendio
            into u_no_unidad,
            	 u_suma_asegurada,
				 u_prima_suscrita,
				 u_tipo_incendio
            from emipouni
           where no_poliza = v_no_poliza

				if _cod_tipoprod = "001" then  -- coaseguro mayoritario 
					select porc_partic_coas
					  into _porc_coas_aa
					  from emicoama
					 where no_poliza    = v_no_poliza
					   and cod_coasegur = "036";

					let u_suma_asegurada = u_suma_asegurada * _porc_coas_aa/100;
					let u_prima_suscrita = u_prima_suscrita * _porc_coas_aa/100;

				end if


			 let u_tipo_asegurado  = 'Sin Nombrar';

			  if u_tipo_incendio = 1 then
				 let u_tipo_asegurado  = 'Edificio';
			 end if

			  if u_tipo_incendio = 2 then
				 let u_tipo_asegurado  = 'Contenido';
			 end if

			  if u_tipo_incendio = 3 then
				 let u_tipo_asegurado  = 'Lucro Cesante';
			 end if

			foreach
			 select	cod_ubica 
			   into _cod_ubica 
			   from	endcuend
			  where no_poliza = v_no_poliza
				and no_unidad = u_no_unidad

				 select nombre
				   into v_ubicacion
				   from emiubica
				  where cod_ubica = _cod_ubica;
				  exit foreach;

			   end foreach

				insert into tmp_vigentes
	 					 ( cod_ramo,
						   desc_ramo,
						   no_documento,
						   asegurado,
				   		   vigencia_inic,
						   vigencia_final,
						   suma_asegurada,
						   prima_suscrita,
						   filtros,
						   descr_cia,
						   no_poliza,
						   tipo_asegurado,
						   no_unidad,
						   usuma_asegurada,
						   uprima_suscrita,
						   ubicacion,
						   cedula	 )
				   values( v_cod_ramo,				 
						   v_desc_ramo,				 
						   v_no_documento,			 
						   v_asegurado,				 
				   		   v_vigencia_inic,			 
						   v_vigencia_final,		 		 
						   v_suma_asegurada,		 
						   v_prima_suscrita,		 
						   v_filtros,				 
						   v_descr_cia,				 
						   v_no_poliza, 			 
						   u_tipo_asegurado, 
						   u_no_unidad,	
						   u_suma_asegurada,		 
						   u_prima_suscrita,
						   v_ubicacion,
						   _cedula   );	 	   
	    end foreach

    end foreach

    set isolation to dirty read;
    foreach 
       select cod_ramo,
			  desc_ramo,
			  no_documento,
			  asegurado,
			  vigencia_inic,
			  vigencia_final,
			  suma_asegurada,
			  prima_suscrita,
			  filtros,
			  descr_cia,
			  no_poliza,
			  tipo_asegurado,
			  no_unidad,
			  usuma_asegurada,
			  uprima_suscrita,
			  ubicacion,
			  cedula	
         into v_cod_ramo,
			  v_desc_ramo,
			  v_no_documento,
			  v_asegurado,
			  v_vigencia_inic,
			  v_vigencia_final,
			  v_suma_asegurada,
			  v_prima_suscrita,
			  v_filtros,
			  v_descr_cia,
			  v_no_poliza,
			  u_tipo_asegurado,
			  u_no_unidad,
			  u_suma_asegurada,
			  u_prima_suscrita,
			  v_ubicacion,
			  _cedula
         from tmp_vigentes 
     order by cod_ramo,no_documento,no_unidad

       return 
              v_asegurado,				  
              _cedula,  				  
              v_no_documento,			  
              v_vigencia_inic,			  
              v_vigencia_final,			  
			  v_suma_asegurada,			  
              u_no_unidad,				  
              u_tipo_asegurado,			  
              u_suma_asegurada,			  
              u_prima_suscrita,			  
              v_ubicacion,				  
              v_cod_ramo,				  
              v_desc_ramo,				         
              v_prima_suscrita,			  
              v_filtros,				  
              v_descr_cia,				  
              v_no_poliza				  
              with resume;  
												 
    end foreach


drop table temp_perfil;
drop table tmp_vigentes;
end procedure;