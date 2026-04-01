-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo009;

CREATE PROCEDURE "informix".sp_bo009()

drop table ef_estfin;

create table ef_estfin(
ano				char(4),
periodo			smallint,
enlace			char(10),
ccosto			char(3),
gascompagcor	dec(16,2) DEFAULT 0,
gascompagrea	dec(16,2) DEFAULT 0,
gascomreaced	dec(16,2) DEFAULT 0,
gasimppagpri	dec(16,2) DEFAULT 0,
gasgasman		dec(16,2) DEFAULT 0,
gasgasins		dec(16,2) DEFAULT 0,
gasgascob		dec(16,2) DEFAULT 0,
sinsinpagsal	dec(16,2) DEFAULT 0,
sinrecobros		dec(16,2) DEFAULT 0,
sinrecreaced	dec(16,2) DEFAULT 0,
sinvarressin	dec(16,2) DEFAULT 0,
sinporrecrea	dec(16,2) DEFAULT 0,
ingprisegdir	dec(16,2) DEFAULT 0,
ingprireaasu	dec(16,2) DEFAULT 0,
ingreacedpro	dec(16,2) DEFAULT 0,
ingreacedxsp	dec(16,2) DEFAULT 0,
ingaumdisres	dec(16,2) DEFAULT 0,
gasrescatest	dec(16,2) DEFAULT 0,
gasgasadmin		dec(16,2) DEFAULT 0,
gasintganinv	dec(16,2) DEFAULT 0,
gasotringgas	dec(16,2) DEFAULT 0,
gasgasfinan		dec(16,2) DEFAULT 0,
ingtotprisus	dec(16,2) DEFAULT 0,
porcpescar		dec(16,2) DEFAULT 0,
gastotgasadm	dec(16,2) DEFAULT 0,
gastotintganinv	dec(16,2) DEFAULT 0,
gastototringgas	dec(16,2) DEFAULT 0,
gastotgasfinan	dec(16,2) DEFAULT 0,
sinvarressin2	dec(16,2) DEFAULT 0,
sinvarressin3	dec(16,2) DEFAULT 0,
gp_salarios		dec(16,2) DEFAULT 0,
gp_decimo		dec(16,2) DEFAULT 0,
gp_seg_social	dec(16,2) DEFAULT 0,
gp_seg_edu		dec(16,2) DEFAULT 0,
gp_ries_pro		dec(16,2) DEFAULT 0,
gp_gas_rep		dec(16,2) DEFAULT 0,
gp_imdemni		dec(16,2) DEFAULT 0,
gp_seg_emp		dec(16,2) DEFAULT 0,
gp_fondo_ces	dec(16,2) DEFAULT 0,
ga_alquiler		dec(16,2) DEFAULT 0,
ga_luz			dec(16,2) DEFAULT 0,
ga_telefono		dec(16,2) DEFAULT 0,
ga_papeleria	dec(16,2) DEFAULT 0,
ga_eq_rod		dec(16,2) DEFAULT 0,
ga_hon_pro		dec(16,2) DEFAULT 0,
ga_rep_man		dec(16,2) DEFAULT 0,
ga_seguros		dec(16,2) DEFAULT 0,
ga_aseo			dec(16,2) DEFAULT 0,
ga_postal		dec(16,2) DEFAULT 0,
ga_cuotas		dec(16,2) DEFAULT 0,
ga_ent_per		dec(16,2) DEFAULT 0,
ga_misce		dec(16,2) DEFAULT 0,
gc_rel_pub		dec(16,2) DEFAULT 0,
gc_pub_pro		dec(16,2) DEFAULT 0,
gc_jun_dir		dec(16,2) DEFAULT 0,
gc_donacion		dec(16,2) DEFAULT 0,
gc_viajes		dec(16,2) DEFAULT 0,
gc_reu_cor		dec(16,2) DEFAULT 0,
gc_ate_emp		dec(16,2) DEFAULT 0,
gg_dep_amor		dec(16,2) DEFAULT 0,
gg_impuestos	dec(16,2) DEFAULT 0,
gt_tot_gas_per	dec(16,2) DEFAULT 0,
gt_tot_gas_adm	dec(16,2) DEFAULT 0,
gt_tot_gas_com	dec(16,2) DEFAULT 0,
gt_tot_gas_otr	dec(16,2) DEFAULT 0,
gt_tot_gas_fin	dec(16,2) DEFAULT 0,
status			char(1),
gastotingdir	dec(16,2) DEFAULT 0,
gascominc		dec(16,2) DEFAULT 0,
gascomneto		dec(16,2) DEFAULT 0,
sinsinpagneto	dec(16,2) DEFAULT 0,
sinvarressin4	dec(16,2) DEFAULT 0,
sinsinnetinc	dec(16,2) DEFAULT 0,
ingprisus		dec(16,2) DEFAULT 0,
ingpricedrea	dec(16,2) DEFAULT 0,
ingprinetret	dec(16,2) DEFAULT 0,
ingprideven		dec(16,2) DEFAULT 0,
sintotgassin	dec(16,2) DEFAULT 0,
perganopeseg	dec(16,2) DEFAULT 0,
utilidadneta	dec(16,2) DEFAULT 0,
gasimprecpri	dec(16,2) DEFAULT 0,
gp_bon_ger		dec(16,2) DEFAULT 0,
primary key (ano, periodo, enlace, ccosto)

);

create index idx_ef_estfin_1 on ef_estfin (ano, periodo, ccosto); 

alter table ef_estfin lock mode (row);


drop table ef_saldodet;

create table ef_saldodet(
sldet_tipo           char(2),
sldet_cuenta         char(12),
sldet_ccosto         char(3),
sldet_ano            char(4),
sldet_periodo        smallint,
sldet_debtop         dec(16,2),
sldet_cretop         dec(16,2),
sldet_saldop         dec(16,2),
sldet_enlace		 char(10),
sldet_recibe         char(1),
primary key (sldet_tipo, sldet_cuenta, sldet_ccosto, sldet_ano, sldet_periodo)
);

create index idx_ef_saldodet_1 on ef_saldodet (sldet_cuenta); 
create index idx_ef_saldodet_2 on ef_saldodet (sldet_cuenta, sldet_recibe); 

alter table ef_saldodet lock mode (row);


drop table ef_sumas;

create table ef_sumas(
ano				char(4),
periodo			smallint,
enlace			char(10),
ccosto			char(3),
monto           dec(16,2),
primary key (ano, periodo, enlace, ccosto)
);

alter table ef_sumas lock mode (row);


drop table ef_cglcuentas;

create table ef_cglcuentas(
cta_cuenta           char(12),
cta_nombre           char(50),
cta_nomexten         char(80),
cta_tipo             char(1),
cta_subtipo          char(2),
cta_nivel            char(1),
cta_tippartida       char(1),
cta_recibe           char(1),
cta_histmes          char(1),
cta_histano          char(1),
cta_auxiliar         char(1),
cta_saldoprom        char(1),
cta_moneda           char(2),
cta_enlace			 char(10),  
primary key (cta_cuenta)
);

create index idx_ef_cglcuentas_1 on ef_cglcuentas (cta_cuenta, cta_recibe); 

alter table ef_cglcuentas lock mode (row);


--drop table ef_compania;

create table ef_compania(
cia_comp		char(3),
cia_nom     	char(50),
cia_dir1    	char(35),
cia_dir2    	char(35),
cia_idt     	char(20),
cia_bda_codigo	char(18),
tipo			smallint
);

alter table ef_compania lock mode (row);

end procedure