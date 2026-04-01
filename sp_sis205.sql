-- Parametro que indica la cantidad minima de unidades que se perimiten en un ramo
-- 
-- Creado      :27/03/2015 - Autor: Armando Moreno M.

--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis205;

CREATE PROCEDURE "informix".sp_sis205(a_no_poliza CHAR(10))
RETURNING smallint;

DEFINE _cant_uni_min smallint;
DEFINE _cod_ramo     char(3);


SET ISOLATION TO DIRTY READ;

SELECT cod_ramo
  INTO _cod_ramo
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

select cant_uni_min
  into _cant_uni_min
  from prdramo
 where cod_ramo = _cod_ramo;
 
if _cant_uni_min is null then
	let _cant_uni_min = 0;
end if
		
RETURN _cant_uni_min;

END PROCEDURE; 