-- datos de venezuela - generados de prima suscrita 
-- creado    : 29/05/2011      -- autor: henry giron 
-- execute procedure sp_aud30("001","001",'24/08/2011',"*","001;","*","00141;","*","*","*","*")
drop procedure sp_aud30;
{create procedure "informix".sp_aud30(a_cia	char(3), a_agencia char(3),a_fecha date, a_codramo char(255) default "*")
returning	char(20),	 -- no_documento    
			char(10),	 -- no_poliza       
			char(3),	 -- cod_ramo        
			char(50),	 -- nombre_ramo     
			dec(16,2),	 -- prima_suscrita           
			dec(16,2),	 -- prima_neta		    
			dec(16,2),	 -- suma_asegurada 	
			date,		 -- vigencia_inic   
			date,		 -- vigencia_final  
			char(5),	 -- no_unidad       
			dec(16,2),	 -- suma_unidad 	
			char(10),	 -- cod_asegurado   
			char(100),	 -- nombre_asegurado
			date,		 -- fecha_recibo    
            char(10),	 -- no_recibo											
			smallint,	 -- tipo
			varchar(50), -- nombre_tipo
			char(20),    -- cedula
			CHAR(3),	 -- cod_ubica	
			CHAR(50);	 -- ubicacion	}

create procedure "informix".sp_aud30(a_cia char(03),a_agencia char(3),a_fecha date,a_codsucursal char(255) default "*",a_codramo char(255) default "*",a_codgrupo char(255) default "*",a_agente char(255) default "*",a_usuario char(255) default "*", a_cod_cliente char(255) default "*", a_acreedor char(255) default "*", a_no_documento char(255) default "*")
RETURNING 	CHAR(3),		-- cod_ramo,
			CHAR(50),		-- desc_ramo,
			CHAR(20),		-- no_documento,
			CHAR(45),		-- asegurado,
			DATE,			-- vigencia_inic,
			DATE, 			-- vigencia_final,
			DECIMAL(16,2),	-- suma_asegurada,
			DECIMAL(16,2),	-- prima_suscrita,
			CHAR(255),		-- filtros,
			CHAR(50),		-- descr_cia,
			CHAR(10),		-- no_poliza,
			CHAR(50), 		-- tipo_asegurado,
			CHAR(5),		-- no_unidad,
			DECIMAL(16,2),	-- suma_asegurada,
			DECIMAL(16,2),	-- prima_suscrita,
			CHAR(50);		-- ubicacion  

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

---   v_filtros, v_descr_cia char(255), char(50)          
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
	  usuma_asegurada    dec(16,2),		 
	  uprima_suscrita    dec(16,2),		 
	  ubicacion			char(50),
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

    set isolation to dirty read;
--    set debug file to "sp_pro4938.trc";
--    trace on;

    let v_descr_cia = sp_sis01(a_cia);
    call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;

    foreach 
       select y.no_documento,y.cod_ramo,y.cod_contratante,y.vigencia_inic,y.vigencia_final,y.suma_asegurada,y.prima_suscrita,y.no_poliza
         into v_no_documento,v_cod_ramo,v_contratante,v_vigencia_inic,v_vigencia_final,v_suma_asegurada,v_prima_suscrita,v_no_poliza
         from temp_perfil y
        where y.seleccionado = 1 -- and y.no_poliza = '405212'
     order by y.cod_ramo,y.no_documento

       	select a.nombre 
       	  into v_desc_ramo 
       	  from prdramo a 
       	 where a.cod_ramo  = v_cod_ramo; 

       	select nombre 
       	  into v_asegurado 
       	  from cliclien 
       	 where cod_cliente = v_contratante; 

           let u_suma_asegurada = 0;
           let u_prima_suscrita = 0;				 

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

			 let u_tipo_asegurado  = 'etc';

			  if u_tipo_incendio = 1 then
				 let u_tipo_asegurado  = 'edificio';
			 end if

			  if u_tipo_incendio = 2 then
				 let u_tipo_asegurado  = 'contenido';
			 end if

			  if u_tipo_incendio = 3 then
				 let u_tipo_asegurado  = 'lucro cesante';
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

--			begin
--	   			on exception in(-239)
--				end exception

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
						   ubicacion	 )
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
						   v_ubicacion   );	 
  --			end			   
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
			  ubicacion	
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
			  v_ubicacion
         from tmp_vigentes 
     order by cod_ramo,no_documento,no_unidad

       return v_cod_ramo,
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
              v_ubicacion  
              with resume;  
												 
    end foreach


drop table temp_perfil;
drop table tmp_vigentes;
end procedure;
