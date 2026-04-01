-- Procedimiento para hacer back up de los registros que bajan de la pocket hacia nuestro sistema y su eliminacion.
--
-- Creado    : 07/11/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob185c;
CREATE PROCEDURE "informix".sp_cob185c(a_turno integer, a_id_usuario integer)
	   RETURNING   integer;

define 	_user_added    char(8);
define 	_id_cliente    char(10);
define 	_nombre_motivo char(50);
define 	_cod_cobrador  char(3);
define _error          integer;
BEGIN

on exception set _error
 	return _error;         
end exception

--SET DEBUG FILE TO "sp_cob185c.trc";
--TRACE ON;
select * 
  from cdmturno
 where id_usuario = a_id_usuario
   and id_turno   = a_turno
  into temp tmpcdm;
  
delete from cdmturnobk
where id_usuario = a_id_usuario
  and id_turno   = a_turno;

insert into cdmturnobk	--turnos
select * 
  from tmpcdm;

drop table tmpcdm;

select * 
  from cdmtransacciones
 where id_usuario = a_id_usuario
   and id_turno   = a_turno
  into temp tmpcdm;

delete from cdmtransaccionesbk
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
   
insert into cdmtransaccionesbk	--transacciones
select * 
  from tmpcdm;

drop table tmpcdm;

select * 
  from cdmtrandetalle
 where id_usuario = a_id_usuario
   and id_turno   = a_turno
  into temp tmpcdm;

 delete from cdmtrandetallebk
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
   
insert into cdmtrandetallebk	--detalle transacciones
select * 
  from tmpcdm;

drop table tmpcdm;

select * 
  from cdmtrancobro
 where id_usuario = a_id_usuario
   and id_turno   = a_turno
  into temp tmpcdm;

delete from cdmtrancobrobk
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
   
insert into cdmtrancobrobk	--tipo de cobro
select * 
  from tmpcdm;

drop table tmpcdm;

delete from cdmtrancobro
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
delete from cdmtrandetalle
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
delete from cdmtransacciones
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
delete from cdmturno
 where id_usuario = a_id_usuario
   and id_turno   = a_turno;
END

return 0;

END PROCEDURE
