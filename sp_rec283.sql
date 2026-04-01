-- Procedimiento que Busca el banco y chequera dado el ramo de excepcion

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec283;

CREATE PROCEDURE "informix".sp_rec283(a_no_reclamo char(10))
returning dec(16,2);

define _deducible		dec(16,2);
define _deducible2		dec(16,2);

SET ISOLATION TO DIRTY READ;

let _deducible = 0;
let _deducible2 = 0;

SELECT sum(monto)
  INTO _deducible
  FROM rectrmae
 WHERE no_reclamo = a_no_reclamo
   AND cod_tipotran = '007';
 
 SELECT sum(a.monto)
   INTO _deducible2
   FROM rectrcon a, rectrmae b
  WHERE a.no_tranrec = b.no_tranrec
    AND b.no_reclamo = a_no_reclamo
	AND a.cod_concepto in ('006','004','005');
	
if _deducible is null then
	let _deducible = 0;	
end if
	
if _deducible2 is null then
	let _deducible2 = 0;	
end if

let _deducible = _deducible + _deducible2;
 
Return _deducible;

END PROCEDURE
