-- Reportes de Reaseguro Suma Cedida
-- Creado: 11/12/2023 - Autor: Henry Girón
drop procedure sp_proe93b;
create procedure "informix".sp_proe93b(a_compania CHAR(03), a_fecha DATE,a_cod_manzana char(255) DEFAULT '*', a_poliza char(20) DEFAULT '*', a_estatus_poliza smallint,a_agente char(255) DEFAULT '*',a_grupo char(255) DEFAULT '*',a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_ramo char(255) DEFAULT '*',a_subramo char(255) DEFAULT '*', a_acreedor CHAR(255) DEFAULT "*")
returning 	CHAR(20),	-- POLIZA
			CHAR(5),	    -- UNIDAD
			DEC(16,2),	-- SUMA_ASEGURADA
			CHAR(50),	-- ESTATUS
			DATE,	    -- v_inic
			DATE,	    -- v_fin
			CHAR(10),	-- ASEGURADO
			CHAR(50),	-- NOMBRE_ASEGURADO
			CHAR(50),	-- cedula
			CHAR(3),	    -- RAMO
			CHAR(50),	-- NOMBRE RAMO
			CHAR(3),	-- SUBRAMO
			CHAR(50),	-- NOMBRE SUBRAMO
			CHAR(5),	    -- GRUPO
			CHAR(50),	-- NOMBRE_GRUPO
			CHAR(5),	    -- CORREDOR
			CHAR(50),	-- NOMBRE_CORREDOR
			CHAR(5),	-- cod_acreedor
			CHAR(50),	-- name_acreedor
			DEC(16,2),	-- limite_acre
			CHAR(3), 	-- COMPANIA
			CHAR(50),	-- NOMBRE CIA
			CHAR(255);	-- FILTROS
	   


define _no_poliza		  char(10);
define _contratante	      char(10);
define _no_unidad		  char(5);
define _fecha       	  date;
define v_asegurado		  char(100);
define _no_documento      char(20);
define v_filtros          char(255);
define _cod_manzana		  char(15);
define _suc_origen		  char(3);
define _n_suc_origen	  char(30);
define _referencia        char(50);
define _suma_asegurada    dec(16,2);
define _suma			  dec(16,2);
define _suma_ret		  dec(16,2);
define _ret_porc		  dec(9,4);
define _suma_fac		  dec(16,2);
define _fac_porc		  dec(9,4);
define _suma_exc		  dec(16,2);
define _exc_porc		  dec(9,4);
define _actualizado       smallint;
define _tipo_incendio     smallint;
define _vig_ini           date;
define _vig_fin           date;
define _cod_ramo          char(3);
define v_cod_contrato     char(5);
define v_tipo_contrato    smallint;
define _est_pol			  smallint;
define _nombre_ag		  char(255);
define _nombre_ag_acum	  char(255);
define _cod_cober_reas	  char(3);
define _porc_partic_suma  dec(9,4);
define _no_cambio	      smallint;
DEFINE v_compania_nombre  char(50);

DEFINE _mes_contable       CHAR(2);
DEFINE _cod_coasegur       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _fecha_emision      DATE;
DEFINE _fecha_cancelacion  DATE;
DEFINE _cod_contratante    CHAR(10);
DEFINE _no_endoso 		   CHAR(5);
DEFINE _cod_ubica		   CHAR(3);
DEFINE _suma_terremoto     DEC(16,2);
DEFINE _prima_terremoto    DEC(16,2);
DEFINE _suma_incendio      DEC(16,2);
DEFINE _prima_incendio     DEC(16,2); 
DEFINE _cod_agente 		   CHAR(5);
DEFINE _porc_partic_agt    DEC(16,2);
DEFINE _porc_comis_agt     DEC(16,2); 
DEFINE _grupo   		   CHAR(5);
DEFINE _suma_otros         DEC(16,2);
DEFINE _otros_porc         DEC(16,2); 
DEFINE _prima_ter_ret      DEC(16,2);
DEFINE _prima_inc_ret      DEC(16,2); 
DEFINE _prima_ter_fac      DEC(16,2);
DEFINE _prima_inc_fac      DEC(16,2); 
DEFINE _prima_ter_otros    DEC(16,2);
DEFINE _prima_inc_otros    DEC(16,2); 
DEFINE _prima_suscrita     DEC(16,2);
DEFINE u_tipo_asegurado    CHAR(50);                   
DEFINE u_referencia        CHAR(50);                   
DEFINE v_ubicacion         CHAR(50);                   
DEFINE v_desc_grupo        CHAR(50);                   
DEFINE u_tipo_incendio , _cnt	    INTEGER;	 
DEFINE _tipo               CHAR(1);
DEFINE v_nombre_ramo       CHAR(50);
define _cod_subramo       char(3);
DEFINE v_nombre_subramo    CHAR(50);
DEFINE _fecha_desde	   	   DATE;
DEFINE _fecha_hasta	       DATE;
DEFINE v_cod_grupo,_cod_acreedor,_limite	 CHAR(5);
DEFINE v_contratante,v_codigo,_temp_poliza	 CHAR(10);
define _limite_acre				dec(16,2);
define _fronting      	smallint;
define _cod_tipoprod	char(3);
define _porc_coas       dec(7,4);
define _name_acreedor	   char(50); 
define _cedula					varchar(30);
DEFINE _estatus_pol       CHAR(50);  
drop table if exists temp_ubica;
drop table if exists temp_filtro;
drop table if exists temp_perfil;

CREATE TEMP TABLE temp_filtro(
		NO_DOCUMENTO 		   CHAR(20),
		NO_POLIZA 			   CHAR(10),
		NO_ENDOSO 			   CHAR(10),
		NO_UNIDAD			   CHAR(5),
		NO_MANZANA			   CHAR(15),
		NO_CORREDOR			   CHAR(5),
		NO_GRUPO			   CHAR(5),
		ESTATUS				   SMALLINT,
		RAMO				   CHAR(3),
		SUBRAMO				   CHAR(3),
		SELECCIONADO	       SMALLINT, 
		desc_grupo             CHAR(50),
        PRIMARY KEY (NO_POLIZA,NO_ENDOSO,NO_UNIDAD,NO_CORREDOR))
        WITH NO LOG;

CREATE TEMP TABLE temp_ubica(
		COMPANIA			   CHAR(3),
		GRUPO				   CHAR(5),
		NOMBRE_GRUPO	       CHAR(50),
		RAMO				   CHAR(3),
		SUBRAMO				   CHAR(3),
		DESDE				   DATE,
		HASTA				   DATE,
		ESTATUS				   SMALLINT,
		POLIZA				   CHAR(20),
		UNIDAD				   CHAR(5),
		ASEGURADO			   CHAR(10),
		NOMBRE_ASEGURADO	   CHAR(50),
		UBICACION			   CHAR(3),
		NOMBRE_UBICACION	   CHAR(50),
		MANZANA				   CHAR(15),
		NOMBRE_MANZANA		   CHAR(50),
		CORREDOR			   CHAR(5),
		NOMBRE_CORREDOR		   CHAR(50),
		PORC_COMISION		   DEC(16,2),
		TIPO				   CHAR(15),
		SUMA_ASEGURADA		   DEC(16,2),
		RETENCION			   DEC(16,2),
		CONTRATOS			   DEC(16,2),
		FACULTATIVO			   DEC(16,2),
		TOTAL_PRIMA_SUSCRITA   DEC(16,2), 
		PRIMA_INC			   DEC(16,2),	
		INC_RETENCION  		   DEC(16,2),	
		INC_CONTRATOS  		   DEC(16,2),	
		INC_FACULTATIVO		   DEC(16,2),	
		PRIMA_TERREMOTO	   	   DEC(16,2),	
		TER_RETENCION		   DEC(16,2),	
		TER_CONTRATOS		   DEC(16,2),	
		TER_FACULTATIVO		   DEC(16,2),			
		cod_acreedor           char(5),
		limite_acre           dec(16,2),
		vig_ini               DATE,  						 
		vig_fin                DATE,							
		cedula                 varchar(30),
        PRIMARY KEY (POLIZA,UNIDAD,CORREDOR))
        WITH NO LOG;

SET ISOLATION TO DIRTY READ;

LET _fecha = CURRENT;
LET _suma_asegurada = 0;
LET _suma_ret       = 0;
let _limite_acre = 0;
let _porc_coas = 0;
let _name_acreedor = '';
let _estatus_pol = '';

LET  v_compania_nombre = sp_sis01(a_compania); 
LET _ano_contable = YEAR(a_fecha);
LET _tipo = NULL;
IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF
LET _periodo = _ano_contable || "-" || _mes_contable;
--Let _no_poliza = sp_sis21(a_poliza);
let _cod_coasegur = sp_sis02(a_compania,a_compania);
--CALL sp_pro03_03("001","001",a_fecha,a_ramo) RETURNING v_filtros;
CALL sp_pro03("001","001",a_fecha,a_ramo) RETURNING v_filtros;



FOREACH WITH HOLD
   SELECT y.no_documento,y.no_poliza,y.cod_grupo
     INTO _no_documento,_no_poliza,_grupo
     FROM temp_perfil y
    WHERE y.seleccionado = 1
--    AND no_documento = "0309-00215-01"
    ORDER BY y.cod_ramo,y.no_documento
	
	

      let _no_endoso = '00000';
	SELECT estatus_poliza,cod_ramo,cod_subramo,cod_tipoprod,fronting
	  INTO _est_pol,_cod_ramo,_cod_subramo,_cod_tipoprod,_fronting
	  FROM emipomae
     WHERE no_poliza   = _no_poliza;	 
		
	if _cod_tipoprod = '002' then
		continue foreach;
	end if	 

	if _fronting = 1 then
	continue foreach;
	end if		

{
	FOREACH
	 SELECT	no_unidad			
	   INTO _no_unidad
	   FROM	emicupol
	  WHERE no_poliza = _no_poliza

	   SELECT cod_manzana
	     INTO _cod_manzana
		 FROM emipouni
		WHERE no_poliza = _no_poliza
		  AND no_unidad = _no_unidad
		  and activo    = 1;		  	  
}
	FOREACH
	   SELECT no_unidad, cod_manzana
	     INTO _no_unidad, _cod_manzana
		 FROM emipouni
		WHERE no_poliza = _no_poliza
		--  AND no_unidad = _no_unidad
		  and activo    = 1
	      if _cod_manzana is null then
	         let _cod_manzana = '';
         end if 		  
		  
			FOREACH
			 SELECT agtagent.cod_agente
			   INTO _cod_agente
			   FROM agtagent, emipoagt 
			  WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) 
			    AND ( emipoagt.no_poliza = _no_poliza ) 

					BEGIN
					ON EXCEPTION IN(-239)
					END EXCEPTION
					INSERT INTO temp_filtro
					(  NO_DOCUMENTO, 
					   NO_POLIZA, 	
					   NO_ENDOSO, 	
					   NO_UNIDAD,	
					   NO_MANZANA,	
					   NO_CORREDOR,	
					   NO_GRUPO,
					   ESTATUS,		
					   RAMO,
					   SUBRAMO,
					   SELECCIONADO)		 
					   VALUES(
					   _no_documento,
					   _no_poliza,
					   _no_endoso,
					   _no_unidad,
					   _cod_manzana,
					   _cod_agente,
					   _grupo,
					   _est_pol,
					   _cod_ramo,
					   _cod_subramo,
					   1) ;
					END
		END FOREACH
	END FOREACH
END FOREACH
--trace off; 
-- Procesos para Filtros
LET v_filtros = "";
IF a_grupo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);
	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND NO_GRUPO NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND NO_GRUPO IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

IF a_acreedor <> "*" THEN
       drop table if exists tmp_acreedor;
	 CREATE TEMP TABLE tmp_acreedor
		   (cod_acreedor CHAR(5),
			no_poliza    CHAR(10),
			limite       DEC(16,2),
			seleccionado SMALLINT DEFAULT 1)
		  WITH NO LOG;

	 FOREACH
		SELECT no_poliza 
		  INTO _temp_poliza
		  FROM temp_perfil
		 WHERE seleccionado = 1
		FOREACH
			SELECT cod_acreedor, limite
			  INTO _cod_acreedor, _limite
			  FROM emipoacr
			 WHERE no_poliza = _temp_poliza

			INSERT INTO tmp_acreedor
				 VALUES(_cod_acreedor,
						_temp_poliza,
						_limite,
						1);
		END FOREACH
	 END FOREACH

	 LET v_filtros = TRIM(v_filtros) ||"Acreedor: "||TRIM(a_acreedor);
	 LET _tipo = sp_sis04(a_acreedor); -- Separa los valores del String

	 IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_acreedor
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_acreedor NOT IN(SELECT codigo FROM tmp_codigos);
	 ELSE
		UPDATE tmp_acreedor
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_acreedor IN(SELECT codigo FROM tmp_codigos);
	 END IF

	 UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_poliza NOT IN(SELECT no_poliza FROM tmp_acreedor WHERE seleccionado = 1);
		   
	 UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_poliza NOT IN(SELECT no_poliza FROM tmp_acreedor WHERE seleccionado = 1);		   

	 DROP TABLE tmp_codigos;
	 DROP TABLE tmp_acreedor;
END IF
IF a_agente <> "*" THEN
	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos
   	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);
	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND NO_CORREDOR NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND NO_CORREDOR IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF
IF a_poliza <> "*" THEN
   	LET v_filtros = TRIM(v_filtros) || " Poliza: " ||  TRIM(a_poliza);
	UPDATE temp_filtro
	   SET seleccionado = 0
	 WHERE seleccionado = 1
	   AND NO_DOCUMENTO NOT IN (a_poliza);
END IF

IF a_cod_manzana <> "*" THEN
	LET _tipo = sp_sis04(a_cod_manzana);  -- Separa los Valores del String en una tabla de codigos
   	LET v_filtros = TRIM(v_filtros) || " Manzana: " ||  TRIM(a_cod_manzana);
	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND NO_MANZANA NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND NO_MANZANA IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF
IF a_ramo <> "*" THEN
	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos
   	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);
	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND RAMO NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE temp_filtro
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND RAMO IN (SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

--if trim(a_ramo) = "001,003;" or  trim(a_ramo) = "003,001;" or  trim(a_ramo) = "001,003;Ex" or  trim(a_ramo) = "003,001;Ex" then

if trim(a_ramo[1,3]) in ("001","003") then
	   	LET v_filtros = TRIM(v_filtros) || " Subramo: ZONA LIBRE " ;
		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE temp_filtro
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND RAMO||'/'||SUBRAMO NOT IN (select cod_ramo||'/'||cod_subramo from prdsubra where cod_ramo in ( '001','003') and upper(nombre) like ('%ZONA LIBRE%'));
		ELSE		        -- Excluir estos Registros

			UPDATE temp_filtro
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND  RAMO||'/'||SUBRAMO IN (select cod_ramo||'/'||cod_subramo from prdsubra where cod_ramo in ( '001','003') and upper(nombre) like ('%ZONA LIBRE%'));
		END IF
else
	IF a_subramo <> "*" THEN
		LET _tipo = sp_sis04(a_subramo);  -- Separa los Valores del String en una tabla de codigos
	   	LET v_filtros = TRIM(v_filtros) || " Subramo: " ||  TRIM(a_subramo);
		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE temp_filtro
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND SUBRAMO NOT IN (SELECT codigo FROM tmp_codigos);
		ELSE		        -- Excluir estos Registros

			UPDATE temp_filtro
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND SUBRAMO IN (SELECT codigo FROM tmp_codigos);
		END IF
		DROP TABLE tmp_codigos;
	END IF
END IF
--SET DEBUG FILE TO "sp_pr99b.trc";
--trace on; 
		SELECT COUNT(*)
		  INTO _cnt
		    FROM temp_perfil
    WHERE seleccionado = 1;
	let _cnt = _cnt;
		  
		SELECT COUNT(*)
		  INTO _cnt
		  FROM temp_filtro;		  
	let _cnt = _cnt;		  
--trace on; 
FOREACH WITH HOLD
   SELECT NO_POLIZA, 	
		  NO_ENDOSO, 	
		  NO_UNIDAD,	
		  NO_MANZANA,	
		  NO_CORREDOR,	
		  NO_GRUPO,
		  ESTATUS		  
     INTO _no_poliza,
		  _no_endoso,
		  _no_unidad,
		  _cod_manzana,
		  _cod_agente,
		  _grupo,
		  _est_pol
     FROM temp_filtro
    WHERE SELECCIONADO  = 1

	SELECT sucursal_origen,
	       no_documento,
	  	   actualizado,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_subramo,
		   estatus_poliza,
		   fecha_cancelacion,
		   cod_contratante,
		   cod_grupo,
		   cod_tipoprod,
		   fronting
	  INTO _suc_origen,
	       _no_documento,
	  	   _actualizado,
		   _vig_ini,
		   _vig_fin,
		   _cod_ramo,
		   _cod_subramo,
		   _est_pol,
		   _fecha_cancelacion,
		   _cod_contratante,
		   _grupo,
		   _cod_tipoprod,
		   _fronting
	  FROM emipomae
     WHERE no_poliza   = _no_poliza
       and estatus_poliza = _est_pol;
	   
	if _fronting = 1 then -- excluye fronting
		continue foreach;
	end if	   

   SELECT descripcion
     INTO _n_suc_origen
     FROM insagen
    WHERE codigo_compania = "001"
     AND codigo_agencia  = _suc_origen;
	 
	let _cod_ubica = '';
	--let _no_unidad = '';
	let _suma_terremoto = 0; 
	let _prima_terremoto = 0;
	let _suma_incendio = 0; 
	let _prima_incendio = 0;	 
{
	foreach
	 SELECT	cod_ubica, 
	        no_unidad,
			suma_terremoto, 
			prima_terremoto, 
			suma_incendio, 
			prima_incendio 
	   INTO _cod_ubica, 
	        _no_unidad,
			_suma_terremoto, 
			_prima_terremoto, 
			_suma_incendio, 
			_prima_incendio
	   FROM	emicupol
	  WHERE no_poliza = _no_poliza
	  }
	  
	foreach
	   select suma_asegurada,
			  cod_asegurado,
			  tipo_incendio,
			  cod_manzana,
			  prima_suscrita
	     into _suma_asegurada,
			  _contratante,
			  _tipo_incendio,
			  _cod_manzana,
			  _prima_suscrita
		 from emipouni a
		where a.no_poliza = _no_poliza		
		  and a.no_unidad = _no_unidad
		  and a.activo = 1  --;
		  

		if _cod_tipoprod = '001' then
			SELECT porc_partic_coas
			  INTO _porc_coas
			  FROM emicoama
			 WHERE no_poliza    = _no_poliza
			   AND cod_coasegur = _cod_coasegur;

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF
			
			let _suma_asegurada = _suma_asegurada * _porc_coas / 100;
		elif _cod_tipoprod = '002' then  --Excluye 'MIN'
			let _suma_asegurada = 0.00;   
		end if	 		  


	   SELECT nombre, cedula
	     INTO v_asegurado, _cedula
	     FROM cliclien
	    WHERE cod_cliente = _contratante;

	   SELECT referencia
	     INTO _referencia
	     FROM emiman05
	    WHERE cod_manzana = _cod_manzana;
		

			
			let _suma_ret = 0;
			let _ret_porc = 0;
			let _suma_fac = 0;
			let _fac_porc = 0;
			let _suma_exc = 0;
			let	_exc_porc = 0;
			let _cod_cober_reas	= null; 
			let	_porc_partic_suma = 0;
			let _suma_otros = 0;
			let _otros_porc = 0;
			--let _suma_asegurada = _suma_incendio; se cambia
			let _prima_ter_ret   = 0;
			let _prima_inc_ret   = 0;
			let	_prima_ter_fac   = 0;
			let _prima_inc_fac   = 0;
			let	_prima_ter_otros = 0;
			let _prima_inc_otros = 0;

			let _no_cambio = null;

			if _cod_ramo in ("001") then
				let _cod_cober_reas = "001";
			else
				let _cod_cober_reas = "003";
			end if

		   	SELECT max(no_cambio)
			  INTO _no_cambio
			  FROM emireama
			 WHERE no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;

			FOREACH
			 SELECT cod_contrato,porc_partic_suma
			   INTO v_cod_contrato,_porc_partic_suma
			   FROM emireaco
			  WHERE no_poliza      = _no_poliza
			    AND no_unidad      = _no_unidad
			    AND no_cambio      = _no_cambio
				AND cod_cober_reas = _cod_cober_reas

		       SELECT tipo_contrato
		         INTO v_tipo_contrato
		         FROM reacomae
		        WHERE cod_contrato = v_cod_contrato;

			   	   IF _porc_partic_suma IS NULL THEN
			   		  LET _porc_partic_suma = 0;
			   	  END IF

			   	   IF _suma_asegurada IS NULL THEN
			   		  LET _suma_asegurada = 0;
			   	  END IF

		       IF v_tipo_contrato = 1  THEN
					let _suma_ret = _suma_asegurada * _porc_partic_suma / 100;
					let _prima_inc_ret = _prima_incendio * _porc_partic_suma / 100;
					let _prima_ter_ret = _prima_terremoto * _porc_partic_suma / 100;
					let _ret_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 3  THEN
					let _suma_fac = _suma_asegurada * _porc_partic_suma / 100;
					let _prima_inc_fac = _prima_incendio * _porc_partic_suma / 100;
					let _prima_ter_fac = _prima_terremoto * _porc_partic_suma / 100;
					let _fac_porc = _porc_partic_suma;
			   end if
		       IF v_tipo_contrato = 7  THEN
					let _suma_exc = _suma_asegurada * _porc_partic_suma / 100;
					let _exc_porc = _porc_partic_suma;
			   end if
			   if  v_tipo_contrato <> 1 and v_tipo_contrato <> 3 then
					let _suma_otros = _suma_asegurada * _porc_partic_suma / 100;
					let _prima_inc_otros = _prima_incendio * _porc_partic_suma / 100;
					let _prima_ter_otros = _prima_terremoto * _porc_partic_suma / 100;
					let _otros_porc = _porc_partic_suma;
			   end if

		   END FOREACH	

		--AGENTES DE LA POLIZA
			LET _nombre_ag = "";
			LET _nombre_ag_acum = "";
			LET u_tipo_asegurado  = '';
			LET u_referencia      = '';
			LET u_tipo_asegurado  = 'etc';
			LET v_ubicacion       = '';
			let _limite_acre = 0;
			
			 IF _tipo_incendio = 1 THEN
			    LET u_tipo_asegurado  = 'Edificio';
			END IF

			 IF _tipo_incendio = 2 THEN
			    LET u_tipo_asegurado  = 'Contenido';
			END IF

			 IF _tipo_incendio = 3 THEN
			    LET u_tipo_asegurado  = 'Lucro Cesante';
			END IF

	       	SELECT referencia
	       	  INTO u_referencia 
	       	  FROM emiman05 
	       	 WHERE cod_manzana = _cod_manzana; 
			  
			  IF u_referencia is null THEN
				 LET u_referencia  = '';
			 END IF
			 LET u_referencia = TRIM(REPLACE(TRIM(u_referencia),"EN MAPA OFICIAL",""));
			 SELECT nombre
			   INTO v_ubicacion
			   FROM emiubica
			  WHERE cod_ubica = _cod_ubica;

	       	 SELECT nombre 
	       	   INTO v_desc_grupo 
	       	   FROM cligrupo 
	       	  WHERE cod_grupo = _grupo; 
			  
			SELECT first 1 cod_acreedor, limite
			  INTO _cod_acreedor, _limite_acre
			  FROM emipoacr
			 WHERE no_poliza = _no_poliza
			   and no_unidad = _no_unidad and limite > 0;
			   --order by limite desc;			  
			   
	           IF _cod_acreedor IS NULL THEN
			      continue foreach;
		   END IF		
		   
			IF _limite_acre IS NULL THEN
				LET _limite_acre = 0;
			END IF		   

			FOREACH
				   SELECT TRIM(agtagent.nombre),agtagent.cod_agente,emipoagt.porc_comis_agt,emipoagt.porc_partic_agt
				     INTO _nombre_ag,_cod_agente,_porc_comis_agt,_porc_partic_agt
					 FROM agtagent, emipoagt 
					WHERE ( emipoagt.cod_agente = agtagent.cod_agente ) 
					  AND ( emipoagt.no_poliza = _no_poliza ) 

				      LET _nombre_ag_acum = trim(_nombre_ag_acum) || " " || trim(_nombre_ag) ;

					BEGIN
			   			ON EXCEPTION IN (-239, -268)
							UPDATE temp_ubica			   
							   SET TOTAL_PRIMA_SUSCRITA = TOTAL_PRIMA_SUSCRITA + 0
							 WHERE poliza = _no_poliza
							   and unidad = _no_unidad
							   and corredor = _cod_agente;
						END EXCEPTION
						INSERT INTO temp_ubica
						(  COMPANIA, 			 
						   GRUPO,				 
						   NOMBRE_GRUPO,
						   RAMO, 				 
						   SUBRAMO, 	
						   DESDE, 				 
						   HASTA, 				 
						   ESTATUS, 			 
						   POLIZA, 				 
						   UNIDAD, 				 
						   ASEGURADO, 			 
						   NOMBRE_ASEGURADO,
						   UBICACION, 			 
						   NOMBRE_UBICACION,
						   MANZANA,			
						   NOMBRE_MANZANA, 	 
						   CORREDOR, 		
						   NOMBRE_CORREDOR, 
						   PORC_COMISION, 		 
						   TIPO,				 
						   SUMA_ASEGURADA,		 
						   RETENCION,			 
						   CONTRATOS,			 
						   FACULTATIVO,			 
						   TOTAL_PRIMA_SUSCRITA, 
						   PRIMA_INC,			 
						   INC_RETENCION,  		 
						   INC_CONTRATOS,  		 
						   INC_FACULTATIVO,		 
						   PRIMA_TERREMOTO,	   	 
						   TER_RETENCION,		 
						   TER_CONTRATOS,		 
						   TER_FACULTATIVO,
						   cod_acreedor, 
						   limite_acre,
						   vig_ini,   						 
		                   vig_fin,							
						   cedula)		 
						   VALUES(a_compania,
						   _grupo,   
						   v_desc_grupo,
						   _cod_ramo,
						   _cod_subramo,
						   a_fecha,
						   a_fecha,
						   _est_pol,
						   _no_documento,
						   _no_unidad,
						   _contratante,
						   v_asegurado,
						   _cod_ubica,
						   v_ubicacion,
						   _cod_manzana,
						   u_referencia,
						   _cod_agente,
						   _nombre_ag,
						   _porc_comis_agt,
						   u_tipo_asegurado,
						   _suma_asegurada,
						   _suma_ret,
						   _suma_otros,
						   _suma_fac,
						   _prima_suscrita,
						   _prima_incendio,
						   _prima_inc_ret,
						   _prima_inc_otros,
						   _prima_inc_fac,
						   _prima_terremoto,
						   _prima_ter_ret,
						   _prima_ter_otros,
						   _prima_ter_fac,
						   _cod_acreedor, 
						   _limite_acre,
						   _vig_ini,   						 
		                   _vig_fin,							
						   _cedula
						   );
					END
--  Tipo_incendio
--1	Edificio
--2	Contenido
--3	Lucro Cesante
			END FOREACH
	END FOREACH
END FOREACH


FOREACH WITH HOLD
   SELECT a.COMPANIA, 			 
	   a.GRUPO,				 
	   a.NOMBRE_GRUPO,
	   a.RAMO, 				 
	   a.SUBRAMO, 		
	   a.DESDE, 				 
	   a.HASTA, 				 
	   (CASE  WHEN A.ESTATUS = '1' THEN "VIGENTES" WHEN A.ESTATUS = '2' THEN "CANCELADAS" WHEN A.ESTATUS = '3' THEN "VENCIDAS" WHEN A.ESTATUS = '4' THEN "ANULADA" ELSE "TODAS" END) ESTATUS,  --//a.ESTATUS, 			 
	   a.POLIZA, 				 
	   a.UNIDAD, 				 
	   a.ASEGURADO, 			 
	   a.NOMBRE_ASEGURADO,
	   a.UBICACION, 			 
	   a.NOMBRE_UBICACION,
	   a.MANZANA,			
	   a.NOMBRE_MANZANA, 	 
	   a.CORREDOR, 		
	   a.NOMBRE_CORREDOR, 
	   a.PORC_COMISION, 		 
	   a.TIPO,				 
	   a.SUMA_ASEGURADA,		 
	   a.RETENCION,			 
	   a.CONTRATOS,			 
	   a.FACULTATIVO,			 
	   a.TOTAL_PRIMA_SUSCRITA, 
	   a.PRIMA_INC,			 
	   a.INC_RETENCION,  		 
	   a.INC_CONTRATOS,  		 
	   a.INC_FACULTATIVO,		 
	   a.PRIMA_TERREMOTO,	   	 
	   a.TER_RETENCION,		 
	   a.TER_CONTRATOS,		 
	   a.TER_FACULTATIVO,
	   a.cod_acreedor, 
	   a.limite_acre,
       a.vig_ini,   						 
	   a.vig_fin,							
	   a.cedula	   
	   INTO a_compania,
	   _grupo,   
	   v_desc_grupo,
	   _cod_ramo,
	   _cod_subramo,
	   _fecha_desde,
	   _fecha_hasta,
	   _estatus_pol,
	   _no_documento,
	   _no_unidad,
	   _contratante,
	   v_asegurado,
	   _cod_ubica,
	   v_ubicacion,
	   _cod_manzana,
	   u_referencia,
	   _cod_agente,
	   _nombre_ag,
	   _porc_comis_agt,
	   u_tipo_asegurado,
	   _suma_asegurada,
	   _suma_ret,
	   _suma_otros,
	   _suma_fac,
	   _prima_suscrita,
	   _prima_incendio,
	   _prima_inc_ret,
	   _prima_inc_otros,
	   _prima_inc_fac,
	   _prima_terremoto,
	   _prima_ter_ret,
	   _prima_ter_otros,
	   _prima_ter_fac,
	   _cod_acreedor,
	   _limite_acre,
	   _vig_ini,   						 
       _vig_fin,							
       _cedula
     FROM temp_ubica a, temp_filtro	b  
	where TRIM(b.NO_DOCUMENTO) = TRIM(a.POLIZA) 		
	  and b.NO_UNIDAD = a.UNIDAD	
	 -- and b.NO_MANZANA = a.MANZANA
	  and b.NO_CORREDOR	= a.CORREDOR
	  and b.NO_GRUPO = a.GRUPO
	  and b.ESTATUS	= a.ESTATUS
	  and b.SELECCIONADO  = 1	
	order by  a.RAMO,a.SUBRAMO,a.UBICACION,a.MANZANA,a.POLIZA,a.UNIDAD

         SELECT nombre
  	       INTO v_nombre_ramo
           FROM prdramo
          WHERE cod_ramo = _cod_ramo;

         SELECT nombre
  	       INTO v_nombre_subramo
           FROM prdsubra
          WHERE cod_ramo = _cod_ramo
            and cod_subramo = _cod_subramo;
			
        select trim(cod_acreedor) ||'-'||upper(trim(nombre))
		  into _name_acreedor
		  from emiacre 
		 where cod_acreedor = _cod_acreedor;
		 
		   RETURN 	
				_no_documento,	
				_no_unidad,	
				_suma_asegurada,	
				_estatus_pol,   --_est_pol,	
				_vig_ini,   	
				_vig_fin,	
				_contratante,	
				v_asegurado,	
				_cedula,	
				_cod_ramo,	
				v_nombre_ramo,	
				_cod_subramo,	
				v_nombre_subramo,	
				_grupo,   	
				v_desc_grupo,	
				_cod_agente,	
				_nombre_ag,	
				_cod_acreedor,	
				_name_acreedor,	
				_limite_acre,	
				a_compania,	
				v_compania_nombre,	
				v_filtros	
			 WITH RESUME;	

    		 
END FOREACH



end procedure