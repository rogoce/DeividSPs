-- Procedimiento para crear la carta del suntracs -- 
-- Creado    : 10/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro1001e;
CREATE PROCEDURE sp_pro1001e(a_poliza CHAR(10)) 
RETURNING   CHAR(10),
			decimal(16,2);

define _suma_asegurada   decimal(16,2);
define _no_unidad        char(5);

SET ISOLATION TO DIRTY READ;

let _no_unidad = "";

select min(no_unidad)
  into _no_unidad
  from emipouni
 where no_poliza = a_poliza;

select sum(limite_1)
  into _suma_asegurada
  from emipocob
 where no_poliza = a_poliza
   and no_unidad = _no_unidad
   and cod_cobertura = '01563';
   
if _suma_asegurada is null then
	let _suma_asegurada = 0;
end if   
 
RETURN a_poliza, _suma_asegurada;

END PROCEDURE			   