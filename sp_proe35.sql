-- Procedimiento para actualizar los valores de las primas en endedcob
-- f_emision_calcular_primas
--
-- Creado    : 15/03/2006 - Autor: Amado Perez M.
-- Modificado: 15/03/2006 - Autor: Amado Perez M.
-- Como el sp_proe01 pero para tablas de endoso.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe35;
CREATE PROCEDURE sp_proe35(a_poliza CHAR(10), a_endoso CHAR(5), a_unidad CHAR(5), a_cia CHAR(3))
			RETURNING   SMALLINT			 -- _error

DEFINE _error		  INTEGER;
DEFINE ls_cobertura   CHAR(5);
DEFINE ls_unidad   	  CHAR(5);
DEFINE ls_producto    CHAR(5);

DEFINE ld_factor_vigencia   DECIMAL(9,6);  --10,4
DEFINE ld_prima             DECIMAL(16,2);
DEFINE ld_prima_resta		DECIMAL(16,2);
DEFINE ld_prima_anual		DECIMAL(16,2);
DEFINE ld_descuento			DECIMAL(16,2);
DEFINE ld_recargo			DECIMAL(16,2);
DEFINE ld_prima_neta		DECIMAL(16,2);
DEFINE _descuento_max       DECIMAL(16,2);
DEFINE ld_prima_aux         DECIMAL(16,2); 
define v_tot_descto         DECIMAL(16,2); 
DEFINE   v_prima_descto DECIMAL(16,2);
DEFINE _tipo_descuento      SMALLINT;
DEFINE _cod_tipo_tar        CHAR(3);


DEFINE li_acepta_desc    	INTEGER;

DEFINE _desc_cob 			DECIMAL(16,2);
DEFINE _tipo_auto           SMALLINT;
DEFINE _desc_porc           DECIMAL(7,4);
DEFINE _fecha_suscripcion   DATE;
DEFINE _nueva_renov         CHAR(1);
DEFINE _cod_marca           CHAR(5);
DEFINE _cod_modelo          CHAR(5);
DEFINE _no_motor            CHAR(30); 
DEFINE _desc_modelo         dec(16,2);
DEFINE _retorno             INTEGER;
DEFINE _nuevo               smallint;
DEFINE _descuento_feria     dec(16,2);
DEFINE ls_ramo, _cod_subramo CHAR(3);   
DEFINE _descuento_edad      DECIMAL(16,2);  
DEFINE _descuento_pr_tipov  DECIMAL(16,2); 
define ld_prima_acu         dec(16,2); 
DEFINE _desc_cob_total		DECIMAL(16,2);
DEFINE _cant                smallint;

BEGIN

ON EXCEPTION SET _error
 	RETURN _error;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe35.trc";
--TRACE ON;

LET ld_factor_vigencia = 1.000000;

SELECT endedmae.factor_vigencia
  INTO ld_factor_vigencia
  FROM endedmae
 WHERE no_poliza = a_poliza
   AND no_endoso = a_endoso;

Select fecha_suscripcion, nueva_renov, cod_ramo, cod_subramo
  Into _fecha_suscripcion, _nueva_renov, ls_ramo, _cod_subramo
  From emipomae
 Where no_poliza = a_poliza;
   
FOREACH
	SELECT no_unidad,
		   cod_producto
	  INTO ls_unidad,
	  	   ls_producto
	  FROM endeduni
	 WHERE no_poliza = a_poliza
	   AND no_endoso = a_endoso
	   AND no_unidad MATCHES a_unidad
	   
    let _cod_tipo_tar = null;
	   
	Select cod_tipo_tar
	  Into _cod_tipo_tar
	  From emipouni 
	 Where no_poliza   = a_poliza
	   And no_unidad   = a_unidad;
	   
    FOREACH
    	SELECT endedcob.cod_cobertura, endedcob.prima_anual
    	  INTO ls_cobertura, ld_prima_anual
		  FROM endedcob
		 WHERE endedcob.no_poliza = a_poliza
		   and endedcob.no_endoso = a_endoso
		   AND endedcob.no_unidad = ls_unidad

		SELECT prdcobpd.acepta_desc, descuento_max, tipo_descuento
		  INTO li_acepta_desc, _descuento_max, _tipo_descuento
		  FROM prdcobpd
		 WHERE prdcobpd.cod_producto  = ls_producto
		   AND prdcobpd.cod_cobertura = ls_cobertura;

		IF li_acepta_desc IS NULL THEN
		   LET li_acepta_desc = 0;
		END IF

		LET ld_prima = ld_factor_vigencia * ld_prima_anual;
		LET ld_prima_resta = ld_prima;

	    -- Buscar Descuento
		LET ld_descuento = 0.00;
		LET _desc_porc = 0;
		LET _desc_cob = 0;
		LET _descuento_feria = 0.00;
		LET ld_prima_aux = ld_prima;
		let ld_prima_acu = ld_prima;
		let _desc_cob_total = 0;

		If li_acepta_desc = 1 Then
			if _cod_tipo_tar is null then -- Inclusion de unidad
			   select no_motor 
			     into _no_motor
				 from endmoaut
				where no_poliza = a_poliza
				  and no_endoso = a_endoso
				  and no_unidad = ls_unidad;
				  
			   select cod_marca,
			          cod_modelo,
					  nuevo
				 into _cod_marca,
			          _cod_modelo,
					  _nuevo
				 from emivehic 
				where no_motor = _no_motor;
				
			   let _descuento_pr_tipov = 0;
			   let _descuento_pr_tipov = sp_proe89b(a_poliza, a_endoso, ls_unidad);
				
			   if _tipo_descuento = 1 then	--> Descuento RC, solo polizas nuevas
					let _tipo_auto = 0;
					let _tipo_auto = sp_proe76(a_poliza, a_endoso, ls_unidad);
					if _tipo_auto = 0 then
						let _descuento_max = 0;
					end if 
					if _descuento_max > 0 then
						let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura, '004', _descuento_max); -- Descuento combinado
					end if
					if _descuento_pr_tipov > 0 then
						let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura, '009', _descuento_pr_tipov); -- Descuento tipo automovil por producto
						let _descuento_max = _descuento_max + _descuento_pr_tipov;
					end if
					let _desc_porc   = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
			   elif _tipo_descuento = 2 then --> Descuento Combinado Casco, solo polizas nuevas
					let _descuento_max = 0;
					if ls_ramo = '002' and _cod_subramo = '001' then -- Solo automovil particulares
						let _descuento_max = sp_proe85c(a_poliza,ls_unidad,a_endoso); --> Descuento Vehiculos Clasificados, solo polizas nuevas
					end if
					if _descuento_max > 0 then
						let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura, '007', _descuento_max); -- Descuento Vehiculo Clasificado
							--#########################################################################################
							let _desc_porc   = _descuento_max / 100;
							let _desc_cob    = ld_prima_acu * _desc_porc;
							let ld_prima_acu = ld_prima_acu - _desc_cob;
							let _desc_cob_total = _desc_cob + _desc_cob_total;
							--#########################################################################################	
						if ls_ramo = '002' and _cod_subramo = '001' then -- Solo automovil particulares
							let _descuento_edad = sp_proe86c(a_poliza,ls_unidad,a_endoso); --> Descuento por edad
							if _descuento_edad > 0 then
								let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura,'008',_descuento_edad);
								--let _descuento_max = _descuento_max + _descuento_edad;
								--#########################################################################################
								let _desc_porc   = _descuento_edad / 100;
								let _desc_cob    = ld_prima_acu * _desc_porc;
								let ld_prima_acu = ld_prima_acu - _desc_cob;
								let _desc_cob_total = _desc_cob + _desc_cob_total;
								--#########################################################################################	
							end if
						end if
					else
						let _descuento_max = sp_proe77(a_poliza, a_endoso, ls_unidad); 
						if _descuento_max > 0 then
							let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura, '004', _descuento_max); -- Descuento combinado
							--#########################################################################################
							let _desc_porc   = _descuento_max / 100;
							let _desc_cob    = ld_prima_acu * _desc_porc;
							let ld_prima_acu = ld_prima_acu - _desc_cob;
							let _desc_cob_total = _desc_cob + _desc_cob_total;
							--#########################################################################################	
							if ls_ramo = '002' and _cod_subramo = '001' then -- Solo automovil particulares
								let _descuento_edad = sp_proe86c(a_poliza,ls_unidad,a_endoso); --> Descuento por edad
								if _descuento_edad > 0 then
									let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura,'008',_descuento_edad);
									--let _descuento_max = _descuento_max + _descuento_edad;
									--#########################################################################################
									let _desc_porc   = _descuento_edad / 100;
									let _desc_cob    = ld_prima_acu * _desc_porc;
									let ld_prima_acu = ld_prima_acu - _desc_cob;
									let _desc_cob_total = _desc_cob + _desc_cob_total;
									--#########################################################################################	
								end if
							end if
						end if
						
						let _desc_modelo = 0;
						let _desc_modelo = sp_proe81(_cod_marca, _cod_modelo);	
						if ls_producto in ('02206','03005','03012', '03013') and _nuevo = 1 then -- MotorShow
							let _descuento_feria = sp_proe83(_cod_marca, _cod_modelo);
							--let _desc_modelo = _desc_modelo + _descuento_feria;
						end if
						if _desc_modelo > 0 then
							let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura, '005', _desc_modelo); -- Descuento por modelo
							--#########################################################################################
							let _desc_porc   = _desc_modelo / 100;
							let _desc_cob    = ld_prima_acu * _desc_porc;
							let ld_prima_acu = ld_prima_acu - _desc_cob;
							let _desc_cob_total = _desc_cob + _desc_cob_total;
							--#########################################################################################	
						end if			
						if _descuento_feria > 0 then
							--#########################################################################################
							let _desc_porc   = _descuento_feria / 100;
							let _desc_cob    = ld_prima_acu * _desc_porc;
							let ld_prima_acu = ld_prima_acu - _desc_cob;
							let _desc_cob_total = _desc_cob + _desc_cob_total;
							--#########################################################################################	
						end if
						--let _descuento_max = _descuento_max + _desc_modelo;
					end if
					
					if _descuento_pr_tipov > 0 then
						let _retorno = sp_sis431(a_poliza, ls_unidad, a_endoso, ls_cobertura, '009', _descuento_pr_tipov); -- Descuento tipo automovil por producto
						--let _descuento_max = _descuento_max + _descuento_pr_tipov;
						--#########################################################################################
						let _desc_porc   = _descuento_pr_tipov / 100;
						let _desc_cob    = ld_prima_acu * _desc_porc;
						let ld_prima_acu = ld_prima_acu - _desc_cob;
						let _desc_cob_total = _desc_cob + _desc_cob_total;
						--#########################################################################################	
					end if
					
					let _desc_cob    = _desc_cob_total;
					let ld_prima_aux = ld_prima_acu;
						
					--let _desc_porc   = _descuento_max / 100;
					--let _desc_cob    = ld_prima * _desc_porc;
					--let ld_prima_aux = ld_prima - _desc_cob;
			   end if
            else -- Modificacion
			   if _tipo_descuento = 1 and _cod_tipo_tar = '002'  then	--> Descuento RC, solo polizas nuevas
					let _tipo_auto = 0;
					let _tipo_auto = sp_proe75(a_poliza,a_unidad);
					if _tipo_auto = 0 then
						let _descuento_max = 0;
					end if
					
					let _desc_porc     = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
			   elif _tipo_descuento = 2 and _cod_tipo_tar = '002'  then --> Descuento Combinado Casco, solo polizas nuevas
					let _descuento_max = sp_sis430(a_poliza, a_endoso, a_unidad, ls_cobertura);

			        if  _descuento_max = 0.00 then
						let _descuento_max = sp_proe72b(a_poliza,a_endoso,a_unidad); 
					end if
					
					let _desc_porc     = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
			   end if

		{	   if _tipo_descuento in (1,2) and _cod_tipo_tar = '001' and _fecha_suscripcion >= "28/07/2014" and _nueva_renov = "R" then
					let _descuento_max = sp_proe78(a_poliza, a_unidad, ls_producto, ls_cobertura);
					
					let _desc_porc     = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
			   end if
		}	   
			   
			    if _cod_tipo_tar = '001' or _cod_tipo_tar = '004' or _cod_tipo_tar = '005' or _cod_tipo_tar = '006' or _cod_tipo_tar = '007' or _cod_tipo_tar = '008' then -- Descuento por modelo, Descuento por Siniestralidad, Descuento Sedan
					let _descuento_max = sp_sis430(a_poliza, a_endoso, a_unidad, ls_cobertura);
					let _desc_porc     = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
					
					
					{if a_poliza = '2015270' and ls_unidad = '00001' and a_endoso = '00001' and ls_cobertura in('00118','00119')then
						let v_tot_descto   = 0.00;
						let v_prima_descto = ld_prima;
						foreach
							select x.porc_descuento
							  Into _descuento_max
							  from emicobde x
							 where x.no_poliza  = a_poliza
							   and x.no_unidad  = ls_unidad
							   and x.cod_cobertura = ls_cobertura

							if _descuento_max is null then
								let _descuento_max = 0.00;
							end if

							let v_tot_descto   = v_tot_descto + ((_descuento_max * v_prima_descto)/100);
							let v_prima_descto = v_prima_descto - ((_descuento_max * v_prima_descto)/100); --v_tot_descto;

						end foreach
						let ld_prima_aux = v_prima_descto;
						let _desc_cob = v_tot_descto;
				    end if}

                    -- Amado 01-08-2025 cuando hay mas de 2 descuentos se estaba calculando mal y descontaba de más
					let v_tot_descto   = 0.00;
					let v_prima_descto = ld_prima;
					
					select count(*)
					  into _cant
					  from endcobde  
					 where no_poliza = a_poliza
					   and no_endoso = a_endoso
					   and no_unidad = a_unidad 
					   and cod_cobertura = ls_cobertura;
							   
					If _cant = 0 then 
						foreach
							select porc_descuento
							  into _descuento_max
							  from emicobde  
							 where no_poliza = a_poliza
							   and no_unidad = a_endoso 
							   and cod_cobertura = ls_cobertura
							   
							if _descuento_max is null then
								let _descuento_max = 0.00;
							end if
							
							let _desc_porc     = _descuento_max / 100;
							let _desc_cob      = v_prima_descto * _desc_porc;
							let v_prima_descto = v_prima_descto - _desc_cob;
							let v_tot_descto   = v_tot_descto   + _desc_cob;	
							   
						end foreach
					else
						foreach
							select porc_descuento
							  into _descuento_max
							  from endcobde  
							 where no_poliza = a_poliza
							   and no_endoso = a_endoso
							   and no_unidad = a_unidad 
							   and cod_cobertura = ls_cobertura

							if _descuento_max is null then
								let _descuento_max = 0.00;
							end if

							let _desc_porc     = _descuento_max / 100;
							let _desc_cob      = v_prima_descto * _desc_porc;
							let v_prima_descto = v_prima_descto - _desc_cob;
							let v_tot_descto   = v_tot_descto   + _desc_cob;	
						end foreach
					end if
					
					let ld_prima_aux = v_prima_descto;
					let _desc_cob = v_tot_descto;
				
			    end if
			end if
            if _desc_cob > 0 then
				delete from endunide
				 where no_poliza = a_poliza
				   and no_endoso = a_endoso
				   and no_unidad = ls_unidad
				   and cod_descuen = "001";
		    end if

		    CALL sp_proe36(a_poliza, a_endoso, ls_unidad, ld_prima_aux) RETURNING ld_descuento;

            LET ld_descuento = ld_descuento + _desc_cob;
		End If

		If ld_descuento > 0 Then
		   LET ld_prima_resta = ld_prima - ld_descuento;
		End If

		-- Buscar Recargo
		LET ld_recargo = 0.00;
		If li_acepta_desc = 1 Then
		   CALL sp_proe37(a_poliza, a_endoso, ls_unidad, ld_prima_resta) RETURNING ld_recargo;
		End If

		-- Calcular Prima Neta
		LET ld_prima_neta = ld_prima + ld_recargo - ld_descuento;

		Update endedcob
		   Set prima 			= ld_prima,
			   descuento		= ld_descuento,
			   recargo			= ld_recargo,
			   prima_neta		= ld_prima_neta
		 Where no_poliza 		= a_poliza
		   And no_endoso        = a_endoso
		   And no_unidad 		= ls_unidad
		   And cod_cobertura	= ls_cobertura;
	END FOREACH

--	CALL sp_proe38(a_poliza, a_endoso, ls_unidad, a_cia) RETURNING _error;
END FOREACH
RETURN 0;
END
END PROCEDURE;
