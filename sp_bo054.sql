-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 16/04/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_bo054;

create procedure "informix".sp_bo054(a_cuenta char(12))

let a_cuenta = trim(a_cuenta) || "*";

delete from ef_sumas;

insert into ef_sumas
select pre2_ano, 
       pre2_periodo, 
       pre2_enlace, 
       pre2_ccosto, 
       sum(pre2_montoacu), 
       sum(pre2_montomes),
	   pre2_cia_comp
  from sac999:ef_cglpre02
 where pre2_cuenta matches a_cuenta
--   and pre2_recibe = 'S'
 group by pre2_ano, pre2_periodo, pre2_enlace, pre2_ccosto, pre2_cia_comp;

end procedure