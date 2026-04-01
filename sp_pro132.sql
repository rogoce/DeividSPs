-- Polizas Vigentes - Reserva Prima No Devengada.
-- 
-- Creado    : 07/11/2003 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_pro132;
CREATE procedure "informix".sp_pro132(
a_cia 			CHAR(3),
a_agencia 		CHAR(3),
a_codsucursal 	CHAR(255) DEFAULT "*",
a_codgrupo 		CHAR(255) DEFAULT "*",
a_codramo 		CHAR(255) DEFAULT "*",
a_periodo 		DATE,
a_cod_cliente 	CHAR(255) DEFAULT "*",
a_no_documento  CHAR(255) DEFAULT "*",
a_agente 		CHAR(255) DEFAULT "*"
)
RETURNING CHAR(50),
		  CHAR(5),
		  CHAR(50),
		  CHAR(50),
		  CHAR(03),
          CHAR(50),
          CHAR(45),
          CHAR(20),
          DATE,
          DATE,
          DECIMAL(16,2),
          DATE,
          CHAR(100),
          DECIMAL(16,2),
		  DECIMAL(5,2),
		  DECIMAL(16,2),
		  INTEGER,
		  INTEGER;

BEGIN
	define _cant,_cant2						integer;
    DEFINE v_nopoliza,v_contratante,v_codigo CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsucursal,v_saber  CHAR(3);
    DEFINE v_vigencia_inic,v_vigencia_final DATE;
    DEFINE v_prima_suscrita,_prima_sus,_upr    DECIMAL(16,2);
    DEFINE v_codagente,v_codgrupo           CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_desc_agente,v_descr_cia,v_desc_grupo,
           v_desc_ramo CHAR(50);
    DEFINE v_filtros                        CHAR(100);
    DEFINE _tipo                            CHAR(1);
	define _upr2							DECIMAL(16,2);
	define _upr2_x_comis					DECIMAL(16,2);
	define _porc_comis,_porc_comis_agt,_porc_partic_agt		DECIMAL(5,2);
	define _res								integer;

    LET v_prima_suscrita = 0;
    LET _prima_sus		 = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_descr_cia      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_filtros        = NULL;
    LET v_documento      = NULL;

    SET ISOLATION TO DIRTY READ;

    LET v_descr_cia = sp_sis01(a_cia);

   LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_codramo); --trae las polizas vigentes.

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
     -- Filtro de Grupo
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
       -- Filtro de Clientes
      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente "||TRIM(a_cod_cliente);
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
     -- Filtro de Corredores
      IF a_agente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "; --||TRIM(a_agente);
         LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = "";
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = " Ex";
         END IF
		 FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
	          INTO v_desc_agente,v_codigo
	          FROM agtagent,tmp_codigos
	         WHERE agtagent.cod_agente = codigo
	         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
		 END FOREACH

         DROP TABLE tmp_codigos;
      END IF

    FOREACH
       SELECT no_poliza,
       		  no_documento,
       		  cod_grupo,
       		  cod_ramo,
              cod_contratante,
              vigencia_inic,
              vigencia_final,
              prima_suscrita,
              cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codgrupo,
         	  v_codramo,
              v_contratante,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita,
              v_codagente
         FROM temp_perfil
        WHERE seleccionado = 1
        ORDER BY cod_ramo,vigencia_final,no_documento

       SELECT sum(prima_suscrita)
	     INTO _prima_sus
	     FROM endedmae
	    WHERE no_poliza = v_nopoliza;

		let _res  		  = 0;
		let _upr  		  = 0;
		let _upr2 		  = 0;
		let _cant 		  = v_vigencia_final - v_vigencia_inic;
		let _upr          = _prima_sus / (v_vigencia_final - v_vigencia_inic);
		let _res          = v_vigencia_final - a_periodo;
		let _cant2        = v_vigencia_final - a_periodo;
		let _upr2         = _upr * _res;
		let _upr2_x_comis = 0;
		let _porc_comis   = 0;

	   foreach
	    SELECT porc_comis_agt,
			   porc_partic_agt
		  INTO _porc_comis_agt,
			   _porc_partic_agt			   
		  FROM emipoagt
		 WHERE no_poliza = v_nopoliza

		let _upr2_x_comis = (_upr2_x_comis + _upr2 * _porc_comis_agt / 100) * (_porc_partic_agt / 100);
		let _porc_comis   = _porc_comis + _porc_comis_agt;
	   end foreach

       SELECT nombre
	     INTO v_desc_agente
	     FROM agtagent
	    WHERE cod_agente = v_codagente;

       SELECT nombre
         INTO v_desc_cliente
         FROM cliclien
        WHERE cod_cliente = v_contratante;

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_codramo;

       SELECT nombre
         INTO v_desc_grupo
         FROM cligrupo
        WHERE cod_grupo    = v_codgrupo
          AND cod_compania = a_cia;

       RETURN v_descr_cia,v_codgrupo,v_desc_grupo,v_desc_agente,v_codramo,
              v_desc_ramo,v_desc_cliente,v_documento,v_vigencia_inic,
              v_vigencia_final,v_prima_suscrita,a_periodo,
              v_filtros,_upr2,_porc_comis,_upr2_x_comis,_cant,_cant2
              WITH RESUME;

       LET v_prima_suscrita = 0;
    END FOREACH

  DROP TABLE temp_perfil;
END
END PROCEDURE;
