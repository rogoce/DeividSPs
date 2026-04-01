--- Procedimiento para actualizar los valores de emifacon por unidad
-- Renovacion Automatica
-- Creado:     08/05/2009 - Autor Armando Moreno M.
-- Modificado: 08/05/2009 - Autor Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro323a;
CREATE PROCEDURE "informix".sp_pro323a(a_poliza CHAR(10), a_unidad CHAR(5), a_suma DECIMAL(16,2), a_cia CHAR(3))
			RETURNING   INTEGER   -- _error


DEFINE ls_cober_reas			CHAR(3);
DEFINE ls_contrato, ls_ruta		CHAR(5);
DEFINE ld_porc_suma				DECIMAL(10,4);
DEFINE ld_porc_prima  			DECIMAL(10,4);
DEFINE ld_suma					DECIMAL(16,2); 
DEFINE ld_letra					DECIMAL(16,2);
DEFINE li_orden					INTEGER;
DEFINE li_return				INTEGER;
DEFINE li_tipo_ramo, li_meses	INTEGER;
DEFINE _error, li_tipopro		INTEGER;
DEFINE li_uno					INTEGER;
DEFINE ls_ramo, ls_perpago  	CHAR(3);
DEFINE ls_impuesto, ls_tipopro	CHAR(3);
DEFINE ls_ase_lider				CHAR(3);
DEFINE ld_prima		   			DECIMAL(16,2);
DEFINE ld_descuento		   		DECIMAL(16,2);
DEFINE ld_recargo		   		DECIMAL(16,2);
DEFINE ld_prima_neta			DECIMAL(16,2);
DEFINE ld_prima_anual			DECIMAL(16,2);
DEFINE ld_suma_asegurada		DECIMAL(16,2);
DEFINE ld_impuesto		   		DECIMAL(16,2);
DEFINE ld_impuesto1		   		DECIMAL(16,2);
DEFINE ld_prima_bruta			DECIMAL(16,2);
DEFINE ld_prima_total			DECIMAL(16,2);
DEFINE ld_suscrita       		DECIMAL(16,2);
DEFINE ld_retenida       		DECIMAL(16,2);
DEFINE ld_imp_total       		DECIMAL(16,2);
DEFINE ld_porc_coaseg			DECIMAL(16,4);
DEFINE ld_porc_impuesto			DECIMAL(16,4);

define _ld_prima_neta_t  		DECIMAL(16,2);
define _prima_neta_emif			DECIMAL(16,2);
define _suma_aseg_emif			DECIMAL(16,2);
define _prima_dif               DECIMAL(16,2);
define _suma_dif                DECIMAL(16,2);

define _porc_proporcion		dec(9,6);
define _mensaje             char(100);


BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe04.trc";
--TRACE ON;
                                                                     
-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
Select cod_tipoprod,cod_ramo
  Into ls_tipopro,ls_ramo
  From emipomae
 Where no_poliza = a_poliza;

Select tipo_produccion
  Into li_tipopro
  From emitipro
 Where cod_tipoprod = ls_tipopro;

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

LET ld_suma 	  = 0.00;
LET ld_porc_suma  = 0.00;

if ls_ramo = '002' then
	call sp_sis188(a_poliza) returning _error,_mensaje;
end if

	
FOREACH
     SELECT prdcober.cod_cober_reas,
            Sum(emipocob.prima_neta)
	   INTO ls_cober_reas,
	   		ld_letra
       FROM emipocob, prdcober  
      WHERE emipocob.no_poliza     = a_poliza
        AND emipocob.no_unidad     = a_unidad
        AND prdcober.cod_cobertura = emipocob.cod_cobertura
      GROUP BY prdcober.cod_cober_reas
	  
	  select first 1 orden
	    into li_orden
	    from emifacon
	   where no_poliza = a_poliza
	     and no_endoso = '00000'
		 and no_unidad	 = a_unidad
		 and cod_cober_reas = ls_cober_reas;

     /*FOREACH
		Select porc_partic_suma,
			   porc_partic_prima,
			   cod_cober_reas,
			   orden
  		  Into ld_porc_suma,
  		  	   ld_porc_prima,
			   ls_cober_reas,
			   li_orden
		  From emifacon
		 Where no_poliza      = a_poliza
		   And no_endoso      = '00000'
		   And no_unidad 	  = a_unidad
		   And cod_cober_reas = ls_cober_reas

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
			 
		If ld_prima >= 0 Then
		   Update emifacon
			  Set prima			  = prima + ld_prima,
			      suma_asegurada  = suma_asegurada + ld_suma
			Where no_poliza 	  = a_poliza
			  And no_endoso       = '00000'
			  And no_unidad 	  = a_unidad
			  And cod_cober_reas  = ls_cober_reas
			  And orden			  = li_orden;
		End If
     END FOREACH*/

		---Verificacion de centavos diferencia
		select sum(e.prima_neta)
		  into _ld_prima_neta_t
		  from emipocob e, prdcober c
	     where e.no_poliza = a_poliza
	       and e.no_unidad = a_unidad
	       and c.cod_cobertura = e.cod_cobertura;

		select sum(prima),
		       sum(suma_asegurada)
		  into _prima_neta_emif,
		       _suma_aseg_emif
		  from emifacon
		 where no_poliza = a_poliza
		   and no_endoso =	'00000'
		   and no_unidad =	a_unidad;

		let _prima_dif = 0;
        let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;

        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emifacon
			   set prima			= prima + _prima_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden = li_orden;
			
        end if

		let _suma_dif = 0;
        let _suma_dif = a_suma - _suma_aseg_emif;
		
        if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then

			update emifacon
			   set suma_asegurada   = suma_asegurada + _suma_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden = li_orden;
			
        end if 
END FOREACH

if ls_ramo = '002' then
	drop table if exists tmp_dist_rea;
end if

RETURN 0;
END
END PROCEDURE;