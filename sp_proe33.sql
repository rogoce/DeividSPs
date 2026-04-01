--  POLIZAS EN COASEGURO MINORITARIO
--  Armando Moreno M.

-- Modificado por: Marquelda Valdelamar 28/08/2001 para incluir filtro de cliente
--                                     06/09/2001 para filtro de poliza

DROP procedure sp_proe33;
CREATE procedure "informix".sp_proe33(a_compania CHAR(03),a_agencia  CHAR(03),a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codcoasegur CHAR(255) DEFAULT "*",a_cod_cliente CHAR(255) DEFAULT "*",a_no_documento CHAR(255) DEFAULT "*")
         RETURNING CHAR(20),CHAR(30),DATE,DATE,SMALLINT,CHAR(10),CHAR(7),DEC(16,2),DEC(16,2),DATE,CHAR(40),CHAR(100);

   BEGIN
	  DEFINE _mes_char         CHAR(2);
	  DEFINE _ano_char		 CHAR(4);
      DEFINE _no_poliza,_nofactura,_cod_cliente		   CHAR(10);
      DEFINE v_nodocumento                   		   CHAR(20);
      DEFINE v_cod_tipoprod,v_cod_coasegur 			   CHAR(3);
      DEFINE v_saldo,_ult_pago				 		   DECIMAL(16,2);
      DEFINE v_comision                      		   DECIMAL(9,2);
      DEFINE _no_pol_coaseg                  		   CHAR(30);
      DEFINE v_filtros                       		   CHAR(255);
      DEFINE _tipo                           		   CHAR(1);
      DEFINE v_desc_coaseg                   		   CHAR(40);
      DEFINE mes1,mes2,ano1,ano2,v_estatus             SMALLINT;
	  DEFINE v_no_cambio 							   CHAR(3);
      DEFINE _vig_ini,_vig_fin,_fecha_ult_pago,_fecha         DATE;
	  DEFINE _periodo_fac,_periodo			 		   CHAR(7);
	  DEFINE v_asegurado	  CHAR(100);								
	  DEFINE v_por_vencer     DEC(16,2);	 
	  DEFINE v_exigible		  DEC(16,2);
	  DEFINE v_corriente	  DEC(16,2);
	  DEFINE v_monto_30		  DEC(16,2);
	  DEFINE v_monto_60		  DEC(16,2);
	  DEFINE v_monto_90		  DEC(16,2);


       CREATE TEMP TABLE temp_coaseguro
               (ult_factura        CHAR(10),
				periodo			   CHAR(7),	
                no_documento       CHAR(20),
                no_documento_c     CHAR(30),
                estatus			   SMALLINT,
				vig_ini			   DATE,
				vig_fin			   DATE,
                cod_coasegur       CHAR(3),
                saldo              DEC(16,2),
                ult_pago           DEC(16,2),
				fecha_ult_pago     DATE,
				cod_cliente		   CHAR(10),
                seleccionado       SMALLINT DEFAULT 1);

      CREATE INDEX id1_temp_coaseguro ON temp_coaseguro(cod_coasegur);

      LET v_saldo     = 0;
      LET _ult_pago   = 0;

      SET ISOLATION TO DIRTY READ;

       SELECT cod_tipoprod
         INTO v_cod_tipoprod
         FROM emitipro
        WHERE tipo_produccion = 3; --COASEG MINORITARIO

--SET DEBUG FILE TO "sp_pro41.trc";
--trace on;

IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;

FOREACH WITH HOLD

		 SELECT no_documento
		   INTO v_nodocumento
		   FROM emipomae
		  WHERE actualizado = 1
            AND cod_tipoprod = v_cod_tipoprod
		  GROUP BY no_documento

	   FOREACH
		 SELECT y.estatus_poliza,
				y.no_poliza_coaseg,
				y.vigencia_inic,
				y.vigencia_final,
				y.no_poliza,
				y.fecha_ult_pago,
				y.cod_contratante
           INTO v_estatus,
				_no_pol_coaseg,
				_vig_ini,
				_vig_fin,
				_no_poliza,
				_fecha_ult_pago,
				_cod_cliente
           FROM emipomae y
          WHERE y.no_documento = v_nodocumento
            AND y.actualizado  = 1
     	  ORDER BY y.vigencia_final DESC
			EXIT FOREACH;
	   END FOREACH

		CALL sp_cob33(
		a_compania,
		a_agencia,
		v_nodocumento,
		_periodo,
		today
		) RETURNING v_por_vencer,
				    v_exigible,  
				    v_corriente, 
				    v_monto_30,  
				    v_monto_60,  
				    v_monto_90,
				    v_saldo
				    ;
		   FOREACH
			 SELECT a.no_factura,
					a.periodo
	           INTO _nofactura,
					_periodo_fac
	           FROM endedmae a
	          WHERE a.actualizado = 1
	            AND a.no_poliza   = _no_poliza
				ORDER BY periodo desc
			EXIT FOREACH;
		   END FOREACH

         FOREACH
            SELECT cod_coasegur
              INTO v_cod_coasegur
              FROM emicoami
             WHERE no_poliza = _no_poliza
			EXIT FOREACH;
		 END FOREACH

		FOREACH
		 SELECT monto,
				fecha
		   INTO _ult_pago,
				_fecha
		   FROM cobredet
		  WHERE no_poliza   = _no_poliza		-- Recibos de la Poliza
		    AND actualizado  = 1			    -- Recibo este actualizado
		    AND tipo_mov     IN ('P')		-- Pago de Prima(P)
		  ORDER BY fecha desc
		  exit foreach; 
		END FOREACH

           INSERT INTO temp_coaseguro
                  VALUES(_nofactura,
                         _periodo_fac,
                         v_nodocumento,
						 _no_pol_coaseg,
                         v_estatus,
                         _vig_ini,
                         _vig_fin,
                         v_cod_coasegur,
						 v_saldo,
						 _ult_pago,
						 _fecha_ult_pago,
						 _cod_cliente,
                         1);
END FOREACH

      IF a_codcoasegur <> "*" THEN
         LET v_filtros =
             TRIM(v_filtros) ||"Coaseguradora "||TRIM(a_codcoasegur);
         LET _tipo = sp_sis04(a_codcoasegur); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_coaseguro
                  SET seleccionado = 0
                WHERE seleccionado = 1
                  AND cod_coasegur NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_coasegur IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_coaseguro
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

      FOREACH
         SELECT ult_factura,
				periodo,
         		no_documento,
         		no_documento_c,
				estatus,
				vig_ini,
				vig_fin,
				cod_coasegur,
				saldo,
				ult_pago,
				fecha_ult_pago,
				cod_cliente
           INTO _nofactura,
           		_periodo_fac,
           		v_nodocumento,
           		_no_pol_coaseg,
                v_estatus,
                _vig_ini,
                _vig_fin,
   				v_cod_coasegur,
				v_saldo,
				_ult_pago,
				_fecha_ult_pago,
				_cod_cliente
           FROM temp_coaseguro
          WHERE seleccionado = 1
          ORDER BY no_documento

         SELECT nombre
           INTO v_desc_coaseg
           FROM emicoase
          WHERE cod_coasegur = v_cod_coasegur;

		--Lectura de Asegurado
		SELECT nombre
		  INTO v_asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

         RETURN v_nodocumento,
         		_no_pol_coaseg,
                _vig_ini,
                _vig_fin,
				v_estatus,
				_nofactura,
				_periodo_fac,
				v_saldo,
				_ult_pago,
                _fecha_ult_pago,
                v_desc_coaseg,
                v_asegurado WITH RESUME;

      END FOREACH;
   DROP TABLE temp_coaseguro;
   END
END PROCEDURE;