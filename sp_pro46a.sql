-- Eliminacion, Inclusion, Modificacion de Unidades del Endoso
--
-- Creado    : 31/10/2000 - Autor: Victor Molinar
-- Modificado: 03/07/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 20/08/2001 - Autor: Demetrio Hurtado Almanza

-- 20/08/2001  Se modifico la sentencia insert endeduni colocando los campos de forma
--			   explicita para cuando se agregara otro campo en endeduni no de error.
--			   Demetrio			
-- 03/07/2001: Se Incluyo la Opcion para que cuando fuese Modificacion de Unidades
--             los valores de las Unidades y de las Coberturas se grabaran en cero (0).
--             Demetrio
-- 11/10/2011: Amado: Se agrego un cambio en la distribucion de reaseguro cuando se modificacion.

drop procedure sp_pro46a;
create procedure "informix".sp_pro46a(v_poliza char(10), v_endoso char(5), v_unidad char(5), v_cant_dias smallint, v_factor DECIMAL(16,2))
RETURNING SMALLINT,CHAR(30),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2);

--if v_poliza = '874726' then	  
	--SET DEBUG FILE TO "sp_pro46a.trc";
	--TRACE ON;
--end if

BEGIN

DEFINE   r_error       SMALLINT;
DEFINE   r_descripcion CHAR(30);
DEFINE   r_prima       DECIMAL(16,2);
DEFINE   r_descuento   DECIMAL(16,2);
DEFINE   r_recargo     DECIMAL(16,2);
DEFINE   r_prima_neta  DECIMAL(16,2);
DEFINE   r_impuesto    DECIMAL(16,2);
DEFINE   r_prima_bruta DECIMAL(16,2);
DEFINE   r_prima_cober DECIMAL(16,2);
DEFINE   v_prima_descto DECIMAL(16,2);
DEFINE   v_cobertura   CHAR(5);
DEFINE   limite        VARCHAR(50);
DEFINE   factor        Decimal(9,6);
DEFINE   v_prima       Decimal(16,2);
DEFINE   v_impto       Smallint;
DEFINE   v_dias        Smallint;
DEFINE   v_cantidad    Smallint;
DEFINE   r_cant        Smallint;
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
DEFINE   v_suma_asegurada Decimal(16,2);
DEFINE   v_cober_reas  CHAR(3);
DEFINE   v_orden 	   SMALLINT;
DEFINE   v_contrato    CHAR(5);
DEFINE   v_partic_suma DECIMAl(9,6);
DEFINE   v_partic_prima	DECIMAl(9,6);
DEFINE   v_prima_reaseguro DECIMAL(16,2);
DEFINE   v_suma_reaseguro  DECIMAL(16,2);
DEFINE   v_coasegur    CHAR(3);
DEFINE   v_partic_reas DECIMAL(9,6);
DEFINE   v_prima_reas  DECIMAL(16,2);
DEFINE   v_suma_reas   DECIMAL(16,2);
DEFINE   _cod_tipocalc CHAR(3);

DEFINE   _cod_endomov  CHAR(3);
DEFINE   _tipo_mov     SMALLINT;

define _cod_origen      char(3); 
define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _canti           smallint;
define _aplica_imp      smallint;
define _cod_impuesto    char(3);
define _porct_imp		DECIMAL(9,6);
DEFINE _existe_imp		SMALLINT;
define _no_cambio       SMALLINT;
define v_cod_producto   varchar(10);
define _ld_prima_neta_t     decimal(16,2);
define _suma_aseg_emif      decimal(16,2);
define _suma_dif            decimal(16,2);
define _prima_neta_emif     decimal(16,2);
define _prima_dif           decimal(16,2);
define _cod_ramo_uni        char(3);

SET ISOLATION TO DIRTY READ;

LET limite        = NULL;
LET factor        = 0.00;
LET v_prima       = 0.00;
LET v_dias        = 0;   
LET v_cantidad    = 0;   
LET v_impuesto    = 0.00;
LET v_rata_dia    = 0.00;
LET v_prima_uni   = 0.00;
LET v_prima_cob   = 0.00;
LET v_tot_descto  = 0.00;
LET v_porc_descto = 0.00;
LET v_tot_recargo = 0.00;
LET v_prima_neta  = 0.00;
LET v_prima_bruta = 0.00;

LET r_error       = 0;   
LET r_descripcion = NULL;
LET r_prima       = 0.00;
LET r_descuento   = 0.00;
LET r_recargo     = 0.00;
LET r_prima_neta  = 0.00;
LET r_impuesto    = 0.00;
LET r_prima_bruta = 0.00;

--SET DEBUG FILE TO "sp_pro46a.trc";
--TRACE ON;

SELECT cod_endomov, cod_tipocalc
  INTO _cod_endomov, _cod_tipocalc
  FROM endedmae
 WHERE no_poliza = v_poliza
   AND no_endoso = v_endoso;

SELECT tipo_mov
  INTO _tipo_mov
  FROM endtimov
 WHERE cod_endomov = _cod_endomov;

if _tipo_mov = 5 AND _cod_tipocalc = "005" Then
   let v_factor = 0.00;
end if

-------------
---  Buscar la vigencia del endoso y la prima para calcular el factor
-----------

Select x.vigencia_inic, x.vigencia_final, x.cod_ramo
  Into v_poliza_inic, v_poliza_fin, _cod_ramo_uni
  From emipouni x
 Where x.no_poliza   = v_poliza
   And x.no_unidad   = v_unidad;

LET v_dias = v_poliza_fin - v_poliza_inic;

-------------
---  Pasar la unidad de la poliza al endoso
-------------
let r_cant = 0;

select count(*) 
  into r_cant 
  from endeduni
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then

	IF _tipo_mov = 6 THEN

-- suma_asegurada, 

	   insert into endeduni(
	   		  no_poliza, 
	   		  no_endoso, 
	   		  no_unidad, 
	   		  cod_ruta, 
	   		  cod_producto,
	          cod_cliente, 
	          suma_asegurada, 
	          prima, 
	          descuento, 
	          recargo, 
	          prima_neta,
	          impuesto, 
	          prima_bruta, 
	          reasegurada, 
	          vigencia_inic, 
	          vigencia_final,
	          beneficio_max, 
	          desc_unidad, 
	          prima_suscrita, 
	          prima_retenida)
	   select no_poliza, 
	   		  v_endoso, 
	   		  no_unidad, 
	   		  cod_ruta, 
	   		  cod_producto,
	          cod_asegurado, 
	          suma_asegurada,--0.00, 
	          prima, 
	          descuento, 
	          recargo, 
	          prima_neta,
	          impuesto, 
	          prima_bruta, 
	          reasegurada, 
	          vigencia_inic, 
	          vigencia_final,
	          beneficio_max, 
	          desc_unidad, 
	          prima_suscrita, 
	          prima_retenida
	   from emipouni
	  where no_poliza = v_poliza
	    and no_unidad = v_unidad;
		
	ELSE

	   insert into endeduni(
	   		  no_poliza, 
	   		  no_endoso, 
	   		  no_unidad, 
	   		  cod_ruta, 
	   		  cod_producto,
	          cod_cliente, 
	          suma_asegurada, 
	          prima, 
	          descuento, 
	          recargo, 
	          prima_neta,
	          impuesto, 
	          prima_bruta, 
	          reasegurada, 
	          vigencia_inic, 
	          vigencia_final,
	          beneficio_max, 
	          desc_unidad, 
	          prima_suscrita, 
	          prima_retenida)
	   select no_poliza, 
	   		  v_endoso, 
	   		  no_unidad, 
	   		  cod_ruta, 
	   		  cod_producto,
	          cod_asegurado, 
	          suma_asegurada, 
	          prima, 
	          descuento, 
	          recargo, 
	          prima_neta,
	          impuesto, 
	          prima_bruta, 
	          reasegurada, 
	          vigencia_inic, 
	          vigencia_final,
	          beneficio_max, 
	          desc_unidad, 
	          prima_suscrita, 
	          prima_retenida
	   from emipouni
	  where no_poliza = v_poliza
	    and no_unidad = v_unidad;

	END IF

end if
----------------
-----  Calculos de las coberturas
----------------
--trace off;

let r_cant = 0;

select count(*) 
  into r_cant 
  from endedcob
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then

   foreach
	  select x.cod_cobertura 
	    into v_cobertura
	    from emipocob x
	   where x.no_poliza = v_poliza
	     and x.no_unidad = v_unidad

	  let v_prima    = 0.00;
	  let v_rata_dia = 0.00;

	  Select x.prima 
	    Into v_prima 
	    From emipocob x
	   Where x.no_poliza     = v_poliza
	     and x.no_unidad     = v_unidad
	     and x.cod_cobertura = v_cobertura;

	  LET v_prima_cob = v_prima * v_factor;

	  ----------------
	  ---  Pasar las coberturas de la poliza al endoso
	  ----------------
	  IF _tipo_mov = 6 THEN

		  insert into endedcob(
		  no_poliza,
		  no_endoso,
		  no_unidad,
		  cod_cobertura,
		  orden,
		  tarifa,
		  deducible,
		  limite_1,
		  limite_2,
		  prima_anual,
		  prima,
		  descuento,
		  recargo,
		  prima_neta,
		  date_added,
		  date_changed,
		  desc_limite1,
		  desc_limite2,
		  factor_vigencia,
		  opcion)
		  select no_poliza, v_endoso, no_unidad, cod_cobertura, orden, tarifa,
		         deducible, limite_1, limite_2, prima_anual, prima, descuento,
		         recargo, prima_neta, date_added, date_changed, limite, limite,
		         factor, 2
		    from emipocob
		   where no_poliza     = v_poliza
		     and no_unidad     = v_unidad
		     and cod_cobertura = v_cobertura;

	  ELSE
	  	
		  insert into endedcob(
		  no_poliza,
		  no_endoso,
		  no_unidad,
		  cod_cobertura,
		  orden,
		  tarifa,
		  deducible,
		  limite_1,
		  limite_2,
		  prima_anual,
		  prima,
		  descuento,
		  recargo,
		  prima_neta,
		  date_added,
		  date_changed,
		  desc_limite1,
		  desc_limite2,
		  factor_vigencia,
		  opcion)
		  select no_poliza, v_endoso, no_unidad, cod_cobertura, orden, tarifa,
		         deducible, limite_1, limite_2, prima_anual, prima, descuento,
		         recargo, prima_neta, date_added, date_changed, limite, limite,
		         factor, 0
		    from emipocob
		   where no_poliza     = v_poliza
		     and no_unidad     = v_unidad
		     and cod_cobertura = v_cobertura;

	  END IF
	  	
	  ------------
	  ---  Calcular el descuento de la cobertura
	  ------------
	  let v_porc_descto  = 0.00;
	  let v_tot_descto   = 0.00;
	 { let v_prima_descto = v_prima_cob;

	  foreach
	     select x.porc_descuento 
	       Into v_porc_descto 
	       from emicobde x
	      where x.no_poliza     = v_poliza
	        and x.no_unidad     = v_unidad
	        and x.cod_cobertura = v_cobertura

	     if v_porc_descto is null then
	        let v_porc_descto = 0.00;
	     end if
	     let v_tot_descto   = v_tot_descto + ((v_porc_descto * v_prima_descto)/100);
	     let v_prima_descto = v_prima_descto - v_tot_descto;
	  end foreach

	  let v_tot_descto  = v_tot_descto * -1;}

	  -------------
	  ---  Calcular el recargo de la cobertura
	  ------------
	  let v_tot_recargo = 0.00;
	 { select sum(x.porc_recargo) into v_tot_recargo from emicobre x
	   where x.no_poliza  = v_poliza
	     and x.no_unidad  = v_unidad
	     and x.cod_cobertura = v_cobertura;
	  if v_tot_recargo is null then
	     let v_tot_recargo = 0.00;
	  else
	     let v_tot_recargo = (v_tot_recargo * (v_prima_cob - v_tot_descto)/100);
	  end if}
	  let v_prima_neta  = v_prima_cob + v_tot_descto - v_tot_recargo;

	  -------------
	  ---  actualizar valores de la cobertura
	  ------------
	  if _tipo_mov = 5 AND _cod_tipocalc = "005" Then
		  update endedcob
		     set endedcob.prima       = 0.00,
		         endedcob.descuento   = 0.00,
		         endedcob.recargo     = 0.00,
		         endedcob.prima_neta  = 0.00,
		         endedcob.prima_anual = 0.00,
		         endedcob.limite_1    = 0.00,
		         endedcob.limite_2    = 0.00
		   where endedcob.no_poliza   = v_poliza
		     and endedcob.no_endoso   = v_endoso
		     and endedcob.no_unidad   = v_unidad
		     and endedcob.cod_cobertura = v_cobertura;
	  else
		 { update endedcob
		     set endedcob.prima         = v_prima_cob,
		         endedcob.descuento     = v_tot_descto,
		         endedcob.recargo       = v_tot_recargo,
		         endedcob.prima_neta    = v_prima_neta
		   where endedcob.no_poliza     = v_poliza
		     and endedcob.no_endoso     = v_endoso
		     and endedcob.no_unidad     = v_unidad
		     and endedcob.cod_cobertura = v_cobertura;}
	  end if
   end foreach
end if

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

	if _cod_ramo_uni = '020' then
		let v_impuesto = 6;
	end if
	 if v_impuesto > 0.00 then
	    let v_impuesto = (v_prima_neta * v_impuesto) / 100;
	 else
	 
	    --VALIDACION PARA POLIZAS DE FIANZAS, VIDA, COLEC VIDA*****************************************************************************
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
							    and no_endoso = no_endoso
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
							  and x.cod_impuesto = y.cod_impuesto
							  and y.pagado_por   = "C";

							let v_impuesto = v_prima_neta * ( _porct_imp / 100);

							update endedimp
							   set monto = v_impuesto
							 where no_poliza = v_poliza
							   and no_endoso = v_endoso;

					end if
				end if

		end if	

	 end if
 End If
 let v_prima_bruta = v_prima_neta + v_impuesto;

-------------
 if v_prima_uni < 0 Then
    let v_signo = -1;
 else
    let v_signo = 1;
 end if
 if _tipo_mov = 5 AND _cod_tipocalc = "005" Then
    let v_signo = 0;
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

---  FIN DEL CALCULO DE LAS UNIDADES
----------------------------------------------------------------------------
---  Pasar los descuentos de la coberturas de la poliza al endoso
------------
let r_cant = 0;
select count(*) into r_cant from endcobde
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then
   insert into endcobde
   select no_poliza, v_endoso, no_unidad, cod_cobertura, cod_descuen,
		  porc_descuento
	 from emicobde
	where no_poliza = v_poliza
	  and no_unidad = v_unidad;
end if
-------------
---  Pasar los recargos de la coberturas de la poliza al endoso
------------
let r_cant = 0;
select count(*) into r_cant from endcobre
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then
   insert into endcobre
   select no_poliza, v_endoso, no_unidad, cod_cobertura, cod_recargo, porc_recargo
     from emicobre
    where no_poliza = v_poliza
      and no_unidad = v_unidad;
End If
-------------
---  Pasar los acreedores de la unidad de la poliza al endoso
------------
let r_cant = 0;
select count(*) into r_cant from endedacr
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then
   insert into endedacr
   select no_poliza, v_endoso, no_unidad, cod_acreedor, limite
     from emipoacr
    where no_poliza = v_poliza
      and no_unidad = v_unidad;
end if
-------------
---  Pasar la  descripcion de la unidad de la poliza al endoso
------------
--let r_cant = 0;
--select count(*) into r_cant from endedde2
-- where no_poliza = v_poliza
--   and no_unidad = v_unidad
--   and no_endoso = v_endoso;

--If r_cant = 0 Then
--   insert into endedde2
--   select no_poliza, v_endoso, no_unidad, descripcion
--     from emipode2
--    where no_poliza = v_poliza
--      and no_unidad = v_unidad;
--End If
-------------
---  Pasar los descuentos de la unidad de la poliza al endoso
------------
let r_cant = 0;
select count(*) into r_cant from endunide
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then
	select count(*)
	  into r_cant
     from emiunide
    where no_poliza = v_poliza
      and no_unidad = v_unidad;
	If r_cant = 0 Then
	else
	   insert into endunide
	   select no_poliza, v_endoso, no_unidad, cod_descuen, porc_descuento
		 from emiunide
		where no_poliza = v_poliza
		  and no_unidad = v_unidad;
	end if	  
End If
-------------
---  Pasar los recargos de la unidad de la poliza al endoso
------------
let r_cant = 0;
select count(*) into r_cant from endunire
 where no_poliza = v_poliza
   and no_unidad = v_unidad
   and no_endoso = v_endoso;

If r_cant = 0 Then
   insert into endunire
   select no_poliza, v_endoso, no_unidad, cod_recargo, porc_recargo
     from emiunire
    where no_poliza = v_poliza
      and no_unidad = v_unidad;
End If

-------------
---  Pase de distribucion de la compania
------------

IF _tipo_mov = 6 THEN

   	let r_cant = 0; 
	select count(*)				-----> En caso que no haya registro en emireama Amado 11-10-2011
	  into r_cant
	  from emireama
	 where no_poliza = v_poliza
	   and no_unidad = v_unidad;

    If r_cant = 0 Then
		let r_cant = 0;							 
		select count(*) into r_cant from emifacon
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad
		   and no_endoso = v_endoso;

		If r_cant = 0 Then
		   select * from emifacon
		    where no_poliza = v_poliza
		      and no_endoso = "00000"
		      and no_unidad = v_unidad
		     into temp pruebas;

		   update pruebas set no_endoso = v_endoso,
		          suma_asegurada = 0,
				  prima = 0
		    where no_poliza = v_poliza
		      and no_endoso = "00000"
		      and no_unidad = v_unidad;

		   insert into emifacon
		   select * from pruebas
		    where no_poliza = v_poliza
		      and no_endoso = v_endoso
		      and no_unidad = v_unidad;

		  drop table pruebas;
		end if
		-------------
		---  Pase de distribucion del facultativo
		------------
		let r_cant = 0;
		select count(*) into r_cant from emifafac
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad
		   and no_endoso = v_endoso;

		If r_cant = 0 Then
			select * from emifafac
			 where no_poliza = v_poliza
			   and no_endoso = "00000"
			   and no_unidad = v_unidad
			  into temp pruebas;

			update pruebas
			   set no_endoso = v_endoso,
		           suma_asegurada = 0,
				   prima = 0,
				   impreso = 0,        
				   fecha_impresion = current,
				   no_cesion = null     
			 where no_poliza = v_poliza
			   and no_endoso = "00000"
			   and no_unidad = v_unidad;

			insert into emifafac
			select * from pruebas
			 where no_poliza = v_poliza
			   and no_endoso = v_endoso
			   and no_unidad = v_unidad;

			drop table pruebas;
		end if
	
-------------------------------------------	 Este reemplaza lo de arriba para que tome los cambios en los reaseguros Amado 11-10-2011 
    Else  
		-- Cargar Reaseguros Individuales
		drop table if exists prueba;
		create temp table prueba(
		       no_poliza         CHAR(10),
			   no_endoso	     CHAR(5),
			   no_unidad	     CHAR(5),
			   cod_cober_reas    CHAR(3),
			   orden		     SMALLINT,
			   cod_contrato	     CHAR(5),
			   cod_ruta		     CHAR(5),
			   porc_partic_suma	 DECIMAL(9,6),
			   porc_partic_prima DECIMAL(9,6),
			   suma_asegurada	 DECIMAL(16,2) default 0,
			   prima			 DECIMAL(16,2) default 0
			   ) with no log;

		select max(no_cambio)
		  into _no_cambio
		  from emireama
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad;

	--	IF _no_cambio IS NULL THEN
	--	   LET _no_cambio = 0;
	--	END IF

		let r_cant = 0;

		select count(*) into r_cant from emifacon
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad
		   and no_endoso = v_endoso;

		If r_cant = 0 Then
			insert into prueba(
			no_poliza,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
			)
		    select 
		    no_poliza,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
		    from emireaco
		   where no_poliza = v_poliza
		     and no_unidad = v_unidad
		     and no_cambio = _no_cambio;

			update prueba
			   set no_endoso = v_endoso
			 Where no_poliza = v_poliza
			   and no_unidad = v_unidad;

			insert into emifacon(
			no_poliza,        
			no_endoso,	    
			no_unidad,	    
			cod_cober_reas,   
			orden,		    
			cod_contrato,	    
			cod_ruta,		    
			porc_partic_suma,	
			porc_partic_prima,
			suma_asegurada,	
			prima			
			)
			select 
			no_poliza,        
			no_endoso,	    
			no_unidad,	    
			cod_cober_reas,   
			orden,		    
			cod_contrato,	  
			cod_ruta,		  
			porc_partic_suma,	
			porc_partic_prima,
			suma_asegurada,	
			prima			
			from prueba
		   where no_poliza = v_poliza
		     and no_unidad = v_unidad;
	   End if

	   drop table prueba;

	   --  Cargar Reaseguros Facultativos

	   create temp table prueba(
		       no_poliza         CHAR(10),
			   no_endoso	     CHAR(5),
			   no_unidad	     CHAR(5),
			   cod_cober_reas    CHAR(3),
			   orden		     SMALLINT,
			   cod_contrato	     CHAR(5),
			   cod_coasegur	     CHAR(3),
			   porc_partic_reas	 DECIMAL(9,6),
			   porc_comis_fac    DECIMAL(9,6),
			   porc_impuesto	 DECIMAL(5,2),
			   suma_asegurada	 DECIMAL(16,2) default 0,
			   prima			 DECIMAL(16,2) default 0,
			   impreso           SMALLINT default 0,
			   fecha_impresion   DATE default today,
			   no_cesion         CHAR(10) default null,
			   subir_bo          SMALLINT default 0,
			   monto_comision	 dec(16,2),
			   monto_impuesto	 dec(16,2),
			   cant_garantia_pago	smallint,
			   cod_perfac			char(3),
			   fecha_primer_pago	date
			   ) with no log;

		let r_cant = 0;

		select count(*) into r_cant from emifafac
		 where no_poliza = v_poliza
		   and no_unidad = v_unidad
		   and no_endoso = v_endoso;

		If r_cant = 0 Then
			insert into prueba(
			no_poliza,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			cod_coasegur,
			porc_partic_reas,
			porc_comis_fac,
			porc_impuesto
			)
		    select
		    no_poliza,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			cod_coasegur,
			porc_partic_reas,
			porc_comis_fac,
			porc_impuesto
		    from emireafa
		   where no_poliza = v_poliza
		     and no_unidad = v_unidad
			 and no_cambio = _no_cambio;

		    update prueba
		       set no_endoso = v_endoso
		     where no_poliza = v_poliza
			   and no_unidad = v_unidad;

			insert into emifafac (no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_coasegur,porc_partic_reas,porc_comis_fac,porc_impuesto,suma_asegurada,prima,impreso,fecha_impresion,no_cesion,subir_bo,monto_comision,monto_impuesto,cant_garantia_pago,cod_perfac,fecha_primer_pago)
			select no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_coasegur,porc_partic_reas,porc_comis_fac,porc_impuesto,suma_asegurada,prima,impreso,fecha_impresion,no_cesion,subir_bo,monto_comision,monto_impuesto,cant_garantia_pago,cod_perfac,fecha_primer_pago from prueba
			 where no_poliza = v_poliza
			   and no_unidad = v_unidad;
		  End If

		  drop table prueba;
    End If
 -------------------------------------


   select suma_asegurada
     into v_suma_asegurada
	 from endeduni
	where no_poliza = v_poliza
	  and no_endoso = v_endoso
	  and no_unidad = v_unidad;

   foreach
      select x.cod_cober_reas, 
             x.orden, 
             x.cod_contrato, 
             x.porc_partic_suma, 
             x.porc_partic_prima
        into v_cober_reas, 
             v_orden, 
             v_contrato, 
             v_partic_suma, 
             v_partic_prima
        from emifacon x
       where x.no_poliza = v_poliza
         and x.no_endoso = v_endoso
         and x.no_unidad = v_unidad

      select sum(x.prima_neta) into r_prima_cober
        from prdcober y, endedcob x
       Where x.no_poliza      = v_poliza
         and x.no_endoso      = v_endoso
         and x.no_unidad      = v_unidad
         and x.cod_cobertura  = y.cod_cobertura
         and y.cod_cober_reas = v_cober_reas;

      LET v_prima_reaseguro = (v_partic_prima * r_prima_cober)    / 100; 
      LET v_suma_reaseguro  = (v_partic_suma  * v_suma_asegurada) / 100;

--	  LET v_prima_reaseguro =  v_prima_reaseguro * _porc_coas / 100;	
--	  LET v_suma_reaseguro  =  v_suma_reaseguro  * _porc_coas / 100;	

	  If v_prima_reaseguro is null Then
	     let v_prima_reaseguro = 0.00;
	  End If
	  If v_suma_reaseguro is null Then
	     let v_suma_reaseguro = 0.00;
	  End If

      update emifacon
	     set emifacon.prima          = v_prima_reaseguro,
		     emifacon.suma_asegurada = v_suma_reaseguro * v_signo
       where emifacon.no_poliza      = v_poliza
         and emifacon.no_endoso      = v_endoso
         and emifacon.no_unidad      = v_unidad
         and emifacon.cod_cober_reas = v_cober_reas
         and emifacon.orden          = v_orden;

	foreach
	    select x.cod_coasegur, x.porc_partic_reas
	      into v_coasegur, v_partic_reas
	      from emifafac x
	     where x.no_poliza      = v_poliza
	       and x.no_endoso      = v_endoso
	       and x.no_unidad      = v_unidad
	       and x.cod_cober_reas = v_cober_reas
	       and x.orden          = v_orden
	       and x.cod_contrato   = v_contrato

	    LET v_prima_reas = (v_partic_reas * v_prima_reaseguro) / 100; 
	    LET v_suma_reas  = (v_partic_reas * v_suma_reaseguro) / 100;

		If v_prima_reas is null Then
		   let v_prima_reas = 0.00;
	    End If
		If v_suma_reas is null Then
		   let v_suma_reas = 0.00;
	    End If

	    update emifafac
	       set emifafac.prima          = v_prima_reas,
	           emifafac.suma_asegurada = v_suma_reas * v_signo,
			   emifafac.monto_comision = v_prima_reas * emifafac.porc_comis_fac / 100,
			   emifafac.monto_impuesto = v_prima_reas * emifafac.porc_impuesto / 100
	     where emifafac.no_poliza      = v_poliza
	       and emifafac.no_endoso      = v_endoso
	       and emifafac.no_unidad      = v_unidad
	       and emifafac.cod_cober_reas = v_cober_reas
	       and emifafac.orden          = v_orden
		   and emifafac.cod_contrato   = v_contrato
		   and emifafac.cod_coasegur   = v_coasegur;

	end foreach

   end foreach

   ----
   ---Verificacion de centavos diferencia
		   
   select suma_asegurada
     into v_suma_asegurada
	 from endeduni
	where no_poliza = v_poliza
	  and no_endoso = v_endoso
	  and no_unidad = v_unidad; 
	  
		select sum(e.prima_neta)
		  into _ld_prima_neta_t
		  from endedcob e, prdcober c
		 where c.cod_cobertura = e.cod_cobertura
		   and e.no_poliza = v_poliza
		   and e.no_endoso = v_endoso
		   and e.no_unidad = v_unidad;

		select sum(prima),
		       sum(suma_asegurada)
		  into _prima_neta_emif,
		       _suma_aseg_emif
		  from emifacon
		 where no_poliza = v_poliza
		   and no_endoso =	v_endoso
		   and no_unidad =	v_unidad;

		let _prima_dif = 0;
        let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;
        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emifacon
			   set prima			= prima + _prima_dif
			 where no_poliza		= v_poliza
			   and no_endoso		= v_endoso
			   and no_unidad		= v_unidad
			   and cod_cober_reas	= v_cober_reas
			   and orden			= v_orden;
			
        end if

		let _suma_dif = 0;
        let _suma_dif = v_suma_asegurada - _suma_aseg_emif;
		
        if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then

			update emifacon
			   set suma_asegurada   = suma_asegurada + _suma_dif
			 where no_poliza		= v_poliza
			   and no_endoso		= v_endoso
			   and no_unidad		= v_unidad
			   and cod_cober_reas	= v_cober_reas
			   and orden			= v_orden;
			
        end if
END IF

Select x.prima, x.descuento, x.recargo, x.prima_neta, x.impuesto, x.prima_bruta
  Into r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto, r_prima_bruta
  From endeduni x
 Where x.no_poliza = v_poliza
   And x.no_unidad = v_unidad
   And x.no_endoso = v_endoso;

RETURN r_error, r_descripcion, r_prima, r_descuento, r_recargo, r_prima_neta, r_impuesto, r_prima_bruta;

END
end procedure;
