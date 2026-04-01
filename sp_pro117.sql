--DROP procedure sp_pro117;
CREATE procedure "informix".sp_pro117(a_compania CHAR(03),a_agencia CHAR(03),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*")

     RETURNING CHAR(3),
               CHAR(50),
			   CHAR(20),
			   CHAR(100),
               DECIMAL(16,2),
               DECIMAL(16,2),
			   DATE,
			   DATE,
               CHAR(50),
               CHAR(255);

--------------------------------------------
---  TOTALES DE COASEGURO ASUMIDO POR RAMO -
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro45
--------------------------------------------
BEGIN

  DEFINE s_nopoliza                       CHAR(10);
  DEFINE v_nodocumento					  CHAR(20);
  DEFINE v_cod_contratante				  CHAR(10);
  DEFINE s_cia,s_codsucursal,s_codramo    CHAR(03);
  DEFINE v_descramo                       CHAR(50);
  DEFINE v_prima_suscrita, v_suma_asegurada DECIMAL(16,2);
  DEFINE v_coaseguro_asum                 DECIMAL(16,2);
  DEFINE v_porc_comi                      DECIMAL(5,2);
  DEFINE v_comision                       DECIMAL(9,2);
  DEFINE v_filtros                        CHAR(255);
  DEFINE _tipo                            CHAR(01);
  DEFINE v_descr_cia                      CHAR(50);
  DEFINE s_tipopro                        CHAR(03);
  DEFINE _estatus, _encontrado            SMALLINT;
  DEFINE _cod_coasegur                    CHAR(3);
  DEFINE v_vigencia_inic, v_vigencia_final DATE;
  DEFINE v_desc_nombre                   CHAR(100);

  	
  SET ISOLATION TO DIRTY READ;

  {CREATE TEMP TABLE temp_coaseguro
           (no_documento     CHAR(20),
		    no_poliza        CHAR(10),
			cod_contratante  CHAR(10),
            coaseguro_asum   DEC(16,2),
			suma_asegurada   DEC(16,2),
            seleccionado     SMALLINT DEFAULT 1
            ) WITH NO LOG;			 }

  --CREATE INDEX id1_temp_coaseguro ON temp_coaseguro(cod_sucursal);
  --CREATE INDEX id2_temp_coaseguro ON temp_coaseguro(cod_ramo);

  LET s_tipopro        = NULL;
  LET v_descramo       = NULL;
  LET v_prima_suscrita = 0;
  LET v_porc_comi      = 0;

  LET v_descr_cia = sp_sis01(a_compania);

  SELECT emitipro.cod_tipoprod
    INTO s_tipopro
    FROM emitipro
   WHERE emitipro.tipo_produccion = 3;

 -- CALL sp_pro116a(a_compania,a_agencia,a_fecha,"*","002")
 --      RETURNING v_filtros;
  let v_filtros = "";
  FOREACH 
   SELECT no_poliza,
          prima_suscrita,
		  suma_asegurada,
		  no_documento,
		  cod_contratante
     INTO s_nopoliza,
          v_prima_suscrita,
		  v_suma_asegurada,
		  v_nodocumento,
		  v_cod_contratante
     FROM emipomae
    WHERE cod_tipoprod = '002'

	LET _cod_coasegur = NULL;
	LET _encontrado = 0;

    FOREACH
     SELECT cod_coasegur
       INTO _cod_coasegur
       FROM emicoami
      WHERE no_poliza = s_nopoliza
--	    AND cod_coasegur = '017'

     IF _cod_coasegur = '017' THEN
	    LET _encontrado = 1;
	    EXIT FOREACH;
     END IF
   END FOREACH

   IF _encontrado = 0 THEN
      CONTINUE FOREACH;
   END IF

{   INSERT INTO temp_coaseguro
        VALUES(v_nodocumento,
               s_nopoliza,
			   v_cod_contratante,
               v_prima_suscrita,
               v_suma_asegurada,
               1);

  END FOREACH
       -- Procesos v_filtros
  LET v_filtros ="";
 { IF a_codsucursal <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
     LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

     IF _tipo <> "E" THEN -- Incluir los Registros

        UPDATE temp_coaseguro
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_coaseguro
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
     END IF
     DROP TABLE tmp_codigos;
  END IF}
  {FOREACH
     SELECT no_documento,   
     		no_poliza,      
     		cod_contratante,
     		coaseguro_asum, 
            suma_asegurada 
       INTO v_nodocumento,
			s_nopoliza,
			v_cod_contratante,
			v_prima_suscrita,
			v_suma_asegurada
       FROM temp_coaseguro 
      WHERE seleccionado = 1 }

        SELECT nombre
          INTO v_desc_nombre
          FROM cliclien
         WHERE cod_cliente = v_cod_contratante;

		SELECT vigencia_inic,
			   vigencia_final,
			   cod_ramo
		  INTO v_vigencia_inic, 
			   v_vigencia_final,
			   s_codramo
		  FROM emipomae
		 WHERE no_poliza = s_nopoliza;

        SELECT nombre
		  INTO v_descramo
		  FROM prdramo
		 WHERE cod_ramo = s_codramo;

     RETURN s_codramo,
            v_descramo,
			v_nodocumento,
			v_desc_nombre,
            v_prima_suscrita,
            v_suma_asegurada,
			v_vigencia_inic, 
 			v_vigencia_final,
            v_descr_cia,
            v_filtros  
            WITH RESUME;

  END FOREACH

--DROP TABLE temp_coaseguro;
--DROP TABLE temp_perfil;

END

END PROCEDURE;
