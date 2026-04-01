-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo012;

create procedure "informix".sp_bo012(a_cuenta char(12))

define _ano_fiscal	smallint;

select par_anofiscal
  into _ano_fiscal
  from cglparam;

let _ano_fiscal = _ano_fiscal - 1;

let a_cuenta = trim(a_cuenta) || "*";

delete from ef_sumas;

insert into ef_sumas
select sldet_ano, 
       sldet_periodo, 
       sldet_enlace, 
       sldet_ccosto, 
       sum(sldet_saldop), 
       sum(sldet_debtop + sldet_cretop),
	   sldet_cia_comp
  from ef_saldodet
 where sldet_cuenta matches a_cuenta
   and sldet_recibe = 'S'
   and sldet_ano   >= _ano_fiscal
 group by sldet_ano, sldet_periodo, sldet_enlace, sldet_ccosto, sldet_cia_comp;

end procedure