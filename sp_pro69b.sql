DROP procedure sp_pro69b;
CREATE procedure "informix".sp_pro69b(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING CHAR(3),	   -- cod_ramo
 		  CHAR(50),    -- desc. ramo
 		  CHAR(10),    -- no_factura
 		  CHAR(20),    -- no_documento
          CHAR(50),    -- cliente
          DEC(16,2),   -- suma asegurada
          DEC(16,2),   -- prima suscrita
          CHAR(50),    -- desc. cia
          DATE,	  	   -- vig ini
		  DATE,	  	   -- vig fin
          CHAR(255),   -- filtros
		  CHAR(50),    -- corredor
		  dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2);
--------------------------------------------
---  DETALLE DE POLIZAS DECLARATIVAS     ---
---  Henry Giron - 23/11/2011            ---
---  Ref. Power Builder - d_sp_pro34b	 ---
--------------------------------------------
   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso,_cod_corredor        CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(100);
      DEFINE v_desc_ramo,v_corredor          CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
	  DEFINE v_vig_ini,v_vig_fin			 DATE;
      DEFINE _mes_vig                        SMALLINT;
      DEFINE _prima_bruta                    DECIMAL(16,2);	  
	  DEFINE _ene 	 		 				 DECIMAL(16,2);
	  DEFINE _feb 	 		 				 DECIMAL(16,2);
	  DEFINE _mar 	 		 				 DECIMAL(16,2);
	  DEFINE _abr 	 		 				 DECIMAL(16,2);
	  DEFINE _may 	 		 				 DECIMAL(16,2);
	  DEFINE _jun 	 		 				 DECIMAL(16,2);
	  DEFINE _jul 	 		 				 DECIMAL(16,2);
	  DEFINE _ago 	 		 				 DECIMAL(16,2);
	  DEFINE _sep 	 		 				 DECIMAL(16,2);
	  DEFINE _oct 	 		 				 DECIMAL(16,2);
	  DEFINE _nov 	 		 				 DECIMAL(16,2);
	  DEFINE _dic 	 		 				 DECIMAL(16,2);
	  DEFINE _total    		 				 DECIMAL(16,2);
	  DEFINE _hay         					 INTEGER;
      DEFINE _periodo1		                 CHAR(7);
      DEFINE _periodo2		                 CHAR(7);


		CREATE TEMP TABLE tmp_mensual (
         		no_documento	CHAR(20),
				v_inicial		DATE,
				v_final			DATE,
		        ene 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        feb 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        mar 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        abr 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        may 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        jun 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        jul 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        ago 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        sep 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        oct 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        nov 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        dic 	  		DECIMAL(16,2) DEFAULT 0 NOT NULL,
		        total     		DECIMAL(16,2) DEFAULT 0 NOT NULL ) WITH NO LOG;
		CREATE INDEX xie01_tmp_mensual ON tmp_mensual(no_documento,v_inicial,v_final);

		CREATE TEMP TABLE tmp_ver (
         		no_documento	CHAR(20)) WITH NO LOG;
		CREATE INDEX xie01_tmp_ver ON tmp_ver(no_documento);

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro69(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_cliente, a_no_documento)
                    RETURNING v_filtros;
--	  Set debug file to "sp_pro69.trc";
--      trace on;

      SET ISOLATION TO DIRTY READ;
      FOREACH WITH HOLD
         SELECT cod_ramo,no_documento,max(vigencia_inic),max(vigencia_final),sum(suma_asegurada),sum(prima)
           INTO v_cod_ramo,v_nodocumento,v_vig_ini,v_vig_fin,v_suma_asegurada,v_prima_suscrita
           FROM temp_det
          WHERE seleccionado = 1
          group by 1,2
          ORDER BY 1,2

		 SELECT min(vigencia_inic),min(vigencia_final)
		   INTO v_vig_ini,v_vig_fin
           FROM emipomae
          WHERE (periodo >= a_periodo1  
            AND  periodo <= a_periodo2) 
            AND actualizado = 1 
            AND no_documento = v_nodocumento;

		   -- let _periodo1 = sp_sis39(v_vig_ini);
		   -- let _periodo2 = sp_sis39(v_vig_fin);

		foreach
         SELECT no_factura,
         		cod_contratante,                
				cod_agente
           INTO v_nofactura,
           		v_cod_contratante,
				_cod_corredor
           FROM temp_det
          WHERE seleccionado = 1 and cod_ramo = v_cod_ramo and no_documento = v_nodocumento	 and vigencia_final =	v_vig_fin
		   exit foreach;
		    end foreach

			    LET _hay   = 0;	
				select count(*)
				  into _hay
				  from tmp_ver
				 where no_documento = v_nodocumento ;
				 		
				if _hay = 0 then
					insert into tmp_ver(no_documento)
					values (v_nodocumento);
				else
					continue foreach;
			   end if

			   let _mes_vig	= 0;
			   let _prima_bruta = 0;
			   LET _ene   = 0;		
			   LET _feb   = 0;		
			   LET _mar   = 0;		
			   LET _abr   = 0;		
			   LET _may   = 0;		
			   LET _jun   = 0;		
			   LET _jul   = 0;		
			   LET _ago   = 0;		
			   LET _sep   = 0;		
			   LET _oct   = 0;		
			   LET _nov   = 0;		
			   LET _dic   = 0;		
			   LET _total = 0;	
			   LET _hay   = 0;	

			select count(*)
			  into _hay
			  from tmp_mensual
			 where no_documento = v_nodocumento ;
			
				if _hay = 0 or _hay is null then
				   LET _hay   = 0;	

					foreach
					 select month(vigencia_inic),sum(prima_bruta)
					   into _mes_vig,_prima_bruta
					   from endedmae
					  where trim(no_documento) = trim(v_nodocumento) 
--					    AND periodo >= _periodo1
--   					AND periodo <= _periodo2
					    AND vigencia_inic >= v_vig_ini 
-					    AND vigencia_final <= v_vig_fin 
					    AND cod_endomov = "023"	  -- movimiento cartas declarativas
				      group by 1
				      order by 1

						select count(*)
						  into _hay
						  from tmp_mensual
						 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
						 		
							if _hay = 0 then
								insert into tmp_mensual(no_documento,v_inicial,v_final,ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total)
								values (v_nodocumento,v_vig_ini,v_vig_fin,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total);
							end if 

							if _mes_vig= 1 then 
								update tmp_mensual
								   set ene         = ene + _prima_bruta    , total = total + _prima_bruta    			 
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;											 
							elif _mes_vig= 2 then
								update tmp_mensual
								   set feb         = feb + _prima_bruta		 , total = total + _prima_bruta    		 	
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 3 then
								update tmp_mensual
								   set mar         = mar + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 4 then
								update tmp_mensual
								   set abr         = abr + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 5 then
								update tmp_mensual
								   set may         = may + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 6 then
								update tmp_mensual
								   set jun         = jun + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 7 then
								update tmp_mensual
								   set jul         = jul + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 8 then
								update tmp_mensual
								   set ago         = ago + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 9 then
								update tmp_mensual
								   set sep         = sep + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 10 then
								update tmp_mensual
								   set oct         = oct + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 11 then
								update tmp_mensual
								   set nov         = nov + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							elif _mes_vig= 12 then
								update tmp_mensual
								   set dic         = dic + _prima_bruta		 , total = total + _prima_bruta    
								 where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin ;
							end if 
					    end foreach

			 SELECT ene,
					feb,
					mar,
					abr,
					may,
					jun,
					jul,
					ago,
					sep,
					oct,
			        nov,
					dic,
					total	 		
			   INTO	_ene,
			   		_feb,
			   		_mar,
			   		_abr,
			   		_may,
			   		_jun,
			   		_jul,
			   		_ago,
					_sep,
					_oct,
					_nov,
					_dic,
					_total
			   FROM tmp_mensual
			  where no_documento = v_nodocumento and v_inicial = v_vig_ini and v_final = v_vig_fin;

			end if

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
           INTO v_corredor
           FROM agtagent
          WHERE cod_agente = _cod_corredor;

         RETURN v_cod_ramo,
         		v_desc_ramo,
         		v_nofactura,
         		v_nodocumento,
                v_desc_nombre,
                v_suma_asegurada,
                v_prima_suscrita,
                v_descr_cia,
				v_vig_ini,
				v_vig_fin,
                v_filtros,
				v_corredor,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total
                WITH RESUME;

      END FOREACH
--   trace off;

   DROP TABLE temp_det;
   DROP TABLE tmp_mensual;
   DROP TABLE tmp_ver; 
   END
END PROCEDURE;
