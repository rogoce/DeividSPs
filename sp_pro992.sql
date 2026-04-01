DROP procedure sp_pro992;
CREATE procedure "informix".sp_pro992(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING 
	char(10),		--no_factura
	char(1),		--tipo_contrato
	char(3),		--cod_reasegur
	varchar(50),	--nombre_coasegur
	dec(16,2),		--porc_reas
	dec(16,2),		--reas_cedida
	CHAR(50),		--v_descr_cia
	CHAR(255),		--v_filtros
	DEC(16,2);		--v_cedido	

--------------------------------------------
---  DETALLE DE FACTURACION POR RAMO     ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro34b
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(1);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia,v_desc_agente       CHAR(50);
	  define v_cod_agente					 CHAR(5);
	  define v_cedido                        DECIMAL(16,2);
      DEFINE _tipo_contrato					 SMALLINT;
      DEFINE _cedido_dist					 DECIMAL(16,2);
      DEFINE _cod_contrato					 CHAR(5);
      DEFINE _cod_cober_reas				 CHAR(3);  
      DEFINE _no_unidad						 CHAR(5);
      DEFINE _cod_coasegur					 CHAR(5);
      DEFINE _nombre_coas					 CHAR(50);
      DEFINE _porc_cont_partic				 DECIMAL(9,2);
      DEFINE _porc_comision					 DECIMAL(9,2);
      DEFINE _prima_cedida					 DECIMAL(16,2);
      DEFINE _comision						 DECIMAL(16,2);
      DEFINE _monto_reas					 DECIMAL(16,2);
	  DEFINE _cantidad						 SMALLINT;
	  define _tot_prima_sus                  dec(16,2);
	  define _porc_partic_agt                decimal(5,2);   

	  define _verificar,f_prima				 DECIMAL(16,2);
	  define _mal 							 Smallint;

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
	  LET v_cedido          = 0;
	  LET _cedido_dist      = 0;
	  let _tot_prima_sus    = 0;
	  let _verificar = 0;
	  let _mal = 0;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
                    RETURNING v_filtros;

	  create temp table tmp_reas (
		no_factura			char(10),
		tipo_contrato		char(1),
		cod_reasegur    	char(3),
		nombre_coasegur     varchar(50),
		porc_reas      	    dec(16,2) default 0,
		reas_cedida     	dec(16,2) default 0,
		prima               dec(16,2) default 0,
		mal					smallint  default 0) WITH NO LOG;	

--Filtro de Cliente

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registroo

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

--set debug file to "sp_pro992.trc";
--trace on;

      FOREACH WITH HOLD
         SELECT x.cod_ramo,
         		x.no_factura,
         		x.no_documento,
         		x.cod_contratante,
                x.estatus,
                x.forma_pago,
                x.cant_pagos,
                x.suma_asegurada,
                x.prima,
                x.comision,
				x.cod_agente,
				x.no_poliza,
         		x.no_endoso
           INTO v_cod_ramo,
           		v_nofactura,
           		v_nodocumento,
           		v_cod_contratante,
                v_estatus,
                v_forma_pago,
                v_cant_pagos,
                v_suma_asegurada,
                v_prima_suscrita,
                v_comision,
				v_cod_agente,
				v_nopoliza,
				v_noendoso
           FROM temp_det x
          WHERE x.seleccionado = 1
          ORDER BY x.cod_ramo,x.no_factura

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

            SELECT sum(e.prima)
              INTO v_cedido
			  FROM emifacon	e, endeduni r, reacomae t
			 WHERE e.no_poliza = r.no_poliza
			   AND e.no_endoso = r.no_endoso
			   AND e.no_unidad = r.no_unidad
			   AND e.cod_contrato = t.cod_contrato
			   AND t.tipo_contrato <> 1
			   AND e.no_poliza = v_nopoliza
			   AND e.no_endoso = v_noendoso	;

				IF v_cedido IS NULL THEN
				  LET v_cedido = 0;
				END IF

		   SELECT porc_partic_agt
		     INTO _porc_partic_agt
		     FROM endmoage
		    WHERE no_poliza  = v_nopoliza
		      and no_endoso  = v_noendoso
			  and cod_agente = v_cod_agente ;

		   LET _tot_prima_sus = 0 ;
		   LET _tot_prima_sus = v_cedido * _porc_partic_agt / 100 ;
		   LET v_cedido = _tot_prima_sus ;

		foreach
		    SELECT t.tipo_contrato,
				   e.cod_contrato,
		           e.cod_cober_reas,
				   e.prima,
				   e.no_unidad
		      INTO _tipo_contrato,
				   _cod_contrato,
		           _cod_cober_reas,  
				   _cedido_dist,
				   _no_unidad
			  FROM emifacon	e, endeduni r, reacomae t
			 WHERE e.no_poliza = r.no_poliza
			   AND e.no_endoso = r.no_endoso
			   AND e.no_unidad = r.no_unidad
			   AND e.cod_contrato = t.cod_contrato
			   AND t.tipo_contrato <> 1
			   AND e.no_poliza = v_nopoliza
			   AND e.no_endoso = v_noendoso	

				IF _cedido_dist IS NULL THEN
				  LET _cedido_dist = 0;
				END IF 

--			   LET _cod_coasegur = _cod_contrato;
--			   LET _nombre_coas = v_nopoliza||":"||v_noendoso||":"||_no_unidad;
			   
			   LET _cod_coasegur = "";
			   LET _nombre_coas = "";

			   LET _tot_prima_sus = 0;
			   LET _tot_prima_sus = _cedido_dist * _porc_partic_agt / 100;
			   LET _cedido_dist = _tot_prima_sus;				

			    IF _tipo_contrato = 3 THEN  -- Facultativo
				    let f_prima = 0;

					foreach
						select cod_coasegur,sum(prima)
						  into _cod_coasegur,f_prima
						  from emifafac
					     where no_poliza      = v_nopoliza
					       and no_endoso      = v_noendoso
					       and cod_contrato   = _cod_contrato
					       and cod_cober_reas = _cod_cober_reas
				           and no_unidad      = _no_unidad					
						   group by cod_coasegur
						   order by 1
				           						
						select nombre
						  into _nombre_coas
						  from emicoase
						 where cod_coasegur = _cod_coasegur ; 
			
			 			INSERT INTO tmp_reas (
						no_factura,
						tipo_contrato,
						cod_reasegur,
						nombre_coasegur,
						porc_reas,
						reas_cedida,
						prima)										
						VALUES(v_nofactura,
						_tipo_contrato,
						_cod_coasegur,
						_nombre_coas,
						0,
						f_prima,
						v_cedido);
			
					end foreach


				ELSE						-- Otros contratos

					 select count(*)
					   into _cantidad
					   from reacoase
				      where cod_contrato   = _cod_contrato
				        and cod_cober_reas = _cod_cober_reas;

					if _cantidad = 0 then

			            LET _nombre_coas = "       * CONTRATO: "||_cod_contrato||" FACTURA: "||v_nofactura;


			 			INSERT INTO tmp_reas (
						no_factura,
						tipo_contrato,
						cod_reasegur,
						nombre_coasegur,
						porc_reas,
						reas_cedida,
						prima)										
						VALUES(v_nofactura,
						_tipo_contrato,
						_cod_coasegur,
						_nombre_coas,
						0,
						_cedido_dist,
						v_cedido);

					else

						foreach
						 select cod_coasegur,
						        porc_cont_partic,
						        porc_comision					
						   into _cod_coasegur,
						        _porc_cont_partic,
								_porc_comision
						   from reacoase
					      where cod_contrato   = _cod_contrato
					        and cod_cober_reas = _cod_cober_reas

								let _monto_reas = _cedido_dist * _porc_cont_partic / 100 ; 
								let _comision   = _monto_reas * _porc_comision / 100 ; 

								select nombre
								  into _nombre_coas
								  from emicoase
								 where cod_coasegur = _cod_coasegur ;

					 			INSERT INTO tmp_reas (
								no_factura,
								tipo_contrato,
								cod_reasegur,
								nombre_coasegur,
								porc_reas,
								reas_cedida,
								prima)										
								VALUES(v_nofactura,
								_tipo_contrato,
								_cod_coasegur,
								_nombre_coas,
								_porc_cont_partic,
								_monto_reas,
								v_cedido);

						end foreach		   
					end if
				END IF
		END FOREACH

		let _verificar = 0;
	    let _mal = 0;

		select sum(reas_cedida)
		  into _verificar
		  from tmp_reas
		 where no_factura = v_nofactura;

		if (ABS(v_cedido) - ABS(_verificar))  > 1 then
		   let _mal = 1;
		   update tmp_reas
		      set mal = _mal
		    where no_factura = v_nofactura; 
		end if

      END FOREACH

      FOREACH
	   	SELECT no_factura,
			   tipo_contrato,
			   cod_reasegur,
			   nombre_coasegur,
			   porc_reas,
			   reas_cedida,
			   prima
		INTO   v_nofactura,
			   _tipo_contrato,
			   _cod_coasegur,
			   _nombre_coas,
			   _porc_comision,
			   _comision,
			   v_cedido
		FROM tmp_reas
		where mal = 0
		order by 1,4

         RETURN v_nofactura,
			   _tipo_contrato,
			   _cod_coasegur,
			   _nombre_coas,
			   _porc_comision,
			   _comision,
                v_descr_cia,
                v_filtros,
                v_cedido		
                WITH RESUME; 

      END FOREACH


   DROP TABLE temp_det;
   DROP TABLE tmp_reas;

   END
END PROCEDURE;		  