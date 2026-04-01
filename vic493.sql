drop procedure sp_pro493;
create procedure "informix".sp_pro493(v_poliza char(10), v_endoso char(5), v_factor decimal(9,6))

--- Inclusion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

RETURNING SMALLINT, CHAR(30);

BEGIN
DEFINE   v_unidad          CHAR(5);
DEFINE   r_error           SMALLINT;
DEFINE   v_orden		   SMALLINT;
DEFINE   r_descripcion     CHAR(30);
DEFINE   v_prima_suscrita  DECIMAL(16,2);
DEFINE   v_prima_retenida  DECIMAL(16,2);
DEFINE   r_signo           DECIMAL(9,2);
DEFINE   v_factores        DECIMAL(9,4);
DEFINE   v_producto        CHAR(5);
DEFINE   v_tipocalc        CHAR(3);
DEFINE   v_cod_mov         CHAR(3);
DEFINE   v_cober_reas      CHAR(3);
DEFINE   v_tipo_mov	       SMALLINT;
DEFINE   v_tot_saldo       DECIMAL(16,2);
DEFINE   v_prima_total     DECIMAL(16,2);
DEFINE   r_prima_anual     DECIMAL(16,2);
DEFINE   v_prima           DECIMAL(16,2);
DEFINE   r_prima_neta      DECIMAL(16,2);
DEFINE   r_descuento       DECIMAL(16,2);
DEFINE   r_recargo         DECIMAL(16,2);
DEFINE   v_saldo           DECIMAL(16,2);
DEFINE   v_prima_cob       DECIMAL(16,2);
DEFINE   v_acepta          SMALLINT;
DEFINE   v_suma_asegurada  DECIMAL(16,2);
DEFINE   v_descuento       DECIMAL(16,2);
DEFINE   v_recargo         DECIMAL(16,2);
DEFINE   v_impuesto        DECIMAL(16,2);
DEFINE   v_cober_total     DECIMAL(16,2);
DEFINE   v_cobertura       CHAR(5);
DEFINE   v_contrato        CHAR(5);
DEFINE   v_coasegur        CHAR(3);
DEFINE   v_impto           DECIMAL(9,6);
DEFINE   v_partic_suma     DECIMAl(9,6);
DEFINE   v_partic_prima    DECIMAL(9,6);
DEFINE   v_partic_reas     DECIMAL(9,6);
DEFINE   r_prima_cober     DECIMAL(16,2);
DEFINE   r_prima_unidad    DECIMAL(16,2);
DEFINE   v_prima_bruta     DECIMAL(16,2);
DEFINE   v_porc_descto     DECIMAL(5,2);
DEFINE   v_tot_descto      DECIMAL(16,2);
DEFINE   v_tot_recargo     DECIMAL(16,2);
DEFINE   v_prima_reaseguro DECIMAL(16,2);
DEFINE   v_suma_reaseguro  DECIMAL(16,2);
DEFINE   v_prima_reas      DECIMAL(16,2);
DEFINE   v_suma_reas       DECIMAL(16,2);

SET LOCK MODE TO WAIT;

LET r_error       = 0;
LET r_descripcion = NULL;

-- Let v_factor = v_factor * -1;

--------------------
--   Cargar las Unidades
--------------------
delete from endedcob
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from emifafac
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from emifacon
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endunide
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endunire
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

Insert into endeduni
select v_poliza, v_endoso, no_unidad, cod_ruta, cod_producto, cod_asegurado, suma_asegurada,
       prima, descuento, recargo, prima_neta, impuesto, prima_bruta, reasegurada, vigencia_inic,
       vigencia_final, beneficio_max, desc_unidad, prima_suscrita, prima_retenida
  from emipouni
 where no_poliza = v_poliza;

let r_signo = -1;

select cod_tipocalc Into v_tipocalc
  from endedmae
 where no_poliza = v_poliza
   and no_endoso = v_endoso;
if v_tipocalc = "004" Then
   select prima_bruta, saldo into r_prima_anual, v_saldo
     from emipomae
    where no_poliza = v_poliza;

   select Sum(y.factor_impuesto) Into v_impuesto From emipolim x, prdimpue y
    where x.no_poliza    = v_poliza
      and x.cod_impuesto = y.cod_impuesto
      and y.pagado_por   = "C";
   if v_impuesto is null then
      let v_impuesto = 0.00;
   end if
   let r_factor = (v_saldo / r_prima_anual) * r_signo;
--   let v_impuesto = v_impuesto + 100.00;
--   let v_saldo = ((v_saldo * 100) / v_impuesto);
end if 
if v_tipocalc = "005" Then
   let v_saldo = 0.00;
end if
if v_tipocalc = "006" Then
   select prima Into v_saldo
     from endedmae
    where no_poliza = v_poliza
      and no_endoso = v_endoso;
end if
If v_saldo < 0.00 Then
   let v_saldo = v_saldo * r_signo;
End If

foreach 
   select no_unidad, cod_producto, prima, suma_asegurada
     Into v_unidad, v_producto, r_prima_unidad, v_suma_asegurada
     from endeduni
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso

	-------------
	---  Pasar la descripcion de la unidad de la poliza al endoso
	------------
	delete from endedde2
	 where no_poliza   = v_poliza
	   and no_endoso   = v_endoso
	   and no_unidad   = v_unidad;

	Insert Into endedde2
	select v_poliza, v_endoso, v_unidad, descripcion
	  from endedde2	
	 where no_poliza   = v_poliza
	   and no_endoso   = "00000"
	   and no_unidad   = v_unidad;

	-------------
	---  Pasar los descuentos de la unidad de la poliza al endoso
	------------
	delete from endunide
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso
	   and no_unidad = v_unidad;

	insert into endunide
	select no_poliza, v_endoso, no_unidad, cod_descuen, porc_descuento
	  from emiunide
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	---------------
	--  Cargar Reaseguros Individuales
	---------------
	select * from emifacon
	 where no_poliza = v_poliza
	   and no_endoso = "00000"
	   and no_unidad = v_unidad
	  into temp prueba;

	update prueba
	   set no_endoso = v_endoso
	 Where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	insert into emifacon
	select * from prueba
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	  drop table prueba;

	---------------
	--  Cargar Reaseguros Facultativos
	---------------
    select * from emifafac
     where no_poliza = v_poliza
       and no_endoso = "00000"
       and no_unidad = v_unidad
      into temp prueba;

    update prueba
       set no_endoso = v_endoso
     where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	insert into emifafac
	select * from prueba
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	  drop table prueba;

	-------------
	---  Pasar los recargos de la unidad de la poliza al endoso
	------------
	delete from endunire
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso
	   and no_unidad = v_unidad;

	insert into endunire
	select no_poliza, v_endoso, no_unidad, cod_recargo, porc_recargo
	  from emiunire
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

	----------------
	-----  Cargar las coberturas
	----------------
	delete from endedcob
	 where no_poliza   = v_poliza
	   and no_endoso   = v_endoso
	   and no_unidad   = v_unidad;

	Insert Into endedcob
	select v_poliza, v_endoso, v_unidad, cod_cobertura, orden, 0.00, deducible,
	  	   limite_1, limite_2, prima_anual, prima, descuento, recargo, prima_neta,
	       Current, Current, desc_limite1, desc_limite2, v_factor, 0
	  from emipocob	
	 where no_poliza   = v_poliza
	   and no_unidad   = v_unidad;


   update endedcob
	  set prima_anual    = prima_anual * r_factor
    Where no_poliza      = v_poliza
      and no_endoso      = v_endoso
      and no_unidad      = v_unidad;

	Select Sum(prima) Into v_prima_total From endeduni
	 where no_poliza  = v_poliza
	   and no_endoso  = v_endoso;

   let v_prima = (r_prima_unidad * v_saldo) / v_prima_total;
   update endeduni
	  set prima_anual    = prima_anual * r_factor
    Where no_poliza      = v_poliza
      and no_endoso      = v_endoso
      and no_unidad      = v_unidad;

--   update endeduni
--	  set prima          = v_prima * r_signo
--    Where no_poliza      = v_poliza
--      and no_endoso      = v_endoso
--      and no_unidad      = v_unidad;

   Select Sum(prima_anual) Into v_cober_total From endedcob
    Where no_poliza  = v_poliza
      and no_endoso  = v_endoso
      and no_unidad  = v_unidad;

   foreach
      select x.cod_cobertura, x.prima_anual into v_cobertura, r_prima_cober
        from endedcob x
       where x.no_poliza = v_poliza
         and x.no_endoso = v_endoso
         and x.no_unidad = v_unidad

      update endedcob
         set endedcob.prima_anual = endedcob.prima_anual * r_factor,
             endedcob.prima       = endedcob.prima * r_factor,
             endedcob.descuento   = endedcob.descuento * r_factor,
             endedcob.recargo     = endedcob.recargo * r_factor,
             endedcob.prima_neta  = endedcob.prima_neta * r_factor
       where endedcob.no_poliza   = v_poliza
         and endedcob.no_endoso   = v_endoso
         and endedcob.no_unidad   = v_unidad
         and endedcob.cod_cobertura = v_cobertura;

--      LET v_prima_cob = (r_prima_cober * v_prima) / v_cober_total;

      ------------
      ---  Calcular el descuento de la cobertura
	  ------------
--	  let v_porc_descto = 0.00;
--	  let v_tot_descto  = 0.00;
--	  let v_acepta = 0; 
--	  select x.acepta_desc into v_acepta from prdcobpd x
--	   where x.cod_producto  = v_producto
--	     and x.cod_cobertura = v_cobertura;
--	  If v_acepta = 1 Then
--		  foreach
--		     select x.porc_descuento Into v_porc_descto from endunide x
--		     where x.no_poliza  = v_poliza
--		       and x.no_endoso  = v_endoso
--		       and x.no_unidad  = v_unidad
--		     if v_porc_descto is null then
--		        let v_porc_descto = 0.00;
--		     end if
--		     let v_tot_descto = v_tot_descto + ((v_porc_descto * v_prima_cob)/100);
--		  end foreach
--		  let v_tot_descto  = v_tot_descto * -1;
--	  End If

	  -------------
	  ---  Calcular el recargo de la cobertura
	  ------------
	  let v_tot_recargo = 0.00;
	  select sum(x.porc_recargo) into v_tot_recargo from endunire x
	   where x.no_poliza  = v_poliza
	     and x.no_endoso  = v_endoso
	     and x.no_unidad  = v_unidad;
	  if v_tot_recargo is null then
	     let v_tot_recargo = 0.00;
	  else
	     let v_tot_recargo = (v_tot_recargo * (v_prima_cob - v_tot_descto)/100);
	  end if
	  let r_prima_neta  = v_prima_cob + v_tot_descto - v_tot_recargo;

      update endedcob
         set endedcob.prima_anual = v_prima_cob * r_signo,
             endedcob.prima       = v_prima_cob * r_signo,
             endedcob.descuento   = v_tot_descto * r_signo,
             endedcob.recargo     = v_tot_recargo * r_signo,
             endedcob.prima_neta  = r_prima_neta * r_signo
       where endedcob.no_poliza   = v_poliza
         and endedcob.no_endoso   = v_endoso
         and endedcob.no_unidad   = v_unidad
         and endedcob.cod_cobertura = v_cobertura;

   end foreach

   select sum(x.prima), SUM(x.descuento), SUM(x.recargo), SUM(x.prima_neta)
     into r_prima_cober, v_tot_descto, v_tot_recargo, r_prima_neta
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
	     let v_impuesto = (r_prima_neta * v_impuesto) / 100;
	  else
	     let v_impuesto = 0.00;
	  end if
   End If
   let v_prima_bruta = r_prima_neta + v_impuesto;

   foreach
      select x.cod_cober_reas, x.orden, x.cod_contrato, x.porc_partic_suma, x.porc_partic_prima
        into v_cober_reas, v_orden, v_contrato, v_partic_suma, v_partic_prima
        from emifacon x
       where x.no_poliza = v_poliza
         and x.no_endoso = v_endoso
         and x.no_unidad = v_unidad

      select SUM(x.prima_neta) into r_prima_cober
        from prdcober y, endedcob x
       Where x.no_poliza = v_poliza
         and x.no_endoso = v_endoso
         and x.no_unidad = v_unidad
         and x.cod_cobertura  = y.cod_cobertura
         and y.cod_cober_reas = v_cober_reas;

      LET v_prima_reaseguro = (v_partic_prima * r_prima_cober) / 100; 
      LET v_suma_reaseguro  = (v_partic_suma * v_suma_asegurada) / 100;

      update emifacon
	     set emifacon.prima          = v_prima_reaseguro,
		     emifacon.suma_asegurada = v_suma_reaseguro * r_signo
       where emifacon.no_poliza = v_poliza
         and emifacon.no_endoso = v_endoso
         and emifacon.no_unidad = v_unidad
         and emifacon.cod_cober_reas = v_cober_reas
         and emifacon.orden     = v_orden;

	  foreach
	    select x.cod_coasegur, x.porc_partic_reas
	      into v_coasegur, v_partic_reas
	      from emifafac x
	     where x.no_poliza = v_poliza
	       and x.no_endoso = v_endoso
	       and x.no_unidad = v_unidad
	       and x.cod_cober_reas = v_cober_reas
	       and x.orden     = v_orden
	       and x.cod_contrato   = v_contrato

	    LET v_prima_reas = (v_partic_reas * v_prima_reaseguro) / 100; 
	    LET v_suma_reas  = (v_partic_reas * v_suma_reaseguro) / 100;

	    update emifafac
	       set emifafac.prima          = v_prima_reas * r_signo,
	           emifafac.suma_asegurada = v_suma_reas * r_signo
	     where emifafac.no_poliza = v_poliza
	       and emifafac.no_endoso = v_endoso
	       and emifafac.no_unidad = v_unidad
	       and emifafac.cod_cober_reas = v_cober_reas
	       and emifafac.orden     = v_orden
		   and emifafac.cod_contrato = v_contrato
		   and emifafac.cod_coasegur = v_coasegur;

	  end foreach
   end foreach

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
      set endeduni.descuento   = v_tot_descto,
          endeduni.recargo     = v_tot_recargo,
          endeduni.prima_neta  = r_prima_neta,
          endeduni.impuesto    = v_impuesto,
          endeduni.prima_bruta = v_prima_bruta,
          endeduni.prima_suscrita = v_prima_suscrita,
          endeduni.prima_retenida = v_prima_retenida,
          endeduni.suma_asegurada = v_suma_asegurada * r_signo
    where endeduni.no_poliza   = v_poliza
      and endeduni.no_endoso   = v_endoso
      and endeduni.no_unidad   = v_unidad;

end foreach

RETURN r_error, r_descripcion  WITH RESUME;
END

end procedure;