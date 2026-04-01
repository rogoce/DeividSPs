

DROP PROCEDURE sp_pr109a;
CREATE PROCEDURE "informix".sp_pr109a(a_compania  CHAR(3),a_agencia  CHAR(3),a_periodo1  CHAR(7),a_periodo2  CHAR(7),a_sucursal  CHAR(255) DEFAULT "*",a_ramo  CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_agente    CHAR(255) DEFAULT "*")
  RETURNING CHAR(50),
            DECIMAL(16,2), 
            DECIMAL(16,2), 
            DECIMAL(16,2),
            CHAR(50),
            CHAR(255),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2),
            DECIMAL(16,2);

DEFINE v_nombre     	 							 CHAR(50);
DEFINE _no_poliza     	 							 CHAR(10);
DEFINE v_total_prima_sus 							 DECIMAL(16,2);
DEFINE v_comision,_pagado_neto,_reserva_neto  		 DECIMAL(16,2);
DEFINE v_total_prima_ret 							 DECIMAL(16,2);
DEFINE v_total_prima_ced,_res_tec 					 DECIMAL(16,2);
DEFINE _impuesto,_comision_rea_ced,_siniestro_pagado DECIMAL(16,2);
DEFINE v_total_prima_neta_ret,_cont_fac,_cont_otros	 DECIMAL(16,2);
DEFINE v_compania_nombre 							 CHAR(50);
DEFINE v_filtros,v_filtros2							 CHAR(255);
DEFINE _cod_ramo         							 CHAR(3);
DEFINE _cantidad         							 INTEGER;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod2(
	        cod_ramo       		 CHAR(3) NOT NULL,
	     	nombre         		 CHAR(50),
	        total_pri_sus  		 DEC(16,2) NOT NULL,
	    	total_pri_ret  		 DEC(16,2) NOT NULL,
	    	total_pri_ced  		 DEC(16,2) NOT NULL,
			total_prima_neta_ret DEC(16,2) NOT NULL,
			comision_corredor 	 DEC(16,2) NOT NULL,
			impuesto		 	 DEC(16,2) NOT NULL,
			comision_rea_ced 	 DEC(16,2) NOT NULL,
	        no_poliza      		 CHAR(10) NOT NULL,
	    PRIMARY KEY (cod_ramo)) WITH NO LOG;

LET v_filtros = sp_pro109(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo,
a_agente
);

--Recorre la tabla temporal y asigna valores a variables de salida

SET ISOLATION TO DIRTY READ;

LET v_filtros2 = sp_rec01(
				a_compania, 
				a_agencia, 
				a_periodo1, 
				a_periodo2,
				a_sucursal,
				a_grupo,
				a_ramo,
				a_agente
				); 

FOREACH WITH HOLD
 SELECT cod_ramo,
		total_pri_sus,
		total_pri_ret,
		total_pri_ced,
		total_prima_neta_ret,
		comision_corredor,
		impuesto,
		comision_rea_ced,
		no_poliza
   INTO _cod_ramo,
		v_total_prima_sus,
		v_total_prima_ret,
		v_total_prima_ced,
		v_total_prima_neta_ret,
		v_comision,
		_impuesto,
		_comision_rea_ced,
		_no_poliza
   FROM tmp_prod
  WHERE seleccionado = 1

if _comision_rea_ced is null then
	let _comision_rea_ced = 0;
end if

--Selecciona los nombres de Ramos
    BEGIN
          ON EXCEPTION IN(-239)
             UPDATE tmp_prod2
                  SET total_pri_sus 	   = total_pri_sus + v_total_prima_sus,
                      total_pri_ret 	   = total_pri_ret + v_total_prima_ret,
	                  total_pri_ced 	   = total_pri_ced + v_total_prima_ced,
	                  total_prima_neta_ret = total_prima_neta_ret + v_total_prima_neta_ret,
	                  comision_corredor    = comision_corredor + v_comision,
	                  impuesto    		   = impuesto + _impuesto,
	                  comision_rea_ced     = comision_rea_ced + _comision_rea_ced
	             WHERE cod_ramo = _cod_ramo;

          END EXCEPTION

         SELECT nombre
  	       INTO v_nombre
           FROM prdramo
          WHERE cod_ramo = _cod_ramo;

          INSERT INTO tmp_prod2
              VALUES(_cod_ramo,
					 v_nombre,
                     v_total_prima_sus,
                     v_total_prima_ret,
                     v_total_prima_ced,
                     v_total_prima_neta_ret,
                     v_comision,
                     _impuesto,
                     _comision_rea_ced,
                     _no_poliza);
    END
END FOREACH;

FOREACH WITH HOLD
    SELECT cod_ramo,
	       nombre,
		   total_pri_sus,
		   total_pri_ret,
		   total_pri_ced,
		   total_prima_neta_ret,
		   comision_corredor,
		   impuesto,
		   comision_rea_ced
   	  INTO _cod_ramo,
           v_nombre,
		   v_total_prima_sus,
		   v_total_prima_ret,
		   v_total_prima_ced,
		   v_total_prima_neta_ret,
		   v_comision,
		   _impuesto,
		   _comision_rea_ced
   	  FROM tmp_prod2
  ORDER BY cod_ramo

	 SELECT SUM(pagado_bruto),
			SUM(pagado_neto),
			SUM(reserva_neto)
	   INTO	_siniestro_pagado,
		    _pagado_neto,
			_reserva_neto
	   FROM	tmp_sinis
	  WHERE seleccionado = 1
	  	AND cod_ramo     = _cod_ramo;

	 SELECT SUM(cont_facultativo),
			SUM(cont_otros)
	   INTO	_cont_fac,
		    _cont_otros
	   FROM	tmp_prod
	  WHERE seleccionado = 1
	  	AND cod_ramo     = _cod_ramo;

	 If _siniestro_pagado is null Then
		let _siniestro_pagado = 0;
	 end if
	 If _pagado_neto is null Then
		let _pagado_neto = 0;
	 end if
	 If _reserva_neto is null Then
		let _reserva_neto = 0;
	 end if

	 LET _res_tec = v_total_prima_neta_ret - (v_comision + _impuesto - _comision_rea_ced) - (_pagado_neto + _reserva_neto);

	 If _res_tec is null Then
		let _res_tec = 0;
	 end if

  RETURN  v_nombre,
   		  v_total_prima_sus,
		  v_total_prima_ret,
		  v_total_prima_ced,
		  v_compania_nombre,
		  v_filtros,
		  v_total_prima_neta_ret,
		  v_comision,
		  _impuesto,
		  _comision_rea_ced,
		  _siniestro_pagado,
		  _pagado_neto,
		  _reserva_neto,
		  _res_tec,
		  _cont_fac,
		  _cont_otros
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;
DROP TABLE tmp_sinis;

END PROCEDURE                                                                                                                                                 
