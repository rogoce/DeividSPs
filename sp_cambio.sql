DROP PROCEDURE sp_cambio;

CREATE PROCEDURE "informix".sp_cambio(
a_numero		CHAR(10)
) RETURNING SMALLINT,
               CHAR(100),
                CHAR(10);

define a_no_remesa			char(10);
DEFINE _error_code      	INTEGER;
DEFINE _renglon      		INTEGER;
define _neto_pagado			dec(16,2);
DEFINE _monto_comis			dec(16,2);
DEFINE _comis_cobro			dec(16,2);
define _monto_cobrado		dec(16,2);


SET DEBUG FILE TO "sp_cob212.trc"; 
TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Pagos Externos', '';
END EXCEPTION

foreach
	Select neto_pagado,
		   monto_comis,
		   comis_cobro,
		   monto_cobrado,
		   renglon
	  into _neto_pagado,
		   _monto_comis,
		   _comis_cobro,
		   _monto_cobrado,
		   _renglon
	  from cobpaex1
	 where numero = a_numero
	
	let _neto_pagado = _neto_pagado	* -1;
	let	_monto_comis = _monto_comis	* -1;
	let	_comis_cobro = _comis_cobro	* -1;
	--let	_monto_cobrado = _monto_cobrado	* -1;

	update cobpaex1 set neto_pagado =_neto_pagado, 
						monto_comis =_monto_comis,
						comis_cobro	=_comis_cobro,
						monto_cobrado = _monto_cobrado
				  where numero = a_numero
				    and renglon = _renglon;
end foreach;
return 0,"Actualizacion exitosa",'';

end
end procedure;