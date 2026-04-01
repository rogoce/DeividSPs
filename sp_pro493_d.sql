--- Inclusion de unidades del Endoso
--- SD#3059 copia del reversar sin actualizar
--- 12/04/2022

drop procedure sp_pro493_d;
create procedure sp_pro493_d(v_poliza char(10), v_endoso char(5), a_no_endoso_ant char(5))
returning smallint, char(30);

define _error_desc			char(30);
define r_descripcion		char(30);
define _no_documento		char(20);
define _cod_manzana			char(15);
define v_cobertura			char(5);
define v_unidades			char(5);
define v_producto			char(5);
define v_contrato			char(5);
define v_unidad				char(5);
define _cober				char(5);
define _cod_impuesto_i		char(3);
define _cod_subramo_i		char(3);
define _cod_origen_i		char(3); 
define _cod_compania		char(3);
define _cod_coasegur		char(3);
define _cod_impuesto		char(3);
define _cod_tipo_tar		char(3);
define v_cober_reas			char(3);
define _cod_ramo_i			char(3);
define v_tipocalc			char(3);
define v_coasegur			char(3);
define v_cod_mov			char(3);
define _cod_ramo			char(3);
define _nueva_renov         char(1);
define _factor_impuesto,_porc_impuesto		dec(5,2);
define _descuento_max		dec(5,2);
define _desc_porc			dec(7,4);
define r_signo,_porc_comis_fac				dec(9,2);
define v_factores			dec(9,4);
define v_partic_prima		dec(9,6);
define v_partic_reas		dec(9,6);
define v_partic_suma		dec(9,6);
define _porct_imp_i			dec(9,6);
define v_impto				dec(9,6);
define v_impuesto			dec(20,8);
define _porc_coas			dec(16,4);
define v_prima_reaseguro	dec(16,2);
define v_suma_reaseguro		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_prima_retenida		dec(16,2);
define _prima_neta_cob		dec(16,2);
define r_prima_unidad		dec(16,2);
define _tot_reaseguro		dec(16,2);
define v_porc_descto		dec(16,4);
define v_prima_bruta		dec(16,2);
define r_prima_cober		dec(16,2);
define v_tot_recargo		dec(16,2);
define v_cober_total		dec(16,2);
define v_prima_total		dec(16,2);
define r_prima_anual		dec(16,2);
define v_prima_reas			dec(16,2);
define v_tot_descto			dec(16,2);
define _prima_salud			dec(16,2);
define r_prima_neta			dec(16,2);
define ld_prima_aux			dec(16,2);
define v_tot_bruta			dec(16,2);
define v_suma_reas			dec(16,2);
define _prima_neta			dec(16,2);
define r_descuento			dec(16,2);
define v_tot_saldo			dec(16,2);
define v_prima_cob			dec(16,2);
define v_descuento			dec(16,2);
define _descuento			dec(16,2);
define _desc_cob			dec(16,2);
define v_recargo			dec(16,2);
define r_recargo			dec(16,2);
define v_descto				dec(16,2);
define _sum_imp				dec(16,2);
define v_prima				dec(16,2);
define v_saldo				dec(16,2);
define _gastos				dec(16,2);
define _neta				dec(16,2);
define _porc_proporcion		dec(10,6);
define _acepta_descuento	smallint;
define _tipo_produccion		smallint;
define _tiene_impuesto		smallint;
define _tipo_descuento		smallint;
define _tipo_incendio		smallint;
define _aplica_imp_i		smallint;
define _existe_imp_i		smallint;
define _impuesto_tot		smallint;
define _cnt_unidad			smallint;
define _tipo_auto			smallint;
define v_tipo_mov			smallint;
define _cnt_cober			smallint;
define _no_cambio			smallint;
define _ramo_sis			smallint;
define v_acepta				smallint;
define _canti_i				smallint;
define _end_imp				smallint;
define v_orden				smallint;
define r_error				smallint;
define _cant1				smallint;
define _cant				smallint;
define _error				smallint;
define _fecha_suscripcion	date;


begin
on exception set r_error
 	return r_error, 'Error al Realizar el Calculo';
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';


--set debug file to "sp_pro493_d.trc";
--trace on;
--let v_factor = v_factor;

-- verificaciones para coaseguro mayoritario
select t.tipo_produccion,
	   p.cod_compania,
	   p.cod_ramo,
	   p.fecha_suscripcion,
	   p.nueva_renov
  into _tipo_produccion,
	   _cod_compania,
	   _cod_ramo,
	   _fecha_suscripcion,
	   _nueva_renov
  from emipomae	p, emitipro t
 where p.no_poliza    = v_poliza
   and p.cod_tipoprod = t.cod_tipoprod;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
 
if _ramo_sis = 8 then --multiriesgo debe llevar contenido
	let _tipo_incendio = 2;
else
	let _tipo_incendio = null;
end if

if _tipo_produccion = 2 then
	select par_ase_lider
	  into _cod_coasegur
	  from parparam
	 where cod_compania = _cod_compania;

	select porc_partic_coas
	  into _porc_coas
	  from emicoama
	 where no_poliza    = v_poliza
	   and cod_coasegur = _cod_coasegur;
else
	let _porc_coas = 100;
end if

------------------------
-- Cargar las Unidades
------------------------
--drop table if exists prue;
create temp table prue(
no_poliza		char(10),
no_endoso		char(5),
no_unidad		char(5),
descripcion		text ) with no log;

delete from endcobde
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endcobre
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

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

insert into prue
select * from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedde2
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endedacr
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endcuend
 where no_poliza = v_poliza
   and no_endoso = v_endoso;
   
select *
  from endmoaut
 where no_poliza = v_poliza
   and no_endoso = v_endoso
  into temp tmp_endmoaut;

delete from endmoaut
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

delete from endeduni
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

select * 
  from endeduni
 where no_poliza = v_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set suma_asegurada = suma_asegurada ,
       no_endoso      = v_endoso,
	   prima          = prima ,
	   descuento      = descuento  ,
	   recargo        = recargo ,
	   prima_neta     = prima_neta ,
	   impuesto       = impuesto ,
	   prima_bruta    = prima_bruta ,
	   prima_suscrita = prima_suscrita ,
	   prima_retenida = prima_retenida ;
	   
insert into endeduni
select * from e_prueba;

drop table e_prueba;

insert into endmoaut
select *
  from tmp_endmoaut
 where no_poliza = v_poliza
   and no_endoso = v_endoso;

drop table tmp_endmoaut;

insert into endedde2
select * from prue
 where no_poliza = v_poliza
   and no_endoso = v_endoso;
   
drop table prue;

select * 
  from endunide
 where no_poliza = v_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set no_endoso      = v_endoso;
	   
insert into endunide
select * from e_prueba;

drop table e_prueba;

select * 
  from emifacon
 where no_poliza = v_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set suma_asegurada = suma_asegurada ,
       prima          = prima ,
       no_endoso      = v_endoso;
	   
insert into emifacon
select * from e_prueba;

drop table e_prueba;

select * 
  from emifafac
 where no_poliza = v_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set suma_asegurada = suma_asegurada ,
       no_endoso      = v_endoso,
	   prima          = prima ,
	   monto_comision = monto_comision  ,
	   monto_impuesto = monto_impuesto ;
	   
insert into emifafac
select * from e_prueba;

drop table e_prueba;
--****
select * 
  from endunire
 where no_poliza = v_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set no_endoso = v_endoso;
   
insert into endunire
select * from e_prueba;

drop table e_prueba;

-- Cargar las coberturas

delete from endedcob
 where no_poliza   = v_poliza
   and no_endoso   = v_endoso;
   
select *
  from endedcob
 where no_poliza = v_poliza
   and no_endoso = a_no_endoso_ant
  into temp e_prueba;
  
update e_prueba
   set prima          = prima ,
       no_endoso      = v_endoso,
	   limite_1       = 0,
	   limite_2       = 0,
	   prima_anual    = prima_anual ,
	   prima          = prima ,
	   descuento      = descuento  ,
	   recargo        = recargo ,
	   prima_neta     = prima_neta ,
	   date_added     = current,
	   date_changed   = current;
	   
insert into endedcob
select * from e_prueba;

drop table e_prueba;

return r_error, r_descripcion;
end
end procedure;