drop procedure sp_pro462a;
create procedure sp_pro462a(v_poliza char(10), v_endoso char(5), v_unidad char(5))

--- Salvar Valores a las Unidades
--- Victor Molinar
--- 31/10/2000

RETURNING SMALLINT, CHAR(30), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2), DECIMAL(16,2);

BEGIN
DEFINE   r_error       SMALLINT;
DEFINE   r_descripcion CHAR(30);
DEFINE   r_suma        DECIMAL(16,2);
DEFINE   r_prima       DECIMAL(16,2);
DEFINE   r_descuento   DECIMAL(16,2);
DEFINE   r_recargo     DECIMAL(16,2);
DEFINE   r_prima_neta  DECIMAL(16,2);
DEFINE   r_impuesto    DECIMAL(16,4);
DEFINE   r_prima_bruta DECIMAL(16,2);
DEFINE   r_suma_aseg   DECIMAL(16,2);
DEFINE   v_cobertura   CHAR(5);
DEFINE   limite        VARCHAR(50);
DEFINE   factor        Decimal(9,6);
DEFINE   v_prima       Decimal(16,2);
DEFINE   v_dias        Smallint;
DEFINE   v_impto       Smallint;
DEFINE   v_cantidad    Smallint;
DEFINE   v_impuesto    Decimal(16,4);
DEFINE   v_rata_dia    Decimal(16,2);
DEFINE   v_poliza_inic Date;
DEFINE   v_poliza_fin  Date;
DEFINE   v_prima_uni   Decimal(16,2);
DEFINE   v_prima_cob   Decimal(16,2);
DEFINE   v_tot_descto  Decimal(16,2);
DEFINE   v_porc_descto Decimal(16,2);
DEFINE   v_tot_recargo Decimal(16,2);
DEFINE   v_prima_neta  Decimal(16,2);
DEFINE   v_prima_bruta Decimal(16,2);
DEFINE   v_prima_suscrita Decimal(16,2);
DEFINE   v_prima_retenida Decimal(16,2);
DEFINE   v_signo       SMALLINT;

DEFINE _cod_origen      CHAR(3); 
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _canti           SMALLINT;
DEFINE _aplica_imp      SMALLINT;
DEFINE _cod_impuesto    CHAR(3);
DEFINE _porct_imp		DECIMAL(9,6);
DEFINE _existe_imp		SMALLINT;
define _cod_ramo_uni    char(3);

SET ISOLATION TO DIRTY READ;

LET limite  = NULL;
LET factor  = 0.00;
LET v_prima = 0.00;
LET v_dias  = 0;
LET r_suma  = 0.00;
LET v_cantidad = 0;
LET v_impuesto = 0.00;
LET v_rata_dia = 0.00;
LET v_prima_uni = 0.00;
LET v_prima_cob = 0.00;
LET v_tot_descto = 0.00;
LET v_porc_descto = 0.00;
LET v_tot_recargo = 0.00;
LET v_prima_neta  = 0.00;
LET v_prima_bruta = 0.00;
LET v_prima_suscrita = 0.00;
LET v_prima_retenida = 0.00;

LET r_error       = 0;
LET r_descripcion = NULL;
LET r_prima       = 0.00;
LET r_descuento   = 0.00;
LET r_recargo     = 0.00;
LET r_prima_neta  = 0.00;
LET r_impuesto    = 0.00;
LET r_suma_aseg   = 0.00;

-------------
---  SAlvar Valores a Las Unidades
------------
--set debug file to "sp_pro462a.txt";
--trace on;

 select sum(x.prima), SUM(x.descuento), SUM(x.recargo), SUM(x.prima_neta)
   into v_prima_uni, v_tot_descto, v_tot_recargo, v_prima_neta
   from endedcob x
  where x.no_poliza   = v_poliza
    and x.no_endoso   = v_endoso
    and x.no_unidad   = v_unidad;

-------------
---  Calcular el impuesto de la unidad
------------
  let v_impuesto = 0.00;

  Select x.tiene_impuesto
    Into v_impto
    From endedmae x
   Where x.no_poliza    = v_poliza
     And x.no_endoso    = v_endoso;

  If v_impto = 1 Then

	  select Sum(y.factor_impuesto)
	    Into v_impuesto
	    From emipolim x, prdimpue y
	   where x.no_poliza    = v_poliza
	     and x.cod_impuesto = y.cod_impuesto
	     and y.pagado_por   = "C";
		 
      select cod_ramo into _cod_ramo_uni from emipouni where no_poliza = v_poliza and no_unidad = v_unidad;
	  if _cod_ramo_uni = '020' then
		let v_impuesto = 6;
	  end if
	  if v_impuesto > 0.00 then
	     let v_impuesto = (v_prima_neta * v_impuesto) / 100;
	  else
		SELECT cod_ramo,
			   cod_subramo,
			   cod_origen
		  INTO _cod_ramo,
			   _cod_subramo,
			   _cod_origen
		  FROM emipomae
		 where no_poliza = v_poliza;

		if _cod_ramo = "008" or _cod_ramo = "019" or _cod_ramo = "016" then

			select count(*)
			  into _canti
			  from emipolim
			 where no_poliza = v_poliza;

				if _canti = 0 then

					Select aplica_impuesto
					  Into _aplica_imp
					  From parorig
					 Where cod_origen = _cod_origen;

					if _aplica_imp = 1 then

						foreach
							Select cod_impuesto
							  into _cod_impuesto
							  From prdimsub
							 Where cod_ramo    = _cod_ramo
							   And cod_subramo = _cod_subramo

							   let _existe_imp = 0;

							   select count(*)
							   into _existe_imp
							   from endedimp
							   where no_poliza = v_poliza
							   and no_endoso = v_endoso
							   and cod_impuesto = _cod_impuesto;

							   if _existe_imp = 0 then
									Insert Into endedimp (no_poliza, no_endoso, cod_impuesto, monto)
									Values (v_poliza, v_endoso, _cod_impuesto, 0.00);
								end if
						end foreach

						   select Sum(y.factor_impuesto) 
								Into _porct_imp
								From endedimp x, prdimpue y
								where x.no_poliza    = v_poliza
								  and x.no_endoso    = v_endoso
								  and x.cod_impuesto = y.cod_impuesto
								  and y.pagado_por   = "C";

							let v_impuesto = v_prima_neta * ( _porct_imp / 100);
					else

						let v_impuesto = 0.00;

					end if
				end if

		end if	

	  end if

  End If

  let v_prima_bruta = v_prima_neta + v_impuesto;

  select sum(emifacon.prima)
    into v_prima_suscrita
    from emifacon
   where emifacon.no_poliza   = v_poliza
     and emifacon.no_endoso   = v_endoso
     and emifacon.no_unidad   = v_unidad;

  if v_prima_suscrita is null Then
     let v_prima_suscrita = 0.00;
  end if

  select sum(emifacon.prima)
    into v_prima_retenida
    from emifacon, reacomae
   where emifacon.no_poliza   = v_poliza
     and emifacon.no_endoso   = v_endoso
	 and emifacon.no_unidad   = v_unidad
	 and emifacon.cod_contrato  = reacomae.cod_contrato
	 and reacomae.tipo_contrato = "1";

  if v_prima_retenida is null Then
     let v_prima_retenida = 0.00;
  end if

  update endeduni
     set endeduni.prima       = v_prima_uni,
         endeduni.descuento   = v_tot_descto,
         endeduni.recargo     = v_tot_recargo,
         endeduni.prima_neta  = v_prima_neta,
         endeduni.impuesto    = v_impuesto,
         endeduni.prima_bruta = v_prima_bruta,
         endeduni.prima_suscrita = v_prima_suscrita,
         endeduni.prima_retenida = v_prima_retenida
   where endeduni.no_poliza   = v_poliza
     and endeduni.no_endoso   = v_endoso
     and endeduni.no_unidad   = v_unidad;

---  FIN DEL CALCULO DE LAS UNIDADES
----------------------------------------------------------------------------
Select x.suma_asegurada Into r_suma
  From endeduni x
 Where x.no_poliza = v_poliza
   And x.no_endoso = v_endoso
   And x.no_unidad = v_unidad;

RETURN r_error, r_descripcion, v_prima_uni, v_tot_descto, v_tot_recargo, v_prima_neta, v_impuesto,
       v_prima_bruta, r_suma, v_prima_suscrita, v_prima_retenida;

END
end procedure;
