-- Retorna los Reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro82m2;

create procedure sp_pro82m2(a_no_documento char(20))
returning integer,dec(16,2),dec(16,2),integer,smallint,dec(16,2),dec(16,2),varchar(50);

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

define _no_sinis_ult		smallint;
define _no_sinis_his		smallint;
define _no_vigencias		smallint;
define _no_sinis_pro		dec(16,2);

define _prima_devengada		dec(16,2);
define _siniestralidad		dec(16,2);
define _descuento_sini		dec(16,2);
define _cod_subramo         CHAR(3);
define _condicion           smallint;
define _retorno             smallint;
define _desc_desc           varchar(50);
define _estatus_audiencia   smallint;

let _inc_total = 0.00;
let _cantidad  = 0;

set isolation to dirty read;

--if a_no_documento = '0219-03929-09' then
--	set debug file to "sp_pro82m.trc"; 
--	trace on;
--end if

{foreach
 select no_reclamo --,estatus_audiencia 
   into	_no_reclamo --, _estatus_audiencia 
   from recrcmae
  where	actualizado  = 1
	and no_documento = a_no_documento

 select count(*)
   into _cant
   from recrccob
  where no_reclamo = _no_reclamo;

 if _cant = 0 then
	continue foreach;
 end if

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
 
 --if _incurrido_reclamo > 0 and _estatus_audiencia = 2 then
  if _incurrido_reclamo > 0 then
     let _cantidad  = _cantidad  + 1;  -- Se tomará del sp_pro550 -- Amado 12-06-2025
end if

end foreach		
}
call sp_cob115b("001","001",a_no_documento,"*") returning _saldo;

let _cant_mov = 0;

select count(*)
  into _cant_mov
  from eminotas
 where no_documento = a_no_documento
   and procesado = 0;

call sp_sis470b(a_no_documento) returning a_no_documento, _no_sinis_ult, _cantidad, _no_vigencias, _no_sinis_pro, _inc_total, _prima_devengada, _siniestralidad, _descuento_sini, _condicion;
--call sp_pro550(a_no_documento) returning a_no_documento, _no_sinis_ult, _cantidad, _no_vigencias, _no_sinis_pro, _inc_total, _prima_devengada, _siniestralidad, _descuento_sini, _condicion;

let _desc_desc = "";

If _condicion = 0 then
	if _descuento_sini = 0.00 then
		let _desc_desc = 'Sin descuento';
	else
		let _desc_desc = 'Descuento: % ' || _descuento_sini;
	end if
else
	let _desc_desc = 'Recargo sobre Descuento Comb.: % ' || _descuento_sini;
end if

IF _cantidad IS NULL THEN
   LET _cantidad = 0;
END IF
    
return _cantidad,_inc_total,_saldo,_cant_mov, _no_sinis_ult, _no_sinis_pro, _siniestralidad, _desc_desc;
				
end procedure