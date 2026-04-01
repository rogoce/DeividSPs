-- Procedure que verifica que cuadre cglresumen vs cglsaldodet

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac110;

create procedure sp_sac110() 
returning integer,
            char(50);

define _notrx		integer;
define _comprobante	char(8);
define _ccosto		char(3);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _diferencia	dec(16,2);
define _cantidad	smallint;

define _error		integer;
define _error_desc	char(50);

foreach
 select res_notrx, 
 		res_comprobante, 
 		res_ccosto, 
 		sum(res_debito), 
 		sum(res_credito), 
 		sum(res_debito - res_credito), 
 		count(*)
   into _notrx, 
        _comprobante,
		_ccosto,
		_debito,
		_credito,
		_diferencia,
		_cantidad
   from cglresumen
  where year(res_fechatrx) = 2009
    and res_origen         = "PRO"
    and res_ccosto         = "017"
  group by 1, 2, 3
 having sum(res_debito - res_credito) <> 0
  order by 1, 2, 3

	call sp_sac109(_notrx) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if

--	exit foreach;

end foreach

return 0, "Actualizacion Exitosa";

end procedure