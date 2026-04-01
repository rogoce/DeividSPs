 DROP procedure sp_actuario9;

 CREATE procedure "informix".sp_actuario9(a_periodo1 char(7), a_periodo2 char(7))
 RETURNING char(30),char(20),char(50),char(1),date,date,date,date,DECIMAL(16,2),char(50),char(50),date,char(7),char(10),char(9),DECIMAL(16,2),char(1),char(50);

--------------------------------------------
---  DATA PARA RAMO SALUD SOLICITADA POR ALEJANDRA DE TITULARES
--   EL SP_ACTUARIO10 TIENE LA PARTE DE LOS DEPENDDIENTES
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
	define _colectiva                         char(1);
	define _cod_perpago						  char(3);
	define _n_perpago						  char(50);


SET ISOLATION TO DIRTY READ; 

let _prima_pagada = 0;
let _ced_dep = '';
let _sexo_dep = '';
let _fecha_ani = '01/01/2013';
let _n_parentesco = '';

delete from cartsal7;

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
			  estatus_poliza,
			  colectiva,
			  cod_perpago
         INTO v_no_poliza,
         	  v_no_documento,
         	  v_vigencia_inic,
              v_vigencia_final,
              v_fecha_cancel,
			  _cod_sucursal,
			  _fecha_suscripcion,
			  _cod_contratante,
			  _cod_subramo,
			  _estatus,
			  _colectiva,
			  _cod_perpago
         FROM emipomae
        WHERE cod_ramo = "018"
		  AND actualizado = 1

{		if _cod_subramo not in("003","011","013","009","016","007","017","018")	then
			continue foreach;
		end if}

		select nombre
		  into _n_perpago
		  from cobperpa
		 where cod_perpago = _cod_perpago;


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

		SELECT count(*)
		  INTO _cnt
		  FROM endedmae
		 WHERE cod_compania  = '001'
		   AND actualizado   = 1
		   AND periodo       >= a_periodo1   --'2010-01'
		   AND periodo       <= a_periodo2   --'2010-12'
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
	    AND periodo       >= a_periodo1
	    AND periodo       <= a_periodo2
		AND renglon       <> 0;

	   let _prima = 0;
	   	
       FOREACH
        
          SELECT no_unidad,
          		 suma_asegurada,
				 cod_producto,
				 cod_asegurado,
				 vigencia_inic
            INTO v_no_unidad,
            	 v_suma_asegurada,
				 _cod_producto,
				 _cod_asegurado,
				 _fecha_efectiva
            FROM emipouni
           WHERE no_poliza = v_no_poliza

		   select nombre
		     into _n_producto
		     from prdprod
		    where cod_producto = _cod_producto;

		       SELECT fecha_aniversario,
			          cedula,
					  sexo
		         INTO _fecha_ani_aseg,
				      _ced_ase,
					  _sexo_ase
		         FROM cliclien
		        WHERE cod_cliente = _cod_asegurado;


			   if _fecha_ani_aseg is not null then 
				   let _edad = sp_sis78(_fecha_ani_aseg,today);
			   else
			       let _edad = 0;
			   end if

		    foreach

				SELECT no_factura,
				       periodo,
					   prima_neta
				  INTO _no_factura,
				       _periodo,
					   _prima
				  FROM endedmae
				 WHERE cod_compania  = '001'
				   AND actualizado   = 1
				   AND periodo       >= a_periodo1
				   AND periodo       <= a_periodo2
				   and no_poliza     = v_no_poliza
				   and cod_endomov   in('014','011')

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
				   fecha_cancelacion,
				   colectiva,
				   n_perpago
				   )
				   VALUES(
				   _n_subramo,
				   _sucursal,
				   _n_producto,
				   v_no_documento,
				   _ced_ase,
				   _sexo_ase,
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
				   v_fecha_cancel,
				   _colectiva,
				   _n_perpago
				   );
			end foreach
       END FOREACH 
END FOREACH

foreach

	select subramo,
		   sucursal,
		   plan,
		   poliza,
		   ced_titular,
		   sexo_titular,
		   fec_nac_aseg,
--		   sexo_dep,
--		   fec_nac_dep,
--		   parentesco,
		   vigencia_desde,
		   vigencia_hasta,
		   fecha_suscripcion,
		   periodo,
		   prima,
		   prima_cobrada,
		   no_factura,
		   estatus_poliza,
		   fecha_cancelacion,
		   colectiva,
		   n_perpago
	  into _n_subramo,
		   _sucursal,
		   _n_producto,
		   v_no_documento,
		   _ced_ase,
		   _sexo_ase,
		   _fecha_ani_aseg,
--		   _sexo_dep,
--		   _fecha_ani,
--		   _n_parentesco,
		   v_vigencia_inic,
		   v_vigencia_final,
		   _fecha_efectiva,
		   _periodo,
		   _prima,
		   _prima_pagada,
		   _no_factura,
		   _estatus_char,
		   v_fecha_cancel,
		   _colectiva,
		   _n_perpago
	  from cartsal7

	  return _ced_ase,v_no_documento,_sucursal,_sexo_ase,_fecha_efectiva,v_fecha_cancel,v_vigencia_inic,v_vigencia_final,_prima,_n_producto,_n_subramo,_fecha_ani_aseg,
	         _periodo,_no_factura,_estatus_char,_prima_pagada,_colectiva,_n_perpago with resume;


end foreach

END
END PROCEDURE;
