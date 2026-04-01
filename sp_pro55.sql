--  POLIZAS POR CORREDOR POR PERIODO CONTABLE
--
-- Creado:     01/2001   - Autor: Armando Moreno M.  
-- Modificado: 07/09/2001- Autor: Marquelda Valdelamar (inclusion de filtro de poliza y cliente)
--------------------------------------------

DROP procedure sp_pro55;

CREATE PROCEDURE "informix".sp_pro55(a_cia CHAR(3), a_agencia CHAR(3), a_codsucursal CHAR(255) DEFAULT "*", a_corredor char(255) DEFAULT "*", a_periodo1 CHAR(7), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
	   RETURNING CHAR(50),      --nom cia
				 CHAR(50),      --nom corredor
                 CHAR(50),      --nom cliente
                 CHAR(20),      --no_documento
                 DATE,	  	    --vig ini
                 DATE,	  	    --vig fin
                 DECIMAL(16,2), --prima fact.
                 CHAR(10),      --no_factura
                 CHAR(255);	    --v_filtros

 BEGIN
    DEFINE v_no_poliza,v_contratante          CHAR(10);
    DEFINE v_no_documento                     CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   DATE;
    DEFINE v_prima_bruta,v_prima_facturada DECIMAL(16,2);
    DEFINE v_codagente                        CHAR(5);
    DEFINE v_cod_sucursal                     CHAR(3);
    DEFINE v_no_factura                       CHAR(10);
    DEFINE v_desc_cliente                     CHAR(50);
    DEFINE v_filtros                          CHAR(255);
    DEFINE _tipo                              CHAR(01);
    DEFINE v_desc_agente,v_descr_cia          CHAR(50);
	DEFINE _fecha1,_fecha2  		 		  DATE;
	DEFINE _mes1,_ano1,_mes2,_ano2			  SMALLINT;

    LET v_prima_bruta = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

	-- Descomponer los periodos en fechas
	LET _ano1 = a_periodo1[1,4];
	LET _mes1 = a_periodo1[6,7];
	LET _fecha1 = MDY(_mes1,1,_ano1);
	LET _ano2 = a_periodo1[1,4];
	LET _mes2 = a_periodo1[6,7];

	IF _mes1 = 12 THEN
	   LET _mes1 = 1;
	   LET _ano2 = _ano2 + 1;
	ELSE
	   LET _mes2 = _mes2 + 1;
	END IF
	LET _fecha2 = MDY(_mes2,1,_ano2);
	LET _fecha2 = _fecha2 - 1;

    LET v_descr_cia = sp_sis01(a_cia);
		   CREATE TEMP TABLE temp_perfil
             (no_poliza       CHAR(10),
              no_documento    CHAR(20),
              no_factura      CHAR(10),
              cod_sucursal    CHAR(3),
              cod_contratante CHAR(10),
              cod_agente      CHAR(5),
              prima_facturada DEC(16,2),
              vigencia_inic   DATE,
              vigencia_final  DATE,
              seleccionado    SMALLINT DEFAULT 1)
              WITH NO LOG;

         --PRIMARY KEY(no_poliza))
       CREATE INDEX i_perfil1 ON temp_perfil(no_poliza);
       CREATE INDEX i_perfil5 ON temp_perfil(cod_sucursal);
	   FOREACH WITH HOLD
          SELECT  d.no_poliza,d.no_documento,d.no_factura,d.cod_sucursal,
                  d.vigencia_inic,d.vigencia_final,d.prima_bruta
             INTO v_no_poliza,v_no_documento,v_no_factura,v_cod_sucursal,
                  v_vigencia_inic,v_vigencia_final,v_prima_bruta
             FROM endedmae d
            WHERE d.cod_compania = a_cia
              AND d.actualizado = 1
              AND d.periodo = a_periodo1
			  OR  (d.vigencia_inic >= _fecha1 and d.vigencia_inic <= _fecha2)
			-- son las facturas de ese periodo y dentro de la vigencia que corresponde
			-- al mismo periodo.

		  SELECT cod_contratante
           	INTO v_contratante
           	FROM emipomae
           WHERE no_poliza = v_no_poliza;

          FOREACH
            SELECT cod_agente
               INTO v_codagente
               FROM emipoagt
               WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
          END FOREACH

          INSERT INTO temp_perfil
            VALUES(v_no_poliza,
                   v_no_documento,
                   v_no_factura,
				   v_cod_sucursal,
                   v_contratante,
                   v_codagente,
                   v_prima_bruta,
                   v_vigencia_inic,
                   v_vigencia_final,
                   1);
       END FOREACH
    -- Filtro de Sucursal
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
    -- Filtro de Corredor
	  LET v_filtros = "";
      IF a_corredor <> "*" THEN
		 LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_corredor);
         LET _tipo = sp_sis04(a_corredor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF


     IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--

    SET ISOLATION TO DIRTY READ;
    FOREACH
       SELECT y.no_poliza,y.no_documento,y.no_factura,
              y.cod_contratante,y.vigencia_inic,y.vigencia_final,y.prima_facturada,y.cod_agente
              INTO v_no_poliza,v_no_documento,v_no_factura,
                   v_contratante,v_vigencia_inic,v_vigencia_final,v_prima_facturada,v_codagente
              FROM temp_perfil y
             WHERE seleccionado = 1
           
       SELECT a.nombre
              INTO v_desc_agente
              FROM agtagent a
             WHERE a.cod_agente = v_codagente;

       SELECT b.nombre
              INTO v_desc_cliente
              FROM cliclien b
             WHERE b.cod_cliente = v_contratante;

         RETURN v_descr_cia,v_desc_agente,
                v_desc_cliente,v_no_documento,
                v_vigencia_inic,v_vigencia_final,
                v_prima_facturada,v_no_factura,v_filtros
                 WITH RESUME;

    	LET v_prima_bruta = 0;
      END FOREACH
    DROP TABLE temp_perfil;
   END
END PROCEDURE;