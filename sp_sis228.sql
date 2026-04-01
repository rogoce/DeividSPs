-- Procedimiento que Ajusta la información de prima en la estructura de emision tomando en cuenta la información que esta en endosos
-- Creado    : 07/11/2016 - Autor: Román Gordon

drop procedure sp_sis228;
create procedure "informix".sp_sis228(a_no_poliza char(10))--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje				char(250);
define _cod_cobertura		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _prima_anual_cob		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _descuento_cob		dec(16,2);
define _recargo_cob			dec(16,2);
define _prima_cob			dec(16,2);
define _suma_aseg_adic_u	dec(16,2);
define _suma_asegurada_u	dec(16,2);
define _prima_bruta_u		dec(16,2);
define _prima_neta_u		dec(16,2);
define _descuento_u			dec(16,2);
define _impuesto_u			dec(16,2);
define _recargo_u			dec(16,2);
define _prima_u				dec(16,2);
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to "sp_sis228.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

foreach
	select no_unidad		   
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

	select sum(u.suma_asegurada),
		   sum(u.prima),
		   sum(u.prima_neta),
		   sum(u.descuento),
		   sum(u.recargo),
		   sum(u.impuesto),
		   sum(u.prima_bruta),
		   sum(u.suma_aseg_adic)
	  into _suma_asegurada_u,
		   _prima_u,
		   _prima_neta_u,
		   _descuento_u,
		   _recargo_u,
		   _impuesto_u,
		   _prima_bruta_u,
		   _suma_aseg_adic_u
	  from endeduni u, endedmae e
	 where u.no_poliza = e.no_poliza
	   and u.no_endoso = e.no_endoso
	   and u.no_poliza = a_no_poliza
	   and u.no_unidad = _no_unidad
	   and e.actualizado = 1;

	update emipouni
	   set suma_asegurada = _suma_asegurada_u, 
		   prima = _prima_u,
		   prima_neta = _prima_neta_u,
		   descuento = _descuento_u,
		   recargo = _recargo_u,
		   impuesto = _impuesto_u,
		   prima_bruta = _prima_bruta_u,
		   suma_aseg_adic = _suma_aseg_adic_u
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;
	
	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from emipocob
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		 order by 1
	
		select sum(c.prima),
			   sum(c.prima_anual),
			   sum(c.prima_neta),
			   sum(c.descuento),
			   sum(c.recargo)
		  into _prima_cob,
			   _prima_anual_cob,
			   _prima_neta_cob,
			   _descuento_cob,
			   _recargo_cob
		  from endedcob c, endedmae e
		 where c.no_poliza = e.no_poliza
		   and c.no_endoso = e.no_endoso
		   and c.no_poliza = a_no_poliza
		   and c.no_unidad = _no_unidad
		   and c.cod_cobertura = _cod_cobertura
		   and e.actualizado = 1;

		update emipocob
		   set prima = _prima_cob,
			   prima_anual = _prima_anual_cob,
			   prima_neta = _prima_neta_cob,
			   descuento = _descuento_cob,
			   recargo = _recargo_cob
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura = _cod_cobertura;
	end foreach
end foreach
end

end procedure;