-- Pólizas vigentes y con endoso 
-- Creado    : 20/03/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob355;
create procedure sp_cob355()
returning	char(20)	as Poliza, --_no_documento
			date		as Fecha_Cancelacion;

define _no_documento		char(20);
define _cnt_vigente			smallint; 
define _cnt_rehab			smallint; 
define _fecha_impresion		date;

set isolation to dirty read;

foreach
	select no_documento,
		   max(fecha_impresion)
	  into _no_documento,
		   _fecha_impresion	       
	  from endedmae
	 where cod_endomov = '002'
	   and cod_tipocan = '001'
	   and fecha_impresion >= '01/01/2013'
	   and actualizado = 1
	 group by 1

	let _cnt_vigente = 0;

	select count(*)
	  into _cnt_vigente
	  from emipomae
	 where no_documento = _no_documento
	   and estatus_poliza = 1
	   and actualizado = 1;

	if _cnt_vigente is null then
		let _cnt_vigente = 0;
	end if

	if _cnt_vigente = 0 then
		continue foreach;
	end if

	let _cnt_rehab = 0;
	select count(*)
	  into _cnt_rehab
	  from endedmae
	 where no_documento = _no_documento
	   and cod_endomov = '003'
	   and fecha_impresion >= _fecha_impresion
	   and actualizado = 1;

	if _cnt_rehab is null then
		let _cnt_rehab = 0;
	end if

	if _cnt_rehab > 0 then
		continue foreach;
	end if

	return	_no_documento,
			_fecha_impresion with resume;
end foreach
end procedure;