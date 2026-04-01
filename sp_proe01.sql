-- Procedimiento para actualizar los valores de las primas en emipocob
-- f_emision_calcular_primas
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe01;
CREATE PROCEDURE sp_proe01(a_poliza CHAR(10), a_unidad CHAR(5), a_cia CHAR(3))
			RETURNING   SMALLINT			 -- _error
						

DEFINE _error		  INTEGER;
DEFINE ls_cobertura   CHAR(5);	
DEFINE ls_unidad   	  CHAR(5);	
DEFINE ls_producto    CHAR(5);	
DEFINE ls_ramo        CHAR(3);

DEFINE ld_factor_vigencia   DECIMAL(9,6);  --10,4
DEFINE ld_prima             DECIMAL(16,2);
DEFINE ld_prima_resta		DECIMAL(16,2);
DEFINE ld_prima_anual		DECIMAL(16,2);
DEFINE ld_descuento			DECIMAL(16,2);
DEFINE ld_recargo			DECIMAL(16,2);
DEFINE ld_recargo_dep		DECIMAL(16,2);
DEFINE ld_prima_neta		DECIMAL(16,2);
DEFINE ld_prima_dep         DECIMAL(16,2);
DEFINE ld_prima_aux      	DECIMAL(16,2);
DEFINE _descuento_mod       DECIMAL(16,2);

DEFINE li_acepta_desc    	INTEGER;
DEFINE li_tipo_ramo			SMALLINT;
define _linea_rapida        smallint;
DEFINE _descuento_max		DECIMAL(5,2);
DEFINE _tipo_descuento      SMALLINT;

DEFINE _desc_cob 			DECIMAL(16,2);
DEFINE _nueva_renov         CHAR(1);
DEFINE _tipo_auto           SMALLINT;
DEFINE _desc_porc           DECIMAL(7,4);
DEFINE _descuento_feria     DECIMAL(5,2);
DEFINE _descuento_edad      DECIMAL(16,2);
DEFINE _descuento_tv_x_pr   DECIMAL(16,2);
DEFINE _valor				smallint;
DEFINE _cod_subramo         CHAR(3);
DEFINE _cotizacion          CHAR(10);
DEFINE _dias_cot, _fecha_inicio DATE; 
DEFINE _cont_dias           smallint;     
      
       
BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

if a_poliza = '0002700127' then
SET DEBUG FILE TO "sp_proe01.trc";      
TRACE ON;                                                                     
end if

let ld_factor_vigencia = 1.000000;
let _linea_rapida      = 0;

SELECT factor_vigencia, cod_ramo,linea_rapida, nueva_renov, cod_subramo, cotizacion
  INTO ld_factor_vigencia, ls_ramo,_linea_rapida, _nueva_renov, _cod_subramo, _cotizacion
  FROM emipomae 
 WHERE no_poliza = a_poliza;
 
let _fecha_inicio = null;
 
SELECT DATE(fechainicio)
  INTO _fecha_inicio
  FROM wf_db_autos
 where nrocotizacion = _cotizacion;

let _dias_cot = 0; 
let _cont_dias = 0;
 
if _fecha_inicio is not null then
	let _dias_cot = mdy(3, 3, 2017);
	let _cont_dias = _dias_cot - _fecha_inicio;
end if
  
Select prdramo.ramo_sis 
  Into li_tipo_ramo
  From prdramo
 Where prdramo.cod_ramo = ls_ramo;

if _linea_rapida = 1 and ls_ramo = '020' then
	return 0;
end if

foreach
 select no_unidad,
 	    cod_producto
   into ls_unidad,
    	ls_producto
   from emipouni 
  where no_poliza = a_poliza
	and no_unidad matches a_unidad

	FOREACH
     SELECT emipocob.cod_cobertura, 
            emipocob.prima_anual 
       INTO ls_cobertura, 
            ld_prima_anual
	   FROM emipocob
	  WHERE emipocob.no_poliza = a_poliza
	    AND emipocob.no_unidad = ls_unidad

        LET _descuento_max  = 0;
        LET _tipo_descuento = 0;
		let _descuento_mod  = 0;
		      		
		SELECT prdcobpd.acepta_desc, descuento_max, tipo_descuento
		  INTO li_acepta_desc, _descuento_max, _tipo_descuento 
		  FROM prdcobpd
		 WHERE prdcobpd.cod_producto  = ls_producto
		   AND prdcobpd.cod_cobertura = ls_cobertura;
		   		
		IF li_acepta_desc IS NULL THEN
		   LET li_acepta_desc = 0;
		END IF

        let ld_prima_dep = 0;

		If li_tipo_ramo = 5 Then   --> Amado cuando se hace un recargo a una unidad se tiene que aplicar solo a la prima del asegurado y no de toda la familia 17/11/2010
		    If ld_prima_anual <> 0.00 Then
				CALL sp_proe54(a_poliza, ls_unidad) RETURNING ld_prima_dep;
				LET ld_prima_dep = ld_factor_vigencia * ld_prima_dep;
			End if
	    End If
				
		LET ld_prima = ld_factor_vigencia * ld_prima_anual;
		
		LET ld_prima_resta = ld_prima - ld_prima_dep; --> Amado 17/11/2010
				
	    -- Buscar Descuento

		LET ld_descuento = 0.00;
		LET _desc_porc = 0;
		LET _desc_cob = 0;
		let _descuento_feria = 0;
		let _descuento_edad = 0;
		let _descuento_tv_x_pr = 0;
		
		LET ld_prima_aux = ld_prima;

		If li_acepta_desc = 1 Then
			if a_poliza != '0003018821' then
			   if _tipo_descuento = 1 and _nueva_renov = 'N' then	--> Descuento RC, solo polizas nuevas
					let _tipo_auto = 0;
					let _tipo_auto = sp_proe75(a_poliza,ls_unidad);
					if _tipo_auto = 0 then
						let _descuento_max = 0; 
					end if 
					if _descuento_max > 0 then
						let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'004',_descuento_max);
					end if
					let _descuento_tv_x_pr = sp_proe89(a_poliza, ls_unidad); --> Descuento por tipo de vehiculo por Producto (Ducruet)
					if _descuento_tv_x_pr > 0 then
						let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'009',_descuento_tv_x_pr);
						let _descuento_max = _descuento_max + _descuento_tv_x_pr; 
					end if
					let _desc_porc   = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
					
			   elif _tipo_descuento = 2 and _nueva_renov = 'N' then 
					if ls_ramo = '002' and _cod_subramo = '001' and _cont_dias > 15 or _cont_dias <= 0 or _cont_dias is null then -- Solo automovil particulares
						let _descuento_max = sp_proe85(a_poliza,ls_unidad); --> Descuento Vehiculos Clasificados, solo polizas nuevas
					else
						let _descuento_max = 0;
					end if
					if _descuento_max > 0 then
						let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'007',_descuento_max);
						let _descuento_edad = sp_proe86(a_poliza,ls_unidad); --> Descuento por edad
						if _descuento_edad > 0 then
							let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'008',_descuento_edad);
							let _descuento_max = _descuento_max + _descuento_edad;
						end if
					else		   
						let _descuento_max = sp_proe72(a_poliza,ls_unidad); --> Descuento Combinado Casco, solo polizas nuevas
						if _descuento_max > 0 then
							let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'004',_descuento_max);
							if ls_ramo = '002' and _cod_subramo = '001' then -- Solo automovil particulares
								if _cont_dias > 15 or _cont_dias <= 0 or _cont_dias is null then
									let _descuento_edad = sp_proe86(a_poliza,ls_unidad); --> Descuento por edad
								end if
								if _descuento_edad > 0 then
									let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'008',_descuento_edad);
									let _descuento_max = _descuento_max + _descuento_edad;
								end if
							end if
						end if
						let _descuento_mod = sp_proe80(a_poliza,ls_unidad); -- Descuento por modelo
						let _descuento_feria = sp_proe82(a_poliza,ls_unidad); -- MotorShow2015
						let _descuento_mod = _descuento_mod + _descuento_feria;
						if _descuento_mod > 0 then
							let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'005',_descuento_mod);
						end if
					end if
					let _descuento_tv_x_pr = sp_proe89(a_poliza, ls_unidad); --> Descuento por tipo de vehiculo por Producto (Ducruet)
					if _descuento_tv_x_pr > 0 then
						let _valor = sp_proe79(a_poliza, ls_unidad, ls_cobertura,'009',_descuento_tv_x_pr);
						let _descuento_max = _descuento_max + _descuento_tv_x_pr; 
					end if
					let _descuento_max = _descuento_max + _descuento_mod;
					let _desc_porc   = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
			   elif _tipo_descuento IN (1, 2) and _nueva_renov = 'R' THEN --> Descuento para las renovaciones
					let _descuento_max = sp_proe74(a_poliza, ls_unidad, ls_producto, ls_cobertura); 
					let _desc_porc   = _descuento_max / 100;
					let _desc_cob    = ld_prima * _desc_porc;
					let ld_prima_aux = ld_prima - _desc_cob;
			   end if

			   if _desc_cob > 0 and _nueva_renov = 'N' then
					delete from emiunide
					 where no_poliza = a_poliza
					   and no_unidad = ls_unidad
					   and cod_descuen = "001";

					update emipouni
					   set cod_tipo_tar	= '002'
					 where no_poliza = a_poliza
					   and no_unidad = ls_unidad;
			   end if

				if ls_producto in ('02206','03005','03012', '03013') and _nueva_renov = 'N' then -- MotorShow
					update emipouni
					   set cod_tipo_tar	= '007'
					 where no_poliza = a_poliza
					   and no_unidad = ls_unidad;
				end if
		   end if
		   CALL sp_proe21(a_poliza, ls_unidad, ld_prima_aux) RETURNING ld_descuento;

           LET ld_descuento = ld_descuento + _desc_cob;

		End If

		If ld_descuento > 0 Then
		   LET ld_prima_resta = ld_prima - ld_prima_dep - ld_descuento; --> CASO: 19914 USER: ITORRES cuando se hace un recargo a una unidad se tiene que aplicar solo a la prima del asegurado y no de toda la familia
		End If

		-- Buscar Recargo
		LET ld_recargo = 0.00;
		If li_acepta_desc = 1 Then
		   CALL sp_proe22(a_poliza, ls_unidad, ld_prima_resta) RETURNING ld_recargo;
		Else
			If a_poliza = '1213833' Then
			   CALL sp_proe22(a_poliza, ls_unidad, ld_prima_resta) RETURNING ld_recargo;
			End If
		End If
		
		
		-- Buscar Recargo por dependiente
		If li_acepta_desc = 1 Then
			LET ld_recargo_dep = 0.00;
			IF ld_prima_anual <> 0.00 THEN
				CALL sp_proe53(a_poliza, ls_unidad) RETURNING ld_recargo_dep;
				LET ld_recargo = ld_recargo + ld_recargo_dep;
			END IF
		end if

		-- Calcular Prima Neta
		LET ld_prima_neta = ld_prima + ld_recargo - ld_descuento;

		Update emipocob
		   Set prima 			= ld_prima,
			   descuento		= ld_descuento,
			   recargo			= ld_recargo,
			   prima_neta		= ld_prima_neta
		 Where no_poliza 		= a_poliza
		   And no_unidad 		= ls_unidad
		   And cod_cobertura	= ls_cobertura;

	END FOREACH

	CALL sp_proe02(a_poliza, ls_unidad, a_cia) RETURNING _error;

END FOREACH
RETURN 0;
END
END PROCEDURE;