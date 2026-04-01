-- Creado por: 19/07/2007.   Por  Rub‚n Arn ez, para preparar lo Reaseguros Facultativos de la poliza 1606-00015-01
DROP procedure sp_pro191;

CREATE procedure "informix".sp_pro191(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07))

 RETURNING 	CHAR(20),       -- 1.Numero de Documento
			DECIMAL(16,2),  -- 2.Prima Suscrita
			DECIMAL(16,2),  -- 3.Suma Asegurada
 			DATE,		    -- 4.Fecha de Emision
			CHAR(5),	    -- 5.Endoso
 	    	CHAR(5),	    -- 6.Unidad
 			CHAR(50),       -- 7.Nombre
 			CHAR(35), 		-- 8.Nomnre del Asegurado
			DECIMAL(16,2);  -- 9.Suma Asegurada en Facultativo

	  		 
      DEFINE v_nopoliza,v_nofactura           					CHAR(10);
      DEFINE v_nodocumento                    					CHAR(20);
      DEFINE v_noendoso,v_no_unidad           					CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_subramo,
             v_cod_tipoprod                  					CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo,v_cod_acreedor   			CHAR(5);
      DEFINE v_cod_usuario                    					CHAR(8);
      DEFINE v_porc_comis                     					DEC(5,2);
      DEFINE v_cod_contrato,v_cod_contratante,w_cod_contrato, _cod_cliente  CHAR(10);
      DEFINE v_prima,_prima_sus, v_suma, v_suma_asegurada  		DECIMAL(16,2);
      DEFINE v_comision                     					DECIMAL(9,2);
      DEFINE v_desc_contrato                  					CHAR(45);
      DEFINE v_desc_subramo                 					CHAR(25);
      DEFINE v_desc_ramo                      					CHAR(50);
      DEFINE v_desc_nombre, v_desc_nomaseg    					CHAR(35);
      DEFINE v_desc_acreedor                  					CHAR(30);
      DEFINE v_filtros                        					CHAR(255);
      DEFINE _tipo,_tipo_produccion,v_tipo_contrato  			CHAR(01);
      DEFINE v_descr_cia                      					VARCHAR(50);
      DEFINE s_tipopro                        					CHAR(03);
	  DEFINE _tipo_contrato, _orden_comp      					smallint;
	  DEFINE _fecha				              					DATE;
	  DEFINE _edad, v_sum_asegurados, _cont_edad  				smallint;
	  DEFINE _sum_edad						  					INTEGER;
	  DEFINE _cod_cobertura                   					CHAR(5);
	  DEFINE _orden, _longitud, _tipo_fac, _serie 				SMALLINT;
	  DEFINE _cobertura                       					VARCHAR(50);
	  DEFINE v_cobertura, v_cobertura2        					VARCHAR(255);
	  DEFINE v_prom_edad                      					DEC(5,2);
	  DEFINE _separador, _nueva_renov         					CHAR(1);
	  DEFINE _cod_endomov                     					CHAR(3);
	  DEFINE v_vigencia_inic, v_vigencia_final, v_fecha_emision DATE;
	  DEFINE v_nombre											CHAR(50);

	  LET s_tipopro        = NULL;
      LET v_desc_ramo      = NULL;
      LET v_cod_agente     = NULL;
      LET v_prima          = 0;
      LET _prima_sus       = 0;
      LET v_porc_comis     = 0;
	  LET v_cod_acreedor   = " ";

      LET v_descr_cia = sp_sis01(a_compania);


   SET ISOLATION TO DIRTY READ;


	FOREACH 
         SELECT no_poliza,
         		no_endoso,
         		cod_sucursal,
         		no_factura,
				prima_suscrita,
				suma_asegurada,
				fecha_emision,
				cod_endomov,
				no_documento
		   INTO v_nopoliza,
           		v_noendoso,
           		v_cod_sucursal,
           		v_nofactura,
				_prima_sus,
				v_suma_asegurada,
				v_fecha_emision,
				_cod_endomov,
				v_nodocumento
		   FROM endedmae 
          WHERE cod_compania  = a_compania
            AND actualizado   = "1"
            AND periodo      BETWEEN a_periodo1 AND a_periodo2
			AND no_documento  = "1606-00015-01"	

			FOREACH
					SELECT cod_cliente,
						   no_unidad
					  INTO _cod_cliente,
						   v_no_unidad
					  FROM endeduni
					 WHERE no_poliza = v_nopoliza
					   AND no_endoso = v_noendoso

				   FOREACH
				    SELECT cod_contrato,
		            	   prima,
						   suma_asegurada
		              INTO v_cod_contrato,
		              	   v_prima,
						   v_suma
		              FROM emifacon
		             WHERE no_poliza = v_nopoliza
					   AND no_endoso = v_noendoso
					   AND no_unidad = v_no_unidad

						 FOREACH
						     SELECT tipo_contrato,
							        nombre
				               INTO _tipo_contrato,
							        v_nombre
				               FROM reacomae
				              WHERE cod_contrato  = v_cod_contrato
			  	    		    AND nombre        = "FACULTATIVO"

								SELECT fecha_aniversario,
							  	       nombre
							      INTO _fecha,
							           v_desc_nomaseg
							      FROM cliclien
						   	     WHERE cod_cliente = _cod_cliente;
			   	 
			   --	   			IF nombre = "FACULTATIVO" THEN
			   --	   			   CONTINUE FOREACH;
			   --	   			END IF

							 RETURN v_nodocumento,	   -- 1
						            _prima_sus,		   -- 2
									v_suma_asegurada,  -- 3
						            v_fecha_emision,   -- 4
									v_noendoso,		   -- 5
				     		     	v_no_unidad,	   -- 6
									v_nombre,	       -- 7  Facultativo
									v_desc_nomaseg,    -- 8	 Nombre de Asegurado
									v_suma   		   -- 9  Suma Asegurada en Facultativo	
				     		 WITH RESUME;
						END FOREACH
			    END FOREACH
			END FOREACH
	END FOREACH
END PROCEDURE;