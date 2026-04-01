-- Reporte de Total de Produccion por CorredorRamo
--
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno
-- Modificado: 07/01/2001 - Autor: Lic. Yinia M. Zamora
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro107b;

CREATE PROCEDURE "informix".sp_pro107b(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_grupo    CHAR(255) DEFAULT "*", a_usuario  CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*") 
		RETURNING   CHAR(50),
		            CHAR(03),
					CHAR(50),
					CHAR(20),
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
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2),
		            CHAR(50),
					CHAR(100),
					DATE,
					DATE,
		            CHAR(255);


DEFINE v_nombre          CHAR(50);
DEFINE v_total_prima_sus,v_total_prima_nva,v_total_prima_ren,v_total_prima_end, 
       v_total_prima_can,v_total_prima_rev,v_total_prima_cob, _monto, _neto,
       v_total_prima_net_cob,_monto_tot,_neto_tot,v_total_prima_cob_tot,v_total_prima_net_cob_tot DECIMAL(16,2);
DEFINE v_cnt_prima_sus,v_cnt_prima_nva,v_cnt_prima_ren,v_cnt_prima_end,
       v_cnt_prima_can,v_cnt_prima_rev   INTEGER;
DEFINE v_compania_nombre,_nombre_ramo    CHAR(50); 
DEFINE v_filtros                         CHAR(255);
DEFINE _cod_ramo                         CHAR(03);
DEFINE _cod_agente                       CHAR(5);
DEFINE _no_poliza						 CHAR(10);
DEFINE v_documento                       CHAR(20);
DEFINE _cod_contratante					 CHAR(10);
DEFINE v_vigencia_inic,v_vigencia_final	 DATE;
DEFINE v_asegurado                       CHAR(100);
DEFINE _nueva_renov      		CHAR(1);        


-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);
LET v_filtros = '';

LET v_filtros = sp_pro107(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo, 
a_usuario,
a_reaseguro,
a_agente
);

--SET DEBUG FILE TO "sp_apm107.trc";
--trace on;

--Recorre la tabla temporal y asigna valores a vvriables de salida

   LET v_total_prima_cob = 0; 
   LET v_total_prima_net_cob = 0; 
   LET v_total_prima_cob_tot = 0;
   LET v_total_prima_net_cob_tot = 0;

   FOREACH WITH HOLD
   	   SELECT cod_agente,
	          cod_ramo,
	          no_poliza,
   	          SUM(monto),
	          SUM(neto),
			  SUM(monto_tot),
			  SUM(neto_tot)
   	     INTO _cod_agente,
		      _cod_ramo,
			  _no_poliza,
   	          v_total_prima_cob,
		      v_total_prima_net_cob,
			  v_total_prima_cob_tot,
			  v_total_prima_net_cob_tot
   	     FROM tmp_tabla
   		GROUP BY 1,2,3
		ORDER BY 1,2,3

		SELECT no_documento,
		       cod_contratante,
			   vigencia_inic,
			   vigencia_final,
			   nueva_renov
		  INTO v_documento,
		       _cod_contratante,
			   v_vigencia_inic,
			   v_vigencia_final,
			   _nueva_renov
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT nombre
	      INTO v_nombre
	      FROM agtagent
	     WHERE cod_agente = _cod_agente;

	   SELECT nombre
	     INTO v_asegurado
		 FROM cliclien
		WHERE cod_cliente = _cod_contratante;

	   SELECT nombre
	     INTO _nombre_ramo
	     FROM prdramo
	    WHERE cod_ramo = _cod_ramo; 
	   IF _nueva_renov = 'N' THEN
		FOREACH 
		 SELECT SUM(total_pri_sus),
				SUM(total_pri_nva),
				SUM(total_pri_ren), 
				SUM(total_pri_end), 
				SUM(total_pri_can), 
				SUM(total_pri_rev), 
				SUM(cnt_prima_sus), 
				SUM(cnt_prima_nva), 
				SUM(cnt_prima_ren), 
				SUM(cnt_prima_end), 
				SUM(cnt_prima_can), 
				SUM(cnt_prima_rev)
		   INTO v_total_prima_sus,
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
		    AND no_poliza = _no_poliza
		 
   END FOREACH

	RETURN  v_nombre,
	        _cod_ramo,
			_nombre_ramo,
			v_documento,
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
			v_total_prima_cob,
			v_total_prima_net_cob,
			v_total_prima_cob_tot,
			v_total_prima_net_cob_tot,
			v_compania_nombre,
			v_asegurado,                     
			v_vigencia_inic,
			v_vigencia_final,
			v_filtros
		    WITH RESUME;
 END IF

END FOREACH

DROP TABLE tmp_prod;
DROP TABLE tmp_tabla;


END PROCEDURE;
