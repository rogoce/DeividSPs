-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe04;
CREATE PROCEDURE "informix".sp_proe04(a_poliza CHAR(10), a_unidad CHAR(5), a_suma DECIMAL(16,2), a_cia CHAR(3))
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
DEFINE _cant				SMALLINT;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe04.trc";
--TRACE ON;
                                                                     
-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
Select emipomae.cod_tipoprod
  Into ls_tipopro
  From emipomae
 Where emipomae.no_poliza = a_poliza;

Select emitipro.tipo_produccion Into li_tipopro
  From emitipro
 Where emitipro.cod_tipoprod = ls_tipopro;

LET ld_porc_coaseg = 0.00;

If li_tipopro = 2 Then
-- La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - Aseguradora Lider

   SELECT emicoama.porc_partic_coas INTO ld_porc_coaseg
     FROM parparam, emicoama
    WHERE parparam.cod_compania = a_cia
      AND emicoama.no_poliza    = a_poliza
      AND emicoama.cod_coasegur = parparam.par_ase_lider;

   If ld_porc_coaseg Is Null Then
      LET ld_porc_coaseg = 0.00;
   End If
End If

-- Verificar si hay datos en Reaseguro Global
Select Count(*) Into ll_rea_glo
  From emigloco
 Where emigloco.no_poliza = a_poliza;

If ll_rea_glo Is Null Then
   LET ll_rea_glo = 0;
End If

Delete from emifacon
 Where no_poliza   = a_poliza
	And no_endoso  = '00000'
	And no_unidad  = a_unidad;
	
LET ld_suma 	  = 0.00;
LET ld_porc_suma  = 0.00;

	
FOREACH
     SELECT prdcober.cod_cober_reas, Sum(emipocob.prima_neta)
	   INTO ls_cober_reas, ld_letra
       FROM emipocob, prdcober  
      WHERE emipocob.no_poliza = a_poliza
        AND emipocob.no_unidad = a_unidad
        AND prdcober.cod_cobertura = emipocob.cod_cobertura
      GROUP BY prdcober.cod_cober_reas



     FOREACH
		Select emigloco.cod_contrato, emigloco.porc_partic_suma, emigloco.porc_partic_prima,
		       emigloco.cod_ruta, emigloco.orden
  		  Into ls_contrato, ld_porc_suma, ld_porc_prima, ls_ruta, li_orden
		  From emigloco
		 Where emigloco.no_poliza = a_poliza
		   And emigloco.no_endoso = '00000'

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
			 
       	Select Count(*) Into li_return
		  From emifacon
		 Where emifacon.no_poliza = a_poliza
		   And emifacon.no_endoso = '00000'
		   And emifacon.no_unidad = a_unidad
		   And emifacon.cod_cober_reas = ls_cober_reas
		   And emifacon.orden = li_orden;

		If li_return = 0 Or li_return IS NULL Then
			Insert Into emifacon (no_poliza, no_endoso, no_unidad, cod_cober_reas, orden,
								  cod_contrato, porc_partic_suma, porc_partic_prima,
								  suma_asegurada, prima, cod_ruta)
			
			Values (a_poliza, "00000", a_unidad, ls_cober_reas, li_orden, ls_contrato,
					  ld_porc_suma, ld_porc_prima, ld_suma, ld_prima, ls_ruta);
		Else
			If ld_prima > 0 Then
			   Update emifacon
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
END
END PROCEDURE;