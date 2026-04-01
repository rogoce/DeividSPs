-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo056;

create procedure "informix".sp_bo056()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Subtotales

update ef_estfin
   set gt_tot_gas_per = gp_salarios    +
   						gp_vacaciones  + 
   						gp_decimo      + 
   						gp_seg_social  + 
   						gp_seg_edu     + 
   						gp_ries_pro    + 
   						gp_gas_rep     + 
                        gp_imdemni     + 
                        gp_fondo_ces   + 
                        gp_seg_emp     + 
                        gp_bon_ger     +
                        ga_ent_per     + 
       					gc_viajes      + 
                        gc_ate_emp	   +
						gp_uniformes   +
						gp_transporte  +
						gp_sobretiempo +
						gp_bonif_geren +
						gp_partic_util,

       gt_tot_gas_adm = gc_jun_dir     + 
       					ga_alquiler    + 
       					ga_luz         + 
       					ga_telefono    + 
						ga_agua        +
       					ga_papeleria   + 
       					ga_eq_rod      + 
						ga_mant_veh    +
       					ga_hon_pro     + 
                        ga_rep_man     + 
						ga_rep_man_eq  +
						ga_rep_man_ot  +
                        ga_seguros     + 
                        ga_aseo        + 
                        ga_postal      + 
                        ga_cuotas      + 
                        ga_misce	   +
						ga_jun_dir_reu +
       					gc_donacion    + 
						ga_presidencia +
						gg_dep_amor    + 
       					gg_impuestos   +
						ga_leasing     +
						ga_form_impre  +
						ga_gasolina    +
						ga_honor_otros +
						ga_gas_no_ded  +
						ga_rep_man_it,

       gt_tot_gas_com = gc_reu_cor     +
						gc_adies_agen  +
						gc_premios     +
						gc_patrocinios +
						gc_aten_cliente,

       gt_tot_gas_otr = gc_rel_pub     + 
       					gc_pub_pro;

-- Para cuadrar que todos los gastos esten definidos

update ef_estfin
	   set ga_otros       = ga_otros - gt_tot_gas_per - gt_tot_gas_adm - gt_tot_gas_com - gt_tot_gas_otr;

update ef_estfin
	   set gt_tot_gas_adm = gt_tot_gas_adm + ga_otros;

update ef_estfin
   set pre_gt_tot_gas_per = pre_gp_salarios    + 
                            pre_gp_vacaciones  +
   							pre_gp_decimo      + 
   							pre_gp_seg_social  + 
   							pre_gp_seg_edu     + 
   							pre_gp_ries_pro    + 
   							pre_gp_gas_rep     + 
                        	pre_gp_imdemni     + 
                        	pre_gp_fondo_ces   + 
                        	pre_gp_seg_emp     + 
                        	pre_gp_bon_ger     +
                        	pre_ga_ent_per     + 
       						pre_gc_viajes      + 
                        	pre_gc_ate_emp     +
							pre_gp_uniformes   +
							pre_gp_transporte  +
							pre_gp_sobretiempo +
							pre_gp_bonif_geren +
							pre_gp_partic_util,

       pre_gt_tot_gas_adm = pre_gc_jun_dir     + 
       						pre_ga_alquiler    + 
       						pre_ga_luz         + 
       						pre_ga_telefono    + 
							pre_ga_agua        +
       						pre_ga_papeleria   + 
       						pre_ga_eq_rod      + 
							pre_ga_mant_veh    +
       						pre_ga_hon_pro     + 
                        	pre_ga_rep_man     + 
							pre_ga_rep_man_eq  +
							pre_ga_rep_man_ot  +
                        	pre_ga_seguros     + 
                        	pre_ga_aseo        + 
                        	pre_ga_postal      + 
                        	pre_ga_cuotas      + 
                        	pre_ga_misce       +
							pre_ga_jun_dir_reu +
       						pre_gc_donacion    + 
							pre_ga_presidencia +
							pre_gg_dep_amor    + 
       						pre_gg_impuestos   +
							pre_ga_leasing     +
							pre_ga_form_impre  +
							pre_ga_gasolina    +
							pre_ga_honor_otros +
							pre_ga_gas_no_ded  +
							pre_ga_rep_man_it,

       pre_gt_tot_gas_com = pre_gc_reu_cor     + 
							pre_gc_adies_agen  +
							pre_gc_premios     +
							pre_gc_patrocinios +
							pre_gc_aten_cliente,

       pre_gt_tot_gas_otr = pre_gc_rel_pub     + 
       						pre_gc_pub_pro;

-- Acumulacion de pasivos de los gastos

update ef_estfin
   set pas_gt_tot_gas_per = pas_gp_salarios    +
   						    pas_gp_vacaciones  + 
   						    pas_gp_decimo      + 
   						    pas_gp_seg_social  + 
   						    pas_gp_seg_edu     + 
   						    pas_gp_ries_pro    + 
   						    pas_gp_gas_rep     + 
                            pas_gp_imdemni     + 
                            pas_gp_fondo_ces   + 
                            pas_gp_seg_emp     + 
                            pas_gp_bon_ger     +
                            pas_ga_ent_per     + 
       					    pas_gc_viajes      + 
                            pas_gc_ate_emp	   +
						    pas_gp_uniformes   +
						    pas_gp_transporte  +
						    pas_gp_sobretiempo +
						    pas_gp_bonif_geren +
						    pas_gp_partic_util,

       pas_gt_tot_gas_adm = pas_gc_jun_dir     + 
       					    pas_ga_alquiler    + 
       					    pas_ga_luz         + 
       					    pas_ga_telefono    + 
						    pas_ga_agua        +
       					    pas_ga_papeleria   + 
       					    pas_ga_eq_rod      + 
						    pas_ga_mant_veh    +
       					    pas_ga_hon_pro     + 
                            pas_ga_rep_man     + 
						    pas_ga_rep_man_eq  +
						    pas_ga_rep_man_ot  +
                            pas_ga_seguros     + 
                            pas_ga_aseo        + 
                            pas_ga_postal      + 
                            pas_ga_cuotas      + 
                            pas_ga_misce	   +
						    pas_ga_jun_dir_reu +
       					    pas_gc_donacion    + 
						    pas_ga_presidencia +
						    pas_gg_dep_amor    + 
       					    pas_gg_impuestos   +
						    pas_ga_leasing     +
						    pas_ga_form_impre  +
						    pas_ga_gasolina    +
						    pas_ga_honor_otros +
						    pas_ga_gas_no_ded  +
						    pas_ga_rep_man_it,

       pas_gt_tot_gas_com = pas_gc_reu_cor     +
						    pas_gc_adies_agen  +
						    pas_gc_premios     +
						    pas_gc_patrocinios +
						    pas_gc_aten_cliente,

       pas_gt_tot_gas_otr = pas_gc_rel_pub     + 
       					    pas_gc_pub_pro;

-- Total de Gastos

update ef_estfin
   set gt_tot_gas_fin = gt_tot_gas_per + gt_tot_gas_adm + gt_tot_gas_com + gt_tot_gas_otr;

update ef_estfin
   set pre_gt_tot_gas_fin = pre_gt_tot_gas_per + pre_gt_tot_gas_adm + pre_gt_tot_gas_com + pre_gt_tot_gas_otr;

update ef_estfin
   set pas_gt_tot_gas_fin = pas_gt_tot_gas_per + pas_gt_tot_gas_adm + pas_gt_tot_gas_com + pas_gt_tot_gas_otr;

-- Total de Ingresos Directos

update ef_estfin
   set gastotingdir = gascompagcor + 
   					  gascompagrea + 
   					  gascomreaced + 
   					  gasimppagpri - 
   					  gasimprecpri + 
   					  gasgasman    + 
   					  gasgasins    + 
   					  gasgascob;

update ef_estfin
   set pre_gastotingdir = pre_gascompagcor + 
                          pre_gascompagrea + 
                          pre_gascomreaced + 
                          pre_gasimppagpri + 
                          pre_gasimprecpri + 
                          pre_gasgasman    + 
                          pre_gasgasins    + 
                          pre_gasgascob;

-- Total de Comisiones Incurridas

update ef_estfin
   set gascominc = gascompagcor + gascompagrea;

update ef_estfin
   set pre_gascominc = pre_gascompagcor + pre_gascompagrea;

-- Total de Comisiones Neto

update ef_estfin
   set gascomneto = gascompagcor + gascompagrea + gascomreaced;

update ef_estfin
   set pre_gascomneto = pre_gascompagcor + pre_gascompagrea + pre_gascomreaced;

-- Total de Comisiones Pagadas Neto

update ef_estfin
   set sinsinpagneto = sinsinpagsal + sinrecobros + sinrecreaced;

update ef_estfin
   set pre_sinsinpagneto = pre_sinsinpagsal + pre_sinrecobros + pre_sinrecreaced;

-- Total de Siniestros Pend. Liq

update ef_estfin
   set sinvarressin4 = (sinvarressin + sinporrecrea) * -1;

update ef_estfin
   set pre_sinvarressin4 = (pre_sinvarressin + pre_sinporrecrea);

-- Total de Siniestros Netos Incurridos

update ef_estfin
   set sinsinnetinc = sinsinpagsal + sinrecobros + sinrecreaced + sinvarressin3;

update ef_estfin
   set pre_sinsinnetinc = pre_sinsinpagsal + pre_sinrecobros + pre_sinrecreaced + pre_sinvarressin3;

--update ef_estfin
--   set sinsinnetinc = sinsinpagsal + sinrecobros + sinrecreaced - sinvarressin4;


-- Total de Primas suscrita

update ef_estfin
   set ingprisus = ingprisegdir + ingprireaasu;

update ef_estfin
   set pre_ingprisus = pre_ingprisegdir + pre_ingprireaasu;

-- Total de Primas Cedidas en Reaseguro

update ef_estfin
   set ingpricedrea = ingreacedpro + ingreacedxsp;

update ef_estfin
   set pre_ingpricedrea = pre_ingreacedpro + pre_ingreacedxsp;

-- Total de Primas Netas Retenidas

update ef_estfin
   set ingprinetret = ingprisegdir + ingprireaasu + ingreacedpro + ingreacedxsp;

update ef_estfin
   set pre_ingprinetret = pre_ingprisegdir + pre_ingprireaasu + pre_ingreacedpro + pre_ingreacedxsp;

-- Total de Primas Devengadas

update ef_estfin
   set ingprideven = ingprisegdir + ingprireaasu + ingreacedpro + ingreacedxsp + ingaumdisres;

update ef_estfin
   set pre_ingprideven = pre_ingprisegdir + pre_ingprireaasu + pre_ingreacedpro + pre_ingreacedxsp + pre_ingaumdisres;

-- Total de Gastos y Siniestros

update ef_estfin
   set sintotgassin = sinsinnetinc + gastotingdir + gasrescatest + gasgasadmin;
  
update ef_estfin
   set pre_sintotgassin = pre_sinsinnetinc + pre_gastotingdir + pre_gasrescatest + pre_gasgasadmin;
  
-- Perdida-Ganancias Operaciones Seguros

update ef_estfin
   set perganopeseg = ingprideven + sintotgassin;

update ef_estfin
   set pre_perganopeseg = pre_ingprideven + pre_sintotgassin;

-- Perdida-Ganancias Operaciones Seguros

update ef_estfin
   set utilidadneta = perganopeseg + gasintganinv + gasotringgas + gasgasfinan;

update ef_estfin
   set pre_utilidadneta = pre_perganopeseg + pre_gasintganinv + pre_gasotringgas + pre_gasgasfinan;

update ef_estfin
   set gascomreaced = gascomreaced * -1,
       sinrecobros  = sinrecobros  * -1,
       sinrecreaced = sinrecreaced * -1,
       sinvarressin = sinvarressin * -1,
--       sinporrecrea = sinporrecrea * -1,
       ingprisegdir = ingprisegdir * -1,
	   ingprireaasu = ingprireaasu * -1,
       gasintganinv = gasintganinv * -1,
       gasotringgas = gasotringgas * -1,
       ingprisus    = ingprisus    * -1,
       ingprinetret = ingprinetret * -1,
       ingprideven  = ingprideven  * -1,
       ingaumdisres = ingaumdisres * -1,
       perganopeseg = perganopeseg * -1,

	   ingpricedrea  = ingpricedrea  * -1,
	   sinsinpagsal  = sinsinpagsal  * -1,
	   sinvarressin3 = sinvarressin3 * -1,
	   gascompagcor  = gascompagcor  * -1,
	   gasimppagpri  = gasimppagpri  * -1,
	   gasgasman     = gasgasman     * -1,
	   gasgasins     = gasgasins     * -1,
	   gasgascob     = gasgascob     * -1,
	   gasrescatest  = gasrescatest  * -1,
	   gasgasadmin   = gasgasadmin   * -1,

	   gascompagrea  = gascompagrea  * -1,	

       utilidadneta = utilidadneta * -1;

end

return 0, "Actualizacion Exitosa";

end procedure