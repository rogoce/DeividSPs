DROP procedure sp_pro13a;
CREATE procedure "informix".sp_pro13a(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_contratante CHAR(255)) RETURNING CHAR(50);

--------------------------------------------
---    INFORME DE SELECCION POR CLIENTE  ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro13
--------------------------------------------

 BEGIN

    DEFINE v_cod_cliente     CHAR(10);
    DEFINE v_cod_sucursal    CHAR(03);
    DEFINE _tipo             CHAR(01);
    DEFINE v_filtros         CHAR(50);

    LET v_cod_cliente    = NULL;
    LET v_cod_sucursal   = NULL;

    CREATE TEMP TABLE tmp_cliente
                (cod_cliente      CHAR(10),
                 cod_sucursal     CHAR(03),
                 seleccionado     SMALLINT DEFAULT 1);

    IF a_contratante = "*" THEN
       FOREACH WITH HOLD
          SELECT cod_cliente,cod_sucursal
                 INTO v_cod_cliente,v_cod_sucursal
                 FROM cliclien
                WHERE cod_compania  = a_cia

          INSERT INTO tmp_cliente
                 VALUES(v_cod_cliente,
                        v_cod_sucursal,
                        1);
       END FOREACH
    END IF
    LET v_filtros = " ";
    IF a_contratante <> "*" THEN
       LET v_filtros = TRIM(v_filtros) ||"Contratante "||TRIM(a_contratante);
       LET _tipo = sp_sis04(a_contratante); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros
           FOREACH WITH HOLD
            SELECT cod_cliente
                   INTO v_cod_cliente
                   FROM cliclien
                  WHERE cod_compania  = a_cia
                    AND cod_cliente IN(SELECT codigo FROM tmp_codigos)

            INSERT INTO tmp_cliente
                   VALUES(v_cod_cliente,
                          v_cod_sucursal,
                          1);
           END FOREACH

         ELSE
           FOREACH WITH HOLD
            SELECT cod_cliente
                   INTO v_cod_cliente
                   FROM cliclien
                  WHERE cod_compania  = a_cia
                    AND cod_cliente NOT IN(SELECT codigo FROM tmp_codigos)

            INSERT INTO tmp_cliente
                   VALUES(v_cod_cliente);
           END FOREACH
         END IF
    DROP TABLE tmp_codigos;
    END IF
    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cliente
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cliente
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF
    RETURN v_filtros;
   END
END PROCEDURE;
