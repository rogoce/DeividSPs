 DROP procedure sp_actuario18;
 -- Copia de sp_actuario
 CREATE procedure "informix".sp_actuario18(a_serie smallint, periodo1 char(7), periodo2 char(7), a_ramo char(3))
   RETURNING smallint, char(30), char(30), smallint, char(50), decimal(16,2), decimal(16,2),decimal(16,2), decimal(16,2), decimal(16,2),
			 char(20), char(3), char(30), date, date, date, date, char(10),dec(16,2), dec(16,2),
			 dec(16,2),char(30), dec(16,2), dec(16,2), dec(16,2), char(30), dec(16,2), dec(16,2), dec(16,2), char(30), dec(16,2),
			 dec(16,2), dec(16,2), char(30), dec(16,2),dec(16,2), dec(16,2), char(30),dec(16,2), dec(16,2), dec(16,2),char(30),
			 dec(16,2), dec(16,2), dec(16,2), char(30),char(50), char(50), char(10),char(50), char(10), dec(16,2), dec(16,2),dec(16,2),
			 dec(16,2), char(30), dec(16,2), dec(16,2),dec(16,2),char(30), smallint,dec(16,2), dec(16,2), dec(16,2),dec(16,2),dec(16,2),
			 char(30),dec(16,2), dec(16,2), dec(16,2), char(30),dec(16,2),dec(16,2), dec(16,2),char(30),dec(16,2),char(5),char(7),
			 dec(16,2),char(1);
 
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
	DEFINE _periodo                           char(7);
	DEFINE v_no_endoso                        char(5);
    DEFINE _descuento                         dec(16,2);
	DEFINE _nueva_renov						  char(1);

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
	let _descuento    = 0.00;

	delete from carter08;



FOREACH WITH HOLD

       SELECT a.no_poliza,
	          a.no_endoso,
       		  a.no_documento,
       		  a.vigencia_inic,
              a.vigencia_final,
              b.fecha_cancelacion,
			  b.cod_sucursal,
			  a.fecha_emision,
			  b.cod_ramo,
			  b.cod_subramo,
			  b.serie,
			  a.prima,
			  a.prima_bruta,
			  a.no_pagos,
			  a.periodo,
			  a.descuento,
			  b.nueva_renov
         INTO v_no_poliza,
		      v_no_endoso,
         	  v_no_documento,
         	  v_vigencia_inic,
              v_vigencia_final,
              v_fecha_cancel,
			  _cod_sucursal,
			  _fecha_suscripcion,
			  _cod_ramo,
			  _ls_subramo,
			  _serie,
			  _prima,
			  _prima_bruta,
			  _no_pagos,
			  _periodo,
			  _descuento,
			  _nueva_renov
         FROM endedmae a, emipomae b
        WHERE a.no_poliza = b.no_poliza
          AND b.cod_ramo = a_ramo
		  AND a.actualizado = 1
		  AND a.periodo >= periodo1
		  AND a.periodo <= periodo2

	   if v_vigencia_final is null then
			continue foreach;
	   end if

       SELECT descripcion
         INTO _sucursal
         FROM insagen
        WHERE codigo_agencia  = _cod_sucursal
          AND codigo_compania = "001";
		  
	   SELECT nombre
	     INTO v_subramo
		 FROM prdsubra
		 WHERE cod_ramo = a_ramo 
		 AND   cod_subramo = _ls_subramo;
		  
	   SELECT count(*)
		 INTO _cnt
	     FROM emipouni
	    WHERE no_poliza = v_no_poliza;

	   let _tipo = '';

	   if _cnt > 1 then
			let _tipo = 'COLECTIVO';
	   else
			let _tipo = 'INDIVIDUAL';
	   end if

	   foreach

	       SELECT cod_agente
	         INTO _cod_agente
	         FROM emipoagt
	        WHERE no_poliza = v_no_poliza

		  exit foreach;
	   end foreach

       SELECT nombre
         INTO _n_corredor
         FROM agtagent
        WHERE cod_agente = _cod_agente;

       FOREACH 
          SELECT no_unidad,
          		 suma_asegurada,
				 cod_producto
            INTO v_no_unidad,
            	 v_suma_asegurada,
				 _cod_producto
            FROM endeduni
           WHERE no_poliza = v_no_poliza
		     AND no_endoso = v_no_endoso

          SELECT no_motor,
				 cod_tipoveh,
				 uso_auto
            INTO v_no_motor,
			     _cod_tipoveh,
				 _uso_auto
            FROM emiauto
           WHERE no_poliza = v_no_poliza
             AND no_unidad = v_no_unidad;

          SELECT nombre
		    INTO v_producto
			FROM prdprod
		   WHERE cod_producto = _cod_producto;

		  if v_no_motor is null then
			let v_no_motor = 'SIN MOTOR';
		  end if

          if _uso_auto = 'P' then
			let v_uso = 'PARTICULAR';
		  elif _uso_auto = 'C' then
			let v_uso = 'COMERCIAL';
		  else
			let v_uso = 'NO TIENE';
		  end if

          SELECT nombre
            INTO _tipo_vehiculo
            FROM emitiveh
           WHERE cod_tipoveh = _cod_tipoveh;

		  if _tipo_vehiculo is null then
			let _tipo_vehiculo = 'SIN TIPO VEHICULO';
		  end if

          SELECT cod_marca,
          		 cod_modelo,
          		 ano_auto,
          		 placa
            INTO v_cod_marca,
            	 v_cod_modelo,
            	 v_ano_auto,
            	 v_placa
            FROM emivehic
           WHERE no_motor = v_no_motor;

          SELECT nombre
            INTO v_nom_modelo
            FROM emimodel
           WHERE cod_marca  = v_cod_marca
             AND cod_modelo = v_cod_modelo;

		  if v_nom_modelo is null then
			let v_nom_modelo = 'SIN MODELO';
		  end if

          SELECT nombre
            INTO v_nom_marca
            FROM emimarca
           WHERE cod_marca  = v_cod_marca;

		  if v_nom_marca is null then
			let v_nom_marca = 'SIN MARCA';
		  end if

		   LET _ld_deduc_anter = 0.00;
		   LET _prima_anual    = 0.00;

		   SELECT sum(prima_neta),		--> Verificar
		          sum(prima_anual)
			 INTO _ld_prima_anter,
			      _prima_anual
			 FROM emipocob
		    WHERE no_poliza     = v_no_poliza
		      AND no_unidad     = v_no_unidad
		      AND cod_cobertura IN ("00119", "00118", "00120", "00121", "00103", "00900","00901","00902");

		   if _ld_prima_anter is null then
				let _ld_prima_anter = 0.00;
				let _prima_anual    = 0.00;
		   end if

		   let _tasa_p_anual = 0;
		   let _tasa_p_neta  = 0;
		   if v_suma_asegurada <> 0 then
			   let _tasa_p_anual = _prima_anual / v_suma_asegurada;
			   let _tasa_p_neta  = _ld_prima_anter / v_suma_asegurada;
		   end if

		   -- Blanqueo
		   let _ld_p_gas = 0;
		   let _ld_p_comp = 0;
		   let _ld_p_col = 0;
		   let _ld_p_inc = 0;
		   let _ld_p_rob = 0;
		   let _ld_p_les = 0;
		   let _ld_p_dan = 0;
		   let _ld_p_rem = 0;
		   let _ld_lim1_comp = 0;
		   let _ld_lim2_comp = 0;
		   let _ld_lim1_col  = 0;	
		   let _ld_lim2_col  = 0;	
		   let _ld_lim1_inc  = 0;	
		   let _ld_lim2_inc  = 0;	
		   let _ld_lim1_rob  = 0;	
		   let _ld_lim2_rob  = 0;	
		   let _ld_lim1_les  = 0;	
		   let _ld_lim2_les  = 0;	
		   let _ld_lim1_dan  = 0;	
		   let _ld_lim2_dan  = 0;	
		   let _ld_lim1_gas  = 0;	
		   let _ld_lim2_gas  = 0;
		   let _ls_ded_comp  =	"";
		   let _ls_ded_col	  = "";
		   let _ls_ded_inc	  =	"";
		   let _ls_ded_rob	  =	"";
		   let _ls_ded_les	  =	"";
		   let _ls_ded_dan	  =	"";
		   let _ls_ded_gas   = "";
		   let v_prima_cobrada = 0.00;
		   let _ld_lim1_rem	= 0;
		   let _ld_lim2_rem	= 0;
		   let _ls_ded_rem	= "";
		   let _ld_p_avi	= 0;
		   let _ld_lim1_avi	= 0;
		   let _ld_lim2_avi	= 0;
		   let _ls_ded_avi	= "";
		   let _ld_p_mte	= 0;
		   let _ld_lim1_mte	= 0;
		   let _ld_lim2_mte	= 0;
		   let _ls_ded_mte	= "";
		   let _ld_p_inv	= 0;
		   let _ld_lim1_inv	= 0;
		   let _ld_lim2_inv	= 0;
		   let _ls_ded_inv	= "";

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_comp,
				      _ld_lim1_comp,
					  _ld_lim2_comp,
					  _ls_ded_comp
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN ("00118","00900") --comprensivo
				
			   exit foreach;
		   end foreach	

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_col,
				      _ld_lim1_col,
					  _ld_lim2_col,
					  _ls_ded_col
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN ("00119","00121") --colision
				
			   exit foreach;
		   end foreach	

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_inc,
				      _ld_lim1_inc,
					  _ld_lim2_inc,
					  _ls_ded_inc
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN ("00902","00120") --incendio
				
			   exit foreach;
		   end foreach	

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_rob,
				      _ld_lim1_rob,
					  _ld_lim2_rob,
					  _ls_ded_rob
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN ("00901","00103") --Robo
				
			   exit foreach;
		   end foreach	

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_les,
				      _ld_lim1_les,
					  _ld_lim2_les,
					  _ls_ded_les
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN("00102","01021") --Lesiones

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_dan,
				      _ld_lim1_dan,
					  _ld_lim2_dan,
					  _ls_ded_dan
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN("00113","01022") --Danos P.A.

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_gas,
				      _ld_lim1_gas,
					  _ld_lim2_gas,
					  _ls_ded_gas
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN("00107","01028") --Gastos Med

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_asi,
				      _ld_lim1_asi,
					  _ld_lim2_asi,
					  _ls_ded_asi
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura = "00117"    --Asist Med

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_rem,
				      _ld_lim1_rem,
					  _ld_lim2_rem,
					  _ls_ded_rem
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN("00104","00122") --reembolso por auto sust

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_avi,
				      _ld_lim1_avi,
					  _ld_lim2_avi,
					  _ls_ded_avi
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura IN("00907","01030") --asistencia vial

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_mte,
				      _ld_lim1_mte,
					  _ld_lim2_mte,
					  _ls_ded_mte
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura = "00123"    --Muerte Accidental

			   exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_inv,
				      _ld_lim1_inv,
					  _ld_lim2_inv,
					  _ls_ded_inv
				 FROM endedcob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
				  AND no_endoso     = v_no_endoso
			      AND cod_cobertura = "00108"    --Invalidez Total y permanente

			   exit foreach;
		   end foreach

		   if _ld_p_mte is null then
			let _ld_p_mte = 0;
		   end if
		   if _ld_p_inv is null then
			let _ld_p_inv = 0;
		   end if
		   if _ld_p_gas is null then
			let _ld_p_gas = 0;
		   end if
		   if _ld_p_comp is null then
			let _ld_p_comp = 0;
		   end if
		   if _ld_p_col is null then
			let _ld_p_col = 0;
		   end if
		   if _ld_p_inc is null then
			let _ld_p_inc = 0;
		   end if
		   if _ld_p_rob is null then
			let _ld_p_rob = 0;
		   end if
		   if _ld_p_les is null then
			let _ld_p_les = 0;
		   end if
		   if _ld_p_dan is null then
			let _ld_p_dan = 0;
		   end if
		   if _ld_p_rem is null then
			let _ld_p_rem = 0;
		   end if
		   if _ld_p_asi is null then
			let _ld_p_asi = 0;
		   end if
		   if _ld_p_avi is null then
			let _ld_p_avi = 0;
		   end if

		   -- Prima cobrada

		   let v_prima_cobrada = 0;
		   let _no_pagado      = 0;

		   -- Segmentando la informacion segun el actuario

           if _cod_ramo = '002' then
		   	if _cod_producto = '00313' OR _cod_producto = '00314' OR _cod_producto = '00340' THEN
				let v_grupo = 'AUTORC';
			elif _cod_producto = '00318' OR _cod_producto = '00282' OR _cod_producto = '00290' THEN
				let v_grupo = 'USADITO';
			else
				let v_grupo = 'CASCO';
            end if
		   else
			let v_grupo = 'SODA';
		   end if

			   if _sucursal is null then
				let _sucursal = '001';
			   end if

			   INSERT INTO carter08(
			   serie,
			   marca,
			   modelo,
			   ano,
			   tipo_vehiculo,
			   suma_asegurada,
			   tasa_p_anual,
			   tasa_p_neta,
			   prima_casco_neta,
			   prima_casco_anual,
			   poliza,
			   sucursal,
			   no_motor,
			   fecha_suscripcion,
			   fecha_cancelacion,
			   vigencia_desde,
			   vigencia_hasta,
			   tipo,
			   prima_comp,
			   limite_1_comp,
			   limite_2_comp,
			   ded_comp,
			   prima_colis,
			   limite_1_colis,
			   limite_2_colis,
			   ded_colis,
			   prima_inc,
			   limite_1_inc,
			   limite_2_inc,
			   ded_inc,
			   prima_robo,
			   limite_1_robo,
			   limite_2_robo,
			   ded_robo,
			   prima_lesi,
			   limite_1_lesi,
			   limite_2_lesi,
			   ded_lesi,
			   prima_dan,
			   limite_1_dan,
			   limite_2_dan,
			   ded_dan,
			   prima_gasto,
			   limite_1_gasto,
			   limite_2_gasto,
			   ded_gasto,
			   corredor,
			   subramo,
			   uso_auto,
			   producto,
			   grupo,
			   prima_cobrada,
			   prima_asi,
			   limite_1_asi,
			   limite_2_asi,
			   ded_asi,
			   prima_rem,
			   limite_1_rem,
			   limite_2_rem,
			   ded_rem,
			   no_pagos,
			   no_pagado,
			   prima_bruta,
			   prima_avi,
			   limite_1_avi,
			   limite_2_avi,
			   ded_avi,
			   prima_mte,
			   limite_1_mte,
			   limite_2_mte,
			   ded_mte,
			   prima_inv,
			   limite_1_inv,
			   limite_2_inv,
			   ded_inv,
			   subtotal,
			   no_endoso,
			   periodo,
			   descuento,
			   nueva_renov
			   )
			   VALUES(
			   a_serie,
			   v_nom_marca,
			   v_nom_modelo,
			   v_ano_auto,
			   _tipo_vehiculo,
			   v_suma_asegurada,
			   _tasa_p_anual,
			   _tasa_p_neta,
			   _ld_prima_anter,
			   _prima_anual,
			   v_no_documento,
			   _sucursal,
			   v_no_motor,
			   _fecha_suscripcion,
			   v_fecha_cancel,
			   v_vigencia_inic,
			   v_vigencia_final,
			   _tipo,
			   _ld_p_comp,
			   _ld_lim1_comp,
			   _ld_lim2_comp,
			   _ls_ded_comp,
			   _ld_p_col,
			   _ld_lim1_col,
			   _ld_lim2_col,
			   _ls_ded_col,
			   _ld_p_inc,
			   _ld_lim1_inc,
			   _ld_lim2_inc,
			   _ls_ded_inc,
			   _ld_p_rob,
			   _ld_lim1_rob,
			   _ld_lim2_rob,
			   _ls_ded_rob,
			   _ld_p_les,
			   _ld_lim1_les,
			   _ld_lim2_les,
			   _ls_ded_les,
			   _ld_p_dan,
			   _ld_lim1_dan,
			   _ld_lim2_dan,
			   _ls_ded_dan,
			   _ld_p_gas,
			   _ld_lim1_gas,
			   _ld_lim2_gas,
			   _ls_ded_gas,
			   _n_corredor,
			   v_subramo,
			   v_uso,
			   v_producto,
			   v_grupo,
			   v_prima_cobrada,
			   _ld_p_asi,
			   _ld_lim1_asi,
			   _ld_lim2_asi,
			   _ls_ded_asi,
			   _ld_p_rem,
			   _ld_lim1_rem,
			   _ld_lim2_rem,
			   _ls_ded_rem,
			   _no_pagos,
			   _no_pagado,
			   _prima_bruta,
			   _ld_p_avi,
			   _ld_lim1_avi,
			   _ld_lim2_avi,
			   _ls_ded_avi,
			   _ld_p_mte,
			   _ld_lim1_mte,
			   _ld_lim2_mte,
			   _ls_ded_mte,
			   _ld_p_inv,
			   _ld_lim1_inv,
			   _ld_lim2_inv,
			   _ls_ded_inv,
		       _prima,
			   v_no_endoso,
			   _periodo,
			   _descuento,
			   _nueva_renov
			   );
       END FOREACH 
END FOREACH

foreach
	select serie, marca, modelo, ano, tipo_vehiculo, suma_asegurada, tasa_p_anual, tasa_p_neta, prima_casco_neta, prima_casco_anual,
		   poliza, sucursal,no_motor, fecha_suscripcion, fecha_cancelacion,vigencia_desde, vigencia_hasta, tipo, prima_comp,limite_1_comp,
		   limite_2_comp, ded_comp, prima_colis,limite_1_colis,limite_2_colis,ded_colis,prima_inc,limite_1_inc,limite_2_inc, ded_inc, prima_robo,
		   limite_1_robo,limite_2_robo, ded_robo,prima_lesi,limite_1_lesi,limite_2_lesi, ded_lesi,prima_dan,limite_1_dan, limite_2_dan, ded_dan,
		   prima_gasto, limite_1_gasto,limite_2_gasto, ded_gasto, corredor, subramo, uso_auto, producto, grupo,prima_cobrada,prima_asi,limite_1_asi,
		   limite_2_asi, ded_asi,prima_rem,limite_1_rem,limite_2_rem,ded_rem,no_pagos,no_pagado, prima_bruta, prima_avi,limite_1_avi, limite_2_avi,
		   ded_avi, prima_mte,limite_1_mte,limite_2_mte,ded_mte,prima_inv,limite_1_inv,limite_2_inv,ded_inv, subtotal, no_endoso,periodo, descuento, nueva_renov
      into a_serie,v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo, v_suma_asegurada,_tasa_p_anual,_tasa_p_neta, _ld_prima_anter,_prima_anual,v_no_documento,
		   _sucursal, v_no_motor,_fecha_suscripcion,v_fecha_cancel, v_vigencia_inic,v_vigencia_final, _tipo,_ld_p_comp,_ld_lim1_comp, _ld_lim2_comp, _ls_ded_comp,
		   _ld_p_col,_ld_lim1_col,_ld_lim2_col, _ls_ded_col, _ld_p_inc,_ld_lim1_inc,_ld_lim2_inc, _ls_ded_inc, _ld_p_rob, _ld_lim1_rob,_ld_lim2_rob,_ls_ded_rob,
		   _ld_p_les, _ld_lim1_les,_ld_lim2_les,_ls_ded_les,_ld_p_dan,_ld_lim1_dan,_ld_lim2_dan,_ls_ded_dan,_ld_p_gas,_ld_lim1_gas,_ld_lim2_gas,_ls_ded_gas,_n_corredor,
		   v_subramo,v_uso,v_producto,v_grupo,v_prima_cobrada,_ld_p_asi,_ld_lim1_asi,_ld_lim2_asi,_ls_ded_asi,_ld_p_rem,_ld_lim1_rem,_ld_lim2_rem,_ls_ded_rem,_no_pagos,
		   _no_pagado,_prima_bruta,_ld_p_avi,_ld_lim1_avi,_ld_lim2_avi,_ls_ded_avi,_ld_p_mte,_ld_lim1_mte,_ld_lim2_mte,_ls_ded_mte,_ld_p_inv,_ld_lim1_inv,_ld_lim2_inv,
		   _ls_ded_inv,_prima,v_no_endoso,_periodo,_descuento,_nueva_renov
	  from carter08
	  
	  return a_serie, v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo, v_suma_asegurada, _tasa_p_anual,_tasa_p_neta, _ld_prima_anter, _prima_anual,
	  		 v_no_documento, _sucursal, v_no_motor, _fecha_suscripcion, v_fecha_cancel, v_vigencia_inic, v_vigencia_final, _tipo,_ld_p_comp, _ld_lim1_comp,
	  		 _ld_lim2_comp,_ls_ded_comp, _ld_p_col, _ld_lim1_col, _ld_lim2_col, _ls_ded_col, _ld_p_inc, _ld_lim1_inc, _ld_lim2_inc, _ls_ded_inc, _ld_p_rob,
			 _ld_lim1_rob, _ld_lim2_rob, _ls_ded_rob, _ld_p_les,_ld_lim1_les, _ld_lim2_les, _ls_ded_les,_ld_p_dan, _ld_lim1_dan, _ld_lim2_dan,_ls_ded_dan,
			 _ld_p_gas, _ld_lim1_gas, _ld_lim2_gas, _ls_ded_gas,_n_corredor, v_subramo, v_uso,v_producto, v_grupo, v_prima_cobrada, _ld_p_asi,_ld_lim1_asi,
			 _ld_lim2_asi, _ls_ded_asi, _ld_p_rem, _ld_lim1_rem,_ld_lim2_rem,_ls_ded_rem, _no_pagos,_no_pagado, _prima_bruta, _ld_p_avi,_ld_lim1_avi,_ld_lim2_avi,
			 _ls_ded_avi,_ld_p_mte, _ld_lim1_mte, _ld_lim2_mte, _ls_ded_mte,_ld_p_inv,_ld_lim1_inv, _ld_lim2_inv,_ls_ded_inv,_prima,v_no_endoso,_periodo,
			 _descuento,_nueva_renov with resume;
end foreach

END
END PROCEDURE;
