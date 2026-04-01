-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 16/04/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo060;

create procedure "informix".sp_bo060()

delete from ef_sumas;

insert into ef_sumas
select ano, 
       periodo, 
       enlace, 
       ccosto, 
	   sum(prima_cobrada_acu),
       sum(prima_cobrada),
	   cia_comp
  from sac:cglsaldocob
 group by cia_comp, ano, periodo, enlace, ccosto;

end procedure