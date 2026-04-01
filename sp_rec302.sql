-- Verificar que al realizar una transaccion de pago, se haya pagado deducible si lo amerita.

-- Creado    : 18/10/2019 - Autor: Armando Moreno M.

drop PROCEDURE sp_rec302;
CREATE PROCEDURE sp_rec302(a_no_tranrec	char(10))
RETURNING INTEGER,VARCHAR(100);

define _cod_tipotran,_cod_ramo char(3);
define _cod_cpt      char(10);
define _cnt,_perd_total, _perd_total_tr smallint;
define _est_aud      smallint;
define _transaccion  char(10);
define _no_reclamo   char(10);
define _anular_nt    char(10);
define _cod_cobertura char(5);
define _n_cober       char(50);
define _ded_pag,_ded  dec(16,2);
define _no_poliza     char(10);
define _no_unidad     char(5);
define _numrecla      char(18);
define _no_tranrec    char(10);
define _cod_grupo     char(5);
define _permite_perit  smallint;
define _cod_tipopago  char(3);
define _controversia  smallint;
define _cnt_exonera   smallint;
define _cnt_alq_diag  smallint;
define _cnt_colision  smallint;
define _wf_inc_auto   integer;

SET ISOLATION TO DIRTY READ;

if a_no_tranrec = '3052260' then
	set debug file to "sp_rwf39.trc";
	trace on;
end if


let _cnt     = 0;
let _ded_pag = 0;
let _ded     = 0;
let _cod_tipopago = null;
let _cnt_exonera = 0;
let _cnt_alq_diag = 0;
let _cnt_colision = 0;

select no_reclamo,
       cod_tipotran,
	   anular_nt,
	   perd_total,
       cod_tipopago,
	   wf_inc_auto
  into _no_reclamo,
       _cod_tipotran,
	   _anular_nt,
	   _perd_total_tr, -- CASO: 35240 USER: YARIZA RECLAMO 116476 NO ME DEJA REALIZAR EL PAGO DEL SALVAMENTO PORQUE 
       _cod_tipopago,
	   _wf_inc_auto
  from rectrmae       -- ME SOLICITA PAGO DE DEDUCIBLE Y ESTOY PAGANDO UNA PERDIDA CONSTRUCTIVA 08-08-2020 agregue si la transacción tiene chk en perd_total
 where no_tranrec = a_no_tranrec;

{if _no_reclamo = '514345' then
	return 0, "";
end if}
 
let _perd_total = 0;

select perd_total,
	   estatus_audiencia,
	   no_poliza,
	   no_unidad
  into _perd_total,
       _est_aud,
	   _no_poliza,
	   _no_unidad
  from recrcmae
 where no_reclamo = _no_reclamo;
 
select cod_ramo,
       cod_grupo 
  into _cod_ramo,
       _cod_grupo  
  from emipomae
 where no_poliza = _no_poliza;

if _cod_ramo not in ('002','023','020') then	--Solo Automovil
	return 0, "";
end if
if _cod_tipotran not in ('004') then --Solo N/T de pagos
	return 0, "";
end if

--Habilitar Excepción en la generación de Transacciones de Pagos Sin Validar el pago de Deducible – Reclamos Auto - DRN-TBD276 - Amado 24-02-2025
if _est_aud in (1, 7, 11) then --Ganado / FUD Ganado / Ganado Pend. Resolución 
	select count(*)
	  into _cnt_alq_diag
	  from rectrcon
	 where no_tranrec   = a_no_tranrec
	   and cod_concepto in('022','077'); --022- ALQUILER DE AUTO -077- DIAGNOSTICO
	   
	select count(*)
	  into _cnt_colision
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_tranrec
       and a.monto <> 0	
       and (b.nombre like 'COLISI%VUELCO%' 	--00121 - 00119 COLISION O VUELCO
	    or b.nombre like 'COMPRENSIVO%' 	--#15605 Agregar Cobertura en Esquema que excepciona TRX de Pago, Con o sin Deducible Pago -- Amado 12-12-2025
		or b.nombre like 'ROBO%')   		--#15605 Agregar Cobertura en Esquema que excepciona TRX de Pago, Con o sin Deducible Pago -- Amado 12-12-2025
	   and b.cod_ramo in ('002','023','020') ;	   
	
	if _cnt_alq_diag is null then
		let _cnt_alq_diag = 0;
	end if

	if _cnt_colision is null then
		let _cnt_colision = 0;
	end if
	
	if _cnt_alq_diag > 0 and _cnt_colision > 0 then
		return 0, "";
	end if
	
end if

-- SD 12975 - DRN para concepto de pago Auto de Alquiler bajo excepción // DRN12870 - Amado 12-03-2025 
-- Excepcion cuando la pieza es 474- DIAGNOSTICO COMPUTARIZADO

if _wf_inc_auto is not null and _wf_inc_auto <> 0 then
    let _cnt_colision = 0;
	
	select count(*)
	  into _cnt_colision
	  from wf_ordcomp
	 where wf_incidente = _wf_inc_auto
	   and trim(no_parte) = '474';	 
    
	if _cnt_colision is null then
		let _cnt_colision = 0;
	end if
	   
	if _cnt_colision > 0 then
		return 0, "";
	end if
end if

--CASO 3965 habilitar excepción que permite generar pagos a proveedores de auto, que brinden servicio de peritaje, IMPLEMENTADO 11/07/2022 AMM
select count(*)
  into _cnt
  from rectrcon
 where no_tranrec   = a_no_tranrec
   and cod_concepto in('068','040','039');

let _permite_perit = 0;
if _cnt is null then
	let _cnt = 0;
end if
if _cnt > 0 then
	let _permite_perit = 1;
end if 

-- Solicitud 6040 -- Incluir nuevo Concepto de Pago en excepciones para generación y aprobación de TRX de pago referentes a pago a proveedores dentro de los ajustes de reclamos de AUTO.
select count(*)
  into _cnt
  from rectrcon
 where no_tranrec   = a_no_tranrec
   and cod_concepto in('072');

let _controversia = 0;
if _cnt is null then
	let _cnt = 0;
end if
if _cnt > 0 and _cod_tipopago = '001' then
	let _controversia = 1;
end if 

--Se elimina esta condición SD 9172 Amado 31-01-2024
{if _perd_total = 1 OR _est_aud in(1,7) then	-- OR _perd_total_tr = 1 --Se excepciona reclamo marcado como perdida total,o estatus aud. marcado como ganado o fut ganado.
   if _permite_perit = 1 or _controversia = 1 then
		--Debe perimite que se actualice la N/T segun caso 3965
   else
		return 0, "";
   end if	
end if
}
-- Se excluye grupo del estado 17-08-2020 caso 35294
if trim(_cod_grupo) in ('00000','1000') then 
	return 0, "";
end if

--Permitir: Desc. ded, Legal, Honorarios por recuperación de auto, Investigación, Trámites Municipales, Placa,Avaluó, Peritaje mecánico,Peritaje Legal, Custodia, Grúa.
select count(*)
  into _cnt
  from rectrcon
 where no_tranrec   = a_no_tranrec
   and cod_concepto in('006','012','042','021','058','062','043','040','039','011','030','077','078');
   
if _cnt is null then
	let _cnt = 0;
end if
if _cnt > 0 then	--Se excepciona concepto descuenta deducible
	if _permite_perit = 1 then
		--Debe perimite que se actualice la N/T segun caso 3965
	else	
		return 0, "";
	end if
end if

select count(*)
  into _cnt
  from rectrcon c, rectrmae t
 where c.no_tranrec   = t.no_tranrec
   and t.no_reclamo   = _no_reclamo
   and t.actualizado  = 1
   and c.cod_concepto in ('006','008','072','076','077','078')	--devolucion deducible -- CASO 35141 YARIZA 22-07-2020 agregué descuenta deducible por si se hizo en otra transacción
   and (t.anular_nt is null                     --Solicitud 6040 -- Incluir nuevo Concepto de Pago en excepciones para generación y aprobación de TRX de pago referentes a pago a proveedores dentro de los ajustes de reclamos de AUTO. APM
    or t.anular_nt = "");                       -- Se agrega el 076 Exoneración de Deducible SD 9172 - Amado 31-01-2024
                                                -- Se agrega el 077 DIAGNOSTICO SD 9725 - Amado 13-03-2024
												-- Se agrega el 078 - REEMBOLSO DE GRÚA - Amado 09-07-2024
if _cnt is null then
	let _cnt = 0;
end if
if _cnt > 0 then	--Se excepciona concepto devolucion deducible, siempre y cuando la transaccion no este anulada.
	if _permite_perit = 1 or _controversia = 1 then
		--Debe perimite que se actualice la N/T segun caso 3965
	else
		return 0, "";
	end if
end if	
		 
if _anular_nt is not null and trim(_anular_nt) <> "" then	--No N/T anuladas
	return 0, "";
end if



let _cod_cobertura = null;
let _n_cober       = '';

foreach
	select cod_cobertura
	  into _cod_cobertura
	  from rectrcob
	 where no_tranrec = a_no_tranrec
       and monto > 0
	   
	let _ded     = 0;
	let _ded_pag = 0;
	
	select deducible
	  into _ded
	  from emipocob
	 where no_poliza     = _no_poliza
       and no_unidad     = _no_unidad
       and cod_cobertura = _cod_cobertura;
	   
	if _ded <> 0 AND _cod_cobertura not in('00113','00671','01651','01304','01022') then	--Se excluye coberturas de DPA segun correo Roman 24/10/19
	
		select sum(deducible_pagado)
		  into _ded_pag
		  from recrccob
		 where no_reclamo    = _no_reclamo;
	   
		if _ded_pag <> 0 then
			exit foreach;
		else
			if _permite_perit = 1 or _controversia = 1 then
			--Debe perimite que se actualice la N/T segun caso 3965
			else
				select nombre into _n_cober from prdcober where cod_cobertura = _cod_cobertura;
				return 1,"No se ha pagado el deducible de este Reclamo, verifique."; 
			end if
		end if
	end if
end foreach

return 0,"";
END PROCEDURE
