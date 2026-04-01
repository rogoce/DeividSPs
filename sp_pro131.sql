--  DETALLE DE PRODUCCION especial transporte
-- Creado:     Octubre 2003 - Autor:  Lic. Armando Moreno M.


DROP procedure sp_pro131;

CREATE procedure "informix".sp_pro131(
a_compania 		CHAR(03),
a_agencia 		CHAR(03),
a_periodo1 		CHAR(07),
a_periodo2 		CHAR(07),
a_codsucursal 	CHAR(255) DEFAULT "*",
a_codgrupo 		CHAR(255) DEFAULT "*",
a_codagente 	CHAR(255) DEFAULT "*",
a_codusuario 	CHAR(255) DEFAULT "*",
a_codramo 		CHAR(255) DEFAULT "009;",
a_reaseguro 	CHAR(255) DEFAULT "*",
a_tipopol 		CHAR(1),
a_cod_cliente 	CHAR(255) DEFAULT "*",
a_no_documento 	CHAR(255) DEFAULT "*")

RETURNING CHAR(5),
		  CHAR(50),
		  CHAR(10),
		  CHAR(20),
          CHAR(50),
          DEC(16,2),
          DEC(16,2),
          CHAR(50),
          CHAR(255),
          SMALLINT,
          SMALLINT,
          CHAR(6),
          char(3),
          char(3),
          char(50),
          char(50),
          char(50);

BEGIN

      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE s_cia,v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_agente,v_cod_grupo        CHAR(5);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_porc_comis                    DEC(5,2);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_grupo                    CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE s_tipopro                       CHAR(03);
      DEFINE _grupo		                     CHAR(6);
      DEFINE _estado,_declarativa            SMALLINT;
	  DEFINE v_cod_subramo 					 CHAR(3);
	  DEFINE v_nombre_subramo 				 CHAR(50);
	  DEFINE v_nombre_tipopro 				 CHAR(50);
	  DEFINE _nombre_tipocan				 char(50);
	  DEFINE _cod_tipocan					 char(3);

      LET s_tipopro         = NULL;
      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
--	  let _estado           = 0;
	  let _declarativa      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_agente      = NULL;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);

      CALL sp_pro131a(a_compania,
      				a_agencia,
      				a_periodo1,
                    a_periodo2,
                    a_codsucursal,
                    a_codgrupo,
                    a_codagente,
                    a_codusuario,
                    a_codramo,
                    a_reaseguro,
                    a_tipopol)
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

	  SET ISOLATION TO DIRTY READ;

      FOREACH WITH HOLD
         SELECT cod_grupo,
         		no_factura,
         		no_documento,
         		cod_contratante,
                suma_asegurada,
                prima,
				estado,
				declarativa,
				cod_tipoprod,
				cod_subramo,
				cod_tipocan
           INTO v_cod_grupo,
           		v_nofactura,
           		v_nodocumento,
           		v_cod_contratante,
|								                v_suma_asegurada,
                v_prima_suscrita,
				_estado,
				_declarativa,
				v_cod_tipoprod,
				v_cod_subramo,
				_cod_tipocan
           FROM temp_det
          WHERE seleccionado = 1
       ORDER BY estado

		select nombre
		  into _nombre_tipocan
		  from endtican
		 where cod_tipocan = _cod_tipocan;

		if _nombre_tipocan is null then
			let _nombre_tipocan = "";
		end if

         SELECT nombre
           INTO v_nombre_tipopro
           FROM emitipro
          WHERE cod_tipoprod = v_cod_tipoprod;

         SELECT nombre
           INTO v_nombre_subramo
           FROM prdsubra
          WHERE cod_ramo    = "009"
            and cod_subramo = v_cod_subramo;

         SELECT nombre
           INTO v_desc_grupo
           FROM cligrupo
          WHERE cod_grupo = v_cod_grupo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

		 if _estado = 1 then
			let _grupo = "ESTADO";
		 else
			let _grupo = "OTROS";
		 end if

         RETURN v_cod_grupo,
         		v_desc_grupo,
         		v_nofactura,
         		v_nodocumento,
                v_desc_nombre,
                v_suma_asegurada,
                v_prima_suscrita,
                v_descr_cia,
                v_filtros,
                _estado,
                _declarativa,
                _grupo,
				v_cod_subramo,
				v_cod_tipoprod,
				v_nombre_subramo,
				v_nombre_tipopro,
				_nombre_tipocan
                WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;

   END

END PROCEDURE;
