-- Procedimiento para buscar el valor del Recargo de Salud
-- Creado    : 31/05/2024 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro423;
create procedure "informix".sp_pro423(a_no_poliza char(10))
returning	integer, char(100); -- ld_descuento

define _no_unidad		char(5);
define _recargo			dec(16,2);
define _anos			smallint;
define _cod_asegurado   char(10);
define _no_documento    char(20);
define _vigencia_inic, _vigencia_final date;
define _cnt				smallint;
define _error			integer;
define _cantidad		integer; 

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al Cambiar Tarifas...";
end exception


-- set debug file to "sp_proe70.trc";
-- trace on;

let _recargo		= 0.00;

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
	return 0, 'Menor a 1 agno';
end if

select count(*)
  into _cantidad
  from emipouni
 where no_poliza = a_no_poliza 
   and activo = 1;	   --> Le agregue esta condicion Amado 2/8/2011 

if _cantidad > 1 then
	return 0, 'Mas de una unidad';
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
	
	if _cnt = 0 then
		insert into emiunire (
		 no_poliza,
		 no_unidad,
		 cod_recargo,
		 porc_recargo)
		 values (
		 a_no_poliza,
		 _no_unidad,
		 '001',
		 _recargo);
	else
	    update emiunire
		   set porc_recargo = porc_recargo + _recargo
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and cod_recargo = '001';
	end if
end foreach

return 0, 'Exito';
end
end procedure
	   
	
	 
	

	