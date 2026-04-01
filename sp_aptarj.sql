-- procedimiento que busca una factura en emipomae
-- creado    : 18/08/2011 - autor: armando moreno
-- modificado: 18/08/2011 - autor: armando moreno
-- sis v.2.0 - deivid, s.a.

drop procedure sp_aptarj;
create procedure "informix".sp_aptarj(
) returning char(10), char(20);

define _error_code      integer;
define _cnt		      	integer;  
define _nrocotizacion   char(10);
define _no_documento    char(20);

--set debug file to "sp_cob285.trc"; 
--trace on;                                                                

set isolation to dirty read;

begin
on exception set _error_code 
 	--return _error_code, 'Error al Buscar la factura, intente nuevamente...', '';
end exception           

FOREACH WITH HOLD
	select nrocotizacion
	  into _nrocotizacion 
	  from wf_cotizacion
	 where date(vigenciainicial) >= '02/07/2015'
	 
	let _cnt = 0;

	SELECT count(*) 
	  into _cnt
	  from emipomae
	 where cotizacion = TRIM(_nrocotizacion)
	   and cod_formapag in ('003','005')
	   and fecha_suscripcion >= '02/07/2015'
	   and fecha_suscripcion <= '13/07/2015';
	 
	if _cnt > 0 then 
		SELECT no_documento 
		  into _no_documento
		  from emipomae
		 where cotizacion = TRIM(_nrocotizacion);
	 
		return _nrocotizacion, _no_documento with resume;
	end if
end foreach
end
end procedure;
