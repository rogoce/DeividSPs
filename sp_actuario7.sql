 DROP procedure sp_actuario7;

 CREATE procedure "informix".sp_actuario7()
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
	define _serie                             integer;
	define _numrecla                          char(18);
	define _no_reclamo                        char(10);
	define _no_poliza                         char(10);
	define _monto_bruto						  dec(16,2);
	define _pagado_bruto                      dec(16,2);
	define _monto_total						  dec(16,2);
	define _no_tranrec                        char(10);
	define _porc_coas						  decimal(7,4);
	define _porc_reas						  decimal(9,6);
	define _no_unidad                         char(5);
	define _canti                             integer;                   


SET ISOLATION TO DIRTY READ; 

let _pagado_bruto = 0;
let _canti = 0;

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
			  serie
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
			  _serie
         FROM emipomae
        WHERE cod_ramo    = "018"
		  AND cod_subramo = "013"
		  AND actualizado = 1
		ORDER BY no_documento,serie

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

		FOREACH

			 select	numrecla,
					no_reclamo,
					no_poliza,
					no_unidad
			   into	_numrecla,
					_no_reclamo,
					_no_poliza,
					_no_unidad
			   from recrcmae
			  where	no_documento = v_no_documento
			    and actualizado  = 1

			 let _monto_bruto = 0;
			 let _pagado_bruto = 0;
								
				FOREACH

					 SELECT no_reclamo,
					 		monto,
							no_tranrec
					   INTO _no_reclamo,
					   		_monto_total,
							_no_tranrec
					   FROM rectrmae
					  WHERE cod_compania = '001'
					    AND no_reclamo   = _no_reclamo
					    AND actualizado  = 1
						AND cod_tipotran IN ('004','005','006','007')
					    AND monto        <> 0

						-- Informacion de Coseguro

						SELECT porc_partic_coas
						  INTO _porc_coas
					      FROM reccoas
					     WHERE no_reclamo   = _no_reclamo
					       AND cod_coasegur = '036';

						IF _porc_coas IS NULL THEN
							LET _porc_coas = 0;
						END IF

						-- Informacion de Reaseguro

						LET _porc_reas = 0;
						
						FOREACH
						 select	porc_partic_suma
						   into _porc_reas
						   from rectrrea
						  where no_tranrec    = _no_tranrec
						    and tipo_contrato = 1
							EXIT FOREACH;
						END FOREACH
						  
						IF _porc_reas IS NULL THEN
							LET _porc_reas = 0;
						END IF;

						-- Calculos

						let _monto_bruto = _monto_total / 100 * _porc_coas;
						let _pagado_bruto = _pagado_bruto + _monto_bruto;

				END FOREACH
			   
		       SELECT nombre
		         INTO _n_subramo
		         FROM prdsubra
		        WHERE cod_ramo    = '018'
		          AND cod_subramo = _cod_subramo;


				 if _no_unidad is null then	
					foreach

					   select no_unidad
					     into _no_unidad
					     from emipouni
					    where no_poliza = v_no_poliza

						exit foreach;
					end foreach

				   select cod_producto
				     into _cod_producto
				     from emipouni
				    where no_poliza = v_no_poliza
				      and no_unidad = _no_unidad;

				 end if

			   select nombre
			     into _n_producto
			     from prdprod
			    where cod_producto = _cod_producto;

			   INSERT INTO cartsal(
			   poliza,
			   fecha_cancelacion,
			   vigencia_desde,
			   vigencia_hasta,
			   plan,
			   subramo,
			   estatus_poliza,
			   pagado_bruto,
			   reclamo,
			   serie
			   )
			   VALUES(
			   v_no_documento,
			   v_fecha_cancel,
			   v_vigencia_inic,
			   v_vigencia_final,
			   _n_producto,
			   _n_subramo,
			   _estatus_char,
			   _pagado_bruto,
			   _numrecla,
			   _serie
			   );

        END FOREACH

			 select	count(*)
			   into	_canti
			   from recrcmae
			  where	no_documento = v_no_documento
			    and actualizado  = 1;

			if _canti = 0 then

			   let _numrecla = '';
			   let _pagado_bruto = 0;

		       SELECT nombre
		         INTO _n_subramo
		         FROM prdsubra
		        WHERE cod_ramo    = '018'
		          AND cod_subramo = _cod_subramo;

					foreach

					   select no_unidad
					     into _no_unidad
					     from emipouni
					    where no_poliza = v_no_poliza

						exit foreach;
					end foreach

				   select cod_producto
				     into _cod_producto
				     from emipouni
				    where no_poliza = v_no_poliza
				      and no_unidad = _no_unidad;

			   select nombre
			     into _n_producto
			     from prdprod
			    where cod_producto = _cod_producto;

			   INSERT INTO cartsal(
			   poliza,
			   fecha_cancelacion,
			   vigencia_desde,
			   vigencia_hasta,
			   plan,
			   subramo,
			   estatus_poliza,
			   pagado_bruto,
			   reclamo,
			   serie
			   )
			   VALUES(
			   v_no_documento,
			   v_fecha_cancel,
			   v_vigencia_inic,
			   v_vigencia_final,
			   _n_producto,
			   _n_subramo,
			   _estatus_char,
			   _pagado_bruto,
			   _numrecla,
			   _serie
			   );

			end if
END FOREACH

END
END PROCEDURE;
