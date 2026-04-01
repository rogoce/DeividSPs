-- Procedimiento que genera el Endoso de Cambio de Reaseguro Individual para las polizas automovil vigencia desde 01/07/2013
-- 
-- Creado     : 18/09/2013 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis119c;

create procedure sp_sis119c()
 returning integer,
           char(200),
           char(5);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(200);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define _no_documento    char(20);
define _no_factura      char(10);
define li_return        integer;
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_unidad       char(5);
define _cnt             smallint;
define _periodo2        char(7);

--set debug file to "sp_pro518.trc";
--trace on;
begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = "001";

let _cod_endomov  = "017"; -- Cambio de Reaseguro Individual
let _cod_tipocan  = ""; 
let _cod_tipocalc = "001"; -- Prorrata
let _null		  = null;  -- Para campos null
let _suma_asegurada = 0;
let _no_endoso      = '00000';

let _cantidad   = 0;
let _periodo2   = "2013-09";


FOREACH

	select no_poliza,
	       no_unidad
	  into _no_poliza,
	       _no_unidad
	  from camrea
		   
	select count(*)
	  into _cnt
	  from endedmae
	 where no_poliza   = _no_poliza
	   and cod_endomov = '006'
	   and actualizado = 1;

    if _cnt > 0 then
		return 0,_no_poliza,_no_unidad with resume;
	end if

END FOREACH

end

return 0, "Actualizacion Exitosa", _no_endoso;

end procedure