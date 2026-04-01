-- Procedure que crea el Historico de Corredores para las facturas

-- Creado    : 11/12/2004 - Autor: Demetrio Hurtado Almanza
--			   
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis70;		

create procedure "informix".sp_sis70(
a_no_poliza char(10), 
a_no_endoso char(5)
);

define _cantidad	smallint;

select count(*)
  into _cantidad
  from endmoage
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad <> 0 then
	return;
end if

insert into endmoage(
	   no_poliza,
	   no_endoso,
	   cod_agente,
	   porc_partic_agt,
	   porc_comis_agt,
	   porc_produc
	   )
select no_poliza,
	   a_no_endoso,	
       cod_agente,
	   porc_partic_agt,
       porc_comis_agt,
       porc_produc
  from emipoagt
 where no_poliza = a_no_poliza;


end procedure 
