
drop procedure sp_pro82fa;
CREATE PROCEDURE "informix".sp_pro82fa(a_poliza CHAR(10), a_unidad CHAR(5), a_suma DECIMAL(16,2), a_cia CHAR(3), a_opcion integer default 0)
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

define _porc_proporcion		dec(9,6);
define _mensaje             char(100);


BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

--if a_poliza = '0001065914' and a_unidad = '00001' then
--	SET DEBUG FILE TO "sp_pro82fa.trc";
--	TRACE ON;
--end if

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

foreach
	select cod_ruta
	  into ls_ruta
	  from emireglo
	 where no_poliza = a_poliza
	   and no_endoso = '00000'
	exit foreach;
end foreach

Delete from emirerea
 Where no_poliza   = a_poliza
   And no_endoso  = '00000'
   And no_unidad  = a_unidad;
	
LET ld_suma 	  = 0.00;
LET ld_porc_suma  = 0.00;

select cod_ramo into ls_ramo from emipomae
where no_poliza = a_poliza;

if ls_ramo = '002' then
	call sp_sis188(a_poliza) returning _error,_mensaje;
end if

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

	     FOREACH
			Select cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima,
			       orden
	  		  Into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   li_orden
			  From rearucon
			 Where cod_ruta       = ls_ruta
			   And cod_cober_reas = ls_cober_reas
			 order by orden

			LET ld_suma  = 0.00;
			LET ld_prima = 0.00;
			
			LET ld_suma = (a_suma * ld_porc_suma) / 100;

			if ls_ramo = '002' then
				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = ls_cober_reas;

				let ld_suma = (a_suma * ld_porc_suma / 100) * _porc_proporcion / 100;

			end if

			If ld_porc_coaseg > 0 Then
				LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			End If

			LET ld_prima = (ld_letra * ld_porc_prima) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			End If
				 
	       	Select Count(*)
	       	  Into li_return
			  From emirerea
			 Where no_poliza      = a_poliza
			   And no_endoso      = '00000'
			   And no_unidad      = a_unidad
			   And cod_cober_reas = ls_cober_reas
			   And orden          = li_orden;
            if ld_suma is null then
				let ld_suma = 0.00;
			end if
			If li_return = 0 Or li_return IS NULL Then
				Insert Into emirerea (no_poliza, no_endoso, no_unidad, cod_cober_reas, orden,
									  cod_contrato, porc_partic_suma, porc_partic_prima,
									  suma_asegurada, prima, cod_ruta)
				
				Values (a_poliza, "00000", a_unidad, ls_cober_reas, li_orden, ls_contrato,
						  ld_porc_suma, ld_porc_prima, ld_suma, ld_prima, ls_ruta);
			Else
				If ld_prima > 0 Then
				   Update emirerea
					  Set prima				= prima + ld_prima,
					      suma_asegurada    = suma_asegurada + ld_suma
					Where no_poliza 		= a_poliza
					  And no_endoso        	= '00000'
					  And no_unidad 		= a_unidad
					  And cod_cober_reas	= ls_cober_reas
					  And orden				= li_orden;
				End If
			End If
	     END FOREACH
	END FOREACH
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
			       orden
	  		  Into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   li_orden
			  From rearucon
			 Where cod_ruta       = ls_ruta
			   And cod_cober_reas = ls_cober_reas
			 order by orden

			LET ld_suma  = 0.00;
			LET ld_prima = 0.00;
			
			LET ld_suma = (a_suma * ld_porc_suma) / 100;

			if ls_ramo = '002' then
				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = ls_cober_reas;

				let ld_suma = (a_suma * ld_porc_suma / 100) * _porc_proporcion / 100;

			end if

			If ld_porc_coaseg > 0 Then
				LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			End If

			LET ld_prima = (ld_letra * ld_porc_prima) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			End If
				 
	       	Select Count(*)
	       	  Into li_return
			  From emirerea
			 Where no_poliza      = a_poliza
			   And no_endoso      = '00000'
			   And no_unidad      = a_unidad
			   And cod_cober_reas = ls_cober_reas
			   And orden          = li_orden;
			   
            if ld_suma is null then
				let ld_suma = 0.00;
			end if
			If li_return = 0 Or li_return IS NULL Then
				Insert Into emirerea (no_poliza, no_endoso, no_unidad, cod_cober_reas, orden,
									  cod_contrato, porc_partic_suma, porc_partic_prima,
									  suma_asegurada, prima, cod_ruta)
				
				Values (a_poliza, "00000", a_unidad, ls_cober_reas, li_orden, ls_contrato,
						  ld_porc_suma, ld_porc_prima, ld_suma, ld_prima, ls_ruta);
			Else
				If ld_prima > 0 Then
				   Update emirerea
					  Set prima				= prima + ld_prima,
					      suma_asegurada    = suma_asegurada + ld_suma
					Where no_poliza 		= a_poliza
					  And no_endoso        	= '00000'
					  And no_unidad 		= a_unidad
					  And cod_cober_reas	= ls_cober_reas
					  And orden				= li_orden;
				End If
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
			       orden
	  		  Into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   li_orden
			  From rearucon
			 Where cod_ruta       = ls_ruta
			   And cod_cober_reas = ls_cober_reas
			 order by orden

			LET ld_suma  = 0.00;
			LET ld_prima = 0.00;
			
			LET ld_suma = (a_suma * ld_porc_suma) / 100;

			if ls_ramo = '002' then
				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = ls_cober_reas;

				let ld_suma = (a_suma * ld_porc_suma / 100) * _porc_proporcion / 100;

			end if

			If ld_porc_coaseg > 0 Then
				LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			End If

			LET ld_prima = (ld_letra * ld_porc_prima) / 100;
			If ld_porc_coaseg > 0 Then
				LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			End If
				 
	       	Select Count(*)
	       	  Into li_return
			  From emirerea
			 Where no_poliza      = a_poliza
			   And no_endoso      = '00000'
			   And no_unidad      = a_unidad
			   And cod_cober_reas = ls_cober_reas
			   And orden          = li_orden;
			   
            if ld_suma is null then
				let ld_suma = 0.00;
			end if
			If li_return = 0 Or li_return IS NULL Then
				Insert Into emirerea (no_poliza, no_endoso, no_unidad, cod_cober_reas, orden,
									  cod_contrato, porc_partic_suma, porc_partic_prima,
									  suma_asegurada, prima, cod_ruta)
				
				Values (a_poliza, "00000", a_unidad, ls_cober_reas, li_orden, ls_contrato,
						  ld_porc_suma, ld_porc_prima, ld_suma, ld_prima, ls_ruta);
			Else
				If ld_prima > 0 Then
				   Update emirerea
					  Set prima				= prima + ld_prima,
					      suma_asegurada    = suma_asegurada + ld_suma
					Where no_poliza 		= a_poliza
					  And no_endoso        	= '00000'
					  And no_unidad 		= a_unidad
					  And cod_cober_reas	= ls_cober_reas
					  And orden				= li_orden;
				End If
			End If
	     END FOREACH
	END FOREACH
	RETURN 0;
end if
if ls_ramo = '002' then
	drop table tmp_dist_rea;
end if

END
END PROCEDURE                                                                                                                                                                                                 
