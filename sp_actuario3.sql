 DROP procedure sp_actuario3;

 CREATE procedure "informix".sp_actuario3(a_serie smallint)
   RETURNING integer;
 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO SALUD
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
	DEFINE _cnt								  INTEGER;
	DEFINE _fecha_suscripcion                 DATE;
	DEFINE _cod_contratante					  CHAR(10);
	define _prima                             dec(16,2);
	define _cedula,_ced_dep	    			  char(30);
	define _sexo,_sexo_dep					  char(1);
	define _cod_parentesco					  char(3);
	define _n_parentesco					  char(50);
	define _fecha_aniversario,_fecha_ani      date;
	define _edad_cte,_edad                    integer;
	define _cod_cte                           char(10);
	define _cod_producto                      char(5);
	define _n_producto                        char(50);
	define _fecha_ult_p                       date;
	define _cod_subramo                       char(3);
	define _n_subramo                         char(50);
	define _cod_asegurado                     char(10);
	define _estatus                           smallint;
	define _estatus_char                      char(9);
	define _prima_pagada                      dec(16,2);
	define _fecha_efectiva                    date;
	define _fecha_ani_ase                     date;
	define _ced_ase                           char(30);
	define _sexo_ase                          char(1);
	define _no_factura                        char(10);
	define _periodo                           char(7);
	define _fecha_ani_aseg                    date;


SET ISOLATION TO DIRTY READ; 

let _prima_pagada = 0;

FOREACH WITH HOLD

       SELECT no_poliza,
       		  no_documento,
       		  vigencia_inic,
              vigencia_final,
              fecha_cancelacion,
			  cod_sucursal,
			  fecha_suscripcion,
			  cod_contratante,
			  cod_subramo,
			  estatus_poliza
         INTO v_no_poliza,
         	  v_no_documento,
         	  v_vigencia_inic,
              v_vigencia_final,
              v_fecha_cancel,
			  _cod_sucursal,
			  _fecha_suscripcion,
			  _cod_contratante,
			  _cod_subramo,
			  _estatus
         FROM emipomae
        WHERE cod_ramo = "018"
		  AND actualizado = 1

	   SELECT count(*)
		 INTO _cnt
	     FROM emipouni
	    WHERE no_poliza = v_no_poliza;

		let _estatus_char = '';

		if _estatus = 1 then
			let _estatus_char = 'VIGENTE';
		elif _estatus = 2 then
			let _estatus_char = 'CANCELADA';
		elif _estatus = 3 then
			let _estatus_char = 'VENCIDA';
		else
			let _estatus_char = '*';
		end if

	   if _cnt > 1 then
			continue foreach;
	   end if

		SELECT count(*)
		  INTO _cnt
		  FROM endedmae
		 WHERE cod_compania  = '001'
		   AND actualizado   = 1
		   AND periodo[1,4] = '2007'
		   AND no_poliza     = v_no_poliza;

		if _cnt > 0 then
		else
			continue foreach;
		end if
			   
       SELECT nombre
         INTO _n_subramo
         FROM prdsubra
        WHERE cod_ramo    = '018'
          AND cod_subramo = _cod_subramo;

       SELECT descripcion
         INTO _sucursal
         FROM insagen
        WHERE codigo_agencia  = _cod_sucursal
          AND codigo_compania = "001";

       SELECT fecha_aniversario,
			  cedula,
			  sexo
         INTO _fecha_aniversario,
		      _cedula,
			  _sexo
         FROM cliclien
        WHERE cod_cliente  = _cod_contratante;

	   if _fecha_aniversario is not null then 
		   let _edad_cte = sp_sis78(_fecha_aniversario,today);
	   else
	       let _edad_cte = 0;
	   end if

	 -- Primas Pagadas

	 SELECT	sum(prima_neta)
	   INTO	_prima_pagada
	   FROM cobredet
	  WHERE	cod_compania = '001'
	  	AND	actualizado  = 1
	    AND tipo_mov IN ('P', 'N')
	    AND doc_remesa    = v_no_documento
	    AND periodo[1,4]  = '2007'
		AND renglon       <> 0;

	   let _prima = 0;
	   	
       FOREACH
        
          SELECT no_unidad,
          		 suma_asegurada,
				 cod_producto,
				 cod_asegurado,
				 vigencia_inic,
				 prima
            INTO v_no_unidad,
            	 v_suma_asegurada,
				 _cod_producto,
				 _cod_asegurado,
				 _fecha_efectiva,
				 _prima
            FROM emipouni
           WHERE no_poliza = v_no_poliza

		   select nombre
		     into _n_producto
		     from prdprod
		    where cod_producto = _cod_producto;

			foreach

	          SELECT cod_cliente,
					 cod_parentesco
	            INTO _cod_cte,
				     _cod_parentesco
	            FROM emidepen
	           WHERE no_poliza = v_no_poliza
	             AND no_unidad = v_no_unidad
				 AND activo    = 1

		       SELECT nombre
		         INTO _n_parentesco
		         FROM emiparen
		        WHERE cod_parentesco = _cod_parentesco;

		       SELECT fecha_aniversario,
			          cedula,
					  sexo
		         INTO _fecha_ani_aseg,
				      _ced_ase,
					  _sexo_ase
		         FROM cliclien
		        WHERE cod_cliente = _cod_asegurado;

		       SELECT fecha_aniversario,
			          cedula,
					  sexo
		         INTO _fecha_ani,
				      _ced_dep,
					  _sexo_dep
		         FROM cliclien
		        WHERE cod_cliente = _cod_cte;

			   if _fecha_ani is not null then 
				   let _edad = sp_sis78(_fecha_ani,today);
			   else
			       let _edad = 0;
			   end if

		    foreach

			SELECT no_factura,
			       periodo
			  INTO _no_factura,
			       _periodo
			  FROM endedmae
			 WHERE cod_compania  = '001'
			   AND actualizado   = 1
			   AND periodo[1,4] = '2007'
			   and no_poliza     = v_no_poliza
			   and cod_endomov   = '014'

			   if a_serie = 2007 then
				   INSERT INTO cartsal7(
				   subramo,
				   sucursal,
				   plan,
				   poliza,
				   ced_titular,
				   sexo_titular,
				   fec_nac_aseg,
				   ced_dep,
				   sexo_dep,
				   fec_nac_dep,
				   parentesco,
				   vigencia_desde,
				   vigencia_hasta,
				   fecha_suscripcion,
				   periodo,
				   prima,
				   prima_cobrada,
				   no_factura,
				   estatus_poliza,
				   fecha_cancelacion
				   )
				   VALUES(
				   _n_subramo,
				   _sucursal,
				   _n_producto,
				   v_no_documento,
				   _cedula,
				   _sexo,
				   _fecha_ani_aseg,
				   _ced_dep,
				   _sexo_dep,
				   _fecha_ani,
				   _n_parentesco,
				   v_vigencia_inic,
				   v_vigencia_final,
				   _fecha_efectiva,
				   _periodo,
				   _prima,
				   _prima_pagada,
				   _no_factura,
				   _estatus_char,
				   v_fecha_cancel
				   );
			   else
				   INSERT INTO cartsal8(
				   subramo,
				   sucursal,
				   plan,
				   poliza,
				   ced_titular,
				   sexo_titular,
				   fec_nac_aseg,
				   ced_dep,
				   sexo_dep,
				   fec_nac_dep,
				   parentesco,
				   vigencia_desde,
				   vigencia_hasta,
				   fecha_suscripcion,
				   periodo,
				   prima,
				   prima_cobrada,
				   no_factura,
				   estatus_poliza,
				   fecha_cancelacion
				   )
				   VALUES(
				   _n_subramo,
				   _sucursal,
				   _n_producto,
				   v_no_documento,
				   _cedula,
				   _sexo,
				   _fecha_ani_aseg,
				   _ced_dep,
				   _sexo_dep,
				   _fecha_ani,
				   _n_parentesco,
				   v_vigencia_inic,
				   v_vigencia_final,
				   _fecha_efectiva,
				   _periodo,
				   _prima,
				   _prima_pagada,
				   _no_factura,
				   _estatus_char,
				   v_fecha_cancel
				   );

			   end if
			end foreach
		   end foreach
       END FOREACH 
END FOREACH

END
END PROCEDURE;
