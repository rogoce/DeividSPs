-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 16/04/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo058;

create procedure "informix".sp_bo058(a_cuenta char(12))

let a_cuenta = trim(a_cuenta) || "*";

delete from ef_sumas;

insert into ef_sumas
select pre3_ano, 
       pre3_periodo, 
       "99999999", 
       "001", 
       sum(pre3_montoacu), 
       sum(pre3_montomes),
	   "001"
  from sac:cglpre03
 where pre3_cuenta matches a_cuenta
 group by pre3_ano, pre3_periodo;

end procedure