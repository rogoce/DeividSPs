-- 

-- Creado    : 15/04/2013 - Autor: Armando Moreno.

--DROP PROCEDURE sp_sis182;

CREATE PROCEDURE "informix".sp_sis182(a_notrx integer)
returning integer,char(12), dec(16,2),dec(16,2);

define ls_cuenta	 	 char(12);
define _linea2           integer;
define _valortrx2,_valortrx3  dec(16,2);



--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_sis180.trc";
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

foreach

	SELECT c.trx2_cuenta,
	       sum(c.trx2_debito - c.trx2_credito)
	  INTO ls_cuenta,
	       _valortrx2
	  FROM cgltrx2 c, cglcuentas t
	 WHERE c.trx2_cuenta = t.cta_cuenta
	   and c.trx2_notrx  = a_notrx
       and t.cta_auxiliar = 'S'
  group by c.trx2_cuenta
  order by 1

	select sum(trx3_debito - trx3_credito)
	  into _valortrx3
	  from cgltrx3
	 where trx3_notrx  = a_notrx
	   and trx3_cuenta = ls_cuenta;


  if _valortrx2 = _valortrx3 then
  else
 	return 1,ls_cuenta, _valortrx2, _valortrx3 with resume;
  end if

end foreach

return 0,"",0,0;

END
END PROCEDURE
