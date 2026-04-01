-- Consulta de Audiencia de un reclamo

-- Creado    : 28/04/2005 - Autor: Amado Perez M.
-- Modificado: 28/04/2005 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE benef;

CREATE PROCEDURE benef(a_no_poliza_v CHAR(10), a_no_poliza_n CHAR(10))
RETURNING varchar(20);


--set debug file to "sp_rwf02.trc";


--SET ISOLATION TO DIRTY READ;
--begin work;

BEGIN

SET LOCK MODE TO WAIT;

select * 
  from emibenef
 where no_poliza = a_no_poliza_v
  into temp prueba;

update prueba
   set no_poliza = a_no_poliza_n
 where no_poliza = a_no_poliza_v;

insert into emibenef
select * from prueba
 where no_poliza = a_no_poliza_n;

drop table prueba;

END 

--commit work;
RETURN "Actualizacion Exitosa";
END PROCEDURE;