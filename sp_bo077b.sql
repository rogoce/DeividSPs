-- Procedimiento que genera la informacion de las polizas nuevas y renovadas
-- en un rango de fechas 
-- Creado    : 23/02/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_bo077b;
create procedure sp_bo077b(a_no_documento char(20))
returning integer;

define _cnt_cam				smallint;

set isolation to dirty read;


select count(*)
  into _cnt_cam
  from endedmae
 where actualizado = 1
   and no_documento = a_no_documento
   and cod_tipocan = '018';  --cambio de plan

if _cnt_cam is null then
	let _cnt_cam = 0;
end if

return _cnt_cam;

end procedure