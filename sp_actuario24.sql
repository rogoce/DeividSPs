DROP procedure sp_actuario24;

CREATE procedure "informix".sp_actuario24(a_periodo1 char(7), a_periodo2 char(7), a_serie smallint)
RETURNING 	 smallint,char(30),char(30),smallint,char(50),dec(16,2),dec(16,2), dec(16,2),dec(16,2),dec(16,2),char(20),char(30),
			 char(30), date,date, date,date,char(10),date,char(18),char(20), dec(16,2),dec(16,2),dec(16,2),
			 dec(16,2), dec(16,2), dec(16,2),dec(16,2),dec(16,2),char(50),char(50), dec(16,2), dec(16,2), dec(16,2),char(30),dec(16,2),dec(16,2),
			 dec(16,2), char(30),dec(16,2),dec(16,2),dec(16,2), char(30),dec(16,2), dec(16,2),dec(16,2),char(30),dec(16,2),dec(16,2),dec(16,2),
			 char(30),dec(16,2),dec(16,2),dec(16,2),char(30),dec(16,2),dec(16,2),dec(16,2),char(30),char(10),char(50),char(10),dec(16,2),char(10),
			 dec(16,2),char(50),varchar(50),varchar(50),varchar(50),integer,integer,dec(16,2),dec(16,2);



--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO AUTO
---  Armando Moreno M.
--------------------------------------------

BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_no_documento                CHAR(20);
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
	DEFINE _cobertura                         CHAR(50);
	DEFINE _cod_cobertura                     CHAR(5);
	DEFINE _cod_agente                        CHAR(5);
	DEFINE _corredor 						  VARCHAR(50);
	DEFINE _cod_taller                        CHAR(10);
	DEFINE _taller                            VARCHAR(50);
	DEFINE _ajust_interno                     CHAR(3);
	DEFINE _perito                        	  VARCHAR(50);
	DEFINE _cnt_piezas_cam                    INT;
	DEFINE _cnt_piezas_rep                    INT;
	DEFINE _descuenta_ded                     dec(16,2);
	DEFINE _monto_legal                       dec(16,2);

    SET ISOLATION TO DIRTY READ; 
	
    let _ld_p_gas = 0;
    let _ld_p_comp = 0;
    let _ld_p_col = 0;
    let _ld_p_inc = 0;
    let _ld_p_rob = 0;
    let _ld_p_les = 0;
    let _ld_p_dan = 0;
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
	let _no_reclamo = "";
	let _descuenta_ded = 0;
	let	_monto_legal   = 0;

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


BEGIN

DEFINE _prima_suscrita DECIMAL(16,2);

FOREACH 

	SELECT e.prima_suscrita,
		   e.no_poliza
	  INTO	_prima_suscrita,
			_no_poliza
	  FROM endedmae e, emipomae b
	 WHERE e.no_poliza = b.no_poliza
	   and  e.cod_compania = '001'
	   AND e.actualizado  = 1
	   AND e.periodo     >= a_periodo1
	   AND e.periodo     <= a_periodo2
	   and b.cod_ramo = '002'
	   and b.actualizado = 1

		INSERT INTO tmp_montos(
		no_poliza,           
		prima_suscrita
		)
		VALUES(
		_no_poliza,
		_prima_suscrita
		);

END FOREACH

END

-- Primas Pagadas

BEGIN

DEFINE _no_remesa    CHAR(10);     
DEFINE _prima_pagada DEC(16,2);

FOREACH
 SELECT	no_poliza,
        prima_neta
   INTO	_no_poliza,
        _prima_pagada
   FROM cobredet
  WHERE	cod_compania = '001'
  	AND	actualizado  = 1
    AND tipo_mov IN ('P', 'N')
    AND periodo     >= a_periodo1 
    AND periodo     <= a_periodo2
	AND renglon     <> 0

	SELECT porc_partic_coas
	  INTO _porcentaje
	  FROM emicoama
	 WHERE no_poliza    = _no_poliza
	   AND cod_coasegur = _cod_coasegur;
	   
	IF _porcentaje IS NULL THEN
		LET _porcentaje = 100;
	END IF	    

	LET _prima_pagada = _prima_pagada / 100 * _porcentaje;

	INSERT INTO tmp_montos(
	no_poliza,           
	prima_pagada
	)
	VALUES(
	_no_poliza,
	_prima_pagada
	);

END FOREACH

END

let v_filtros = sp_rec139("001","001",a_periodo1,a_periodo2,"*","*","002;","*","*","*","*","*");

delete from deivid_tmp:sinis08;

foreach

	SELECT no_reclamo
	  INTO _no_reclamo
	  FROM tmp_incurrido
	 where no_reclamo is not null
     group by no_reclamo
     order by no_reclamo

	 select fecha_siniestro,
	        numrecla,
			perd_total,
			no_unidad,
			cod_evento,
			no_poliza,
			cod_taller,
			ajust_interno
	   into _fecha_siniestro,
	        _numrecla,
			_perd_total,
			v_no_unidad,
			_cod_evento,
			_no_poliza,
			_cod_taller,
			_ajust_interno
	   from recrcmae
	  where no_reclamo = _no_reclamo;

    select nombre
	  into _perito
	  from recajust
	 where cod_ajustador = _ajust_interno;

	SELECT no_poliza,
		   no_documento,
		   vigencia_inic,
	       vigencia_final,
	       fecha_cancelacion,
		   cod_sucursal,
		   fecha_suscripcion,
		   cod_subramo,
		   cod_ramo,
		   serie,
		   prima_bruta,
		   no_pagos
	  INTO v_no_poliza,
	 	   v_no_documento,
	 	   v_vigencia_inic,
	       v_vigencia_final,
	       v_fecha_cancel,
		   _cod_sucursal,
		   _fecha_suscripcion,
		   _ls_subramo,
		   _cod_ramo,
		   _serie,
		   _prima_bruta,
		   _no_pagos
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

     foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

        exit foreach;
	 end foreach

     select nombre
	   into _corredor
	   from agtagent
	  where cod_agente = _cod_agente;

	 if _cod_ramo = '002' then
	 else
		continue foreach;
	 end if

    foreach
	   --Leer Cobertura
	    select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		select nombre
		  into _cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

	   let _cod_taller = null;
	   let _cod_tipoveh = null;
	   let _uso_auto = null;
	   let v_no_motor = null;
	   let v_cod_marca = null;
	   let v_cod_modelo = null;
	   let v_ano_auto = null;
	   let v_placa = null;
        
		 select	cod_taller, no_motor
		   into _cod_taller, v_no_motor
		   from recrcmae
		  where no_reclamo = _no_reclamo;

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

		  let _cod_tipoveh = null;

 	      SELECT cod_tipoveh,
				 uso_auto
	        INTO _cod_tipoveh,
				 _uso_auto
	        FROM emiauto
	       WHERE no_poliza = _no_poliza
 	         AND no_unidad = v_no_unidad;

          if _cod_tipoveh is null then
			foreach
	 	      SELECT cod_tipoveh,
					 uso_auto
		        INTO _cod_tipoveh,
					 _uso_auto
		        FROM endmoaut
		       WHERE no_poliza = _no_poliza
	 	         AND no_unidad = v_no_unidad
	 	       order by no_endoso desc
	 	       
	 	       exit foreach;

			end foreach
		  end if

        let _taller = null;

	    select nombre
		  into _taller
		  from cliclien
		 where cod_cliente =  _cod_taller;

		 select nombre
		   into _n_evento
		   from recevent
		  where cod_evento = _cod_evento;

		 if _perd_total = 1 then
			let _perdida = 'PERDIDA TOTAL';
		 else
			let _perdida = 'PERDIDA PARCIAL';
		 end if

	   let _monto_legal   = 0;
	   let _descuenta_ded = 0;

	  SELECT SUM(rectrcon.monto)
		INTO _descuenta_ded
		FROM rectrcon  
	   WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
                                      FROM rectrmae  
                                     WHERE rectrmae.no_reclamo = _no_reclamo  )) AND  
         									( rectrcon.cod_concepto = "006" )   ;

	  SELECT SUM(rectrcon.monto)
		INTO _monto_legal
		FROM rectrcon  
	   WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
                                      FROM rectrmae  
                                     WHERE rectrmae.no_reclamo = _no_reclamo  )) AND  
         									( rectrcon.cod_concepto = "012" )   ;


		  SELECT SUM(rectrcon.monto)
			INTO _monto_repuestos
			FROM rectrcon  
		   WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
	                                           FROM rectrmae, rectrcob  
	                                          WHERE rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                            AND rectrcob.monto <> 0)) AND  
	         									( rectrcon.cod_concepto = "017" )    ;

		   SELECT SUM(rectrcon.monto)
			 INTO _monto_obra
			 FROM rectrcon  
			WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
	                                            FROM rectrmae, rectrcob  
	                                           WHERE rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                             AND rectrcob.monto <> 0)) AND  
	         									( rectrcon.cod_concepto in ("013","003","001") )   ;


			--MECANICA

		   SELECT SUM(rectrcon.monto)
			 INTO _monto_mecanica
			 FROM rectrcon  
			WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
	                                            FROM rectrmae, rectrcob  
	                                           WHERE rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                             AND rectrcob.monto <> 0)) AND  
													( rectrcon.cod_concepto = "013" )   ;

			 --CHAPISTERIA
			   
			 SELECT SUM(rectrcon.monto)
			   INTO _monto_chapis
			   FROM rectrcon  
			  WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
	                                            FROM rectrmae, rectrcob  
	                                           WHERE rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                             AND rectrcob.monto <> 0)) AND  
	         									( rectrcon.cod_concepto = "003" )   ;

			--AIRE

			SELECT SUM(rectrcon.monto)
			  INTO _monto_aire
			  FROM rectrcon  
			 WHERE ( rectrcon.no_tranrec IN (  SELECT rectrmae.no_tranrec  
	                                            FROM rectrmae, rectrcob  
	                                           WHERE rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                             AND rectrcob.monto <> 0)) AND  
	         									( rectrcon.cod_concepto = "001" );
			   

			   
		SELECT descripcion
		  INTO _sucursal
		  FROM insagen
		 WHERE codigo_agencia  = _cod_sucursal
		   AND codigo_compania = "001";
	   
	    SELECT nombre
		  INTO v_subramo
		  FROM prdsubra
		 WHERE cod_ramo = "002" 
		   AND cod_subramo = _ls_subramo;
	   

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


		  select min(no_endoso)
			into _no_endoso 
			from endeduni
			where no_poliza = v_no_poliza
			and no_unidad = v_no_unidad;

	      SELECT suma_asegurada,
		         cod_producto
	        INTO v_suma_asegurada,
			     _cod_producto
	        FROM endeduni
	       WHERE no_poliza = v_no_poliza
		     AND no_unidad = v_no_unidad
		     AND no_endoso = _no_endoso;

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
		  let _ld_p_gas = 0;
		  let _ld_p_comp = 0;
		  let _ld_p_col = 0;
		  let _ld_p_inc = 0;
		  let _ld_p_rob = 0;
		  let _ld_p_les = 0;
		  let _ld_p_dan = 0;
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
		  let _ls_ded_comp  = "";
		  let _ls_ded_col	 = "";
		  let _ls_ded_inc	 = "";
		  let _ls_ded_rob	 = "";
		  let _ls_ded_les	 = "";
		  let _ls_ded_dan	 = "";
		  let _ls_ded_gas   = "";	

		  SELECT sum(prima_neta),
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

		   foreach

		      SELECT prima_anual,
		             limite_1,
				     limite_2,
				     deducible
			 	INTO _ld_p_les,
			     	 _ld_lim1_les,
				  	 _ld_lim2_les,
				  	 _ls_ded_les
			 	FROM emipocob
		       WHERE no_poliza     = v_no_poliza
		         AND no_unidad     = v_no_unidad
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
				FROM emipocob
		       WHERE no_poliza     = v_no_poliza
		         AND no_unidad     = v_no_unidad
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
			 	FROM emipocob
		       WHERE no_poliza     = v_no_poliza
		         AND no_unidad     = v_no_unidad
		         AND cod_cobertura IN("00107","01028") --Gastos Med
			
		      exit foreach;
		   end foreach

		   foreach

			   SELECT prima_anual,
			          limite_1,
					  limite_2,
					  deducible
				 INTO _ld_p_comp,
				      _ld_lim1_comp,
					  _ld_lim2_comp,
					  _ls_ded_comp
				 FROM emipocob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
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
				 FROM emipocob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
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
				 FROM emipocob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
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
				 FROM emipocob
			    WHERE no_poliza     = v_no_poliza
			      AND no_unidad     = v_no_unidad
			      AND cod_cobertura IN ("00901","00103") --Robo
				
			   exit foreach;
		   end foreach	

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

			SELECT SUM(prima_suscrita),	
			       SUM(prima_pagada)
			  INTO _prima_suscrita,		
				   v_prima_cobrada
			  FROM tmp_montos
			 WHERE no_poliza = _no_poliza;

	        if _prima_bruta is null or _prima_bruta = 0 then
				let _prima_bruta = 1;
			end if

	        if _no_pagos is null or _no_pagos = 0 then
				let _no_pagos = 1;
			end if

	       	LET _no_pagado = v_prima_cobrada / (_prima_bruta / _no_pagos);

			select count(*)
			  into _saber
			  from deivid_tmp:sinis08
			 where poliza = v_no_documento;

			if _saber > 0 then
				let _prima_suscrita = 0;
				let v_prima_cobrada = 0;
			end if

	        let _incurrido_total = 0;


			SELECT SUM(recordde.cantidad)
			  INTO _cnt_piezas_cam
			  FROM recordde  
			 WHERE ( recordde.no_orden IN (  SELECT recordma.no_orden  
	                                            FROM recordma, rectrmae, rectrcob   
	                                           WHERE recordma.no_tranrec = rectrmae.no_tranrec AND recordma.tipo_ord_comp = "C" 
	                                             AND rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                             AND rectrcob.monto <> 0));

			SELECT SUM(recordde.cantidad)
			  INTO _cnt_piezas_rep
			  FROM recordde  
			 WHERE ( recordde.no_orden IN (  SELECT recordma.no_orden  
	                                            FROM recordma, rectrmae, rectrcob   
	                                           WHERE recordma.no_tranrec = rectrmae.no_tranrec AND recordma.tipo_ord_comp = "R" 
	                                             AND rectrmae.no_tranrec = rectrcob.no_tranrec AND rectrmae.no_reclamo = _no_reclamo AND rectrcob.cod_cobertura = _cod_cobertura 
	                                             AND rectrcob.monto <> 0));

			SELECT SUM(pagado_bruto),
			       SUM(reserva_bruto)
			  into _pagado_total,
				   _reserva_total
			  FROM tmp_incurrido
			 where no_reclamo    = _no_reclamo
			   and cod_cobertura = _cod_cobertura;


	           let _incurrido_total = _pagado_total + _reserva_total;

		 	   INSERT INTO deivid_tmp:sinis08(
			   serie, marca, modelo, ano, tipo_vehiculo, suma_asegurada, tasa_p_anual, tasa_p_neta, prima_casco_neta, prima_casco_anual, poliza, sucursal, no_motor,
			   fecha_suscripcion, fecha_cancelacion, vigencia_desde, vigencia_hasta, tipo, fecha_siniestro, no_siniestro, tipo_perdida, monto_pendiente, monto_pagado,
			   monto_repuestos, monto_manoobra, monto_incurrido, monto_aire, monto_chapisteria, monto_mecanica, evento, subramo, prima_lesi, limite_1_lesi, limite_2_lesi,
			   ded_lesi, prima_dan,limite_1_dan,limite_2_dan, ded_dan, prima_gasto, limite_1_gasto,limite_2_gasto, ded_gasto, prima_comp, limite_1_comp,limite_2_comp,ded_comp,
			   prima_colis,	limite_1_colis,	limite_2_colis,	ded_colis, prima_inc,limite_1_inc, limite_2_inc, ded_inc, prima_robo, limite_1_robo, limite_2_robo,ded_robo,
			   uso_auto, producto, grupo, prima_cobrada, no_reclamo,prima_suscrita, cobertura, corredor, taller,perito,	cnt_piezas_rep,	cnt_piezas_cam,monto_legal,descuenta_ded
			   )
			   VALUES(
			   _serie, v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo,v_suma_asegurada, _tasa_p_anual, _tasa_p_neta,_ld_prima_anter,	_prima_anual,v_no_documento,
			   _sucursal, v_no_motor,_fecha_suscripcion, v_fecha_cancel, v_vigencia_inic,v_vigencia_final,_tipo, _fecha_siniestro,_numrecla, _perdida, _reserva_total,
			   _pagado_total, _monto_repuestos,_monto_obra, _incurrido_total, _monto_aire, _monto_chapis, _monto_mecanica, _n_evento, v_subramo, _ld_p_les,	_ld_lim1_les,
			   _ld_lim2_les, _ls_ded_les,_ld_p_dan,_ld_lim1_dan, _ld_lim2_dan, _ls_ded_dan,_ld_p_gas, _ld_lim1_gas,	_ld_lim2_gas, _ls_ded_gas, _ld_p_comp,_ld_lim1_comp,
			   _ld_lim2_comp,_ls_ded_comp,_ld_p_col, _ld_lim1_col, _ld_lim2_col, _ls_ded_col, _ld_p_inc, _ld_lim1_inc, _ld_lim2_inc, _ls_ded_inc, _ld_p_rob, _ld_lim1_rob,
			   _ld_lim2_rob, _ls_ded_rob, v_uso, v_producto, v_grupo, v_prima_cobrada, _no_reclamo, _prima_suscrita, _cobertura, _corredor,_taller, _perito, _cnt_piezas_rep,
			   _cnt_piezas_cam, _monto_legal, _descuenta_ded);
															   
   end foreach

end foreach

foreach
	  select serie,marca,modelo,ano,tipo_vehiculo,suma_asegurada,tasa_p_anual,tasa_p_neta,prima_casco_neta,prima_casco_anual,poliza,sucursal,no_motor,fecha_suscripcion,
			 fecha_cancelacion, vigencia_desde, vigencia_hasta,tipo,fecha_siniestro,no_siniestro,tipo_perdida,monto_pendiente,monto_pagado,monto_repuestos,monto_manoobra,
			 monto_incurrido,monto_aire,monto_chapisteria, monto_mecanica, evento,subramo,prima_lesi,limite_1_lesi,limite_2_lesi,ded_lesi,prima_dan, limite_1_dan,limite_2_dan,
			 ded_dan,prima_gasto,limite_1_gasto,limite_2_gasto, ded_gasto,prima_comp,limite_1_comp,limite_2_comp,ded_comp,prima_colis,limite_1_colis,limite_2_colis,ded_colis,
			 prima_inc, limite_1_inc, limite_2_inc, ded_inc,prima_robo, limite_1_robo,limite_2_robo,ded_robo,uso_auto,producto,grupo,prima_cobrada, no_reclamo,prima_suscrita,
			 cobertura, corredor,taller,perito, cnt_piezas_rep, cnt_piezas_cam, monto_legal,descuenta_ded
        into _serie,v_nom_marca,v_nom_modelo,v_ano_auto, _tipo_vehiculo,v_suma_asegurada,_tasa_p_anual, _tasa_p_neta,_ld_prima_anter,_prima_anual,v_no_documento,_sucursal,
			 v_no_motor, _fecha_suscripcion,v_fecha_cancel, v_vigencia_inic,v_vigencia_final,_tipo,_fecha_siniestro,_numrecla,_perdida, _reserva_total,_pagado_total,_monto_repuestos,
			 _monto_obra, _incurrido_total, _monto_aire,_monto_chapis,_monto_mecanica,_n_evento,v_subramo, _ld_p_les, _ld_lim1_les, _ld_lim2_les,_ls_ded_les,_ld_p_dan,_ld_lim1_dan,
			 _ld_lim2_dan, _ls_ded_dan,_ld_p_gas,_ld_lim1_gas,_ld_lim2_gas, _ls_ded_gas,_ld_p_comp, _ld_lim1_comp,_ld_lim2_comp,_ls_ded_comp,_ld_p_col,_ld_lim1_col,_ld_lim2_col,
			 _ls_ded_col,_ld_p_inc,_ld_lim1_inc,_ld_lim2_inc,_ls_ded_inc,_ld_p_rob,_ld_lim1_rob,_ld_lim2_rob,_ls_ded_rob,v_uso,v_producto,v_grupo,v_prima_cobrada,_no_reclamo,
			 _prima_suscrita,_cobertura,_corredor,_taller,_perito,_cnt_piezas_rep,_cnt_piezas_cam,_monto_legal,_descuenta_ded
		from deivid_tmp:sinis08

	  return _serie,v_nom_marca,v_nom_modelo,v_ano_auto,_tipo_vehiculo,v_suma_asegurada,_tasa_p_anual, _tasa_p_neta,_ld_prima_anter,_prima_anual,v_no_documento,_sucursal,
			 v_no_motor, _fecha_suscripcion,v_fecha_cancel, v_vigencia_inic,v_vigencia_final,_tipo,_fecha_siniestro,_numrecla,_perdida, _reserva_total,_pagado_total,_monto_repuestos,
			 _monto_obra, _incurrido_total, _monto_aire,_monto_chapis,_monto_mecanica,_n_evento,v_subramo, _ld_p_les, _ld_lim1_les, _ld_lim2_les,_ls_ded_les,_ld_p_dan,_ld_lim1_dan,
			 _ld_lim2_dan, _ls_ded_dan,_ld_p_gas,_ld_lim1_gas,_ld_lim2_gas, _ls_ded_gas,_ld_p_comp, _ld_lim1_comp,_ld_lim2_comp,_ls_ded_comp,_ld_p_col,_ld_lim1_col,_ld_lim2_col,
			 _ls_ded_col,_ld_p_inc,_ld_lim1_inc,_ld_lim2_inc,_ls_ded_inc,_ld_p_rob,_ld_lim1_rob,_ld_lim2_rob,_ls_ded_rob,v_uso,v_producto,v_grupo,v_prima_cobrada,_no_reclamo,
			 _prima_suscrita,_cobertura,_corredor,_taller,_perito,_cnt_piezas_rep,_cnt_piezas_cam,_monto_legal,_descuenta_ded  with resume;


end foreach

drop table tmp_montos;
drop table tmp_incurrido;


END
END PROCEDURE;
