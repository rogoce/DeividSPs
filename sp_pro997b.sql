--  Polizas Vigentes por Subramo
--  Creado        : 13/05/2010    - Autor: Armando Moreno M.
--  Modificado    : 31/10/2017    - Autor: Henry Giron
--  SIS v.2.0 - DEIVID, S.A.     

DROP procedure sp_pro997b;
CREATE PROCEDURE sp_pro997b(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_corredor char(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",a_periodo1 DATE, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*", a_estado smallint DEFAULT 0) 
RETURNING CHAR(3),
 		  CHAR(50),
 		  CHAR(20),
          DATE,
          INTEGER,
          INTEGER,
          VARCHAR(100),
          DATE,
          SMALLINT,
          CHAR(7),
		  CHAR(50),
		  CHAR(255);
 BEGIN

DEFINE v_nopoliza,v_contratante,_cod_asegurado,_no_poliza2   CHAR(10);
DEFINE v_documento                      CHAR(20);
DEFINE v_codramo,v_codsubramo           CHAR(3);
DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy DATE;
DEFINE v_prima_suscrita                 DECIMAL(16,2);
DEFINE v_codagente, _no_endoso          CHAR(5);
DEFINE v_desc_cliente                   CHAR(45);
DEFINE v_filtros                        CHAR(255);
DEFINE _tipo                            CHAR(01);
DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);
DEFINE _dependientes,_edad INTEGER;
DEFINE _cant_ase integer;
DEFINE v_desc_contratante               VARCHAR(100);
DEFINE _edadcal,_est_pol                SMALLINT;
DEFINE _edadcal_tot                     INTEGER;
define _estatus_char					char(7);
define _estatus_poliza                  smallint;	

LET _fecha_hoy = TODAY;
LET v_prima_suscrita = 0;
LET _dependientes    = 0;
LET _edad		     = 0;
LET v_desc_cliente   = NULL;
LET v_desc_agente    = NULL;
LET v_desc_subr      = NULL;
LET v_descr_cia      = NULL;
LET v_filtros        = NULL;

LET v_descr_cia = sp_sis01(a_cia);
CALL sp_pro03(a_cia,a_agencia,a_periodo1,a_codramo) RETURNING v_filtros;
CALL sp_pro03h(a_cia,a_agencia,a_periodo1,a_codramo) RETURNING v_filtros;
	
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
-- Filtro de Subramo
  IF a_subramo <> "*" THEN
	 LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
	 LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

	 IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
	 ELSE
		UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
	 END IF
	 DROP TABLE tmp_codigos;
  END IF
  IF a_corredor <> "*" THEN
	 LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_corredor);
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
	 LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_cod_cliente);
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

--Filtro de poliza
IF a_no_documento <> "*" and a_no_documento <> "" THEN
	 LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

		UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND no_documento <> a_no_documento;
  END IF


SET ISOLATION TO DIRTY READ;

{
-- Filtro de Subramo
  IF a_subramo <> "*" THEN
	 LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
	 LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

	 IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
	 ELSE
		UPDATE temp_perfil
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
	 END IF
	 DROP TABLE tmp_codigos;
  END IF
}
  
if a_estado = 1 then
	let v_filtros = TRIM(v_filtros) ||" ESTATUS: VIGENTES; ";
elif a_estado = 3 then
	let v_filtros = TRIM(v_filtros) ||"  ESTATUS: VENCIDA; ";
else
	let v_filtros = TRIM(v_filtros) ||"  ESTATUS: VIGENTE o VENCIDA; ";
end if

FOREACH
    SELECT distinct y.no_poliza,
		  y.no_documento,
		  y.cod_ramo,
		  y.cod_subramo,
		  y.cod_contratante,
		  y.fecha_suscripcion,
		  y.vigencia_inic,
		  y.vigencia_final,
		  y.prima_suscrita	 --,y.cod_agente
	  INTO v_nopoliza,
		  v_documento,
		  v_codramo,
		  v_codsubramo,
		  v_contratante,
		  v_fecha_suscripc,
		  v_vigencia_inic,
		  v_vigencia_final,
		  v_prima_suscrita    --,v_codagente
	  FROM temp_perfil y
	 WHERE seleccionado = 1
	   
    SELECT nombre
	  INTO v_desc_subr
	  FROM prdsubra
	 WHERE cod_ramo    = v_codramo
	   AND cod_subramo = v_codsubramo;

    let _cant_ase = 1;

    SELECT count(*)
	  INTO _cant_ase
	  FROM emipouni
	 WHERE no_poliza     = v_nopoliza
	   AND vigencia_inic <= a_periodo1
	   AND activo        = 1;
	  
	if _cant_ase is null then
		let _cant_ase = 0;
	end if

    if _cant_ase = 0 then
		let _cant_ase = 1;
    end if

    SELECT COUNT(*)
	  INTO _dependientes
	  FROM emidepen
	 WHERE no_poliza      = v_nopoliza
	   AND activo         = 1
	   AND fecha_efectiva <= a_periodo1;

    SELECT nombre
	  INTO v_desc_contratante
	  FROM cliclien
	 WHERE cod_cliente = v_contratante;
	
    SELECT nombre
	  INTO v_desc_ramo
	  FROM prdramo
	 WHERE prdramo.cod_ramo = v_codramo;			

    IF _dependientes IS NULL THEN
		LET _dependientes = 0;
    END IF

    let _edadcal_tot = 0;

	FOREACH
		SELECT cod_asegurado
		  INTO _cod_asegurado
		  FROM emipouni
		 WHERE no_poliza     = v_nopoliza
		   AND vigencia_inic <= a_periodo1
		   AND activo        = 1

		SELECT fecha_aniversario
		  INTO _fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		let _edadcal = sp_sis78(_fecha_aniversario);
		let _edadcal_tot  = _edadcal_tot + _edadcal;

	END FOREACH

    select estatus_poliza
      into _estatus_poliza 
	  from emipomae 
	 where no_poliza = v_nopoliza;

    let _estatus_char = null;

    if _estatus_poliza = 1 then
		let _estatus_char = 'VIGENTE';
    elif _estatus_poliza = 3 then
		let _estatus_char = 'VENCIDA';
    end if 	   
    if a_estado <> 0 then
		if a_estado <> _estatus_poliza then 
			continue foreach;
		end if			
    end if
  
    if _edadcal_tot is null then
		let _edadcal_tot = 0;
    end if
	
    let _no_poliza2 = sp_sis21(v_documento);

	select estatus_poliza
	  into _est_pol
	  from emipomae
	 where no_poliza = _no_poliza2;

	if _est_pol = 2 then
		continue foreach;
	end if

	RETURN v_codsubramo,v_desc_subr,v_documento,a_periodo1,_cant_ase,_dependientes,v_desc_contratante,v_vigencia_inic,_edadcal_tot/_cant_ase,_estatus_char,v_desc_ramo,v_filtros WITH RESUME;

END FOREACH
DROP TABLE temp_perfil;
END
END PROCEDURE;
