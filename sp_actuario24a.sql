DROP procedure sp_actuario24a;

CREATE procedure "informix".sp_actuario24a(a_periodo1 char(7), a_periodo2 char(7))
RETURNING	char(30),char(30),smallint,char(50),dec(16,2),char(20),char(30),char(30),
		  	date,date,char(10),date,char(18),dec(16,2),char(20),char(50),char(50),
		  	char(30),char(10),char(50),char(1),char(50),char(50),dec(16,2),char(30),char(5);
 

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
	DEFINE _cod_vendedor                      char(3);
	DEFINE _n_zona,_n_ramo					  char(50);
	define _nueva_renov                       char(1);
	define _prima_devengada                   decimal(16,2);
	define _n_tarifa                          char(50);
	define _cod_tipo_tar                      char(3);
    define _error                             integer;

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
	let _prima_devengada = 0;
	let _n_zona = "";

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
	   and b.cod_ramo in('002','023')
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

{-- Primas Pagadas

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

END	}

let v_filtros = sp_rec139("001","001",a_periodo1,a_periodo2,"*","*","002,023;","*","*","*","*","*");

delete from deivid_tmp:sinis14;

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
		   no_pagos,
		   nueva_renov
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
		   _no_pagos,
		   _nueva_renov
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    let _cod_tipo_tar = null;

    select cod_tipo_tar
	  into _cod_tipo_tar
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad;

     if _cod_tipo_tar is null then
		let _cod_tipo_tar = '001';
	 end if

     select nombre
	   into _n_tarifa
	   from emicamtar
	  where cod_tipo_tar = _cod_tipo_tar;

     foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

        exit foreach;
	 end foreach

       select cod_vendedor
	     into _cod_vendedor
		 from agtagent
		where cod_agente = _cod_agente;

       select nombre
	     into _n_zona
		 from agtvende
		where cod_vendedor = _cod_vendedor;


     select nombre
	   into _corredor
	   from agtagent
	  where cod_agente = _cod_agente;

	 if _cod_ramo in('002','023') then --,'023')
	 else
		continue foreach;
	 end if

	   let _cod_tipoveh = null;
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

			   
		SELECT descripcion
		  INTO _sucursal
		  FROM insagen
		 WHERE codigo_agencia  = _cod_sucursal
		   AND codigo_compania = "001";

        select nombre
		  into _n_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;
	   
	    SELECT nombre
		  INTO v_subramo
		  FROM prdsubra
		 WHERE cod_ramo    = _cod_ramo
		   AND cod_subramo = _ls_subramo;
	   

	   let _tipo = '';

	   if _cod_ramo = '023' then
			let _tipo = 'COLECTIVO';
	   else
			let _tipo = 'INDIVIDUAL';
	   end if

		  select min(no_endoso)
			into _no_endoso 
			from endeduni
			where no_poliza = v_no_poliza
			and no_unidad   = v_no_unidad;

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


          if _cod_ramo = '002' then
			   	if _cod_producto = '00313' OR _cod_producto = '00314' OR _cod_producto = '00340' THEN
					let v_grupo = 'AUTORC';
				elif _cod_producto = '00318' OR _cod_producto = '00282' OR _cod_producto = '00290' THEN
					let v_grupo = 'USADITO';
				else
					let v_grupo = 'CASCO';
	            end if
		  elif _cod_ramo = '023' then
			   	if _cod_producto = '02092' THEN
					let v_grupo = 'AUTO FLOTA RC';
				elif _cod_producto = '02083' THEN
					let v_grupo = 'USADITO FLOTA';
				else
					let v_grupo = 'CASCO FLOTA';
				end if
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
			  from deivid_tmp:sinis14
			 where poliza = v_no_documento;

			if _saber > 0 then
				let _prima_suscrita = 0;
				let v_prima_cobrada = 0;
			end if

	        let _incurrido_total = 0;

			SELECT SUM(pagado_bruto),
			       SUM(reserva_bruto)
			  into _pagado_total,
				   _reserva_total
			  FROM tmp_incurrido
			 where no_reclamo    = _no_reclamo;

	           let _incurrido_total = _pagado_total + _reserva_total;

		 	   INSERT INTO deivid_tmp:sinis14(
			   marca, modelo, ano, tipo_vehiculo, suma_asegurada, poliza, sucursal, no_motor,vigencia_desde, vigencia_hasta, tipo, fecha_siniestro, no_siniestro,monto_incurrido,
			   evento, subramo,producto, grupo,no_reclamo,corredor,nueva_renov,zona,ramo,prima_devengada,tipo_tarifa,unidad)
			   VALUES(
			   v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo,v_suma_asegurada, v_no_documento,_sucursal, v_no_motor, v_vigencia_inic,v_vigencia_final,_tipo, _fecha_siniestro,
			   _numrecla,_incurrido_total,_n_evento, v_subramo,v_producto, v_grupo,_no_reclamo, _corredor,_nueva_renov,_n_zona,_n_ramo,_prima_devengada,_n_tarifa,v_no_unidad);
															   
end foreach

let _error = sp_actuario25(a_periodo2);
let _prima_devengada = 0.00;

foreach
 select no_documento,
	    sum(pri_dev_aa)
   into v_no_documento,
	    _prima_devengada
   from tmp_multi
  group by no_documento


 update deivid_tmp:sinis14
    set	prima_devengada = _prima_devengada
  where poliza          = v_no_documento;

end foreach

drop table tmp_multi;


foreach
	  select marca, modelo, ano, tipo_vehiculo, suma_asegurada, poliza, sucursal, no_motor,vigencia_desde, vigencia_hasta, tipo, fecha_siniestro, no_siniestro,monto_incurrido,
			 evento, subramo,producto, grupo,no_reclamo,corredor,nueva_renov,zona,ramo,prima_devengada,tipo_tarifa,unidad
        into v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo,v_suma_asegurada, v_no_documento,_sucursal, v_no_motor, v_vigencia_inic,v_vigencia_final,_tipo, _fecha_siniestro,
			 _numrecla,_incurrido_total,_n_evento, v_subramo,v_producto, v_grupo,_no_reclamo, _corredor,_nueva_renov,_n_zona,_n_ramo,_prima_devengada,_n_tarifa,v_no_unidad
		from deivid_tmp:sinis14

	  return v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo,v_suma_asegurada, v_no_documento,_sucursal, v_no_motor, v_vigencia_inic,v_vigencia_final,_tipo, _fecha_siniestro,
			 _numrecla,_incurrido_total,_n_evento, v_subramo,v_producto, v_grupo,_no_reclamo, _corredor,_nueva_renov,_n_zona,_n_ramo,
			 _prima_devengada,_n_tarifa,v_no_unidad with resume;


end foreach

drop table tmp_montos;
drop table tmp_incurrido;


END
END PROCEDURE;
