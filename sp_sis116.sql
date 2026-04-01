-- Buscar el status de la aprobacion de la poliza( control firmas emision)

-- Creado    : 09/06/2010 - Autor: Amado Perez M. 

drop procedure sp_sis116;

create procedure "informix".sp_sis116(a_poliza char(10), a_endoso char(5))
returning varchar(15), varchar(20),datetime year to fraction(5),datetime year to fraction(5);

define _status 			varchar(15);
define _wf_aprob 		smallint;
define _wf_firma_aprob  varchar(20);
define _wf_fecha_entro  datetime year to fraction(5);
define _wf_fecha_aprob  datetime year to fraction(5);

SET ISOLATION TO DIRTY READ;

let _status = "";
let _wf_fecha_entro = null;
let	_wf_fecha_aprob	= null;

if a_endoso = "00000" then

	select wf_aprob,
		   wf_firma_aprob,
		   wf_fecha_entro,
		   wf_fecha_aprob
	  into _wf_aprob,
	       _wf_firma_aprob,
		   _wf_fecha_entro,
		   _wf_fecha_aprob
	  from emipomae
	 where no_poliza = a_poliza;

	if _wf_aprob = 1 then
		let _status = "EN APROBACION";
	elif _wf_aprob = 2 then
		let _status = "APROBADO";
	elif _wf_aprob = 3 then
		let _status = "RECHAZADO";
	else
		let _status = "";
	end if

	return _status,_wf_firma_aprob,_wf_fecha_entro,_wf_fecha_aprob;

else

	select wf_aprob,
		   wf_firma_aprob,
		   wf_fecha_entro,
		   wf_fecha_aprob
	  into _wf_aprob,
	       _wf_firma_aprob,
		   _wf_fecha_entro,
		   _wf_fecha_aprob
	  from endedmae
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso;

	if _wf_aprob = 1 then
		let _status = "EN APROBACION";
	elif _wf_aprob = 2 then
		let _status = "APROBADO";
	elif _wf_aprob = 3 then
		let _status = "RECHAZADO";
	else
		let _status = "";
	end if

	return _status,_wf_firma_aprob,_wf_fecha_entro,_wf_fecha_aprob;

end if

end procedure 
