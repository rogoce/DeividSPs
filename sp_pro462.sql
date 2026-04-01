drop procedure sp_pro462;
create procedure "informix".sp_pro462(v_poliza char(10), v_endoso char(5), v_unidad char(5))

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
--set debug file to "victor2.txt";
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

	  if v_impuesto > 0.00 then
	     let v_impuesto = (v_prima_neta * v_impuesto) / 100;
	  else
	     let v_impuesto = 0.00;
	  end if

  End If

  let v_prima_bruta = v_prima_neta + v_impuesto;

  select sum(emifacon.prima) into v_prima_suscrita
    from emifacon
   where emifacon.no_poliza   = v_poliza
     and emifacon.no_endoso   = v_endoso
     and emifacon.no_unidad   = v_unidad;
  if v_prima_suscrita is null Then
     let v_prima_suscrita = 0.00;
  end if

  select sum(emifacon.prima) into v_prima_retenida
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
       v_prima_bruta, r_suma, v_prima_suscrita, v_prima_retenida  WITH RESUME;


--Select SUM(x.prima), SUM(x.descuento), SUM(x.recargo), SUM(x.prima_neta),
--       SUM(x.impuesto), SUM(x.prima_bruta), SUM(suma_asegurada),
--	   SUM(x.prima_suscrita), SUM(x.prima_retenida) 
--  Into r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto,
--       r_prima_bruta, r_suma_aseg, v_prima_suscrita, v_prima_retenida
--  From endeduni x
-- Where x.no_poliza = v_poliza
--   And x.no_endoso = v_endoso;

--update endedmae
--   set endedmae.prima       = r_prima,
--       endedmae.descuento   = r_descuento,
--       endedmae.recargo     = r_recargo,
--       endedmae.prima_neta  = r_prima_neta,
--       endedmae.impuesto    = r_impuesto,
--       endedmae.prima_bruta = r_prima_bruta,
--       endedmae.prima_suscrita = v_prima_suscrita,
--       endedmae.prima_retenida = v_prima_retenida,
--       endedmae.suma_asegurada = r_suma_aseg
-- where endedmae.no_poliza   = v_poliza
--   and endedmae.no_endoso   = v_endoso;

--Select x.prima, x.descuento, x.recargo, x.prima_neta, x.impuesto, x.prima_bruta,
--       x.suma_asegurada, x.prima_suscrita, x.prima_retenida
-- Into r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto, r_prima_bruta,
--       r_suma, v_prima_suscrita, v_prima_retenida
--  From endeduni x
-- Where x.no_poliza = v_poliza
--   And x.no_unidad = v_unidad
--   And x.no_endoso = v_endoso;

--RETURN r_error, r_descripcion, r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto,
--       r_prima_bruta, r_suma, v_prima_suscrita, v_prima_retenida  WITH RESUME;

--trace off;
END
end procedure;
