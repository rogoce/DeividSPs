DROP procedure sp_pro991bk;
CREATE procedure "informix".sp_pro991bk(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING 
	CHAR(3),
	CHAR(50),
	CHAR(10),
	CHAR(20),                   
	CHAR(50),
	DEC(16,2), 
	CHAR(50),
	CHAR(255),
	DEC(16,2),
	CHAR(7),
	char(15),
	DEC(16,2),
	varchar(50);

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
	  define _peri                           char(7);
	  define _no_registro					 char(10);
	  define _sac_notrx                      integer;
	  define _res_comprobante				 char(15);
	  define _parti_reas					 dec(16,2);
	  define _cnt                            integer;
	  define n_contrato                      varchar(50);

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
	  LET v_cedido          = 0;
	  let _tot_prima_sus    = 0;
	  let _sac_notrx        = 0;
	  let n_contrato        = NULL;

      LET v_descr_cia = sp_sis01(a_compania);

      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
                    RETURNING v_filtros;


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
			  and cod_agente = v_cod_agente;

			let n_contrato   = "";

			foreach

	            SELECT distinct(t.nombre)
	              INTO n_contrato
				  FROM emifacon	e, endeduni r, reacomae t
				 WHERE e.no_poliza = r.no_poliza
				   AND e.no_endoso = r.no_endoso
				   AND e.no_unidad = r.no_unidad
				   AND e.cod_contrato = t.cod_contrato
				   AND t.tipo_contrato <> 1
				   AND e.no_poliza = v_nopoliza
				   AND e.no_endoso = v_noendoso
			       and e.prima <> 0
				exit foreach;
			end foreach

		   LET _tot_prima_sus = 0;
		   LET _tot_prima_sus = v_cedido * _porc_partic_agt / 100;

		   select periodo
		     into _peri
			 from endedmae
			where no_poliza = v_nopoliza
			  and no_endoso = v_noendoso;

		   let _no_registro = null;

		   foreach
		   		select no_registro
				  into _no_registro
				  from sac999:reacomp
				 where no_poliza = v_nopoliza
				   and no_endoso = v_noendoso

			  exit foreach;
		   end foreach

		   if _no_registro is not null then

		   		select count(*)
				  into _cnt
				  from sac999:reacompasie
				 where no_registro = _no_registro;

				if _cnt > 0 then

				   foreach
				   		select sac_notrx
						  into _sac_notrx
						  from sac999:reacompasie
						 where no_registro = _no_registro

					  exit foreach;
				   end foreach

				   if _sac_notrx is not null then
					  foreach

				   	   select res_comprobante
					     into _res_comprobante
					     from cglresumen
					    where res_notrx = _sac_notrx

					   exit foreach;
					  end foreach
				   end if
				else

				   let _res_comprobante = '';

				end if

		   end if
		   let _parti_reas = 0;

		   if  v_prima_suscrita <> 0 then
			   let _parti_reas = (_tot_prima_sus / v_prima_suscrita) * 100;
		   else
			   let _parti_reas = 0;
		   end if

         RETURN v_cod_ramo,
                v_desc_ramo,
                v_nofactura,
                v_nodocumento,
                v_desc_nombre,
                v_prima_suscrita,
                v_descr_cia,
                v_filtros,
                _tot_prima_sus,
				_peri,
				_res_comprobante,
				_parti_reas,
				n_contrato
                WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;







												