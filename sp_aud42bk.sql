--execute procedure sp_aud27('001','001','2011-01','2011-01','*','*','*','*','*','*','1','*','*')


--Polizas cedidas

DROP procedure sp_aud42bk;
CREATE procedure "informix".sp_aud42bk(a_periodo1 CHAR(07))
RETURNING int,
          int,
		  char(4),
		  char(2),
		  int,
		  int,
		  char(3),
		  char(3),
		  varchar(50),
		  char(3),
		  char(50),
		  char(3),
		  dec(7,3),
		  char(10),
		  char(20),
		  char(5),
		  char(25),
		  char(25),
		  date,
		  date,
		  date,
		  smallint,
		  date,
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  char(10),
		  char(10),
		  date,
		  date,
		  char(8),
		  smallint;

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
	  define v_cod_agente					 char(5);
	  define v_cedido                        dec(16,2);
	  define _tot_prima_sus                  dec(16,2);
	  define _porc_partic_agt                decimal(5,2);
	  define _vig_inic                       date;
	  define _vig_fin						 date;
	  define _no_poliza                      char(10);
	  define _cod_cober_reas                 char(3);
	  define _nombre_cober					 char(50);
	  define v_ano                           int;
	  define v_mes                           int;
	  define v_fecha_emision                 date;
	  define _serie                          int;
	  define _no_pagos                       smallint;
	  define _colectivo                      char(1);
	  define _tipo_poliza                    char(10);
	  define _ramo                           varchar(50);
	  define v_porc_comis                    DEC(5,2);
	  define _no_unidad                      char(5);
	  define _error                          int;
	  define _mensaje						 char(50);
      define _porc_proporcion		         dec(9,6);
	  define _suma_rea           			 dec(16,2);

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
	  LET v_cedido          = 0;
	  let _tot_prima_sus    = 0;
	  let _nombre_cober     = "";
{	  let v_ano = a_periodo1[1,4];
	  let v_mes = a_periodo1[6,7];

      LET v_descr_cia = sp_sis01(a_compania);

 {     CALL sp_pro34(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
                    RETURNING v_filtros;
 }
      CALL sp_pro34('001','*',a_periodo1,a_periodo1)
                    RETURNING v_filtros;


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
         		x.no_endoso,
				x.cod_tipoprod,
				x.cod_usuario
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
				v_noendoso,
				v_cod_tipoprod,
				v_cod_usuario
           FROM temp_det x
          WHERE x.seleccionado = 1
          ORDER BY x.cod_ramo,x.no_factura

		  if v_nopoliza = '686199' then
		  else
			   continue foreach;
		  end if


{         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;


 {		 foreach

            SELECT e.prima,e.suma_asegurada,e.cod_cober_reas
              INTO v_cedido,v_suma_asegurada,_cod_cober_reas
			  FROM emifacon	e, endeduni r, reacomae t
			 WHERE e.no_poliza = r.no_poliza
			   AND e.no_endoso = r.no_endoso
			   AND e.no_unidad = r.no_unidad
			   AND e.cod_contrato = t.cod_contrato
			   AND t.tipo_contrato <> 1
			   AND e.no_poliza = v_nopoliza
			   AND e.no_endoso = v_noendoso

				IF v_cedido IS NULL THEN
				  LET v_cedido = 0;
				END IF
 }
 --		   let _no_poliza = sp_sis21(v_nodocumento);
         
		 foreach 
		  select no_unidad, suma_asegurada
		    into _no_unidad, v_suma_asegurada
			from endeduni
		   where no_poliza = v_nopoliza
			 and no_endoso = v_noendoso	

			if v_cod_ramo = '002' then
				call sp_sis188(v_nopoliza) returning _error,_mensaje;
			end if

           foreach 
			select sum(a.prima_neta), b.cod_cober_reas
			  into v_prima_suscrita, _cod_cober_reas
			  from endedcob	a, prdcober b
		     where a.cod_cobertura = b.cod_cobertura
		       and a.no_poliza = v_nopoliza
			   and a.no_endoso = v_noendoso	
			   and a.no_unidad = _no_unidad
			 group by b.cod_cober_reas

    	   select vigencia_inic,
		          vigencia_final,
				  fecha_emision
			 into _vig_inic,
			      _vig_fin,
				  v_fecha_emision
			 from endedmae
			where no_poliza = v_nopoliza
			  and no_endoso = v_noendoso;

		   select serie, no_pagos, colectiva
		     into _serie, _no_pagos, _colectivo
			 from emipomae
			where no_poliza = v_nopoliza;

           if _colectivo = "1" then
			let _tipo_poliza = 'COLECTIVO';
		   else
			let _tipo_poliza = 'INDIVIDUAL';
		   end if

           select nombre
		     into _ramo
			 from prdramo
			where cod_ramo = v_cod_ramo;

            SELECT porc_comis_agt
              INTO v_porc_comis
              FROM endmoage
             WHERE no_poliza = v_nopoliza
  	           and no_endoso = v_noendoso
			   and cod_agente = v_cod_agente;

			 IF v_porc_comis IS NULL THEN
	            LET v_porc_comis = 0.00;
	         END IF

            LET v_comision     = v_prima_suscrita * v_porc_comis / 100;
           
	 	   select nombre
		     into _nombre_cober
			 from reacobre
			where cod_cober_reas = _cod_cober_reas;

           let _suma_rea = v_suma_asegurada;

			if v_cod_ramo = '002' then
				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = _cod_cober_reas;

				let _suma_rea = v_suma_asegurada * _porc_proporcion / 100;

			end if
           

		 {  SELECT porc_partic_agt
		     INTO _porc_partic_agt
		     FROM endmoage
		    WHERE no_poliza  = v_nopoliza
		      and no_endoso  = v_noendoso
			  and cod_agente = v_cod_agente;

		   LET _tot_prima_sus = 0; 
		   LET _tot_prima_sus = v_cedido * _porc_partic_agt / 100;	
		   LET _tot_prima_sus = v_cedido;	   }

         RETURN null, 			   --id
         		null,			   --empresa
                a_periodo1[1,4],   --ano
				a_periodo1[6,7],   --mes
				_serie,              --serie
				null,			   --area seguro
         		null,              --cod_producto
				v_cod_ramo,
				_ramo,
				_cod_cober_reas,   --ramorea
				_nombre_cober,
				null,              --cod_moneda
				null,              --por_tasa
				_tipo_poliza,      --tip_poliza
				v_nodocumento,     --id_poliza
				_no_unidad,
				null,              --id_recibo
				null,              --id_certificado
				_vig_inic,
				_vig_fin,
				v_fecha_emision,
				null,              --cod_situacion
				null,              --fecha_situacion
				_suma_rea, 
				null,              --mto_reserva
				v_prima_suscrita,
				v_comision,
				v_cod_contratante,
				v_cod_agente,
				null,              --fec_operacion
				null,              --fec_registro
				v_cod_usuario,
				_no_pagos    
                WITH RESUME;

        end foreach
		if v_cod_ramo = '002' then
		   drop table tmp_dist_rea;
		end if
   		end foreach

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;







												