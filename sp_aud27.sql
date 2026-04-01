--execute procedure sp_aud27('001','001','2011-01','2011-01','*','*','*','*','*','*','1','*','*')


--Polizas cedidas

DROP procedure sp_aud27;
CREATE procedure "informix".sp_aud27(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*", a_tipopol CHAR(1), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING 
	CHAR(20),
	date,
	date,
	CHAR(50),
	DEC(16,2),
	DEC(16,2),
	char(50);

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
--                x.suma_asegurada,
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
--                v_suma_asegurada,
                v_prima_suscrita,
                v_comision,
				v_cod_agente,
				v_nopoliza,
				v_noendoso
           FROM temp_det x
          WHERE x.seleccionado = 1
          ORDER BY x.cod_ramo,x.no_factura

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

		 let v_suma_asegurada = 0;

		 foreach

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

		   let _no_poliza = sp_sis21(v_nodocumento);

    	   select vigencia_inic,
		          vigencia_final
			 into _vig_inic,
			      _vig_fin
			 from emipomae
			where no_poliza = _no_poliza;

		   select nombre
		     into _nombre_cober
			 from reacobre
			where cod_cober_reas = _cod_cober_reas;

		 {  SELECT porc_partic_agt
		     INTO _porc_partic_agt
		     FROM endmoage
		    WHERE no_poliza  = v_nopoliza
		      and no_endoso  = v_noendoso
			  and cod_agente = v_cod_agente;

		   LET _tot_prima_sus = 0; 
		   LET _tot_prima_sus = v_cedido * _porc_partic_agt / 100;	}
		   LET _tot_prima_sus = v_cedido;

         RETURN v_nodocumento,
		        _vig_inic,
				_vig_fin,
                v_desc_nombre,
				v_suma_asegurada,
                _tot_prima_sus,
				_nombre_cober
                WITH RESUME;

		end foreach

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;







												