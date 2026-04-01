-- Retorna los Reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro82bk;

create procedure sp_pro82bk(a_no_documento char(20))
returning integer,dec(16,2),dec(16,2),integer;

define _no_reclamo		char(10);
define _cantidad		integer;
define _inc_total       dec(16,2);
DEFINE _estimado		  DEC(16,2);
DEFINE _deducible		  DEC(16,2);
DEFINE _reserva_inicial	  DEC(16,2);
DEFINE _reserva_actual	  DEC(16,2);
DEFINE _pagos			  DEC(16,2);
DEFINE _salvamento		  DEC(16,2);
DEFINE _recupero		  DEC(16,2);
DEFINE _deducible_pagado  DEC(16,2);
DEFINE _deducible_devuel  DEC(16,2);	
DEFINE _ded 			  DEC(16,2);
DEFINE _incurrido_reclamo DEC(16,2);
DEFINE _incurrido_bruto   DEC(16,2);
DEFINE _incurrido_neto	  DEC(16,2);
DEFINE _saldo			  DEC(16,2);
DEFINE v_porc_reas	      DEC(9,6);
DEFINE v_porc_coas	      DEC(7,4);
define _cant_mov		  integer;

let _inc_total = 0.00;
let _cantidad  = 0;

foreach
 select no_reclamo
   into	_no_reclamo
   from recrcmae
  where	actualizado  = 1
	and no_documento = a_no_documento

 call sp_rec33(_no_reclamo) returning _estimado,
									  _deducible,  
									  _reserva_inicial,  
					  				  _reserva_actual,  
						  			  _pagos,      
									  _recupero,
									  _salvamento, 
									  _deducible_pagado,
									  _deducible_devuel,
									  v_porc_reas,
									  v_porc_coas,
									  _ded,
									  _incurrido_reclamo,
									  _incurrido_bruto,
									  _incurrido_neto;

 let _inc_total = _inc_total + _incurrido_reclamo;
 let _cantidad  = _cantidad  + 1;

end foreach		

call sp_cob115b("001","001",a_no_documento,"*") returning _saldo;

let _cant_mov = 0;

select count(*)
  into _cant_mov
  from eminotas
 where no_documento = a_no_documento
   and procesado = 0;

return _cantidad,_inc_total,_saldo,_cant_mov;
				
end procedure