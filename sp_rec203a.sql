-- Procedure que Verifica si la Póliza debe ir a mora o no
-- Creado    : 16/05/2013 - Autor: Roman Gordón
-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_rec203a;

create procedure sp_rec203a()

returning	smallint,
			varchar(255),
			date,
			dec(16,2);

define _error_desc		varchar(255);
define _no_documento	char(21);
define _cod_asignacion	char(10);
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
define _es_colectivo	smallint;
define _cnt_unidades	smallint;
define _carta_aviso		smallint;
define _en_mora			smallint;
define _mora			smallint;
define _error			integer;
define _error_isam		integer;
define _fecha_aviso		date;
define _fecha_hoy		date;

--set debug file to "sp_rec203.trc";

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc		
 	return _error, "Error al verificar la Mora del Reclamo. Error: " || trim(_error_desc),current,0.00;
end exception

foreach
	select cod_asignacion,
		   no_documento
	  into _cod_asignacion,
		   _no_documento
	  from atcdocde
	 where en_mora = 1

	let _es_colectivo = 0;

	if _no_documento = '1800-00035-01' then
		return 0,'La Póliza de Aseguradora Ancón no es tomada en cuenta',current,0.00; 
	end if

	let _fecha_hoy	= current;
	let _periodo	= sp_sis39(_fecha_hoy);
	let _mora		= 0;

	call sp_sis21(_no_documento) returning _no_poliza;

	select count(*)
	  into _cnt_unidades
	  from emipouni
	 where no_poliza = _no_poliza
	   and activo = 1;

	if _cnt_unidades > 10 then
		let _es_colectivo = 1;
	end if

	call sp_cob33c('001','001',_no_documento,_periodo,_fecha_hoy) 
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
			   fecha_aviso_canc
		  into _carta_aviso,
			   _fecha_aviso 
		  from emipomae 
		 where no_poliza = _no_poliza;
		 
		select en_mora
		  into _en_mora 
		  from atcdocde 
		 where cod_asignacion = _cod_asignacion;
		 
		{update atcdocde
		   set en_mora = 1,
			   mora    = 1
		 where cod_asignacion = _cod_asignacion ;}
		
		if _en_mora = 0 then
			return 1,'Esta en Mora y se debe enviar el correo de aviso de mora',_fecha_aviso,_saldo with resume;
		else
			return 0,'Esta en Mora pero no se debe enviar el correo de aviso de mora',_fecha_aviso,_saldo with resume;
		end if
	else
		update atcdocde
		   set en_mora         = 0,
			   user_mora       = 'KCESAR',
			   fec_libero_mora = _fecha_hoy,
			   obs_mora        = 'Se Libero Proceso Automático'
		 where cod_asignacion  = _cod_asignacion;
		return 0,'Se debe quitar la mora. Póliza: ' || trim(_no_documento),_fecha_aviso,_saldo with resume;
	end if
end foreach

return 0,'No es necesario enviar correo de aviso de Mora',current,0.00;
end 
end procedure