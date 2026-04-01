DROP procedure sp_pro992bk;
CREATE procedure "informix".sp_pro992bk(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING 
	char(10),		
	char(10),		
	char(5),		
	dec(16,2),		
	dec(16,2),		
	DEC(16,2),
	char(3);


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
	  DEFINE f_cod_contrato 				 CHAR(5);
	  DEFINE t_cedido						 DECIMAL(16,2);
	  DEFINE f_cedido						 DECIMAL(16,2);
	  DEFINE _db							 DECIMAL(16,2);
	  DEFINE _cr							 DECIMAL(16,2);
	  define _no_poliza                      char(10);
	  define _periodo                        char(7);
	  define _prima_unidad                	 DECIMAL(16,2);
	  define _dif,_dif2                      DECIMAL(16,2);
	  define _cnt                            smallint;
	  define _mal 							 Smallint;
	  define _No_U 							 char(5);
	  define _valor_final                    DECIMAL(16,2);
	  define _prima_uni_tot					 DECIMAL(16,2);
	  define _cod_ramo                       char(3);

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
	  LET v_cedido          = 0;
	  LET _cedido_dist      = 0;
	  LET _tot_prima_sus    = 0;
	  LET _verificar        = 0;
	  LET f_cedido          = 0;
	  LET t_cedido          = 0;
	  let _mal              = 0;
	  let _No_U				= "*";

      LET v_descr_cia = sp_sis01(a_compania);

      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
                    RETURNING v_filtros;

	  create temp table tmp_reas (
		no_factura			char(10),
		no_poliza			char(10),
		no_endoso           char(5),
		reas_cedida     	dec(16,2) default 0,
		prima               dec(16,2) default 0,
		mal					smallint  default 0,
		prima_uni           dec(16,2) default 0
		) WITH NO LOG;

	  create temp table tmp_reas1 (
		no_factura			char(10),
		prima_uni           dec(16,2) default 0,
		no_unidad   		char(5),
		cod_contrato        CHAR(5)
		) WITH NO LOG;	



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

--		    AND x.no_factura   in ("01-728122","01-728128","01-728134")

		   SELECT porc_partic_agt 					   
		     INTO _porc_partic_agt 					   
		     FROM endmoage 							   
		    WHERE no_poliza  = v_nopoliza 			   
		      and no_endoso  = v_noendoso 			   
			  and cod_agente = v_cod_agente; 		   

		let _valor_final   = 0;
		let _prima_uni_tot = 0;

		foreach

		    SELECT e.cod_contrato,
		           e.cod_cober_reas,
				   e.prima,
				   e.no_unidad,
				   r.prima_suscrita*e.porc_partic_prima/100
		      INTO _cod_contrato,
		           _cod_cober_reas,  
				   _cedido_dist,
				   _no_unidad,
				   _prima_unidad
			  FROM emifacon	e, endeduni r
			 WHERE e.no_poliza = r.no_poliza
			   AND e.no_endoso = r.no_endoso
			   AND e.no_unidad = r.no_unidad
			   AND e.no_poliza = v_nopoliza
			   AND e.no_endoso = v_noendoso

			Select count(*)
			  into _cantidad
			  From reacomae
			 Where cod_contrato = _cod_contrato
			   and tipo_contrato <> 1;

			if _cantidad = 0 then
			   continue foreach;
			end if

				Select tipo_contrato
			      Into _tipo_contrato
				  From reacomae
				 Where cod_contrato = _cod_contrato
				   AND tipo_contrato <> 1 ;

				IF _cedido_dist IS NULL THEN
				  LET _cedido_dist = 0;
				END IF 

			   LET _tot_prima_sus = 0;
			   LET _tot_prima_sus = _cedido_dist * _porc_partic_agt / 100;
			   LET _cedido_dist   = _tot_prima_sus;

			   select count(*)
			     into _cnt
			     from tmp_reas1
			    where no_factura   = v_nofactura
			      and no_unidad    = _no_unidad
			      and cod_contrato = _cod_contrato;
			      
			   if _cnt = 0 then
	    			INSERT INTO tmp_reas1(
					no_factura,	
					prima_uni,
					no_unidad,
					cod_contrato
					)
					VALUES(
					v_nofactura,
					_prima_unidad,
					_no_unidad,
					_cod_contrato);

			   end if     				

			   IF _tipo_contrato = 3 THEN  -- Facultativo

				    let f_prima = 0;
					

						select sum(_cedido_dist*porc_partic_reas/100)
						  into f_prima
						  from emifafac
					     where no_poliza      = v_nopoliza
					       and no_endoso      = v_noendoso
					       and cod_contrato   = _cod_contrato
					       and cod_cober_reas = _cod_cober_reas
				           and no_unidad      = _no_unidad;
						 				           						
					 let _valor_final = _valor_final + f_prima;

			   ELSE						-- Otros contratos

					 select count(*)
					   into _cantidad
					   from reacoase
				      where cod_contrato   = _cod_contrato
				        and cod_cober_reas = _cod_cober_reas;

					if _cantidad = 0 then
						 let _valor_final = _valor_final + _cedido_dist;
					end if

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

					 let _valor_final = _valor_final + _monto_reas;

					end foreach

				END IF

		END FOREACH

		select count(*)
		  into _cnt
		  from tmp_reas1
		 where no_factura = v_nofactura;

		if _cnt > 0 then

			select count(*)
			  into _cnt
			  from tmp_reas
			 where no_factura = v_nofactura;

			if _cnt = 0 then

	 			INSERT INTO tmp_reas (
				no_factura,	
				no_poliza,	
				no_endoso,  
				reas_cedida,
				prima_uni)
				VALUES(
				v_nofactura,
				v_nopoliza,
				v_noendoso,
				_valor_final,
				_prima_uni_tot);

			else

				update tmp_reas
				   set reas_cedida = reas_cedida + _valor_final,
				       prima_uni   = prima_uni   + _prima_uni_tot
				 where no_factura = v_nofactura;

			end if
		end if

END FOREACH

let _verificar = 0;
let _mal       = 0;
let _db        = 0;
let _cr        = 0;

foreach

	select no_factura,
	       reas_cedida,
		   prima_uni
	  into v_nofactura,
	       _verificar,
		   _prima_unidad
	  from tmp_reas

	select sum(prima_uni)
	  into _prima_uni_tot
	  from tmp_reas1
	 where no_factura = v_nofactura;

    update tmp_reas
	   set prima_uni  = _prima_uni_tot
	 where no_factura = v_nofactura;

	foreach
	 select no_poliza,
	        no_endoso,
			periodo
	   into _no_poliza,
	        v_noendoso,
			_periodo
	   from endedmae
	  where no_factura  = v_nofactura
	    and actualizado = 1
	 exit foreach;
	end foreach

	foreach

	 select sum(debito),
	        sum(credito)
	   into	_db,
	        _cr
	   from endasien
	  where periodo   = _periodo
		and no_poliza = _no_poliza
		and no_endoso = v_noendoso
		and cuenta    like '511%'
	  exit foreach;
	end foreach

	let _dif2 = 0;
	let _dif2 = (ABS(_cr + _db) - ABS(_verificar));
	let _dif2 = ABS(_dif2);

  {	if _dif2 > 0.03 then
  	   let _mal = 1;
	   update tmp_reas
	      set mal   = 1,
		      prima = _cr + _db
	    where no_factura = v_nofactura;
	else}
	   update tmp_reas
	      set prima = _cr + _db,
		      mal = 0
	    where no_factura = v_nofactura;

  --	end if

end foreach

FOREACH

	   	SELECT no_factura,
			   no_poliza,
			   no_endoso,
			   reas_cedida,
			   prima,
			   prima_uni
		 INTO  v_nofactura,
			   _no_poliza,
			   v_noendoso,
			   v_cedido,
			   _comision,
			   _prima_unidad
		  FROM tmp_reas
	     order by 1

--	     where mal = 1

		 select cod_ramo
		   into _cod_ramo
		   from emipomae
		  where no_poliza = _no_poliza;

         RETURN v_nofactura,
		        _no_poliza,
				v_noendoso,
			    v_cedido,
				_comision,
				_prima_unidad,
				_cod_ramo
                WITH RESUME; 

END FOREACH

DROP TABLE temp_det;
DROP TABLE tmp_reas;
DROP TABLE tmp_reas1;

END
END PROCEDURE;