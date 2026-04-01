-- Procedimiento para actualizar los valores de emirerea por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 19/02/2005 - Autor Armando Moreno
-- copia del sp_proe04

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro82k;
CREATE PROCEDURE "informix".sp_pro82k(
a_poliza 	CHAR(10),
a_unidad 	CHAR(5),
a_suma 		DECIMAL(16,2),
a_cia 		CHAR(3),
a_opcion 	integer default 0
)
RETURNING   INTEGER   -- _error


DEFINE ls_cober_reas		CHAR(3);
DEFINE ls_contrato, ls_ruta	CHAR(5);
DEFINE ld_porc_suma, ld_porc_prima  DECIMAL(10,4);
DEFINE ld_suma				DECIMAL(16,2); 
DEFINE ld_letra				DECIMAL(16,2);
DEFINE li_orden, li_return, ll_rea_glo 	INTEGER;
DEFINE li_tipo_ramo, li_meses	INTEGER;
DEFINE _error, li_tipopro		INTEGER;
DEFINE li_uno					INTEGER;
DEFINE ls_ramo, ls_perpago  	CHAR(3);
DEFINE ls_impuesto, ls_tipopro	CHAR(3);
DEFINE ls_ase_lider				CHAR(3);

DEFINE ld_prima		   		DECIMAL(16,2);
DEFINE ld_descuento		   	DECIMAL(16,2);
DEFINE ld_recargo		   	DECIMAL(16,2);
DEFINE ld_prima_neta		DECIMAL(16,2);
DEFINE ld_prima_anual		DECIMAL(16,2);
DEFINE ld_suma_asegurada	DECIMAL(16,2);
DEFINE ld_impuesto		   	DECIMAL(16,2);
DEFINE ld_impuesto1		   	DECIMAL(16,2);
DEFINE ld_prima_bruta		DECIMAL(16,2);
DEFINE ld_prima_total		DECIMAL(16,2);
DEFINE ld_suscrita       	DECIMAL(16,2);
DEFINE ld_retenida       	DECIMAL(16,2);
DEFINE ld_imp_total       	DECIMAL(16,2);

DEFINE ld_porc_coaseg		DECIMAL(16,4);
DEFINE ld_porc_impuesto		DECIMAL(16,4);
define _ld_prima_neta_t     DECIMAL(16,2);
define _prima_neta_emif		DECIMAL(16,2);
define _suma_aseg_emif		DECIMAL(16,2);
define _prima_dif			DECIMAL(16,2);
define _suma_dif			DECIMAL(16,2);

IF a_poliza = '1056982' AND a_unidad = '00001' then
set debug file to "sp_pro82k.trc";
trace on;
end if
BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
Select cod_tipoprod
  Into ls_tipopro
  From emireaut
 Where no_poliza = a_poliza
   and no_unidad = a_unidad;

Select emitipro.tipo_produccion
  Into li_tipopro
  From emitipro
 Where emitipro.cod_tipoprod = ls_tipopro;

LET ld_porc_coaseg = 0.00;

If li_tipopro = 2 Then
-- La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - Aseguradora Lider

   SELECT emicoama.porc_partic_coas
     INTO ld_porc_coaseg
     FROM parparam, emicoama
    WHERE parparam.cod_compania = a_cia
      AND emicoama.no_poliza    = a_poliza
      AND emicoama.cod_coasegur = parparam.par_ase_lider;

   If ld_porc_coaseg Is Null Then
      LET ld_porc_coaseg = 0.00;
   End If
End If

LET ld_suma 	  = 0.00;
LET ld_porc_suma  = 0.00;
let _ld_prima_neta_t = 0.00;
let _prima_neta_emif = 0.00;
let _suma_aseg_emif	 = 0.00;
let _prima_dif		 = 0.00;
let _suma_dif        = 0.00;

if a_opcion = 0 then	--renovacion	

	FOREACH
	     SELECT prdcober.cod_cober_reas, 
	     		Sum(emireau2.prima_neta_o)
		   INTO ls_cober_reas,
		   		ld_letra
	       FROM emireau2, prdcober  
	      WHERE emireau2.no_poliza = a_poliza
	        AND emireau2.no_unidad = a_unidad
	        AND prdcober.cod_cobertura = emireau2.cod_cobertura
	   GROUP BY prdcober.cod_cober_reas
	   ORDER BY prdcober.cod_cober_reas

	     FOREACH

		   	Select cod_contrato,
			  	   porc_partic_suma,
			   	   porc_partic_prima,
			       cod_ruta,
			       orden
			  Into ls_contrato,
			 	   ld_porc_suma,
			 	   ld_porc_prima,
			 	   ls_ruta,
			 	   li_orden
			 From emirerea
			Where no_poliza = a_poliza
			  And no_endoso = '00000'
			  and no_unidad = a_unidad

			LET ld_suma  = 0.00;
			LET ld_prima = 0.00;
			
			LET ld_suma = (a_suma * ld_porc_suma) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			End If

			LET ld_prima = (ld_letra * ld_porc_prima) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			End If
				 
			If ld_prima > 0 Then
			   Update emirerea
				  Set prima				= ld_prima,
				      suma_asegurada    = ld_suma
				Where no_poliza 		= a_poliza
				  And no_endoso        	= '00000'
				  And no_unidad 		= a_unidad
				  And cod_cober_reas	= ls_cober_reas
				  And orden				= li_orden;
			End If
	     END FOREACH
	END FOREACH
	
	---Verificacion de centavos diferencia
	     SELECT Sum(emireau2.prima_neta_o)
		   INTO _ld_prima_neta_t
	       FROM emireau2, prdcober  
	      WHERE emireau2.no_poliza = a_poliza
	        AND emireau2.no_unidad = a_unidad
	        AND prdcober.cod_cobertura = emireau2.cod_cobertura;

		select sum(prima)
		  into _prima_neta_emif
		  from emirerea
		 where no_poliza = a_poliza
		   and no_endoso =	'00000'
		   and no_unidad =	a_unidad;

		let _prima_dif = 0;
        let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;
        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emirerea
			   set prima			= prima + _prima_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden			= li_orden;
			
        end if
		foreach
			select sum(suma_asegurada),
				   cod_cober_reas
			  into _suma_aseg_emif,
				   ls_cober_reas
			  from emirerea
			 where no_poliza = a_poliza
			   and no_endoso =	'00000'
			   and no_unidad =	a_unidad
			  group by cod_cober_reas
					  
			let _suma_dif = 0;
			let _suma_dif = a_suma - _suma_aseg_emif;
			
			if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then
			
				select e.orden
				  into li_orden
				  from emirerea e, reacomae r
				 where e.cod_contrato = r.cod_contrato
					and r.tipo_contrato = 1
					and e.no_poliza = a_poliza
					and e.no_endoso =	'00000'
					and e.no_unidad = a_unidad
					and e.cod_cober_reas = ls_cober_reas;
				
				update emirerea
				   set suma_asegurada   = suma_asegurada + _suma_dif
				 where no_poliza		= a_poliza
				   and no_endoso		= '00000'
				   and no_unidad		= a_unidad
				   and cod_cober_reas	= ls_cober_reas
				   and orden			= li_orden;
				
			end if
		end foreach
	
RETURN 0;
end if

if a_opcion = 1 then --opcion1
	FOREACH
	     SELECT prdcober.cod_cober_reas, 
	     		Sum(emireau2.prima_neta_1)
		   INTO ls_cober_reas,
		   		ld_letra
	       FROM emireau2, prdcober  
	      WHERE emireau2.no_poliza = a_poliza
	        AND emireau2.no_unidad = a_unidad
	        AND prdcober.cod_cobertura = emireau2.cod_cobertura
		    and emireau2.chek_1    = 1
	   GROUP BY prdcober.cod_cober_reas

	     FOREACH
			Select cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima,
			       cod_ruta,
			       orden
	  		  Into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   ls_ruta,
	  		  	   li_orden
			  From emireglo
			 Where no_poliza = a_poliza
			   And no_endoso = '00000'

			LET ld_suma  = 0.00;
			LET ld_prima = 0.00;
			
			LET ld_suma = (a_suma * ld_porc_suma) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			End If

			LET ld_prima = (ld_letra * ld_porc_prima) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			End If
				 
			If ld_prima > 0 Then
			   Update emirerea
				  Set prima				= ld_prima,
				      suma_asegurada    = ld_suma
				Where no_poliza 		= a_poliza
				  And no_endoso        	= '00000'
				  And no_unidad 		= a_unidad
				  And cod_cober_reas	= ls_cober_reas
				  And orden				= li_orden;
			End If
	     END FOREACH
	END FOREACH
	RETURN 0;
end if
if a_opcion = 2 then --opcion2
	FOREACH
	     SELECT prdcober.cod_cober_reas, 
	     		Sum(emireau2.prima_neta_2)
		   INTO ls_cober_reas,
		   		ld_letra
	       FROM emireau2, prdcober  
	      WHERE emireau2.no_poliza = a_poliza
	        AND emireau2.no_unidad = a_unidad
		    and emireau2.chek_2    = 1
	        AND prdcober.cod_cobertura = emireau2.cod_cobertura
	   GROUP BY prdcober.cod_cober_reas

	     FOREACH
			Select cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima,
			       cod_ruta,
			       orden
	  		  Into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   ls_ruta,
	  		  	   li_orden
			  From emireglo
			 Where no_poliza = a_poliza
			   And no_endoso = '00000'

			LET ld_suma  = 0.00;
			LET ld_prima = 0.00;
			
			LET ld_suma = (a_suma * ld_porc_suma) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			End If

			LET ld_prima = (ld_letra * ld_porc_prima) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			End If
				 
			If ld_prima > 0 Then
			   Update emirerea
				  Set prima				= ld_prima,
				      suma_asegurada    = ld_suma
				Where no_poliza 		= a_poliza
				  And no_endoso        	= '00000'
				  And no_unidad 		= a_unidad
				  And cod_cober_reas	= ls_cober_reas
				  And orden				= li_orden;
			End If
	     END FOREACH
	END FOREACH
	RETURN 0;
end if
END
END PROCEDURE;