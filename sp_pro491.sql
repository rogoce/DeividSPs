drop procedure sp_pro491;
create procedure "informix".sp_pro491(v_poliza char(10), v_endoso char(5), v_unidad char(5), v_producto char(5), v_tarifa char(1))

--- Inclusion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

RETURNING SMALLINT, CHAR(30);

BEGIN
DEFINE   r_error       SMALLINT;
DEFINE   r_descripcion CHAR(30);
DEFINE   r_cobertura   CHAR(5);
DEFINE   r_orden       SMALLINT;
DEFINE   r_limite1     CHAR(50);
DEFINE   r_limite2     CHAR(50);
DEFINE   r_deducible   CHAR(50);
DEFINE   r_cantidad    SMALLINT;
DEFINE   v_prima_descto DECIMAL(16,2);
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
DEFINE   v_cantidad    Smallint;
DEFINE   v_impto       Smallint;
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
DEFINE   v_signo       SMALLINT;


SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = NULL;
LET r_cobertura   = NULL;
LET r_limite1     = 0.00;
LET r_limite2     = 0.00;
LET r_orden       = 0;
LET r_deducible   = NULL;

--set debug file to "victor2.txt";
--trace on;

----------------
-----  Cargar las coberturas
----------------

   Select x.vigencia_inic, x.vigencia_final
     Into v_poliza_inic, v_poliza_fin
     From emipouni x
    Where x.no_poliza   = v_poliza
      And x.no_unidad   = v_unidad;

   LET v_dias = v_poliza_fin - v_poliza_inic;

   ----------------
   -----  Calculos de las coberturas
   ----------------
   foreach
     select x.cod_cobertura into v_cobertura
       from endedcob x
      where x.no_poliza = v_poliza
        and x.no_endoso = v_endoso
        and x.no_unidad = v_unidad

      let v_prima = 0.00;
      let v_rata_dia = 0.00;
      Select x.prima Into v_prima From endedcob x
       Where x.no_poliza     = v_poliza
         and x.no_endoso     = v_endoso
         and x.no_unidad     = v_unidad
         and x.cod_cobertura = v_cobertura;
      LET v_prima_cob = v_prima;

      ------------
      ---  Calcular el descuento de la cobertura
      ------------
      let v_porc_descto = 0.00;
      let v_tot_descto  = 0.00;
	  let v_prima_descto = v_prima_cob;
      foreach
         select x.porc_descuento Into v_porc_descto from endcobde x
         where x.no_poliza  = v_poliza
           and x.no_endoso  = v_endoso
           and x.no_unidad  = v_unidad
           and x.cod_cobertura = v_cobertura
         if v_porc_descto is null then
            let v_porc_descto = 0.00;
         end if
	     let v_tot_descto = v_tot_descto + ((v_porc_descto * v_prima_descto)/100);
	     let v_prima_descto = v_prima_descto - v_tot_descto;
      end foreach
      let v_tot_descto  = v_tot_descto * -1;

      -------------
      ---  Calcular el recargo de la cobertura
      ------------
      let v_tot_recargo = 0.00;
      select sum(x.porc_recargo) into v_tot_recargo from endcobre x
       where x.no_poliza  = v_poliza
         and x.no_endoso  = v_endoso
         and x.no_unidad  = v_unidad
         and x.cod_cobertura = v_cobertura;
      if v_tot_recargo is null then
         let v_tot_recargo = 0.00;
      else
         let v_tot_recargo = (v_tot_recargo * (v_prima_cob - v_tot_descto)/100);
      end if
      let v_prima_neta  = v_prima_cob + v_tot_descto - v_tot_recargo;

      -------------
      ---  actualizar valores de la cobertura
      ------------
      update endedcob
         set endedcob.descuento   = v_tot_descto,
             endedcob.recargo     = v_tot_recargo,
             endedcob.prima_neta  = v_prima_neta
       where endedcob.no_poliza   = v_poliza
         and endedcob.no_endoso   = v_endoso
         and endedcob.no_unidad   = v_unidad
         and endedcob.cod_cobertura = v_cobertura;

   end foreach
   ---  FIN DEL CALCULO DE LAS COBERTURAS
   ----------------------------------------------------------------------------
   ---  actualizar valores de la unidad
   ------------
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
   Select x.tiene_impuesto Into v_impto From endedmae x
    Where x.no_poliza    = v_poliza
      And x.no_endoso    = v_endoso;
   If v_impto = 1 Then
	   select Sum(y.factor_impuesto) Into v_impuesto From emipolim x, prdimpue y
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

   -------------
   if v_prima_uni < 0 Then
      let v_signo = -1;
   else
      let v_signo = 1;
   end if

   update endeduni
      set endeduni.prima       = v_prima_uni,
          endeduni.descuento   = v_tot_descto,
          endeduni.recargo     = v_tot_recargo,
          endeduni.prima_neta  = v_prima_neta,
          endeduni.impuesto    = v_impuesto,
          endeduni.prima_bruta = v_prima_bruta,
          endeduni.suma_asegurada = (endeduni.suma_asegurada * v_signo)
    where endeduni.no_poliza   = v_poliza
      and endeduni.no_endoso   = v_endoso
      and endeduni.no_unidad   = v_unidad;

   --  FIN DEL CALCULO DE LAS UNIDADES
   ---------------------------------------------------------------------------

   Select SUM(x.prima), SUM(x.descuento), SUM(x.recargo), SUM(x.prima_neta),
          SUM(x.impuesto), SUM(x.prima_bruta), SUM(suma_asegurada)
     Into r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto,
          r_prima_bruta, r_suma_aseg
     From endeduni x
    Where x.no_poliza = v_poliza
      And x.no_endoso = v_endoso;

   update endedmae
      set endedmae.prima       = r_prima,
          endedmae.descuento   = r_descuento,
          endedmae.recargo     = r_recargo,
          endedmae.prima_neta  = r_prima_neta,
          endedmae.impuesto    = r_impuesto,
          endedmae.prima_bruta = r_prima_bruta,
          endedmae.suma_asegurada = r_suma_aseg
    where endedmae.no_poliza   = v_poliza
      and endedmae.no_endoso   = v_endoso;

 RETURN r_error, r_descripcion  WITH RESUME;
--trace off;
END
end procedure;


 

