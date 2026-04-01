-- Inicializacion de Tablas

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_sac15;

create procedure "informix".sp_sac15()

delete from cglresumen1;
delete from cglresumen;

update cglsaldodet
   set sldet_debtop = 0.00,
	   sldet_cretop	= 0.00,
	   sldet_saldop = 0.00;

update cglsaldoaux
   set sld_incioano = 0.00;

update cglsaldoaux1
   set sld1_debitos  = 0.00,
       sld1_creditos = 0.00,
       sld1_saldo    = 0.00;

update cglperiodo
   set per_status = "A";

update cglparam
   set par_mesfiscal = 12,
       par_anofiscal = 2003;

delete from cgltrx3;
delete from cgltrx2;
delete from cgltrx1;

end procedure
