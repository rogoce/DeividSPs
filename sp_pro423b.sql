-- Procedimiento para buscar el valor del Recargo de Salud
-- Creado    : 31/05/2024 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro423b;
create procedure "informix".sp_pro423b()
returning	char(20), char(10), date, date, dec(16,2),varchar(100), dec(16,2), dec(16,2); -- ld_descuento

define _no_unidad		char(5);
define _recargo			dec(16,2);
define _anos			smallint;
define _cod_asegurado   char(10);
define _no_documento    char(20);
define _vigencia_inic, _vigencia_final date;
define _cnt				smallint;
define _porc_recargo	dec(16,2);
define a_no_poliza 		char(10);
define _desc_error			varchar(250);
define _error_isam			integer;
define _error				integer;
define _cantidad 		integer;


begin
on exception set _error,_error_isam,_desc_error
	return _no_documento, _cod_asegurado, _vigencia_inic, _vigencia_final, _recargo, _error, _recargo, _porc_recargo;
end exception

set isolation to dirty read;

-- set debug file to "sp_proe70.trc";
-- trace on;

let _recargo		= 0.00;
let _porc_recargo		= 0.00;

foreach 
	select distinct no_documento
	  into _no_documento
	  from deivid_tmp:salud_recargo
	
    let a_no_poliza = sp_sis21(_no_documento);	

	select vigencia_inic,
		   vigencia_final,
		   no_documento
	  into _vigencia_inic,
		   _vigencia_final,
		   _no_documento
	  from emipomae
	 where no_poliza = a_no_poliza;

	let _anos = (_vigencia_final - _vigencia_inic) / 365;

	if _anos = 0 then
		return _no_documento, null, _vigencia_inic, _vigencia_final, 0, 'Menor a 1 año', 0, 0 with resume;
		continue foreach;
	end if
	 
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = a_no_poliza 
	   and activo = 1;	   --> Le agregue esta condicion Amado 2/8/2011 

	if _cantidad > 1 then
		return _no_documento, null, _vigencia_inic, _vigencia_final, 0, 'Mas de una unidad', 0, 0 with resume;
	end if
	 	 
	let _recargo = 0.00;

	foreach 
		select recargo,
			   cod_asegurado
		  into _recargo,
			   _cod_asegurado
		  from deivid_tmp:salud_recargo
		 where no_documento = _no_documento
		 
		if _recargo is null then
			let _recargo = 0;
		end if
		
		if _recargo = 0 then
			return _no_documento, _cod_asegurado, _vigencia_inic, _vigencia_final, 0, 'Sin recargo', 0, 0 with resume;
			continue foreach;
		end if
		
		let _no_unidad = null;
		
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = a_no_poliza
		   and cod_asegurado = _cod_asegurado
		   and activo = 1;
		 
		if _no_unidad is null then
			return _no_documento, _cod_asegurado, _vigencia_inic, _vigencia_final, 0, 'Unidad no existe', 0, 0 with resume;
			continue foreach;
		end if	
		
		let _cnt = 0;
		
		select count(*)
		  into _cnt
		  from emiunire
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and cod_recargo = '001';
		   
		if _cnt is null then
			let _cnt = 0;
		end if
		
		let _porc_recargo = 0;
		
		if _cnt = 0 then
		else
			select porc_recargo 
			  into _porc_recargo
			  from emiunire
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
		       and cod_recargo = '001';		   
		end if
		--let _recargo = _recargo + _porc_recargo;
		return _no_documento, _no_unidad, _vigencia_inic, _vigencia_final, _recargo, 'Exito', _porc_recargo, _recargo + _porc_recargo with resume; 
	end foreach

--	return _no_documento, _no_unidad, _vigencia_inic, _vigencia_final, _recargo with resume;
end foreach
end
end procedure
	   
	
	 
	

	