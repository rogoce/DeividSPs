-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_rea_unidad
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe05bk1;
CREATE PROCEDURE "informix".sp_proe05bk1(a_poliza CHAR(10), a_unidad CHAR(5), a_ruta CHAR(5), a_suma DECIMAL(16,2), a_endoso CHAR(5))
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
define _no_endoso           char(5);
define _cod_cober_reas      char(3);
define _ld_prima_neta_t   	DECIMAL(16,2);
define _prima_neta_emif     DECIMAL(16,2);
define _suma_aseg_emif      DECIMAL(16,2);
define _prima_dif        	dec(16,2);
define _suma_dif            dec(16,2);



BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe05bk1.trc";      
--TRACE ON;
                                                                     
-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
Select cod_tipoprod,cod_ramo
  Into ls_tipopro,ls_ramo
  From emipomae
 Where no_poliza = a_poliza;

Select emitipro.tipo_produccion Into li_tipopro
  From emitipro
 Where emitipro.cod_tipoprod = ls_tipopro;

LET ld_porc_coaseg = 0.00;

If li_tipopro = 2 Then
-- La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - Aseguradora Lider

   SELECT emicoama.porc_partic_coas INTO ld_porc_coaseg
     FROM parparam, emicoama
    WHERE parparam.cod_compania = '001'
      AND emicoama.no_poliza    = a_poliza
      AND emicoama.cod_coasegur = parparam.par_ase_lider;

   If ld_porc_coaseg Is Null Then
      LET ld_porc_coaseg = 0.00;
   End If
End If

if ls_ramo in('002','023') then
--	call sp_sis188c(a_poliza,a_endoso) returning _error,_mensaje;
	call sp_sis188(a_poliza) returning _error,_mensaje;
end if

-- Verificar si hay datos en Reaseguro Global
Select Count(*) Into ll_rea_glo
  From emigloco
 Where emigloco.no_poliza = a_poliza;

If ll_rea_glo Is Null Then
   LET ll_rea_glo = 0;
End If

Delete from emifacon
 Where no_poliza   = a_poliza
	And no_endoso  = a_endoso
	And no_unidad  = a_unidad;
	
LET ld_suma 	  = 0.00;
LET ld_porc_suma  = 0.00;
	
FOREACH
     SELECT p.cod_cober_reas, Sum(e.prima_neta)
	   INTO ls_cober_reas, ld_letra
       FROM endedcob e, prdcober p
      WHERE e.no_poliza = a_poliza
        AND e.no_unidad = a_unidad
        AND p.cod_cobertura = e.cod_cobertura
      GROUP BY p.cod_cober_reas

     FOREACH
  	    SELECT rearucon.cod_contrato,   
			   rearucon.porc_partic_suma,
			   rearucon.porc_partic_prima,   
   			   rearucon.orden  
  		  INTO ls_contrato, ld_porc_suma, ld_porc_prima, li_orden
  		  FROM rearucon  
	  	 WHERE rearucon.cod_ruta       = a_ruta
		   AND rearucon.cod_cober_reas = ls_cober_reas
	  ORDER BY rearucon.orden ASC

		LET ld_suma  = 0.00;
		LET ld_prima = 0.00;
		let ld_porc_coaseg = 0.00;
		
		LET ld_suma = (a_suma * ld_porc_suma) / 100;

		if ls_ramo in('002','023') then
			select porc_cober_reas
			  into _porc_proporcion
			  from tmp_dist_rea
			 where cod_cober_reas = ls_cober_reas;

			if _porc_proporcion = 0 then
				let _porc_proporcion = 100;
			end if
			let ld_suma = (a_suma * ld_porc_suma / 100) * _porc_proporcion / 100;

		end if

		If ld_porc_coaseg > 0 Then
			LET ld_suma = (ld_suma * ld_porc_coaseg) / 100;
		End If

		LET ld_prima = (ld_letra * ld_porc_prima) / 100;
		If ld_porc_coaseg > 0 Then
			LET ld_prima = (ld_prima * ld_porc_coaseg) / 100;
		End If
			 
		if ld_suma is null then
			let ld_suma = 0;
		end if
		if ld_prima is null then
			let ld_prima = 0;
		end if

       	Select Count(*) Into li_return
		  From emifacon
		 Where emifacon.no_poliza = a_poliza
		   And emifacon.no_endoso = a_endoso
		   And emifacon.no_unidad = a_unidad
		   And emifacon.cod_cober_reas = ls_cober_reas
		   And emifacon.orden = li_orden;

			If li_return = 0 Then

				Select max(orden) + 1
				  Into li_return
				  From emifacon
				 Where emifacon.no_poliza = a_poliza
				   And emifacon.no_endoso = a_endoso
				   And emifacon.no_unidad = a_unidad
				   And emifacon.cod_cober_reas = ls_cober_reas;

				if li_return is null then
					let li_return = 0;
					let li_return = li_return + 1;
				end if

				Insert Into emifacon (no_poliza, no_endoso, no_unidad, cod_cober_reas, orden,
									  cod_contrato, porc_partic_suma, porc_partic_prima,
									  suma_asegurada, prima, cod_ruta)
				
				Values (a_poliza, a_endoso, a_unidad, ls_cober_reas, li_return, ls_contrato,
						  ld_porc_suma, ld_porc_prima, ld_suma, ld_prima, a_ruta);
			Else
				If ld_prima > 0 Then
				   Update emifacon
					  Set prima				= prima + ld_prima,
					      suma_asegurada    = suma_asegurada + ld_suma
					Where no_poliza 		= a_poliza
					  And no_endoso        	= a_endoso
					  And no_unidad 		= a_unidad
					  And cod_cober_reas	= ls_cober_reas
					  And orden				= li_orden;
				End If
			End If
     END FOREACH
	 {		---Verificacion de centavos diferencia
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
		   and no_endoso = a_endoso
		   and no_unidad = a_unidad;

		let _prima_dif = 0;
        let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;

        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emifacon
			   set prima			= prima + _prima_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= a_endoso
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden			= li_orden;
			
        end if

		let _suma_dif = 0;
        let _suma_dif = a_suma - _suma_aseg_emif;
		
        if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then

			update emifacon
			   set suma_asegurada   = suma_asegurada + _suma_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= a_endoso
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden			= li_orden;
			
        end if }

END FOREACH

Select max(orden) + 1
  Into li_return
  From emifacon
 Where no_poliza = a_poliza
   And no_endoso = a_endoso
   And no_unidad = a_unidad;


Select * From emifacon
 Where no_poliza = a_poliza
   And no_unidad = a_unidad
   And no_endoso <> a_endoso
   into temp prueba;


foreach

  select orden,no_endoso,cod_cober_reas
    into li_orden,_no_endoso,_cod_cober_reas
	from prueba

	update prueba
	   set no_endoso      = a_endoso,
	       suma_asegurada = suma_asegurada * -1,
	       prima          = prima * -1,
		   porc_partic_suma  = 0,
		   porc_partic_prima = 0,
		   subir_bo          = 0,
		   orden             = li_return
	 where no_poliza		 = a_poliza
	   and no_endoso		 = _no_endoso
	   and no_unidad		 = a_unidad
	   and cod_cober_reas	 = _cod_cober_reas
	   and orden			 = li_orden;


  let li_return = li_return + 1;

end foreach

insert into emifacon select * from prueba;

--drop table prueba;

{Select max(orden) + 1
  Into li_return
  From emifacon
 Where no_poliza = a_poliza
   And no_endoso = a_endoso
   And no_unidad = a_unidad
   And cod_cober_reas = '031';


Select * From emifacon
 Where no_poliza = a_poliza
   And no_unidad = a_unidad
   And no_endoso <> a_endoso
   And cod_cober_reas = '031' into temp prueba;

foreach

  select orden,no_endoso
    into li_orden,_no_endoso
	from prueba

	update prueba
	   set no_endoso      = a_endoso,
	       suma_asegurada = suma_asegurada * -1,
	       prima          = prima * -1,
		   porc_partic_suma  = 0,
		   porc_partic_prima = 0,
		   subir_bo          = 0,
		   orden             = li_return
	 where no_poliza		 = a_poliza
	   and no_endoso		 = _no_endoso
	   and no_unidad		 = a_unidad
	   and cod_cober_reas	 = '031'
	   and orden			 = li_orden;


  let li_return = li_return + 1;

end foreach

insert into emifacon select * from prueba;}

if ls_ramo in('002','023') then
 drop table tmp_dist_rea;
 drop table prueba;
end if

RETURN 0;
END
END PROCEDURE;