-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo013;

create procedure "informix".sp_bo013()
returning integer,
          char(50);

define _error	integer;

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Actualizar Registros";
end exception
 
-- Conversion de las Companias

delete from ef_compania;

insert into ef_compania
select * 
  from sigman02;

insert into ef_compania
values ("999", "ANCON INVESTMENT Y SUBSIDIARIAS (CONSOLIDADO)", "", "", "999", "sac999", 2);

-- Conversion de la tabla de cuentas

delete from ef_cglcuentas;

insert into ef_cglcuentas    
select cta_cuenta,
       cta_nombre,
	   cta_nomexten,
	   cta_tipo,
	   cta_subtipo,
	   cta_nivel,
	   cta_tippartida,
	   cta_recibe,
	   cta_histmes,
	   cta_histano,
	   cta_auxiliar,
	   cta_saldoprom,
	   cta_moneda,
	   "99999999",
	   referencia
  from sac:cglcuentas;

select *
  from sac001:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 

select *
  from sac002:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 

select *
  from sac006:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 

{
select *
  from sac003:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 

select *
  from sac004:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 

select *
  from sac005:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 


select *
  from sac007:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 

select *
  from sac008:cglcuentas
  into temp tmp_cuentas;

execute procedure sp_bo011();
drop table tmp_cuentas; 
}

update ef_cglcuentas
   set cta_enlace = cta_cuenta[4,12]
 where cta_cuenta[1,3] in (select cta_cuenta from ef_ctaenlace)
   and cta_recibe = 'S';

end 

return 0, "Actualizacion Exitosa";

end procedure