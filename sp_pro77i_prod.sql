-- Cumulos por Ubicacion
-- 
-- Creado    : 25/09/2001 - Autor: Amado Perez 
-- Modificado: 25/09/2001 - Autor: Amado Perez
-- Modificado: 25/04/2019 - HGIRON CASO: 31242 
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro77i_prod;
CREATE PROCEDURE sp_pro77i_prod(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE, a_fecha2 DATE, a_ubica CHAR(255) DEFAULT "*", a_serie char(255) default "*")
RETURNING   CHAR(50),  -- Ubicacion
            CHAR(50),  -- Ramo
            CHAR(50),  -- Subramo
            CHAR(20),  -- Documento
			DATE,
			CHAR(100), -- Asegurado
            INT,       -- Cnt. poliza
			DEC(16,2), -- Suma Asegurada
			DEC(16,2), -- Retencion ancon
			INT,
			DEC(16,2), -- 1er excedente
			INT,
			DEC(16,2), -- Facultativo
			INT,
			DEC(16,2), -- Prima suscrita terremoto
			CHAR(50),  -- Compania
			char(5),   -- unidad
			char(255), -- filtros
			varchar(50),
			char(15),
			varchar(50),
			varchar(50); --provincia/comarca

DEFINE v_filtros           CHAR(255);
define _tipo				    char(1);
DEFINE v_ubicacion         CHAR(50);
DEFINE v_cnt_poliza        INT; 
DEFINE v_suma_asegurada    DEC(16,2);
DEFINE v_retencion         DEC(16,2);
DEFINE v_excedente         DEC(16,2);
DEFINE v_facultativo       DEC(16,2);
DEFINE v_prima			   DEC(16,2);
DEFINE v_compania_nombre, v_ramo, v_subramo CHAR(50);
DEFINE v_nodocumento       CHAR(20);
DEFINE v_vigencia_final    DATE;
DEFINE v_asegurado         CHAR(100);
DEFINE _no_poliza          CHAR(10);
DEFINE _cod_contratante    CHAR(10);
DEFINE _no_unidad, _no_endoso CHAR(5);
DEFINE _cod_ubica, _cod_ramo, _cod_subramo  CHAR(3);
DEFINE _suma     		   DEC(16,2);
DEFINE _prima    		   DEC(16,2);
DEFINE _suma_retencion     DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   DEC(16,2);
DEFINE _suma_excedente     DEC(16,2);
DEFINE _porc_partic_suma   DEC(9,6);
DEFINE _porcentaje		   DEC(9,6);
DEFINE _tipo_contrato      SMALLINT;
DEFINE _no_cambio, _es_terremoto SMALLINT;
DEFINE _mal_porc 		   CHAR(5);
DEFINE _mes_contable       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion DATE;
DEFINE _orden			   smallint;
DEFINE _prima_cobrada      DEC(16,2);
define _cod_endomov			char(3);
define _suma_aseg_total     dec(16,2);
define _prima_porcion       dec(16,2);
define _prima_cobrada_uni   dec(16,2);
define _prima_unidad        dec(16,2);
define _f_emision_unidad    date;
define _error_desc			CHAR(50);
define _error_isam			integer;
define _error				integer;
define _n_prov_com          varchar(50);
define _cod_manzana         char(2);
define _cod_manzana2		char(15);
define _referencia          varchar(50);
define _barrio              varchar(50);

SET ISOLATION TO DIRTY READ;
LET v_compania_nombre = sp_sis01(a_compania); 
let v_filtros = '';

call sp_pr77tc(a_compania, a_terremoto, a_fecha, a_fecha2, a_ubica) returning _error, _error_desc; 

if _error <> 0 then
	return _error_desc,'','','',null,'',_error, 0.00,0.00,0,0.00,0,0.00,0,0.00,'','',v_filtros,'',null,null,null;		   
end if
-- HG:CASO: 31242
-- Filtro por Serie
IF a_serie <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_ubica
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_ubica
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF

IF a_ubica <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Ubicacion: " ||  TRIM(a_ubica);
	LET _tipo = sp_sis04(a_ubica);  -- Separa los Valores del String en una tabla de codigos
	DROP TABLE tmp_codigos;
END IF

FOREACH WITH HOLD
	  SELECT cod_ubica, 
	         cod_ramo,
			 cod_subramo,
	         cod_contratante,
	         no_poliza,
			 vigencia_final,
	         no_documento,      
			 cantidad,        
			 suma_asegurada,  
			 retencion, 
			 cant_ret,      
			 primer_excedente,
			 cant_exe,
			 facultativo,
			 cant_fac,     
			 prima_terremoto,
			 orden,
			 no_unidad,
             suma_aseg_total		 
		INTO _cod_ubica,
		     _cod_ramo, 
			 _cod_subramo,
		     _cod_contratante,
		     _no_poliza,
		     v_vigencia_final,    	  
		     v_nodocumento, 
			 v_cnt_poliza,     
			 v_suma_asegurada,
			 v_retencion,  
			 _cant_ret,
			 v_excedente,
			 _cant_exe,      
		     v_facultativo,    
			 _cant_fac,
			 v_prima,
			 _orden,
			 _no_unidad,
			 _suma_aseg_total
	   FROM temp_ubica
      WHERE seleccionado = 1	   
	  ORDER BY orden, cod_ramo, cod_subramo, vigencia_final, no_documento, no_unidad

	  SELECT nombre
		INTO v_ubicacion
		FROM emiubica
	   WHERE cod_ubica = _cod_ubica;

      SELECT nombre
	    INTO v_asegurado
      	FROM cliclien
	   WHERE cod_cliente = _cod_contratante;

      SELECT nombre
	    INTO v_ramo
		FROM prdramo
	   WHERE cod_ramo = _cod_ramo;

	  SELECT nombre 
		INTO v_subramo
		FROM prdsubra
	   WHERE cod_ramo = _cod_ramo
	     AND cod_subramo = _cod_subramo;
		 
		if _suma_aseg_total = 0 then
			let _prima_unidad = v_prima;
		else
			let _prima_unidad = (v_suma_asegurada/_suma_aseg_total) * v_prima;
		end if
	
	let _cod_manzana = null;
	
	select cod_manzana[1,2]
	  into _cod_manzana
	  from emipouni
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	   
	let _n_prov_com = null;
	
	if _cod_manzana is not null THEN
		select nombre
		  into _n_prov_com
		  from emiman01
		 where cod_provincia = _cod_manzana; 
	end IF
	
	select first 1 cod_manzana,
	       referencia,
		   nombre_barrio
	  into _cod_manzana2,
	       _referencia,
		   _barrio
	  from temp_unidad
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;	  

	RETURN v_ubicacion,
	       v_ramo,
		   v_subramo,
	       v_nodocumento,
		   v_vigencia_final,
		   v_asegurado,
		   v_cnt_poliza,    	
		   v_suma_asegurada, --/1000,	
		   v_retencion, --/1000,  	
		   _cant_ret,	
		   v_excedente, --/1000,	
		   _cant_exe,      	
		   v_facultativo, --/1000,   	
		   _cant_fac,	
		   _prima_unidad, --v_prima,
		   v_compania_nombre,
           _no_unidad,
		   v_filtros,
		   _n_prov_com,
		   _cod_manzana2,
		   _referencia,
		   _barrio
		   WITH RESUME;

END FOREACH
DROP TABLE temp_ubica;
END PROCEDURE;
