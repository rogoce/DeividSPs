-- Informe de Corredores por vendedor
-- 
-- Creado    : 03/05/2001 - Autor: Armando Moreno Montenegro
-- Modificado: 03/05/2001 - Autor: Armando Moreno Montenegro
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro61;
CREATE PROCEDURE sp_pro61(a_compania CHAR(3),a_sucursal CHAR(3),a_vendedor CHAR(255) DEFAULT "*") 
RETURNING CHAR(50), --corredor
		  CHAR(50), --alias corredor
		  CHAR(50), --vendedor
		  CHAR(50), --cia
		  CHAR(255), --v_filtros
		  VARCHAR(50),
		  CHAR(5),
		  char(3),
		  char(50),
		  date,
		  char(10),
		  char(10);

DEFINE v_nom_corredor    CHAR(50);
DEFINE v_descr_cia       CHAR(50);
DEFINE v_alias,_e_mail   CHAR(50);
DEFINE v_nom_vendedor    CHAR(50);
DEFINE v_cod_vendedor,_cod_cobrador,_tipo_corr    CHAR(3);
DEFINE v_filtros      	 CHAR(255);
DEFINE _tipo          	 CHAR(1);
define _agente_agrupado  char(5);
define v_nom_agrupado    varchar(50);
DEFINE v_cod_agente      CHAR(5);
define _fecha_cumple 	 date;
define _no_lic,_celular  char(10);

LET v_descr_cia = sp_sis01(a_compania);
let _agente_agrupado = "";

CREATE TEMP TABLE temp_det(
	nom_agt		    CHAR(50),
	alias           CHAR(50),
	cod_vendedor    CHAR(3),
	seleccionado   	SMALLINT  DEFAULT 1 NOT NULL,
	agente_agrupado char(5),
	n_agrupado      varchar(50),
	cod_agente      CHAR(5),
	tipo_corredor   CHAR(3)
	) WITH NO LOG;

FOREACH
 	SELECT x.nombre,
		   x.alias,
		   x.cod_vendedor,
		   x.agente_agrupado,
		   x.cod_agente,
		   x.cod_cobrador,
		   x.e_mail,
		   x.fecha_cumple,
		   x.no_licencia,
		   x.celular
	  INTO v_nom_corredor,
	   	   v_alias,
		   v_cod_vendedor,
		   _agente_agrupado,
		   v_cod_agente,
		   _cod_cobrador,
		   _e_mail,
		   _fecha_cumple,
		   _no_lic,
		   _celular
	  FROM agtagent x
	 WHERE x.cod_compania = a_compania

	SELECT nombre
	  INTO v_nom_agrupado
	  FROM agtagent
	 WHERE cod_agente = _agente_agrupado;
	 
	 if _cod_cobrador = '217' THEN
		let _tipo_corr = 'ANC';
	 ELSE
		let _tipo_corr = 'REM';
	 end if

		  INSERT INTO temp_det(
		  nom_agt,
		  alias,
		  cod_vendedor,
		  seleccionado,
		  agente_agrupado,
		  n_agrupado,
		  cod_agente,
		  tipo_corredor
		  )
		  VALUES(
		  v_nom_corredor,
		  v_alias,
		  v_cod_vendedor,
		  1,
		  _agente_agrupado,
		  v_nom_agrupado,
		  v_cod_agente,
		  _tipo_corr
		  );
END FOREACH

           -- Procesos v_filtros
      LET v_filtros ="";

      IF a_vendedor <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Vendedor: "||TRIM(a_vendedor);
         LET _tipo = sp_sis04(a_vendedor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Innluir los Registros

            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_det
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

FOREACH	WITH HOLD

	SELECT nom_agt,
		   alias,
		   cod_vendedor,
		   n_agrupado,
		   cod_agente,
		   tipo_corredor
	  INTO v_nom_corredor,
		   v_alias,
		   v_cod_vendedor,
		   v_nom_agrupado,
		   v_cod_agente,
		   _tipo_corr
	  FROM temp_det
	  WHERE seleccionado = 1

	SELECT nombre
	  INTO v_nom_vendedor
	  FROM agtvende
	 WHERE cod_vendedor = v_cod_vendedor;
	 
	SELECT e_mail,
		   fecha_cumple,
		   no_licencia,
		   celular
	  INTO _e_mail,
		   _fecha_cumple,
		   _no_lic,
		   _celular
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;
	 
	RETURN v_nom_corredor,	   
		   v_alias,      
		   v_nom_vendedor,  
		   v_descr_cia,
		   v_filtros,
		   v_nom_agrupado,
		   v_cod_agente,
		   _tipo_corr,
		   _e_mail,
		   _fecha_cumple,
		   _no_lic,
		   _celular
		   WITH RESUME;

END FOREACH;
DROP TABLE temp_det;
END PROCEDURE