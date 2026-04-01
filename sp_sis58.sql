-- Procedimiento que Determina el Coaseguro y el Reaseguro por Transaccion
-- 
-- Creado    : 05/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_sis58('')

DROP PROCEDURE sp_sis58;		
CREATE PROCEDURE sp_sis58(a_no_tranrec CHAR(10))
RETURNING INTEGER, CHAR(250);

DEFINE _no_reclamo,_no_poliza	  	CHAR(10); 
define _error,_cantidad	integer;
define _cod_tipotran,_cod_ramo  	char(3);
define _error_desc	  	char(50);
define _valor           smallint;

SET ISOLATION TO DIRTY READ;

begin
on exception set _error
	return _error, "Error al Generar el Reaseguro de la Transaccion";
end exception

delete from rectrref where no_tranrec = a_no_tranrec;
delete from rectrrea where no_tranrec = a_no_tranrec;

select no_reclamo,
       cod_tipotran
  into _no_reclamo,
       _cod_tipotran
  from rectrmae
 where no_tranrec = a_no_tranrec;
 
 select no_poliza
   into _no_poliza
   from recrcmae
  where no_reclamo = _no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

if _cod_tipotran = '012' and _cod_ramo in('002','020','023') then --Si es re-abrir reclamo y ramo auto, se debe crear los contratos actuales 5/95, AMM 08/10/24 2.57 pm
	let _valor = sp_arregla_recreaco_ind(_no_reclamo);
end if

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