-- Procedure que determina si hay saldos de las polizas de reaseguro

drop procedure sp_rea061;

create procedure "informix".sp_rea061()
returning char(20),
          dec(16,2);

define _no_documento	char(20);
define v_saldo_b		dec(16,2);
define v_saldo			dec(16,2);

foreach
 select no_documento
   into _no_documento
   from rea_saldo
  where periodo = "2014-12" 
 group by 1
 order by 1
 
	call sp_cob223(	"001",	"001",	_no_documento, "2010-12", "31/12/2010") returning	v_saldo, v_saldo_b;

	if v_saldo_b <> 0 then

		return _no_documento,
		       v_saldo_b
		  with resume;
		  
	end if
   
 end foreach
 
return "0", 0;
 
end procedure