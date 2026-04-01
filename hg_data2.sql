--  ULTIMO  PROCEDIMIENTO PARA CORREGIR LOS SALDOS DE SODA
--  02/11/2009 HENRY
DROP PROCEDURE hg_data2;

CREATE PROCEDURE hg_data2(a_periodo char(7), a_2pri char(2), a_act smallint default 0, a_poliza CHAR(10) default "*")
-- execute procedure hg_data2("2009-09","18",0) -- RAMO SALUD
RETURNING CHAR(20),char(10),char(5),char(5),dec(16,2),dec(16,2),dec(16,2),char(7),char(20);

DEFINE _mensaje         CHAR(100);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _cod_endomov		CHAR(3);
DEFINE _tipo_mov		SMALLINT;
DEFINE _periodo_par     CHAR(7);
DEFINE _periodo_end     CHAR(7);
DEFINE _cod_tipocan     CHAR(3);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final	DATE;
DEFINE _prima_bruta     DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_neta      DEC(16,2);
DEFINE _descuento       DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _prima           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _no_fac_orig,nvo_no_pol     CHAR(10);
DEFINE _error			SMALLINT;
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(16,4);
DEFINE _cod_coasegur	CHAR(3);

DEFINE _prima_sus_sum	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
DEFINE _no_endoso_ext	CHAR(5);
DEFINE _tiene_impuesto	SMALLINT;
DEFINE _no_endoso       CHAR(5);
DEFINE _user_added		CHAR(8);
DEFINE _cod_formapag    CHAR(3);
DEFINE _tipo_forma	    smallint;
define _return			smallint;

DEFINE _cod_asegurado	char(10);
DEFINE _consignado		varchar(50,0);
DEFINE _tipo_embarque	char(1);
DEFINE _clausulas		varchar(50,0);
DEFINE _contenedor		varchar(50,0);
DEFINE _sello			varchar(50,0);
DEFINE _fecha_viaje		date;
DEFINE _viaje_desde		varchar(50,0);
DEFINE _viaje_hasta		varchar(50,0);
DEFINE _no_documento    char(20);
define _no_poliza       char(10);
define _cnt,_existe		smallint;
define _b char(2);

define _prima_emifacon_det decimal;
define _prima_emifacon decimal;
define _prima_endedmae decimal;

DEFINE _q_endeuni		    DEC(16,2);
DEFINE q_facuni_xuni        DEC(16,2);
DEFINE _acumulado           DEC(16,2);
DEFINE _dif_redondeo        DEC(16,2);
DEFINE _q_facuni		    DEC(16,2);
DEFINE f_hay,f_ns100        smallint;
DEFINE _realizar			smallint;
DEFINE i_serie				integer;
DEFINE i_cod_ramo			char(3);
DEFINE i_cod_ruta			char(5);	
DEFINE i_no_cambio			smallint;
DEFINE i_no_unidad			CHAR(5);
DEFINE v_cod_cober_reas	    char(3);
DEFINE i_cod_cober_reas,i_cod_cober_reas_ult	char(3);
DEFINE i_orden,i_orden_ult	integer;
DEFINE i_cod_contrato		char(5);
DEFINE i_porc_suma			DEC(10,4);
DEFINE i_porc_prima		    DEC(10,4);
DEFINE i_tipo_contrato		char(1);
DEFINE i_suma_asegurada 	DECIMAL(16,2);
DEFINE s_porc_partic_prima	DEC(10,4);
DEFINE v_diferencia,_prima_suscrita_xend	 	    DECIMAL(16,2);
DEFINE v_si_hay				smallint;
DEFINE v_p_endeuni	  	 	DECIMAL(16,2);
DEFINE v_p_facuni	   	    DECIMAL(16,2);
DEFINE v_dif_unifac		    DECIMAL(16,2);
DEFINE _porc_partic_agt		    DECIMAL(16,2);
DEFINE _prima_reaseguro		    DECIMAL(16,2);
DEFINE _obs    char(20);


 SET DEBUG FILE TO "hg_data2.trc"; 
 trace on;

let _prima_suscrita = 0;
let _prima_emifacon_det = 0;
let _prima_emifacon = 0;
let _prima_endedmae = 0;
let _b = 'E'; 
let _cnt = 1;  
let _prima_suscrita_xend = 0;
let _porc_partic_agt = 0;
let _obs = 0;

SET ISOLATION TO DIRTY READ;

BEGIN
if a_poliza = "*" then
	select * from endedmae
	 where actualizado       = 1
	   and no_documento[1,2] = a_2pri	 
	   and periodo           = a_periodo
	   INTO TEMP endedmae_TMP;
else
	select * from endedmae
	 where actualizado       = 1
	   and no_documento[1,2] = a_2pri	 
	   and periodo           = a_periodo
	   and no_poliza         = a_poliza
	   INTO TEMP endedmae_TMP;
end if

foreach
	select no_poliza,
	       no_endoso,
		   no_documento,
		   prima_suscrita
	  into _no_poliza,
	  	   _no_endoso,
		   _no_documento,
		   _prima_endedmae
	  from endedmae_TMP
	 where actualizado       = 1
	   and no_documento[1,2] = a_2pri	 
	   and periodo           = a_periodo
--	   and no_poliza         in ( '564466','5537x16')
--	   and cod_endomov       = '014'
--	   and no_poliza = '437817'
--	   and no_endoso = '00000'

	let _prima_suscrita = 0;
	let _prima_suscrita_xend = 0;
	let _porc_partic_agt = 0;

	select sum(prima_suscrita)
	  into _prima_suscrita_xend
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if abs(_prima_suscrita_xend - _prima_endedmae) > 1 then
	   let _cnt = 0;   
	   let _b = 'E';
	end if

     SELECT sum(porc_partic_agt)
          INTO _porc_partic_agt
          FROM endmoage
         WHERE no_poliza = _no_poliza
	       and no_endoso = _no_endoso;

	if abs(_porc_partic_agt) <> 100 or _porc_partic_agt IS NULL  then
	   let _cnt = 0;   
	   let _b = 'A';
	   let _obs = _b||"- "||_porc_partic_agt;
	end if

	foreach
		select no_unidad,prima_suscrita
		  into _no_unidad,_prima_suscrita
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
			let _prima_emifacon_det = 0;

			let _prima_emifacon = 0;
			select sum(prima)
			  into _prima_emifacon
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad;			
		    let _cnt = 1; 
			let _existe = 0;
			if _prima_emifacon is null then
				let _prima_emifacon = 0;
			end if
			if abs(_prima_suscrita - _prima_emifacon) > 1 then
			   let _cnt = 0;   
			   let _b = 'D';
				select count(*)
				  into _existe
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;
				if _existe is null then 
					let _existe = 0;
				end if
			    let _obs = _b||"- "||_existe;
			end if

			IF TRIM(a_2pri) = "18" THEN
			   	let _b = 'S';  -- en caso de salud 'N' no realiza cambios, en todos los demas comentariar esta linea
			    let _obs = _b||"- "||_existe;
			END IF
			IF TRIM(a_2pri) = "19" THEN
			   	let _b = 'S';  -- en caso de salud 'N' no realiza cambios, en todos los demas comentariar esta linea
			    let _obs = 'V'||"- "||_existe;
			END IF

			if _cnt = 0 then
--
					LET q_facuni_xuni = 0;
					LET _acumulado = 0;
					LET _dif_redondeo = 0;

					if _b = 'D' and  _existe =  0 then 		-- NO existe en emifacon

						select suma_asegurada
						into  i_suma_asegurada
						  from emipouni
						 where no_poliza = _no_poliza
						 and no_unidad   = _no_unidad ;

						select serie,cod_ramo
						  into i_serie,i_cod_ramo
						  from emipomae
						 where no_poliza = _no_poliza;

						foreach
							select cod_ruta
							  into i_cod_ruta
							  from rearumae
							 where serie    = i_serie
							   and cod_ramo = i_cod_ramo
							exit foreach;
						end foreach

						select max(no_cambio)
						  into i_no_cambio
						  from emireama
						 where no_poliza = _no_poliza;

						FOREACH
							 Select cod_cober_reas,
									orden,
									cod_contrato,
									porc_partic_suma,
									porc_partic_prima
							   Into i_cod_cober_reas,
									i_orden,
									i_cod_contrato,
									i_porc_suma,
									i_porc_prima
							   From emireaco
							  Where no_poliza = _no_poliza
							    and no_cambio = i_no_cambio
								and no_unidad = _no_unidad

								LET _acumulado = 0;
								LET i_orden_ult = 0;
								LET _dif_redondeo = 0;
								LET _prima_reaseguro = 0;

							  select sum(x.prima_neta)
								into _prima_reaseguro
								from prdcober y, endedcob x  
							   Where x.cod_cobertura  = y.cod_cobertura
							   	 and x.no_poliza = _no_poliza 
							   	 and x.no_endoso = _no_endoso 
							   	 and x.no_unidad = _no_unidad ;

								 if _prima_reaseguro is null then
									LET _prima_reaseguro = 0;
								 end if

								 if abs(_prima_reaseguro - _prima_suscrita) <= 0.05 then
								  select sum(x.prima_neta)
									into _prima_reaseguro
									from prdcober y, endedcob x  
								   Where x.cod_cobertura  = y.cod_cobertura
								   	 and x.no_poliza = _no_poliza 
								   	 and x.no_endoso = _no_endoso 
								   	 and x.no_unidad = _no_unidad  
									 and y.cod_cober_reas = i_cod_cober_reas;
								else
									LET _prima_reaseguro = _prima_suscrita;
								 end if


--								LET q_facuni_xuni =  _prima_suscrita * i_porc_prima / 100 ;  -- realizo la distribucion para todas las cobertura,orden  no por el porcentaje que presenta.
								LET q_facuni_xuni =  _prima_reaseguro * i_porc_prima / 100 ;  -- realizo la distribucion para todas las cobertura,orden  no por el porcentaje que presenta.

								LET _acumulado = _acumulado + q_facuni_xuni;

								LET i_orden_ult = i_orden;
								LET i_cod_cober_reas_ult = i_cod_cober_reas ;
								LET i_suma_asegurada = 0;
								if a_act = 1 then
								    Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
								    Values (_no_poliza,_no_endoso,_no_unidad,i_cod_cober_reas,i_orden,i_cod_contrato,i_cod_ruta,i_porc_prima,i_porc_suma,i_suma_asegurada,q_facuni_xuni);
								end if
						END FOREACH

						-- Para el redondeo
						if _acumulado is null then
							LET _acumulado = 0;
						end if

						LET _dif_redondeo = _prima_reaseguro - _acumulado;

						if 	_dif_redondeo <> 0 then
							if a_act = 1 then
							   	update  emifacon
								SET   emifacon.prima	   = emifacon.prima + _dif_redondeo
								where ( emifacon.no_poliza = _no_poliza )
								and   ( emifacon.no_endoso = _no_endoso )
								and   ( emifacon.no_unidad = _no_unidad )
								and   ( emifacon.cod_cober_reas = i_cod_cober_reas_ult )
								and   ( emifacon.orden = i_orden_ult )	;  
							end if
						end if

					end if

					LET q_facuni_xuni = 0;
					LET _acumulado = 0;
					LET _dif_redondeo = 0;
					LET i_suma_asegurada = 0;

					if _b = 'D' and _existe <>  0 then 		-- SI existe en emifacon

						select suma_asegurada
						into  i_suma_asegurada
						  from emipouni
						 where no_poliza = _no_poliza
						 and no_unidad   = _no_unidad ;

						FOREACH
							SELECT emifacon.cod_cober_reas
							into i_cod_cober_reas
							FROM emifacon  
							where  emifacon.no_poliza = _no_poliza
							and    emifacon.no_endoso = _no_endoso
							and    emifacon.no_unidad = _no_unidad

							LET _acumulado = 0;
							LET i_orden_ult = 0;
							LET _dif_redondeo = 0;
							LET _prima_reaseguro = 0;

						  select sum(x.prima_neta)
							into _prima_reaseguro
							from prdcober y, endedcob x  
						   Where x.cod_cobertura  = y.cod_cobertura
						   	 and x.no_poliza = _no_poliza 
						   	 and x.no_endoso = _no_endoso 
						   	 and x.no_unidad = _no_unidad ;

							 if _prima_reaseguro is null then
								LET _prima_reaseguro = 0;
							 end if

							 if abs(_prima_reaseguro - _prima_suscrita) <= 0.05 then
							  select sum(x.prima_neta)
								into _prima_reaseguro
								from prdcober y, endedcob x  
							   Where x.cod_cobertura  = y.cod_cobertura
							   	 and x.no_poliza = _no_poliza 
							   	 and x.no_endoso = _no_endoso 
							   	 and x.no_unidad = _no_unidad  
								 and y.cod_cober_reas = i_cod_cober_reas;
							else
								LET _prima_reaseguro = _prima_suscrita;
							 end if

								FOREACH
									SELECT orden,porc_partic_prima
									into i_orden,s_porc_partic_prima
									FROM emifacon  
									where  emifacon.no_poliza = _no_poliza
									and    emifacon.no_endoso = _no_endoso
									and    emifacon.no_unidad = _no_unidad 
									and    emifacon.cod_cober_reas = i_cod_cober_reas

--									LET q_facuni_xuni =  _prima_suscrita * s_porc_partic_prima / 100 ;  -- realizo la distribucion para todas las cobertura,orden  no por el porcentaje que presenta.
									LET q_facuni_xuni =  _prima_reaseguro * s_porc_partic_prima / 100 ;  -- realizo la distribucion para todas las cobertura,orden  no por el porcentaje que presenta.

									if q_facuni_xuni is null then
										LET q_facuni_xuni = 0;
									end if

									LET _acumulado = _acumulado + q_facuni_xuni;

									LET i_orden_ult = i_orden;
									if a_act = 1 then
									   	update  emifacon
										SET   emifacon.prima	   = q_facuni_xuni,
										      suma_asegurada	   = i_suma_asegurada * s_porc_partic_prima	/ 100
										where ( emifacon.no_poliza = _no_poliza )
										and   ( emifacon.no_endoso = _no_endoso )
										and   ( emifacon.no_unidad = _no_unidad )
										and   ( emifacon.cod_cober_reas = i_cod_cober_reas )
										and   ( emifacon.orden = i_orden )	;  
									end if

								END FOREACH	 

								-- Para el redondeo
								if _acumulado is null then
									LET _acumulado = 0;
								end if

								LET _dif_redondeo = _prima_reaseguro - _acumulado;

								if 	_dif_redondeo <> 0 then
									if a_act = 1 then
									   	update  emifacon
										SET   emifacon.prima	   = emifacon.prima + _dif_redondeo
										where ( emifacon.no_poliza = _no_poliza )
										and   ( emifacon.no_endoso = _no_endoso )
										and   ( emifacon.no_unidad = _no_unidad )
										and   ( emifacon.cod_cober_reas = i_cod_cober_reas ) 
										and   ( emifacon.orden = i_orden_ult )	;  
									end if
								end if

						END FOREACH
					end if

				   if _b = 'S'  and _existe <>  0 and a_act = 1 then
				   	
				   	update  emifacon
					   SET  emifacon.prima	    = _prima_suscrita
					 where ( emifacon.no_poliza = _no_poliza )
					   and ( emifacon.no_endoso = _no_endoso )
					   and ( emifacon.no_unidad = _no_unidad );

				   end if

				    RETURN _no_documento,
						   _no_poliza,
						   _no_endoso,
						   _no_unidad,
						   _prima_endedmae,
						   _prima_suscrita,
						   _prima_emifacon,
						   a_periodo,
						   _obs
					  WITH RESUME;

	              { Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
				   Values (_no_poliza,_no_endoso,_no_unidad,'019',1,'00577','00378',100,100,0,_prima_suscrita);}				
				
			end if

	end foreach


end foreach

END
DROP TABLE endedmae_TMP;

END PROCEDURE;				