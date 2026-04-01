-- Busqueda del numero de endoso maximo de una poliza
-- cuando se adiciona un endoso

-- Creado    : 08/06/2006 - Autor: Amado Perez M.
-- Modificado: 08/06/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_sis90;

CREATE PROCEDURE sp_sis90(a_no_poliza_v CHAR(10))
RETURNING CHAR(5);

DEFINE v_endoso CHAR(5);

create temp table tmp_endosos(
   no_poliza         CHAR(10),
   no_endoso	     int
   ) with no log;

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;
--begin work;

insert into tmp_endosos(
no_poliza,
no_endoso
)
select 
no_poliza,
no_endoso
from endedmae
 where no_poliza = a_no_poliza_v;

Select max(no_endoso)
  Into v_endoso
  from tmp_endosos;

drop table tmp_endosos;


--commit work;
RETURN v_endoso;

END PROCEDURE;