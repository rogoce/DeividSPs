-- Reporte de Total de Produccion por Ramo
--
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno
-- Modificado: 04/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro86c;

CREATE PROCEDURE "informix".sp_pro86c(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*")
		RETURNING   CHAR(10),
		            CHAR(5),
					CHAR(5),
		            DECIMAL(16,2),
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2), 
					INTEGER,
		            DECIMAL(16,2),
		            INTEGER,
					DECIMAL(16,2),
		            CHAR(50),
		            CHAR(255);
		            
DEFINE v_nombre, v_nombre_subramo CHAR(50); 
DEFINE v_total_prima_sus DECIMAL(16,2);
DEFINE v_total_prima_nva DECIMAL(16,2);
DEFINE v_total_prima_ren DECIMAL(16,2);
DEFINE v_total_prima_end DECIMAL(16,2);
DEFINE v_total_prima_can DECIMAL(16,2);
DEFINE v_total_prima_rev, _prima_suscrita DECIMAL(16,2);
DEFINE v_cnt_prima_sus   INTEGER;
DEFINE v_cnt_prima_nva   INTEGER;
DEFINE v_cnt_prima_ren   INTEGER;
DEFINE v_cnt_prima_end   INTEGER;
DEFINE v_cnt_prima_can   INTEGER;
DEFINE v_cnt_prima_rev   INTEGER;
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _no_poliza     	 CHAR(10);
DEFINE _no_endoso, _no_unidad, _no_endoso_v  CHAR(5);
DEFINE v_descripcion     CHAR(22); 
DEFINE _cod_tipoveh,_cod_subramo CHAR(3);
DEFINE _cod_ramo         CHAR(3);        

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);
LET a_ramo = '002;';

LET v_filtros = sp_pro86(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo, 
a_usuario,
a_reaseguro,
a_agente,
'*'
);

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT cod_ramo,
        cod_subramo,
        no_poliza,
        no_endoso,
		no_unidad,
		total_pri_sus,
		total_pri_nva,
		total_pri_ren, 
		total_pri_end, 
		total_pri_can, 
		total_pri_rev, 
		cnt_prima_sus, 
		cnt_prima_nva, 
		cnt_prima_ren, 
		cnt_prima_end, 
		cnt_prima_can, 
		cnt_prima_rev
   INTO _cod_ramo,
        _cod_subramo,
        _no_poliza,
        _no_endoso,
        _no_unidad,
		v_total_prima_sus,
		v_total_prima_nva, 
		v_total_prima_ren, 
		v_total_prima_end, 
		v_total_prima_can, 
		v_total_prima_rev, 
		v_cnt_prima_sus, 
		v_cnt_prima_nva, 
		v_cnt_prima_ren, 
		v_cnt_prima_end, 
		v_cnt_prima_can, 
		v_cnt_prima_rev
   FROM tmp_prod
  WHERE	seleccionado = 1

  SELECT prima_suscrita
    INTO _prima_suscrita
	FROM endedmae
   WHERE no_poliza = _no_poliza
     AND no_endoso = _no_endoso;

 	RETURN  _no_poliza,
	        _no_endoso,
			_no_unidad,
			v_total_prima_sus,
			v_cnt_prima_sus,
			v_total_prima_nva,
			v_cnt_prima_nva,
			v_total_prima_ren,
			v_cnt_prima_ren,
			v_total_prima_end,
			v_cnt_prima_end,
			v_total_prima_can,
			v_cnt_prima_can,
			v_total_prima_rev,
			v_cnt_prima_rev,
			_prima_suscrita,
			v_compania_nombre,
			v_filtros
			WITH RESUME;
END FOREACH

DROP TABLE tmp_prod;

END PROCEDURE;
