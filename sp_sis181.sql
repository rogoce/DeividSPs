-- 

-- Creado    : 08/04/2013 - Autor: Armando Moreno.

DROP PROCEDURE sp_sis181;

CREATE PROCEDURE "informix".sp_sis181()
returning char(12), integer;

define ls_cuenta	 	 char(12);
define _linea2           integer;
define _db,_cr,ld_debito,ld_credito  dec(16,2);
define _tipo             char(2);
define ls_s_aux          char(1);


--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_sis180.trc";
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

foreach

	SELECT trx2_cuenta,trx2_linea,trx2_debito,trx2_credito,trx2_tipo
	  INTO ls_cuenta,_linea2,_db,_cr,_tipo
	  FROM cgltrx2
	 WHERE trx2_notrx = '343552'
  --	   and trx2_cuenta = '600023505'

	SELECT distinct trim(cglcuentas.cta_auxiliar) 
	  INTO ls_s_aux 
	  FROM cglcuentas 
	 WHERE cglcuentas.cta_cuenta = ls_cuenta;
	 
	 if ls_s_aux = 'S' then
	 else
		continue foreach;
	 end if
	  
 --{ 
 select sum(trx3_debito) 
	into ld_debito 
	From cgltrx3
	where trx3_cuenta = ls_cuenta
	  and trx3_notrx = '343552'
	  and trx3_tipo = _tipo
	  and trx3_lineatrx2 = _linea2;


  if ld_debito - _db <> 0 then
		return ls_cuenta,_linea2 with resume;
  end if
  --}	 

  select sum(trx3_credito) 
	into ld_credito
	From cgltrx3
	where trx3_cuenta = ls_cuenta
	  and trx3_notrx = '343552'
	  and trx3_tipo = _tipo
	  and trx3_lineatrx2 = _linea2;


if ld_credito - _cr <> 0 then
	return ls_cuenta,_linea2 with resume;
end if	 


end foreach


END
END PROCEDURE
