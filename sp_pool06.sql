-- Deterioro de Cartera NIIF
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_pool06;
create procedure "informix".sp_pool06()
returning char(10),char(20),dec(16,2),smallint,dec(16,2),dec(16,2);

define _no_poliza     char(10);
define _cnt			  smallint;
define _no_documento  char(20);
define _prima_b       dec(16,2);
define _no_pagos      smallint;
DEFINE v_por_vencer   DEC(16,2);
DEFINE v_exigible     DEC(16,2);
DEFINE v_corriente    DEC(16,2);
DEFINE v_monto_30     DEC(16,2);
DEFINE v_monto_60     DEC(16,2);
define v_monto_90     DEC(16,2);
define _saldo         DEC(16,2);

begin

set isolation to dirty read;


let _prima_b = 0;

foreach
select e.no_poliza,e.no_documento
  into _no_poliza,_no_documento
  from emirepo e, emideren d
 where e.no_poliza = d.no_poliza
   and year(e.vigencia_final)  = 2013
   and month(e.vigencia_final) = 5
   and e.estatus not in(5,9)
   and d.renglon = 11
   and d.activo = 0
   order by e.no_documento

 select count(*)
   into _cnt
   from emideren
  where no_poliza = _no_poliza;

  if _cnt = 1 then

	 select prima_bruta,no_pagos
	   into _prima_b,_no_pagos
	   from emipomae
	  where no_poliza = _no_poliza;

	if _no_pagos = 12 then
		call sp_cob33('001','001', _no_documento, '2013-05', '30/05/2013')
	     returning v_por_vencer,    
	               v_exigible,      
	               v_corriente,    
	               v_monto_30,      
	               v_monto_60,      
	               v_monto_90,
	               _saldo;   


		return _no_poliza,
		       _no_documento,
			   _prima_b,
			   _no_pagos,
			   v_monto_90,
			   _saldo
			    with resume;
	end if

  end if

end foreach

end
end procedure