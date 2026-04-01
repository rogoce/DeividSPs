DROP procedure sp_rec172a;

CREATE procedure "informix".sp_rec172a(a_periodo1 char(7), a_periodo2 char(7))
RETURNING CHAR(3),CHAR(50),CHAR(20),CHAR(45),CHAR(10),DATE,DATE,DECIMAL(16,2),CHAR(18),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),VARCHAR(50); 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO AUTO
---  Armando Moreno M.
--------------------------------------------

BEGIN

    DEFINE v_no_poliza                   	  CHAR(10);
    DEFINE v_no_documento                	  CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_cancel   DATE;
    DEFINE v_contratante,v_placa              CHAR(10);
    DEFINE v_cod_ramo                         CHAR(3);
    DEFINE v_suma_asegurada                   DECIMAL(16,2);
    DEFINE v_descripcion                      CHAR(50);
    DEFINE v_no_unidad                        CHAR(5);
    DEFINE v_no_motor                         CHAR(30);
    DEFINE v_cod_marca                        CHAR(5);
    DEFINE v_cod_modelo                       CHAR(5);
    DEFINE v_ano_auto                         SMALLINT;
    DEFINE v_desc_nombre                      CHAR(100);
    DEFINE v_nom_modelo,v_nom_marca           CHAR(30);
    DEFINE v_descr_cia                        CHAR(50);
	DEFINE _cod_sucursal					  CHAR(3);
	DEFINE _cod_tipoveh						  CHAR(3);
	DEFINE _sucursal                          CHAR(30);
	DEFINE v_filtros                          CHAR(255);
	DEFINE _no_reclamo                        CHAR(10);
	DEFINE _monto_obra						  dec(16,2);
	DEFINE _monto_repuestos					  dec(16,2);
	DEFINE _monto_aire						  dec(16,2);
	DEFINE _monto_chapis					  dec(16,2);
	DEFINE _monto_mecanica					  dec(16,2);
	DEFINE _no_poliza                         CHAR(10);
	DEFINE _pagado_total                      dec(16,2);
	DEFINE _reserva_total                     dec(16,2);
	DEFINE _incurrido_total                   dec(16,2);
	DEFINE _fecha_siniestro                   dec(16,2);
	DEFINE _numrecla                          CHAR(18);
	DEFINE _perd_total                        SMALLINT;
	DEFINE _no_tranrec                        CHAR(10);
	DEFINE _fecha_suscripcion                 DATE;
	DEFINE _cnt								  INTEGER;
	DEFINE _tipo                              CHAR(10);
	DEFINE _tipo_vehiculo                     CHAR(50);
	DEFINE _ld_deduc_anter					  dec(16,2);
	DEFINE _prima_anual                       dec(16,2);
	DEFINE _ld_prima_anter					  dec(16,2);
	DEFINE _tasa_p_anual					  dec(16,2);
	DEFINE _tasa_p_neta						  dec(16,2);
	DEFINE _perdida                           char(20);
	define _n_evento                          char(50);
	define _cod_evento                        char(3);
	DEFINE _ld_p_les						  dec(16,2);
	DEFINE _ld_lim1_les						  dec(16,2);
	DEFINE _ld_lim2_les						  dec(16,2);
	DEFINE _ls_ded_les						  char(30);
	DEFINE _ld_p_dan						  dec(16,2);
	DEFINE _ld_lim1_dan						  dec(16,2);
	DEFINE _ld_lim2_dan						  dec(16,2);
	DEFINE _ls_ded_dan						  char(30);
	DEFINE _ld_p_gas						  dec(16,2);
	DEFINE _ld_lim1_gas						  dec(16,2);
	DEFINE _ld_lim2_gas						  dec(16,2);
	DEFINE _ls_ded_gas						  char(30);
	DEFINE _ld_p_comp						  dec(16,2);
	DEFINE _ld_lim1_comp					  dec(16,2);
	DEFINE _ld_lim2_comp					  dec(16,2);
	DEFINE _ls_ded_comp						  char(30);
	DEFINE _ld_p_col						  dec(16,2);
	DEFINE _ld_lim1_col						  dec(16,2);
	DEFINE _ld_lim2_col						  dec(16,2);
	DEFINE _ls_ded_col						  char(30);
	DEFINE _ld_p_inc						  dec(16,2);
	DEFINE _ld_lim1_inc						  dec(16,2);
	DEFINE _ld_lim2_inc						  dec(16,2);
	DEFINE _ls_ded_inc						  char(30);
	DEFINE _ld_p_rob						  dec(16,2);
	DEFINE _ld_lim1_rob						  dec(16,2);
	DEFINE _ld_lim2_rob						  dec(16,2);
	DEFINE _ls_ded_rob						  char(30);
	DEFINE _ls_subramo						  char(3);
	DEFINE v_subramo						  char(50);
	DEFINE _uso_auto                          char(1);
	DEFINE v_uso                   			  char(10);
	DEFINE _cod_producto                      char(5);
	DEFINE v_producto                         char(50);
	DEFINE v_grupo                            char(10);
	DEFINE _cod_ramo                          char(3);
	DEFINE v_prima_cobrada                    dec(16,2);
	DEFINE _serie                             smallint;
	DEFINE _porcentaje						  dec(7,4);
	DEFINE _prima_suscrita                    dec(16,2);
	define _cod_coasegur                      char(3);
	define _saber                             smallint;  
	define _no_endoso						  char(5);
    DEFINE _prima_bruta                       dec(16,2);
    DEFINE _no_pagos 						  smallint;
    DEFINE _no_pagado 						  dec(16,2);
	define _cant                          	  smallint;
    DEFINE v_desc_ramo                        CHAR(50);
    DEFINE v_asegurado                		  CHAR(45);
	DEFINE _cod_cobertura                     CHAR(5);
	DEFINE _desc_cobertura                    VARCHAR(50);

    SET ISOLATION TO DIRTY READ; 
	

CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto       DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		no_reclamo          CHAR(10)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza);

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = '001';

let v_filtros = sp_rec01("001","001",a_periodo1,a_periodo2,"*","*","005;","*","*","*","*","*");

insert into tmp_montos(
	   incurrido_bruto,
	   pagado_bruto,
	   reserva_bruto,
	   no_poliza,
	   no_reclamo
       )	
SELECT incurrido_bruto,
       pagado_bruto,
	   reserva_bruto,
       no_poliza,
	   no_reclamo
  FROM tmp_sinis
 where seleccionado = 1;

DROP TABLE tmp_sinis;

foreach

   SELECT  SUM(prima_suscrita),				 
	       SUM(prima_pagada),				 
		   SUM(incurrido_bruto),			 
		   SUM(pagado_bruto),
		   SUM(reserva_bruto),
		   no_reclamo			 	
	  INTO _prima_suscrita,					
		   v_prima_cobrada,
		   _incurrido_total,
		   _pagado_total,
		   _reserva_total,
		   _no_reclamo
	  FROM tmp_montos
	 where no_reclamo is not null
	 GROUP BY no_reclamo

{	SELECT no_reclamo
	  INTO _no_reclamo
	  FROM tmp_montos
	 where no_reclamo is not null
}

	 select fecha_siniestro,
	        numrecla,
			perd_total,
			no_unidad,
			cod_evento,
			no_poliza
	   into _fecha_siniestro,
	        _numrecla,
			_perd_total,
			v_no_unidad,
			_cod_evento,
			_no_poliza
	   from recrcmae
	  where no_reclamo = _no_reclamo;

    SELECT no_poliza,
		   no_documento,
		   vigencia_inic,
	       vigencia_final,
		   cod_ramo,
		   prima_suscrita,
		   cod_contratante
	  INTO v_no_poliza,
	 	   v_no_documento,
	 	   v_vigencia_inic,
	       v_vigencia_final,
		   _cod_ramo,
		   _prima_suscrita,
		   v_contratante
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
		   
       LET _cant = 0;

       SELECT COUNT(*)
	     INTO _cant
		 FROM emipocob
		WHERE no_poliza = _no_poliza
		  AND cod_cobertura in('00225','00885');

       IF _cant = 0 THEN
			CONTINUE FOREACH;
	   END IF

       FOREACH
	   	SELECT cod_cobertura
		  INTO _cod_cobertura
		  FROM emipocob
		 WHERE no_poliza = _no_poliza
		   AND cod_cobertura in('00225','00885')

        SELECT nombre
	      INTO _desc_cobertura
		  FROM prdcober
		 WHERE cod_cobertura = _cod_cobertura;

		 IF _cod_cobertura = '00225' OR _cod_cobertura = '00885' THEN
		 	EXIT FOREACH;
		 END IF

	   END FOREACH


       SELECT a.nombre
         INTO v_desc_ramo
         FROM prdramo a
        WHERE a.cod_ramo  = _cod_ramo;

       SELECT nombre
         INTO v_asegurado
         FROM cliclien
        WHERE cod_cliente = v_contratante;

   return _cod_ramo, v_desc_ramo, v_no_documento,
          v_asegurado, v_contratante, v_vigencia_inic, v_vigencia_final,
		  _prima_suscrita, _numrecla, _incurrido_total, _pagado_total, _reserva_total, _desc_cobertura with resume;

end foreach							  

drop table tmp_montos;

END
END PROCEDURE;
