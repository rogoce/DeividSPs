-- Procedimiento que actualiza los totales de la tabla cobpaex0 cuando se trata de un pago externo de un solo archivo
-- para el procesdo de Pagos Externos 	

-- Creado    : 06/12/2010 - Autor: Roman Gordon

DROP PROCEDURE sp_cob256;

CREATE PROCEDURE "informix".sp_cob256(a_numero char(10))
RETURNING smallint;

Define _monto_cobrado		dec(16,2);
Define _neto_pagado			dec(16,2);
Define _monto_comis			dec(16,2);
Define _comis_desc			dec(16,2);
Define _comis_cobro			dec(16,2);
Define _comis_visa			dec(16,2);
Define _comis_clave			dec(16,2);
Define _monto_bruto			dec(16,2);
Define _tot_monto_cobrado	dec(16,2);
Define _tot_neto_pagado		dec(16,2);
Define _tot_monto_comis		dec(16,2);
Define _tot_comis_desc		dec(16,2);
Define _tot_comis_cobro		dec(16,2);
Define _tot_comis_visa		dec(16,2);
Define _tot_comis_clave		dec(16,2);
Define _tot_monto_bruto		dec(16,2);
define _periodo_desde		date;
define _periodo_hasta		date;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob256.trc";
--trace on;

Let _monto_cobrado		= 0.00;
Let _neto_pagado		= 0.00;
Let _monto_comis		= 0.00;
Let _comis_desc			= 0.00;
Let _comis_cobro		= 0.00;
Let _comis_visa			= 0.00;
Let _comis_clave		= 0.00;
Let _monto_bruto		= 0.00;
Let _tot_monto_cobrado	= 0.00;
Let _tot_neto_pagado	= 0.00;
Let _tot_monto_comis	= 0.00;
Let _tot_comis_desc		= 0.00;
Let _tot_comis_cobro	= 0.00;
Let _tot_comis_visa		= 0.00;
Let _tot_comis_clave	= 0.00;
Let _tot_monto_bruto	= 0.00;
Let _periodo_desde		= '01/01/1900';
Let _periodo_hasta		= '01/01/1900';



foreach
	Select monto_cobrado, 
		   neto_pagado,	
		   monto_comis,	
		   comis_desc,		
		   comis_cobro,	
		   comis_visa,		
		   comis_clave,	
	 	   monto_bruto,
		   periodo_desde,
		   periodo_hasta
	  into _monto_cobrado,
	  	   _neto_pagado,	
	  	   _monto_comis,	
	  	   _comis_desc,		
	  	   _comis_cobro,	
	  	   _comis_visa,		
		   _comis_clave,	
		   _monto_bruto,
		   _periodo_desde,
		   _periodo_hasta
	  from cobpaex1
	  where numero = a_numero

	Let _tot_monto_cobrado	= _tot_monto_cobrado + _monto_cobrado; 
	Let _tot_neto_pagado	= _tot_neto_pagado	 + _neto_pagado;	
	Let _tot_monto_comis	= _tot_monto_comis	 + _monto_comis;	
	Let _tot_comis_desc		= _tot_comis_desc	 + _comis_desc;		
	Let _tot_comis_cobro	= _tot_comis_cobro	 + _comis_cobro;	
	Let _tot_comis_visa		= _tot_comis_visa	 + _comis_visa;		
	Let _tot_comis_clave	= _tot_comis_clave	 + _comis_clave;	
	Let _tot_monto_bruto	= _tot_monto_bruto	 + _monto_bruto;

	Let _monto_cobrado	= 0.00;
	Let _neto_pagado	= 0.00;
	Let _monto_comis	= 0.00;
	Let _comis_desc		= 0.00;
	Let _comis_cobro	= 0.00;
	Let _comis_visa		= 0.00;
	Let _comis_clave	= 0.00;
	Let _monto_bruto	= 0.00;

end foreach

if _periodo_desde is null then
	let _periodo_desde = '01/01/1900';
end if
if _periodo_hasta is null then
	let _periodo_hasta = '01/01/1900';
end if

update cobpaex0 
   set monto_total			= _tot_monto_cobrado, 
	   monto_comis			= _tot_monto_comis,
	   monto_comis_cobro	= _tot_comis_cobro,
	   monto_comis_visa		= _tot_comis_visa,
	   monto_comis_clave	= _tot_comis_clave,
	   monto_bruto			= _tot_monto_bruto,
	   periodo_desde		= _periodo_desde,
	   periodo_hasta		= _periodo_hasta
 where numero = a_numero;
Return 0;

END PROCEDURE;
