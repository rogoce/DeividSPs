-- Procedimiento que retorna el nombre del mes
--
-- Creado    : 29/09/2004 - Autor: Demetrio Hurtado A.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis380;

CREATE PROCEDURE "informix".sp_sis380(a_requis char(10))

define _no_requis char(10);

foreach
	select no_requis
	  into _no_requis
	  from chqchmae
	 where no_requis = a_requis

	delete from chqchdes
	where no_requis = _no_requis;

	delete from chqchmae
	where no_requis = _no_requis;
end foreach	

{select * 
  from emipocob
 where no_poliza = "244387"
  into temp prueba;

update prueba
   set no_poliza = "293882"
 where no_poliza = "244387";

insert into emipocob
select * from prueba
 where no_poliza = "293882";

INSERT INTO endedcob(
no_poliza,
no_endoso,
no_unidad,
cod_cobertura,
orden,
tarifa,
deducible,
limite_1,
limite_2,
prima_anual,
prima,
descuento,
recargo,
prima_neta,
date_added,
date_changed,
desc_limite1,
desc_limite2,
factor_vigencia,
opcion
)
SELECT
no_poliza,
'00000',
no_unidad,
cod_cobertura,
orden,
tarifa,
deducible,
limite_1,
limite_2,
prima_anual,
prima,
descuento,
recargo,
prima_neta,
date_added,
date_changed,
desc_limite1,
desc_limite2,
factor_vigencia,
0
FROM emipocob
WHERE no_poliza = 293882;}

END PROCEDURE