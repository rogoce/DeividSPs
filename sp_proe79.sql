-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe79;
 
create procedure sp_proe79(a_poliza CHAR(10), a_unidad CHAR(5), a_cobertura CHAR(5),a_cod_descuento char(3),a_porc decimal(5,2))
returning smallint;

set isolation to dirty read;

--set debug file to "sp_proe79.trc";
--trace on;

delete from emicobde
where no_poliza = a_poliza
and no_unidad = a_unidad
and cod_cobertura = a_cobertura
and cod_descuen = a_cod_descuento;

insert into emicobde(
cod_cobertura,
cod_descuen,
no_poliza,
no_unidad,
porc_descuento)
values(
a_cobertura,
a_cod_descuento,
a_poliza,
a_unidad,
a_porc
);
return 0;
end procedure
