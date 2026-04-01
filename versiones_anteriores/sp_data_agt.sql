-- Informe de Corredores por vendedor
-- Creado    : 03/05/2001 - Autor: HG
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_data_agt;
CREATE PROCEDURE "informix".sp_data_agt(a_compania CHAR(3),a_sucursal CHAR(3),a_vendedor CHAR(255) DEFAULT "*") 
RETURNING CHAR(5) as CodZonaVentas,
CHAR(50) as ZonaVentas,
CHAR(5) as CodCorredor ,
CHAR(50) as NombreCorredor ,
CHAR(30) as NroLicencia ,
CHAR(30) as EstatusLicencia,
CHAR(10) as Sexo,
CHAR(10) as TipoPersona ,
DATE as FechaAniversario ,
CHAR(10) as TipoCorredor ,
Char(1) as Canal ;  	
  		  

DEFINE v_nom_corredor    CHAR(50);
DEFINE v_descr_cia       CHAR(50);
DEFINE v_alias           CHAR(50);
DEFINE v_nom_vendedor    CHAR(50);
DEFINE v_cod_vendedor    CHAR(3);
DEFINE v_filtros      	 CHAR(255);
DEFINE _tipo          	 CHAR(1);
define _agente_agrupado  char(5);
define v_nom_agrupado    varchar(50);
DEFINE v_cod_agente      CHAR(5);
DEFINE _tipo_agente      CHAR(10);
define _estatus_licencia char(30);
DEFINE _sexo             CHAR(10);  
DEFINE _fecha_cumple     DATE;  
DEFINE _tipo_persona     CHAR(10);
define _no_licencia      char(30);

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
	tipo_agente     CHAR(10),
	estatus_licencia  CHAR(30),
	sexo              CHAR(10),
	fecha_cumple      DATE,
	tipo_persona      CHAR(10),
	no_licencia       CHAR(30)
	) WITH NO LOG;

FOREACH
	SELECT x.nombre,
		   x.alias,
		   x.cod_vendedor,
		   x.agente_agrupado,
		   x.cod_agente,  
		   ( case  when x.tipo_agente = 'A' then "Agente" when x.tipo_agente = 'C' then "Oficina" else "Especial" end) tipo_agente,
		   ( case  when x.estatus_licencia = 'A' then "Activa" when x.estatus_licencia = 'P' then "Suspension Permanente"  when x.estatus_licencia = 'T' then "Suspension Temporal"   else "Susp. Superintendencia" end) estatus_licencia,
		   ( case  when x.sexo = 'M' then "Masculino" when x.sexo = 'F' then "Femenino"  else "Neutro" end) sexo,
		   x.fecha_cumple,		   	
		   ( case  when x.tipo_persona = 'N' then "Natural" when x.tipo_persona = 'G' then "Gubernamental"  else "Juridica" end) tipo_persona ,
		   x.no_licencia 
	  INTO v_nom_corredor,
	   	   v_alias,
		   v_cod_vendedor,
		   _agente_agrupado,
		   v_cod_agente,
		   _tipo_agente,
		   _estatus_licencia,
		   _sexo,
		   _fecha_cumple,
		   _tipo_persona,
		   _no_licencia 
	  FROM agtagent x
	 WHERE x.cod_compania = a_compania

	SELECT nombre
	  INTO v_nom_agrupado
	  FROM agtagent
	 WHERE cod_agente = _agente_agrupado;

		  INSERT INTO temp_det(
		  nom_agt,
		  alias,
		  cod_vendedor,
		  seleccionado,
		  agente_agrupado,
		  n_agrupado,
		  cod_agente,
		  tipo_agente,
		   estatus_licencia,
		   sexo,
		   fecha_cumple,
		   tipo_persona,
		   no_licencia 
		  )
		  VALUES(
		  v_nom_corredor,
		  v_alias,
		  v_cod_vendedor,
		  1,
		  _agente_agrupado,
		  v_nom_agrupado,
		  v_cod_agente,
		  _tipo_agente,
		   _estatus_licencia,
		   _sexo,
		   _fecha_cumple,
		   _tipo_persona,
		   _no_licencia 
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
		   tipo_agente,
		   estatus_licencia,
		   sexo,
		   fecha_cumple,
		   tipo_persona,
		   no_licencia 
	  INTO v_nom_corredor,
		   v_alias,
		   v_cod_vendedor,
		   v_nom_agrupado,
		   v_cod_agente,
		   _tipo_agente,
		   _estatus_licencia,
		   _sexo,
		   _fecha_cumple,
		   _tipo_persona,
		   _no_licencia 
	  FROM temp_det
	  WHERE seleccionado = 1

	SELECT nombre
	  INTO v_nom_vendedor
	  FROM agtvende
	 WHERE cod_vendedor = v_cod_vendedor;	

	RETURN 		   
		v_cod_vendedor,
		v_nom_vendedor,
		v_cod_agente,
		v_nom_corredor,
		_no_licencia,
		_estatus_licencia,
		_sexo,
		_tipo_persona,
		_fecha_cumple,
		_tipo_agente,
		''  WITH RESUME;		   

END FOREACH;
DROP TABLE temp_det;
END PROCEDURE