-- Renumerar las estructuras de detalles

-- Creado    : 23/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac09;

create procedure "informix".sp_sac09(
a_notrx1_old	integer,
a_notrx1_new	integer
) returning integer,
            char(100);

define _error	integer;

--set debug file to "sp_sac09.trc";
--trace on;

begin work;

begin
on exception set _error
	drop table tmp_cgltrx1;
	rollback work;
	return _error, "Error de Base de Datos";
end exception

-- Insertar

select * 
  from cgltrx1
 where trx1_notrx = a_notrx1_old
  into temp tmp_cgltrx1;

select * 
  from cgltrx2
 where trx2_notrx = a_notrx1_old
  into temp tmp_cgltrx2;

select * 
  from cgltrx3
 where trx3_notrx = a_notrx1_old
  into temp tmp_cgltrx3;

-- Actualizar

update tmp_cgltrx1
   set trx1_notrx = a_notrx1_new;

update tmp_cgltrx2
   set trx2_notrx = a_notrx1_new;

update tmp_cgltrx3
   set trx3_notrx = a_notrx1_new;

-- Insertar

insert into cgltrx1
select *
  from tmp_cgltrx1;

insert into cgltrx2
select *
  from tmp_cgltrx2;

insert into cgltrx3
select *
  from tmp_cgltrx3;

-- Borrar

delete from cgltrx3
 where trx3_notrx = a_notrx1_old;

delete from cgltrx2
 where trx2_notrx = a_notrx1_old;

delete from cgltrx1
 where trx1_notrx = a_notrx1_old;

-- Dropear

drop table tmp_cgltrx1;
drop table tmp_cgltrx2;
drop table tmp_cgltrx3;

end
 
--rollback work;
commit work;

return 0, "Actualizacion Exitosa";

end procedure
 
