-- Procedimiento que Determina el Coaseguro y el Reaseguro por Transaccion
-- 
-- Creado    : 05/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_sis58('')

DROP PROCEDURE sp_sis58;		

CREATE PROCEDURE sp_sis58(a_no_tranrec CHAR(10))
RETURNING INTEGER, CHAR(250);

define _cantidad		integer;

DEFINE _no_reclamo	CHAR(10); 
define _error			integer;
define _error_desc	char(50);

SET ISOLATION TO DIRTY READ;

begin
on exception set _error
	return _error, "Error al Generar el Reaseguro de la Transaccion";
end exception

delete from rectrref where no_tranrec = a_no_tranrec;
delete from rectrrea where no_tranrec = a_no_tranrec;

select no_reclamo
  into _no_reclamo
  from rectrmae
 where no_tranrec = a_no_tranrec;

insert into rectrrea(
no_tranrec,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima,
tipo_contrato,
cod_cober_reas
)
select
a_no_tranrec,
r.orden,
r.cod_contrato,
r.porc_partic_suma,
r.porc_partic_prima,
c.tipo_contrato,
r.cod_cober_reas
 from recreaco r, reacomae c
where r.no_reclamo   = _no_reclamo
  and r.cod_contrato = c.cod_contrato;	 

insert into rectrref(
no_tranrec,
orden,
cod_coasegur,
cod_contrato,
porc_partic_reas,
cod_cober_reas
)
select
a_no_tranrec,
orden,
cod_coasegur,
cod_contrato,
porc_partic_reas,
cod_cober_reas
from recreafa
where no_reclamo = _no_reclamo;	 

-- Verificacion
select count(*)
  into _cantidad
  from rectrrea
 where no_tranrec = a_no_tranrec;

if _cantidad = 0 then

	call sp_sis18(_no_reclamo) returning _error, _error_desc;

end if

-- Campo Subir_BO para el DWH
call sp_sis96(2, _no_reclamo, a_no_tranrec) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

-- Reaseguro de los Reclamos para los Asientos
call sp_rea008(3, a_no_tranrec) returning _error, _error_desc;
if _error <> 0 then
	return _error, _error_desc;
end if
end

return 0, "Actualizacion Exitosa ...";

end procedure