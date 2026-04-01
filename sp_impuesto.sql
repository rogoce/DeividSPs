-- Procedimiento plan 3 en 1
-- Creado    : 06/09/2013 - Autor: Román Gordon

drop procedure sp_impuesto;
create procedure "informix".sp_impuesto(a_no_poliza char(10), a_prima_neta dec(16,2), a_impuesto dec(16,2))
returning integer, char(250), dec(16,2), dec(16,2);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_ramo			char(5);
define _error_isam			integer;
define _error				integer;
define _no_cambio			smallint;
define _resultado1          dec(16,2);
define _prima_neta          dec(16,2);
define _impuesto			dec(16,2);
define _no_unidad           char(5);
define _cod_cober_reas		char(3);
define _porc_proporcion		dec(9,6);

set isolation to dirty read;

--set debug file to "sp_sis188.trc";
--trace on;
	let _no_cambio = null;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = a_no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para Esta Poliza: '|| trim(_no_documento) ||', Por Favor Verifique ...';
		return 1, _mensaje,0,0;
	end if
	
	call sp_sis188(a_no_poliza) returning _error,_mensaje;
	
	select no_unidad
      into _no_unidad	
	  from emipouni 
	 where no_poliza = a_no_poliza
	   and cod_ramo = '020';
	
	foreach
		select distinct(cod_cober_reas)
		  into _cod_cober_reas
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio
		
		select porc_cober_reas
		  into _porc_proporcion
		  from tmp_dist_rea
		 where cod_cober_reas = _cod_cober_reas;
		 
		 let _resultado1 = ((_porc_proporcion/100)*a_prima_neta)*0.01;
		 let _impuesto   = a_impuesto + _resultado1;
		 let _prima_neta = a_prima_neta - _resultado1;
	end foreach 


	drop table tmp_dist_rea;


let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje, _prima_neta, _impuesto;

end procedure;