-- Procedure que Verifica si la Póliza debe ir a mora o no
-- Creado    : 16/05/2013 - Autor: Roman Gordón
-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_rec203;

create procedure sp_rec203(a_no_documento char(20), a_cod_asignacion char(10))

returning	smallint,
			varchar(255),
			date,
			dec(16,2);

define _error_desc		varchar(255);
define _no_poliza		char(10);
define _periodo			char(7);
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _moro_tot		dec(16,2);
define _monto30			dec(16,2);
define _monto60			dec(16,2);
define _monto90			dec(16,2);
define _saldo			dec(16,2);
define _corr			dec(16,2);
define _preautorizado	smallint;
define _es_colectivo	smallint;
define _cnt_unidades	smallint;
define _carta_aviso		smallint;
define _en_mora			smallint;
define _mora			smallint;
define _error			integer;
define _error_isam		integer;
define _fecha_aviso		date;
define _fecha_hoy		date;
define _cod_ramo        char(3);

--set debug file to "sp_rec203.trc";

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc		
 	return _error, "Error al verificar la Mora del Reclamo. Error: " || trim(_error_desc),current,0.00;
end exception

let _es_colectivo = 0;

if a_no_documento = '1800-00035-01' then
	return 0,'La Póliza de Aseguradora Ancón no es tomada en cuenta',current,0.00; 
end if

let _fecha_hoy	= current;
let _periodo	= sp_sis39(_fecha_hoy);
let _mora		= 0;

call sp_sis21(a_no_documento) returning _no_poliza;

select en_mora,
	   preautorizado
  into _en_mora,
	   _preautorizado
  from atcdocde 
 where cod_asignacion = a_cod_asignacion;

if _preautorizado = 1 then
	return 0,'El Reclamo esta Preautorizado.',current,0.00;
end if
 
select count(*)
  into _cnt_unidades
  from emipouni
 where no_poliza = _no_poliza
   and activo = 1;

if _cnt_unidades > 10 then
	let _es_colectivo = 1;
end if

call sp_cob33c('001','001',a_no_documento,_periodo,_fecha_hoy) 
returning _por_vencer,_exigible,_corr,_monto30,_monto60,_monto90,_saldo;

let _moro_tot = _monto60 + _monto90;

if _moro_tot > 0 then
	let _mora = 1;
else 
	if _es_colectivo = 0 and _monto30 > 10 then
		let _mora = 1;
	end if
end if

if _mora = 1 then
	
	select carta_aviso_canc,
		   fecha_aviso_canc,
		   cod_ramo
	  into _carta_aviso,
		   _fecha_aviso ,
		   _cod_ramo
	  from emipomae 
	 where no_poliza = _no_poliza;
	 
	if _cod_ramo = '019' then --Poliazs de Vida individual, No deben enviar correo a cobros, segun correo de Enilda 201/04/2016
		let _en_mora = 1;
	elif _exigible = 0 then  --Poliazs de salud, No deben enviar correo a cobros si el exigible es cero, segun correo de Enilda 201/04/2016
		let _en_mora = 1;
	end if
	update atcdocde
	   set en_mora = 1,
		   mora    = 1
	 where cod_asignacion = a_cod_asignacion;
	
	if _en_mora = 0 then
		return 1,'Esta en Mora y se debe enviar el correo de aviso de mora',_fecha_aviso,_saldo;
	else
		return 0,'Esta en Mora pero no se debe enviar el correo de aviso de mora',_fecha_aviso,_saldo;
	end if
end if

return 0,'No es necesario enviar correo de aviso de Mora',current,0.00;
end 
end procedure