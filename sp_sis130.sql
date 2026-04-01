-- Busqueda del numero de unidad maximo de una poliza
-- cuando se adiciona un endoso

-- Creado    : 08/06/2006 - Autor: Amado Perez M.
-- Modificado: 08/06/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_sis130;

CREATE PROCEDURE sp_sis130(a_no_poliza_v CHAR(10))
RETURNING CHAR(5);

DEFINE v_unidad CHAR(5);

create temp table tmp_uni(
   no_poliza         CHAR(10),
   no_unidad	     int
   ) with no log;

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;
--begin work;

insert into tmp_uni(
no_poliza,
no_unidad
)
select 
no_poliza,
no_unidad
from endeduni
 where no_poliza = a_no_poliza_v;

Select max(no_unidad)
  Into v_unidad
  from tmp_uni;

drop table tmp_uni;


--commit work;
RETURN v_unidad;

END PROCEDURE;