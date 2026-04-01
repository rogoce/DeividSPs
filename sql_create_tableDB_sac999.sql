//drop table "DBA".cajs; 

CREATE TABLE "DBA".cajs 
(numero 					FLOAT,
 departamento VARCHAR(255), 
 unidad       VARCHAR(255),
 seccion      VARCHAR(255), 
 nombre       VARCHAR(255), 
 apellido     VARCHAR(255), 
 cedula       VARCHAR(255), 
 empleado     VARCHAR(255), 
 fecha        VARCHAR(255), 
 cargo        VARCHAR(255), 
 fecha_deivid 			 DATE, 
 cedula_deivid    CHAR(30),
 nombre_deivid   CHAR(100),
 edad_deivid       INTEGER,
 codigo_deivid    CHAR(10),
 ced_prov          CHAR(2),
 ced_av            CHAR(2),
 ced_tomo          CHAR(6),
 ced_asiento      CHAR(6));

//drop table "DBA".cglctas;

CREATE TABLE "DBA".cglctas
 (cuenta     CHAR(25) NOT NULL,
  naturaleza CHAR(1),
  nombre     CHAR(50) NOT NULL);

//drop table "DBA".cobasiau;

CREATE TABLE "DBA".cobasiau
(no_remesa CHAR(10)    NOT NULL,
 renglon   SMALLINT    NOT NULL,
 cuenta    CHAR(25)    NOT NULL,
 cod_auxiliar CHAR(5)  NOT NULL,
 debito  DECIMAL(16,2) NOT NULL,
 credito DECIMAL(16,2) NOT NULL,
 tipo_comp 				  SMALLINT,
 periodo 				   CHAR(7), 
 centro_costo 			  CHAR(3));
CREATE INDEX idx_cobasiau_3 ON "DBA".cobasiau (no_remesa, renglon );

//drop table "DBA".cobasien

CREATE TABLE "DBA".cobasien
(no_remesa    CHAR(10) NOT NULL,
 renglon      SMALLINT NOT NULL,
 cuenta       CHAR(25) NOT NULL,
 debito       DECIMAL(16,2) NOT NULL,
 credito      DECIMAL(16,2) NOT NULL,
 tipo_comp    SMALLINT, 
 sac_notrx    INTEGER, 
 periodo      CHAR(7),
 centro_costo CHAR(3));

CREATE INDEX idx_cobasien_2 ON "DBA".cobasien (no_remesa);
CREATE INDEX idx_cobasien_3 ON "DBA".cobasien (no_remesa, renglon);
CREATE INDEX idx_cobasien_4 ON "DBA".cobasien (periodo, tipo_comp, cuenta);
CREATE INDEX idx_cobasien_5 ON "DBA".cobasien (sac_notrx);
CREATE INDEX idx_cobasien_6 ON "DBA".cobasien (periodo, tipo_comp, cuenta, centro_costo);

//drop table "DBA".ef_cglcentro
CREATE TABLE "DBA".ef_cglcentro 
(cen_codigo      CHAR(3)  NOT NULL,
 cen_descripcion CHAR(30) NOT NULL,
 cen_cia_comp CHAR(3));

//drop table "DBA".ef_cglcuentas

CREATE TABLE "DBA".ef_cglcuentas
(cta_cuenta    CHAR(12),
 cta_nombre    CHAR(50),
 cta_nomexten  CHAR(80),
 cta_tipo       CHAR(1), 
 cta_subtipo    CHAR(2), 
 cta_nivel      CHAR(1), 
 cta_tippartida CHAR(1), 
 cta_recibe     CHAR(1), 
 cta_histmes    CHAR(1), 
 cta_histano    CHAR(1), 
 cta_auxiliar   CHAR(1),
 cta_saldoprom  CHAR(1),
 cta_moneda     CHAR(2),
 cta_enlace   CHAR(10));

//drop table  "DBA".ef_cglpre02;

CREATE TABLE "DBA".ef_cglpre02 
(pre2_cia_comp CHAR(3)  NOT NULL,
 pre2_tipo     CHAR(2)  NOT NULL,
 pre2_cuenta   CHAR(12) NOT NULL,
 pre2_ccosto   CHAR(3)  NOT NULL,
 pre2_ano      CHAR(4)  NOT NULL,
 pre2_periodo  SMALLINT NOT NULL, 
 pre2_montomes DECIMAL(16,2) NOT NULL,
 pre2_montoacu DECIMAL(16,2) NOT NULL, 
 pre2_enlace   CHAR(10), pre2_recibe CHAR(1));

//drop table "DBA".ef_cglresumen;

CREATE TABLE "DBA".ef_cglresumen
(res_noregistro    INTEGER,
 res_tipo_resumen  CHAR(2),
 res_notrx         INTEGER,
 res_comprobante   CHAR(8),
 res_fechatrx         DATE,
 res_tipcomp       CHAR(3),
 res_ccosto        CHAR(3),
 res_descripcion  CHAR(50),
 res_moneda        CHAR(2), 
 res_cuenta       CHAR(12),
 res_debito  DECIMAL(15,2),
 res_credito DECIMAL(15,2),
 res_usuariocap   CHAR(15),
 res_usuarioact   CHAR(15), 
 res_fechacap     DATETIME,
 res_fechaact     DATETIME, 
 res_origen        CHAR(3), 
 res_status        CHAR(1),
 res_tabla        CHAR(18),
 res_periodo      SMALLINT,
 res_ano           CHAR(4), 
 res_cia_comp    CHAR(3));

//drop table "DBA".ef_cglresumen1

CREATE TABLE "DBA".ef_cglresumen1 
(res1_noregistro   INTEGER NOT NULL,
 res1_linea        INTEGER NOT NULL,
 res1_tipo_resumen CHAR(2) NOT NULL,
 res1_comprobante  CHAR(8) NOT NULL,
 res1_cuenta       CHAR(12) NOT NULL,
 res1_auxiliar     CHAR(5), 
 res1_debito       DECIMAL(15,2) NOT NULL,
 res1_credito      DECIMAL(15,2) NOT NULL,
 res1_origen       CHAR(3) NOT NULL,
 res1_ccosto       CHAR(3),
 res1_cia_comp     CHAR(3));

//drop table "DBA".ef_cglterceros;

CREATE TABLE "DBA".ef_cglterceros 
(ter_codigo       CHAR(5), 
 ter_descripcion CHAR(35), 
 ter_contacto    CHAR(25), 
 ter_cedula      CHAR(20), 
 ter_telefono    CHAR(15), 
 ter_fax         CHAR(15),
 ter_apartado    CHAR(20), 
 ter_observacion CHAR(50),
 ter_limites DECIMAL(15,2));

//drop table "DBA".ef_compania;

CREATE TABLE "DBA".ef_compania 
(cia_comp  CHAR(3), 
 cia_nom  CHAR(50), 
 cia_dir1 CHAR(35), 
 cia_dir2 CHAR(35),
 cia_idt  CHAR(20), 
 cia_bda_codigo CHAR(18), tipo SMALLINT);

//drop table "DBA".ef_ctaenlace

CREATE TABLE "DBA".ef_ctaenlace (cta_cuenta CHAR(12) NOT NULL) ;

//drop table "DBA".ef_estfin

CREATE TABLE "DBA".ef_estfin 
(ano          CHAR(4),
 periodo      SMALLINT,
 enlace       CHAR(10),
 ccosto       CHAR(3), 
 gascompagcor DECIMAL(16,2) DEFAULT 0.00,
 gascompagrea DECIMAL(16,2) DEFAULT 0.00,
 gascomreaced DECIMAL(16,2) DEFAULT 0.00,
 gasimppagpri DECIMAL(16,2) DEFAULT 0.00,
 gasgasman    DECIMAL(16,2) DEFAULT 0.00, 
 gasgasins    DECIMAL(16,2) DEFAULT 0.00, 
 gasgascob    DECIMAL(16,2) DEFAULT 0.00, 
 sinsinpagsal DECIMAL(16,2) DEFAULT 0.00, 
 sinrecobros  DECIMAL(16,2) DEFAULT 0.00,
 sinrecreaced DECIMAL(16,2) DEFAULT 0.00, 
 sinvarressin DECIMAL(16,2) DEFAULT 0.00, 
 sinporrecrea DECIMAL(16,2) DEFAULT 0.00, 
 ingprisegdir DECIMAL(16,2) DEFAULT 0.00, 
 ingprireaasu DECIMAL(16,2) DEFAULT 0.00, 
 ingreacedpro DECIMAL(16,2) DEFAULT 0.00, 
 ingreacedxsp DECIMAL(16,2) DEFAULT 0.00, 
 ingaumdisres DECIMAL(16,2) DEFAULT 0.00, 
 gasrescatest DECIMAL(16,2) DEFAULT 0.00, 
 gasgasadmin  DECIMAL(16,2) DEFAULT 0.00, 
 gasintganinv DECIMAL(16,2) DEFAULT 0.00,
 gasotringgas DECIMAL(16,2) DEFAULT 0.00,
 gasgasfinan  DECIMAL(16,2) DEFAULT 0.00,
 ingtotprisus DECIMAL(16,2) DEFAULT 0.00,
 porcpescar   DECIMAL(16,2) DEFAULT 0.00,
 gastotgasadm DECIMAL(16,2) DEFAULT 0.00,
 gastotintganinv DECIMAL(16,2) DEFAULT 0.00,
 gastototringgas DECIMAL(16,2) DEFAULT 0.00,
 gastotgasfinan  DECIMAL(16,2) DEFAULT 0.00,
 sinvarressin2   DECIMAL(16,2) DEFAULT 0.00,
 sinvarressin3   DECIMAL(16,2) DEFAULT 0.00,
 gp_salarios     DECIMAL(16,2) DEFAULT 0.00,
 gp_decimo       DECIMAL(16,2) DEFAULT 0.00, 
 gp_seg_social   DECIMAL(16,2) DEFAULT 0.00,
 gp_seg_edu      DECIMAL(16,2) DEFAULT 0.00,
 gp_ries_pro     DECIMAL(16,2) DEFAULT 0.00, 
 gp_gas_rep      DECIMAL(16,2) DEFAULT 0.00,
 gp_imdemni      DECIMAL(16,2) DEFAULT 0.00,
 gp_seg_emp      DECIMAL(16,2) DEFAULT 0.00, 
 gp_fondo_ces    DECIMAL(16,2) DEFAULT 0.00, 
 ga_alquiler     DECIMAL(16,2) DEFAULT 0.00,
 ga_luz          DECIMAL(16,2) DEFAULT 0.00, 
 ga_telefono     DECIMAL(16,2) DEFAULT 0.00,
 ga_papeleria    DECIMAL(16,2) DEFAULT 0.00, 
 ga_eq_rod       DECIMAL(16,2) DEFAULT 0.00,
 ga_hon_pro      DECIMAL(16,2) DEFAULT 0.00,
 ga_rep_man      DECIMAL(16,2) DEFAULT 0.00, 
 ga_seguros      DECIMAL(16,2) DEFAULT 0.00, 
 ga_aseo         DECIMAL(16,2) DEFAULT 0.00, 
 ga_postal       DECIMAL(16,2) DEFAULT 0.00, 
 ga_cuotas       DECIMAL(16,2) DEFAULT 0.00,
 ga_ent_per      DECIMAL(16,2) DEFAULT 0.00, 
 ga_misce        DECIMAL(16,2) DEFAULT 0.00,
 gc_rel_pub      DECIMAL(16,2) DEFAULT 0.00,
 gc_pub_pro      DECIMAL(16,2) DEFAULT 0.00,
 gc_jun_dir      DECIMAL(16,2) DEFAULT 0.00, 
 gc_donacion     DECIMAL(16,2) DEFAULT 0.00, 
 gc_viajes       DECIMAL(16,2) DEFAULT 0.00,
 gc_reu_cor      DECIMAL(16,2) DEFAULT 0.00,
 gc_ate_emp      DECIMAL(16,2) DEFAULT 0.00,
 gg_dep_amor     DECIMAL(16,2) DEFAULT 0.00, 
 gg_impuestos    DECIMAL(16,2) DEFAULT 0.00, 
 gt_tot_gas_per  DECIMAL(16,2) DEFAULT 0.00, 
 gt_tot_gas_adm  DECIMAL(16,2) DEFAULT 0.00,
 gt_tot_gas_com  DECIMAL(16,2) DEFAULT 0.00,
 gt_tot_gas_otr  DECIMAL(16,2) DEFAULT 0.00, 
 gt_tot_gas_fin  DECIMAL(16,2) DEFAULT 0.00, 
 status          CHAR(1), gastotingdir DECIMAL(16,2) DEFAULT 0.00, 
 gascominc       DECIMAL(16,2)  DEFAULT 0.00,
 gascomneto      DECIMAL(16,2)  DEFAULT 0.00, 
 sinsinpagneto   DECIMAL(16,2)  DEFAULT 0.00, 
 sinvarressin4   DECIMAL(16,2)  DEFAULT 0.00, 
 sinsinnetinc    DECIMAL(16,2)  DEFAULT 0.00,
 ingprisus       DECIMAL(16,2)  DEFAULT 0.00, 
 ingpricedrea    DECIMAL(16,2)  DEFAULT 0.00, 
 ingprinetret    DECIMAL(16,2)  DEFAULT 0.00, 
 ingprideven     DECIMAL(16,2)  DEFAULT 0.00, 
 sintotgassin    DECIMAL(16,2)  DEFAULT 0.00, 
 perganopeseg    DECIMAL(16,2)  DEFAULT 0.00, 
 utilidadneta    DECIMAL(16,2)  DEFAULT 0.00,
 gasimprecpri    DECIMAL(16,2)  DEFAULT 0.00, 
 gp_bon_ger      DECIMAL(16,2)  DEFAULT 0.00, 
 tipo_calculo    CHAR(1),   cia_comp CHAR(3),
 pre_gascompagcor  DECIMAL(16,2) DEFAULT 0,
 pre_gascompagrea  DECIMAL(16,2) DEFAULT 0,
 pre_gascomreaced  DECIMAL(16,2) DEFAULT 0,
 pre_gasimppagpri  DECIMAL(16,2) DEFAULT 0,
 pre_gasgasman     DECIMAL(16,2) DEFAULT 0,
 pre_gasgasins     DECIMAL(16,2) DEFAULT 0,
 pre_gasgascob     DECIMAL(16,2) DEFAULT 0,
 pre_sinsinpagsal  DECIMAL(16,2) DEFAULT 0,
 pre_sinrecobros   DECIMAL(16,2) DEFAULT 0,
 pre_sinrecreaced  DECIMAL(16,2) DEFAULT 0,
 pre_sinvarressin  DECIMAL(16,2) DEFAULT 0,
 pre_sinporrecrea  DECIMAL(16,2) DEFAULT 0,
 pre_ingprisegdir  DECIMAL(16,2) DEFAULT 0,
 pre_ingprireaasu  DECIMAL(16,2) DEFAULT 0,
 pre_ingreacedpro  DECIMAL(16,2) DEFAULT 0,
 pre_ingreacedxsp  DECIMAL(16,2) DEFAULT 0,
 pre_ingaumdisres  DECIMAL(16,2) DEFAULT 0, 
 pre_gasrescatest  DECIMAL(16,2) DEFAULT 0, 
 pre_gasgasadmin   DECIMAL(16,2) DEFAULT 0, 
 pre_gasintganinv  DECIMAL(16,2) DEFAULT 0, 
 pre_gasotringgas  DECIMAL(16,2) DEFAULT 0,
 pre_gasgasfinan   DECIMAL(16,2) DEFAULT 0,
 pre_ingtotprisus  DECIMAL(16,2) DEFAULT 0, 
 pre_porcpescar    DECIMAL(16,2) DEFAULT 0,
 pre_gastotgasadm  DECIMAL(16,2) DEFAULT 0, 
 pre_gastotintganinv DECIMAL(16,2) DEFAULT 0,
 pre_gastototringgas DECIMAL(16,2) DEFAULT 0,
 pre_gastotgasfinan  DECIMAL(16,2) DEFAULT 0,
 pre_sinvarressin2   DECIMAL(16,2) DEFAULT 0, 
 pre_sinvarressin3   DECIMAL(16,2) DEFAULT 0,
 pre_gp_salarios     DECIMAL(16,2) DEFAULT 0,
 pre_gp_decimo       DECIMAL(16,2) DEFAULT 0,
 pre_gp_seg_social   DECIMAL(16,2) DEFAULT 0,
 pre_gp_seg_edu      DECIMAL(16,2) DEFAULT 0,
 pre_gp_ries_pro     DECIMAL(16,2) DEFAULT 0,
 pre_gp_gas_rep      DECIMAL(16,2) DEFAULT 0, 
 pre_gp_imdemni      DECIMAL(16,2) DEFAULT 0,
 pre_gp_seg_emp      DECIMAL(16,2) DEFAULT 0,
 pre_gp_fondo_ces    DECIMAL(16,2) DEFAULT 0,
 pre_ga_alquiler     DECIMAL(16,2) DEFAULT 0,
 pre_ga_luz          DECIMAL(16,2) DEFAULT 0, 
 pre_ga_telefono     DECIMAL(16,2) DEFAULT 0, 
 pre_ga_papeleria    DECIMAL(16,2) DEFAULT 0, 
 pre_ga_eq_rod       DECIMAL(16,2) DEFAULT 0, 
 pre_ga_hon_pro      DECIMAL(16,2) DEFAULT 0, 
 pre_ga_rep_man      DECIMAL(16,2) DEFAULT 0, 
 pre_ga_seguros      DECIMAL(16,2) DEFAULT 0, 
 pre_ga_aseo         DECIMAL(16,2) DEFAULT 0, 
 pre_ga_postal       DECIMAL(16,2) DEFAULT 0,
 pre_ga_cuotas       DECIMAL(16,2) DEFAULT 0, 
 pre_ga_ent_per      DECIMAL(16,2) DEFAULT 0, 
 pre_ga_misce        DECIMAL(16,2) DEFAULT 0, 
 pre_gc_rel_pub      DECIMAL(16,2) DEFAULT 0,
 pre_gc_pub_pro      DECIMAL(16,2) DEFAULT 0, 
 pre_gc_jun_dir      DECIMAL(16,2) DEFAULT 0, 
 pre_gc_donacion     DECIMAL(16,2) DEFAULT 0, 
 pre_gc_viajes       DECIMAL(16,2) DEFAULT 0, 
 pre_gc_reu_cor      DECIMAL(16,2) DEFAULT 0,
 pre_gc_ate_emp      DECIMAL(16,2) DEFAULT 0, 
 pre_gg_dep_amor     DECIMAL(16,2) DEFAULT 0, 
 pre_gg_impuestos    DECIMAL(16,2) DEFAULT 0, 
 pre_gt_tot_gas_per  DECIMAL(16,2) DEFAULT 0, 
 pre_gt_tot_gas_adm  DECIMAL(16,2) DEFAULT 0,
 pre_gt_tot_gas_com  DECIMAL(16,2) DEFAULT 0,
 pre_gt_tot_gas_otr  DECIMAL(16,2) DEFAULT 0,
 pre_gt_tot_gas_fin  DECIMAL(16,2) DEFAULT 0, 
 pre_gastotingdir    DECIMAL(16,2) DEFAULT 0,
 pre_gascominc       DECIMAL(16,2) DEFAULT 0,
 pre_gascomneto      DECIMAL(16,2) DEFAULT 0,
 pre_sinsinpagneto   DECIMAL(16,2) DEFAULT 0,
 pre_sinvarressin4   DECIMAL(16,2) DEFAULT 0,
 pre_sinsinnetinc    DECIMAL(16,2) DEFAULT 0,
 pre_ingprisus       DECIMAL(16,2) DEFAULT 0,
 pre_ingpricedrea    DECIMAL(16,2) DEFAULT 0,
 pre_ingprinetret    DECIMAL(16,2) DEFAULT 0, 
 pre_ingprideven     DECIMAL(16,2) DEFAULT 0,
 pre_sintotgassin    DECIMAL(16,2) DEFAULT 0,
 pre_perganopeseg    DECIMAL(16,2) DEFAULT 0,
 pre_utilidadneta    DECIMAL(16,2) DEFAULT 0,
 pre_gasimprecpri    DECIMAL(16,2) DEFAULT 0,
 pre_gp_bon_ger      DECIMAL(16,2) DEFAULT 0);

CREATE INDEX ix_ef_estfin1 ON "DBA".ef_estfin (ano, periodo, ccosto );
CREATE INDEX ix_ef_estfin2 ON "DBA".ef_estfin (tipo_calculo , cia_comp);
CREATE INDEX ix_ef_estfin3 ON "DBA".ef_estfin (cia_comp );

CREATE TABLE "DBA".ef_saldoaux 
(sld1_tipo     CHAR(2)   NOT NULL, 
 sld1_cuenta   CHAR(12)  NOT NULL,
 sld1_tercero  CHAR(5)   NOT NULL, 
 sld1_ano      CHAR(4)   NOT NULL, 
 sld1_periodo  SMALLINT  NOT NULL, 
 sld1_debitos  DECIMAL(15,2) NOT NULL,
 sld1_creditos DECIMAL(15,2) NOT NULL,
 sld1_saldo    DECIMAL(15,2) NOT NULL,
 sld1_ccosto   CHAR(3) NOT NULL,
 sld1_cia_comp CHAR(3));

drop table "DBA".ef_saldodet;

CREATE TABLE "DBA".ef_saldodet
(sldet_tipo         CHAR(2),
 sldet_cuenta      CHAR(12),
 sldet_ccosto       CHAR(3),
 sldet_ano          CHAR(4),
 sldet_periodo     SMALLINT,
 sldet_debtop DECIMAL(16,2),
 sldet_cretop DECIMAL(16,2),
 sldet_saldop DECIMAL(16,2),
 sldet_enlace      CHAR(10),
 sldet_recibe       CHAR(1),
 sldet_cia_comp    CHAR(3));

CREATE INDEX idx_ef_saldodet_1 ON "DBA".ef_saldodet (sldet_cuenta);

drop table "DBA".ef_sumas;

CREATE TABLE "DBA".ef_sumas 
(ano 		 	     CHAR(4), 
 periodo 	    SMALLINT,
 enlace  	    CHAR(10),
 ccosto   	     CHAR(3),
 monto     DECIMAL(16,2),
 monto_mes DECIMAL(16,2),
 cia_comp  CHAR(3));

//drop table "DBA".endasiau;

CREATE TABLE "DBA".endasiau 
(no_poliza   CHAR(10) NOT NULL,
 no_endoso    CHAR(5) NOT NULL,
 cuenta      CHAR(25) NOT NULL, 
 cod_auxiliar CHAR(5) NOT NULL,
 debito  DECIMAL(16,2) NOT NULL,
 credito DECIMAL(16,2) NOT NULL, 
 tipo_comp    SMALLINT NOT NULL, 
 periodo CHAR(7), centro_costo CHAR(3));

//drop table "DBA".endasien
CREATE TABLE "DBA".endasien 
(no_poliza   CHAR(10)  NOT NULL,
 no_endoso   CHAR(5)   NOT NULL,
 cuenta      CHAR(25)  NOT NULL,
 debito  DECIMAL(16,2) NOT NULL,
 credito DECIMAL(16,2) NOT NULL,
 tipo_comp   SMALLINT  NOT NULL,
 sac_notrx              INTEGER,
 periodo                CHAR(7),
 centro_costo          CHAR(3));
CREATE INDEX idx_endasien_2 ON "DBA".endasien (no_poliza , no_endoso);
CREATE INDEX idx_endasien_3 ON "DBA".endasien (periodo , tipo_comp , cuenta);
CREATE INDEX idx_endasien_4 ON "DBA".endasien (sac_notrx);
CREATE INDEX idx_endasien_5 ON "DBA".endasien (periodo , tipo_comp, cuenta, centro_costo);

//drop table "DBA".epa_saldos

CREATE TABLE "DBA".epa_saldos
(poliza CHAR(20) NOT NULL,
 cedula CHAR(30), 
 asegurado  VARCHAR(100)  NOT NULL,
 forma_pago VARCHAR(50)   NOT NULL,
 sucursal   VARCHAR(50)   NOT NULL,
 ramo       VARCHAR(50)   NOT NULL,
 saldo      DECIMAL(16,2) NOT NULL,
 corriente  DECIMAL(16,2) NOT NULL, 
 dias_30    DECIMAL(16,2) NOT NULL, 
 dias_60    DECIMAL(16,2) NOT NULL,
 dias_90    DECIMAL(16,2) NOT NULL, 
 por_vencer DECIMAL(16,2) NOT NULL);

drop table "DBA".recasiau;

CREATE TABLE "DBA".recasiau
(no_tranrec   CHAR(10) NOT NULL,
 cuenta       CHAR(25) NOT NULL,
 tipo_comp    SMALLINT NOT NULL,
 cod_auxiliar CHAR(5)  NOT NULL,
 debito  DECIMAL(16,2) NOT NULL,
 credito DECIMAL(16,2) NOT NULL, periodo CHAR(7), centro_costo CHAR(3)) ;

CREATE INDEX idx_recasiau_2 ON "DBA".recasiau (no_tranrec , cuenta , tipo_comp );
CREATE INDEX idx_recasiau_3 ON "DBA".recasiau (no_tranrec );
CREATE INDEX idx_recasiau_4 ON "DBA".recasiau (no_tranrec , cuenta , tipo_comp , periodo , centro_costo );

//drop table "DBA".recasien;

CREATE TABLE "DBA".recasien
(no_tranrec   CHAR(10) NOT NULL,
 cuenta       CHAR(25) NOT NULL,
 debito  DECIMAL(16,2) NOT NULL,
 credito DECIMAL(16,2) NOT NULL,
 tipo_comp    SMALLINT NOT NULL,
 sac_notrx              INTEGER,
 periodo      				CHAR(7), 
 centro_costo 			  CHAR(3));

CREATE INDEX idx_recasien_2 ON "DBA".recasien (no_tranrec );
CREATE INDEX idx_recasien_3 ON "DBA".recasien (periodo ,tipo_comp, cuenta);
CREATE INDEX idx_recasien_4 ON "DBA".recasien (sac_notrx);
CREATE INDEX idx_recasien_5 ON "DBA".recasien (periodo, tipo_comp, cuenta, centro_costo);

