-- Retorna los Reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis428;
create procedure sp_sis428(a_no_documento char(20))
returning dec(16,2),integer,decimal(16,2),integer;

define _no_reclamo		  char(10);
define _no_poliza		  char(10);
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
define _nro_sini_ult	  integer;
define _fecha_hoy         date;
define _fecha_suscripcion date;
define _nro_anos          integer;
define _nro_sini_all      integer;
define _sini_prom_hist    dec(16,2);
define _vigencia_inic     date;
define _vigencia_final    date;
define _prima_suscrita    dec(16,2);
define _dias,_dias1,_cant integer;
define _factor            dec(16,2);
define _ps_dev            dec(16,2);
define _sini_hist         integer;
define _porc_desc		  dec(16,2);


let _inc_total = 0.00;
let _fecha_hoy = current;
let _nro_anos  = 0;
let _ps_dev    = 0;
let _porc_desc = 0.00;

set isolation to dirty read;

Let _no_poliza = sp_sis21(a_no_documento);

--No. siniestros ultima vigencia
 select count(*)
   into	_nro_sini_ult
   from recrcmae
  where	actualizado  = 1
	and no_poliza    = _no_poliza;

--No. siniestros	total de la poliza
 select count(*)
   into	_nro_sini_all							
   from recrcmae
  where	actualizado  = 1
	and no_documento = a_no_documento;
	
select fecha_suscripcion
  into _fecha_suscripcion
  from emipomae
 where no_documento = a_no_documento
   and actualizado = 1
   and nueva_renov = 'N';

   --No. años de la poliza
   let _nro_anos = (_fecha_hoy - _fecha_suscripcion) / 365;

   --No. siniestros promedio historico
   let _sini_prom_hist = _nro_sini_all / _nro_anos;

select min(vigencia_inic)
  into _vigencia_inic
  from emipomae
 where actualizado = 1
   and no_documento = a_no_documento
   and nueva_renov  = 'N';
 
select vigencia_final
  into _vigencia_final
  from emipomae
 where no_poliza = _no_poliza;
   
select sum(prima_suscrita)   
  into _prima_suscrita
  from endedmae
 where actualizado = 1
   and no_documento   = a_no_documento;

--Prima Suscrita Devengada
let _dias   = _fecha_hoy - _vigencia_inic;
let _dias1  = _vigencia_final - _vigencia_inic;
let _factor = _dias / _dias1;
let _ps_dev = _factor * _prima_suscrita;

--Siniestralidad Historica
foreach
 select no_reclamo
   into	_no_reclamo							
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
 
end foreach

let _sini_hist = (_inc_total / _ps_dev) * 100;

if _nro_sini_ult = 0 and _sini_prom_hist = 0 and _sini_hist = 0 then			--1
	let _porc_desc = 5;
elif _nro_sini_ult = 0 and _sini_prom_hist <= 0.05 and _sini_hist <= 55 then	--2
	let _porc_desc = 4;
elif _nro_sini_ult = 0 and _sini_prom_hist <= 0.05 and _sini_hist > 55 then	--3
	let _porc_desc = 0;
elif _nro_sini_ult = 0 and _sini_prom_hist > 0.5 and _sini_hist <= 55 then		--4
	let _porc_desc = 2;
elif _nro_sini_ult = 0 and _sini_prom_hist > 0.5 and _sini_hist > 55 then		--5
	let _porc_desc = 0;
elif _nro_sini_ult >= 1 and _sini_prom_hist > 0.5 and _sini_hist <= 55 then	--6
	let _porc_desc = 0;
elif _nro_sini_ult >= 1 and _sini_prom_hist > 0.5 and _sini_hist > 55 then		--7
	let _porc_desc = 50;
end if

return _porc_desc,_nro_sini_ult,_sini_prom_hist,_sini_hist;
				
end procedure