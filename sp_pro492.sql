drop procedure sp_pro492;
create procedure "informix".sp_pro492(v_poliza char(10), v_endoso char(5), v_factor decimal(9,6))

--- Inclusion de unidades del Endoso
--- Victor Molinar
--- 31/10/2000

RETURNING SMALLINT, CHAR(30);

BEGIN
DEFINE   v_unidad      CHAR(5);
DEFINE   r_error       SMALLINT;
DEFINE   r_descripcion CHAR(30);
DEFINE   v_prima_suscrita  DECIMAL(16,2);
DEFINE   v_prima_retenida  DECIMAL(16,2);
DEFINE   r_signo       DECIMAL(9,2);
DEFINE   v_cod_mov     CHAR(3);
DEFINE   v_tipo_mov	   SMALLINT;
DEFINE   r_prima_anual DECIMAL(16,2);
DEFINE   r_prima       DECIMAL(16,2);
DEFINE   r_prima_neta  DECIMAL(16,2);
DEFINE   r_descuento   DECIMAL(16,2);
DEFINE   r_recargo     DECIMAL(16,2);
DEFINE   v_saldo       DECIMAL(16,2);

SET LOCK MODE TO WAIT;

LET r_error       = 0;
LET r_descripcion = NULL;

-- Let v_factor = v_factor * -1;

if v_poliza = '1256174' then
	set debug file to "sp_pro493.trc";
	trace on;
end if
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

create temp table prue(
   no_poliza         CHAR(10),
   no_endoso	     CHAR(5),
   no_unidad	     CHAR(5),
   descripcion       TEXT
   ) with no log;

insert into prue 
select * from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

Insert into endeduni(
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
select v_poliza, 
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
 where no_poliza = v_poliza;

insert into endedde2
select * from prue
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

drop table prue;

if v_factor < 0 Then
   let r_signo = -1;
else
   let r_signo = 1;
end if

select cod_endomov into v_cod_mov 
  from endedmae
 Where no_poliza   = v_poliza
   and no_endoso   = v_endoso;

select tipo_mov into v_tipo_mov
  from endtimov
 where cod_endomov = v_cod_mov;

if v_tipo_mov = 1 Or v_tipo_mov = 3 then
   if v_factor < 0.00 Then
      let v_factor = v_factor * -1;
   end if
   if r_signo < 0 Then
      let r_signo = 1;
   end if
end if
if v_tipo_mov = 1 Or v_tipo_mov = 19 then
   let r_signo = 0;
end if

update endeduni
   set suma_asegurada = suma_asegurada * r_signo,
	   prima          = prima          * v_factor,
	   prima_neta     = prima_neta     * v_factor,
	   descuento      = descuento      * (v_factor * -1),
	   recargo        = recargo        * v_factor,
	   impuesto       = impuesto       * v_factor,
	   prima_bruta    = prima_bruta    * v_factor,
	   prima_suscrita = prima_suscrita * v_factor,
	   prima_retenida = prima_retenida * v_factor
 Where no_poliza      = v_poliza
   and no_endoso      = v_endoso;

----------------
-----  Cargar las coberturas
----------------
foreach 
   select no_unidad Into v_unidad
     from endeduni
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso

--   delete from endedde2
--    where no_poliza   = v_poliza
--      and no_endoso   = v_endoso
--      and no_unidad   = v_unidad;

--   Insert Into endedde2
--   select v_poliza, v_endoso, v_unidad, descripcion
--     from endedde2	
--    where no_poliza   = v_poliza
--      and no_endoso   = "00000"
--      and no_unidad   = v_unidad;

   delete from endedcob
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso
      and no_unidad   = v_unidad;

   Insert Into endedcob(
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
   select v_poliza, v_endoso, v_unidad, cod_cobertura, orden, 0.00, deducible,
    	  limite_1, limite_2, prima_anual, prima, descuento, recargo, prima_neta,
    	  Current, Current, desc_limite1, desc_limite2, v_factor, 0
     from emipocob
    where no_poliza   = v_poliza
      and no_unidad   = v_unidad;

   update endedcob
      set prima_anual = prima_anual * v_factor,
          prima       = prima       * v_factor,
          prima_neta  = prima_neta  * v_factor,
          descuento   = descuento   * (v_factor * -1),
          recargo     = recargo     * v_factor,
	      limite_1    = limite_1    * r_signo,
	      limite_2    = limite_2    * r_signo
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso
      and no_unidad   = v_unidad;

---------------
--  Cargar Reaseguros Individuales
---------------
   delete from emifafac
    where no_poliza = v_poliza
      and no_endoso = v_endoso
      and no_unidad = v_unidad;

   delete from emifacon
    where no_poliza = v_poliza
      and no_endoso = v_endoso
      and no_unidad = v_unidad;

   select * from emifacon
    where no_poliza = v_poliza
      and no_endoso = "00000"
      and no_unidad = v_unidad
     into temp prueba;

   update prueba
      set no_endoso = v_endoso,
	      prima     = prima * v_factor,
		  suma_asegurada = suma_asegurada * r_signo
    where no_poliza = v_poliza
      and no_unidad = v_unidad;

   insert into emifacon
   select * from prueba
    where no_poliza = v_poliza
      and no_unidad = v_unidad;

   drop table prueba;

   select * from emifafac
    where no_poliza = v_poliza
      and no_endoso = "00000"
      and no_unidad = v_unidad
     into temp prueba;

   update prueba
      set no_endoso = v_endoso,
          prima     = prima * v_factor,
    	  suma_asegurada = suma_asegurada * r_signo
	where no_poliza = v_poliza
	  and no_unidad = v_unidad;

   update prueba
      set monto_comision = 0,
          monto_impuesto = 0
	where no_poliza = v_poliza
	  and no_endoso = v_endoso
	  and no_unidad = v_unidad
	  and prima     = 0; 

   insert into emifafac
   select * from prueba
    where no_poliza = v_poliza
      and no_unidad = v_unidad;

   drop table prueba;

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
	  set prima_suscrita = v_prima_suscrita,
	      prima_retenida = v_prima_retenida
    Where no_poliza      = v_poliza
      and no_endoso      = v_endoso
      and no_unidad      = v_unidad;

End Foreach

if v_factor = 0.00 Then
   update endedcob
      set deducible = 0.00,
	      limite_1  = 0.00,
	      limite_2  = 0.00
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso;
end if

if v_tipo_mov = 1 Or v_tipo_mov = 19 then
   update endedcob
      set deducible = 0.00,
	      limite_1  = 0.00,
	      limite_2  = 0.00
    where no_poliza   = v_poliza
      and no_endoso   = v_endoso;
end if

select sum(prima_suscrita), sum(prima_retenida)
  Into v_prima_suscrita, v_prima_retenida 
  From endeduni
 where no_poliza      = v_poliza
   and no_endoso      = v_endoso;

update endedmae
   set prima_suscrita = v_prima_suscrita,
       prima_retenida = v_prima_retenida
 where no_poliza      = v_poliza
   and no_endoso      = v_endoso;

RETURN r_error, r_descripcion  WITH RESUME;
END

end procedure;