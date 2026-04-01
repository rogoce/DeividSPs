-- Buscar la prima anual de la poliza

-- Creado    : 09/06/2010 - Autor: Amado Perez M. 

drop procedure amado_reaseguro;

create procedure "informix".amado_reaseguro()
returning char(10), char(5), char(5), char(3), char(5), dec(9,6), dec(9,6), dec(16,2), dec(16,2), char(20), char(10);

define _no_poliza	char(10);
define _no_endoso	char(5);
define _no_unidad	char(5);
define _cod_contrato char(5);
define _cod_cober_reas char(3);
define _porc_partic_suma dec(9,6); 
define _porc_partic_prima dec(9,6);
define _no_documento char(20); 
define _no_factura char(10); 

define _suma_asegurada dec(16,2); 
define _prima dec(16,2); 

SET ISOLATION TO DIRTY READ;

foreach
	select no_poliza, no_endoso, no_documento, no_factura 
	  into _no_poliza, _no_endoso, _no_documento, _no_factura 
	  from endedmae 
	 where periodo >= '2011-01' 
	   and periodo <= '2011-12'

    foreach
		select no_unidad, cod_cober_reas, cod_contrato, porc_partic_suma, porc_partic_prima, suma_asegurada, prima
		  into _no_unidad, _cod_cober_reas, _cod_contrato, _porc_partic_suma, _porc_partic_prima, _suma_asegurada, _prima
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   
		 return _no_poliza, _no_endoso, _no_unidad, _cod_cober_reas, _cod_contrato, _porc_partic_suma, _porc_partic_prima, _suma_asegurada, _prima, _no_documento, _no_factura WITH RESUME;

	end foreach
end foreach


end procedure 
