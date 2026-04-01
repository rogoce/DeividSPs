-- DROP procedure sp_pol_tec;

 CREATE procedure "informix".sp_pol_tec()
   RETURNING char(20),char(15);
 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO AUTO
---  Armando Moreno M.
--------------------------------------------

 BEGIN

    DEFINE v_no_poliza                        CHAR(10);
    DEFINE v_no_documento                     CHAR(20);
    DEFINE v_vigencia_inic					  DATE;
    DEFINE v_vigencia_final					  DATE;
    DEFINE v_fecha_cancel   				  DATE;
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
	DEFINE _cnt								  INTEGER;
	DEFINE _tipo                              CHAR(10);
	DEFINE _tipo_vehiculo                     CHAR(50);
	DEFINE _ld_deduc_anter					  dec(16,2);
	DEFINE _prima_anual                       dec(16,2);
	DEFINE _ld_prima_anter					  dec(16,2);
	DEFINE _tasa_p_anual					  dec(16,2);
	DEFINE _tasa_p_neta						  dec(16,2);
	DEFINE _fecha_suscripcion                 DATE;
	DEFINE _cod_agente                        char(5);
	define _n_corredor						  char(50);
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
	DEFINE _ld_p_rem						  dec(16,2);
	DEFINE _ld_lim1_rem						  dec(16,2);
	DEFINE _ld_lim2_rem						  dec(16,2);
	DEFINE _ls_ded_rem						  char(30);
	DEFINE _ld_p_asi						  dec(16,2);
	DEFINE _ld_lim1_asi						  dec(16,2);
	DEFINE _ld_lim2_asi						  dec(16,2);
	DEFINE _ls_ded_asi						  char(30);
    DEFINE _prima_bruta                       dec(16,2);
    DEFINE _no_pagos 						  smallint;
    DEFINE _no_pagado 						  dec(16,2);
	DEFINE _porcentaje						  dec(7,4);
	DEFINE _ld_p_avi						  dec(16,2);
	DEFINE _ld_lim1_avi						  dec(16,2);
	DEFINE _ld_lim2_avi						  dec(16,2);
	DEFINE _ls_ded_avi						  char(30);
	DEFINE _ld_p_mte						  dec(16,2);
	DEFINE _ld_lim1_mte						  dec(16,2);
	DEFINE _ld_lim2_mte						  dec(16,2);
	DEFINE _ls_ded_mte						  char(30);
	DEFINE _ld_p_inv						  dec(16,2);
	DEFINE _ld_lim1_inv						  dec(16,2);
	DEFINE _ld_lim2_inv						  dec(16,2);
	DEFINE _ls_ded_inv						  char(30);
    DEFINE _prima                             dec(16,2);
	define _estatus                           smallint;
	define _estatus_char                      char(15);

    SET ISOLATION TO DIRTY READ;
    
    let _ld_p_gas = 0;
    let _ld_p_comp = 0;
    let _ld_p_col = 0;
    let _ld_p_inc = 0;
    let _ld_p_rob = 0;
    let _ld_p_les = 0;
    let _ld_p_dan = 0;
	let	_ld_p_rem	 = 0;
	let	_ld_lim1_rem = 0;
	let	_ld_lim2_rem = 0;
	let	_ld_p_asi	 = 0;
	let	_ld_lim1_asi = 0;
	let	_ld_lim2_asi = 0;
	let	_ld_lim1_comp = 0;
	let	_ld_lim2_comp = 0;
	let	_ld_lim1_col  = 0;	
	let	_ld_lim2_col  = 0;	
	let	_ld_lim1_inc  = 0;	
	let	_ld_lim2_inc  = 0;	
	let	_ld_lim1_rob  = 0;	
	let	_ld_lim2_rob  = 0;	
	let	_ld_lim1_les  = 0;	
	let	_ld_lim2_les  = 0;	
	let	_ld_lim1_dan  = 0;	
	let	_ld_lim2_dan  = 0;	
	let	_ld_lim1_gas  = 0;	
	let	_ld_lim2_gas  = 0;
	let	_ls_ded_comp  =	"";
	let	_ls_ded_col	  = "";
	let	_ls_ded_inc	  =	"";
	let	_ls_ded_rob	  =	"";
	let	_ls_ded_les	  =	"";
	let	_ls_ded_dan	  =	"";
	let _ls_ded_gas   = "";	
	let _ls_ded_rem	  = "";
	let _ls_ded_asi   = "";


FOREACH WITH HOLD

       SELECT no_poliza,
       		  no_documento,
       		  estatus_poliza,
              vigencia_final,
              fecha_cancelacion,
			  cod_sucursal,
			  fecha_suscripcion,
			  cod_ramo,
			  cod_subramo,
			  serie,
			  prima,
			  prima_bruta,
			  no_pagos
         INTO v_no_poliza,
         	  v_no_documento,
         	  _estatus,
              v_vigencia_final,
              v_fecha_cancel,
			  _cod_sucursal,
			  _fecha_suscripcion,
			  _cod_ramo,
			  _ls_subramo,
			  _serie,
			  _prima,
			  _prima_bruta,
			  _no_pagos
         FROM emipomae
        WHERE cod_ramo = '002'
		  AND actualizado = 1

	   foreach

	       SELECT cod_agente
	         INTO _cod_agente
	         FROM emipoagt
	        WHERE no_poliza = v_no_poliza

		  exit foreach;
	   end foreach

	 IF _cod_agente = '00180' then
	 else
		 continue foreach;
	 end if
	   if _estatus = 1 then
			let _estatus_char = 'Vigente';
	   elif _estatus = 2 then
			let _estatus_char = 'Cancelada';
	   elif _estatus = 3 then
			let _estatus_char = 'Vencida';
	   end if

       FOREACH 
          SELECT no_unidad,
          		 suma_asegurada,
				 cod_producto
            INTO v_no_unidad,
            	 v_suma_asegurada,
				 _cod_producto
            FROM emipouni
           WHERE no_poliza = v_no_poliza

		   LET _ld_deduc_anter = 0.00;
		   LET _prima_anual    = 0.00;

		   SELECT count(*)
			 INTO _cnt
			 FROM emipocob
		    WHERE no_poliza     = v_no_poliza
		      AND no_unidad     = v_no_unidad
		      AND cod_cobertura IN ("01200");

		   if _cnt > 0 then

			 return v_no_documento,_estatus_char with resume;

		   else
			continue foreach;
		   end if

       END FOREACH 
END FOREACH

END
END PROCEDURE;
