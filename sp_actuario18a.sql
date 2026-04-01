 DROP procedure sp_actuario18a;
 CREATE procedure "informix".sp_actuario18a(periodo1 char(7), periodo2 char(7))
 RETURNING   char(30), char(30), smallint, char(50), decimal(16,2),
			 char(20), char(30), char(30), date, date, char(10),
			 char(30),char(50), char(50),char(10),dec(16,2),char(5),
			 char(7),char(1),char(5),char(50),char(50),dec(16,2),char(50);

 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS PARA RAMO AUTOMOVIL 002,023
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
	DEFINE _ls_subramo						  char(3);
	DEFINE v_subramo						  char(50);
	DEFINE _uso_auto                          char(1);
	DEFINE v_uso                   			  char(10);
	DEFINE _cod_producto                      char(5);
	DEFINE v_producto                         char(50);
	DEFINE v_grupo                            char(20);
	DEFINE _cod_ramo                          char(3);
	DEFINE v_prima_cobrada                    dec(16,2);
    DEFINE _prima_bruta                       dec(16,2);
	DEFINE _periodo                           char(7);
	DEFINE v_no_endoso                        char(5);
	DEFINE _nueva_renov						  char(1);
	DEFINE _cod_vendedor					  char(3);
	DEFINE _n_zona                            char(50);
	DEFINE v_ramo                             char(50);
	DEFINE _cod_tipo_tar					  char(3);
	DEFINE _n_tarifa                          char(50);
	DEFINE _error                             smallint;
	DEFINE _pri_dev_aa						  DECIMAL(16,2);

    SET ISOLATION TO DIRTY READ;
    
	delete from carter14;


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
			  a.prima_bruta,
			  a.periodo,
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
			  _prima_bruta,
			  _periodo,
			  _nueva_renov
         FROM endedmae a, emipomae b
        WHERE a.no_poliza = b.no_poliza
          AND b.cod_ramo in('002','023')
		  AND a.actualizado = 1
		  AND a.periodo >= periodo1
		  AND a.periodo <= periodo2
		  order by b.cod_ramo

	   if v_vigencia_final is null then
			continue foreach;
	   end if

       SELECT descripcion
         INTO _sucursal
         FROM insagen
        WHERE codigo_agencia  = _cod_sucursal
          AND codigo_compania = "001";
		  
	   SELECT nombre
	     INTO v_ramo
		 FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	   SELECT nombre
	     INTO v_subramo
		 FROM prdsubra
		 WHERE cod_ramo    = _cod_ramo 
		 AND   cod_subramo = _ls_subramo;
		  
	   let _tipo = '';

	   if _cod_ramo = '023' then
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

       select cod_vendedor
	     into _cod_vendedor
		 from agtagent
		where cod_agente = _cod_agente;

       select nombre
	     into _n_zona
		 from agtvende
		where cod_vendedor = _cod_vendedor;

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

		 let _cod_tipo_tar = null;

         select cod_tipo_tar
		   into _cod_tipo_tar
		   from emipouni
		  where no_poliza = v_no_poliza
		    and no_unidad = v_no_unidad;

         if _cod_tipo_tar is null then
			let _cod_tipo_tar = '001';
		 end if

         select nombre
		   into _n_tarifa
		   from emicamtar
		  where cod_tipo_tar = _cod_tipo_tar;

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

			   if _sucursal is null then
				let _sucursal = '001';
			   end if

			   INSERT INTO carter14(
			   unidad,
			   marca,
			   modelo,
			   ano,
			   tipo_vehiculo,
			   suma_asegurada,
			   poliza,
			   sucursal,
			   no_motor,
			   vigencia_desde,
			   vigencia_hasta,
			   tipo,
			   corredor,
			   subramo,
			   producto,
			   grupo,
			   prima_bruta,
			   no_endoso,
			   periodo,
			   nueva_renov,
			   zona,
			   ramo,
			   prima_devengada,
			   tipo_tarifa
			   )
			   VALUES(
			   v_no_unidad,
			   v_nom_marca,
			   v_nom_modelo,
			   v_ano_auto,
			   _tipo_vehiculo,
			   v_suma_asegurada,
			   v_no_documento,
			   _sucursal,
			   v_no_motor,
			   v_vigencia_inic,
			   v_vigencia_final,
			   _tipo,
			   _n_corredor,
			   v_subramo,
			   v_producto,
			   v_grupo,
			   _prima_bruta,
			   v_no_endoso,
			   _periodo,
			   _nueva_renov,
			   _n_zona,
			   v_ramo,
			   0,
			   _n_tarifa
			   );
       END FOREACH 
END FOREACH

let _error = sp_actuario25(periodo2);
let _pri_dev_aa = 0.00;

foreach
 select no_documento,
	    sum(pri_dev_aa)
   into v_no_documento,
	    _pri_dev_aa
   from tmp_multi
  group by no_documento


 update carter14
    set	prima_devengada = _pri_dev_aa
  where poliza          = v_no_documento;

end foreach

drop table tmp_multi;

foreach
	select marca, modelo, ano, tipo_vehiculo, suma_asegurada,poliza, sucursal,no_motor, vigencia_desde, vigencia_hasta,
	       tipo,corredor, subramo, producto, grupo,prima_bruta,no_endoso,periodo,nueva_renov,unidad,zona,ramo,prima_devengada,tipo_tarifa
      into v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo, v_suma_asegurada,v_no_documento,_sucursal, v_no_motor, v_vigencia_inic,v_vigencia_final,
           _tipo,_n_corredor,v_subramo,v_producto,v_grupo,_prima_bruta,v_no_endoso,_periodo,_nueva_renov,v_no_unidad,_n_zona,v_ramo,_pri_dev_aa,_n_tarifa
	  from carter14
	 order by ramo
	  
	  return v_nom_marca, v_nom_modelo, v_ano_auto, _tipo_vehiculo, v_suma_asegurada, 
	  		 v_no_documento, _sucursal, v_no_motor, v_vigencia_inic, v_vigencia_final, _tipo,_n_corredor, v_subramo, v_producto, v_grupo, _prima_bruta,
	  		 v_no_endoso,_periodo,_nueva_renov,v_no_unidad,_n_zona,v_ramo,_pri_dev_aa,_n_tarifa with resume;
end foreach

END
END PROCEDURE;
