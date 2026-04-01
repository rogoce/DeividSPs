-- Busqueda del numero de endoso maximo de una poliza
-- cuando se adiciona un endoso

-- Creado    : 08/06/2006 - Autor: Amado Perez M.
-- Modificado: 08/06/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_sis189;

CREATE PROCEDURE sp_sis189(a_no_poliza_v CHAR(10))
RETURNING int;

DEFINE v_unidad int;

create temp table tmp_endosos(
   no_poliza         CHAR(10),
   no_unidad	     int
   ) with no log;

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;
--begin work;

let v_unidad = 0;

insert into tmp_endosos(
no_poliza,
no_unidad
)
select 
no_poliza,
no_unidad
from emipouni
 where no_poliza = a_no_poliza_v;

Select max(no_unidad)
  Into v_unidad
  from tmp_endosos;

drop table tmp_endosos;

if v_unidad is null then
	let v_unidad = 0;
end if

--commit work;
RETURN v_unidad;

END PROCEDURE;