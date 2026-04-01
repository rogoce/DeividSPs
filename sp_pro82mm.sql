-- Retorna los Reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro82mm;
create procedure sp_pro82mm(a_no_documento char(20))
returning integer;

define _no_reclamo		  char(10);
define _cantidad		  integer;
define _inc_total         dec(16,2);
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
define _cant_mov,_cant	  integer;

let _inc_total = 0.00;
let _cantidad  = 0;

set isolation to dirty read;

let _cant_mov = 0;

select count(*)
  into _cant_mov
  from eminotas
 where no_documento = a_no_documento
   and procesado = 0;

return _cant_mov;
				
end procedure