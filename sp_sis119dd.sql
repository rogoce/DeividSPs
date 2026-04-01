-- Procedimiento que genera el Endoso de Cambio de Reaseguro Individual para las polizas automovil vigencia desde 01/07/2013
-- Creado     : 18/09/2013 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_sis119dd;
create procedure sp_sis119dd()
returning	char(10),char(5),char(20),date;

define _descripcion		char(200);
define _error_desc		char(50);
define _no_documento	char(20);
define _no_factura		char(10);
define _no_poliza		char(10);
define _periodo2		char(7);
define _periodo			char(7);
define _no_endoso_ext	char(5);
define _no_endoso		char(5);
define _cod_tipocalc	char(3);
define _no_unidad		char(5);
define _cod_impuesto	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _null			char(1);
define _factor_impuesto	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _descuento		dec(16,2);
define _impuesto		dec(16,2);
define _recargo			dec(16,2);
define _prima			dec(16,2);
define _tiene_impuesto	smallint;
define _no_endoso_int	smallint;
define _cantidad		smallint;
define _cnt				smallint;
define _error_isam		integer;
define li_return		integer;
define _error			integer;
define _vigencia_final	date;
define _vigencia_inic	date;
define _bandera         smallint;
define _fecha_suscripcion  date;

--set debug file to "sp_pro518.trc";
--trace on;
begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "","";
end exception

set isolation to dirty read;

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = "001";

let _suma_asegurada	= 0;
let _cantidad		= 0;
let _cod_tipocalc	= "001"; -- Prorrata
let _cod_endomov	= "017"; -- Cambio de Reaseguro Individual
let _cod_tipocan	= ""; 
let _no_endoso		= '00000';
let _null			= null;  -- Para campos null
let _periodo2		= "2013-09";

{create temp table tmp_camrea(
	no_poliza		char(10),
	no_unidad	    char(5)) with no log;}


foreach
	select no_poliza,
	       no_unidad
	  into _no_poliza,
	       _no_unidad
	  from camrea
	 order by no_poliza, no_unidad

   select count(*)
     into _cnt
	 from camrear
   where no_poliza = _no_poliza
     and no_unidad = _no_unidad;


   if _cnt > 0 then
		continue foreach;	
   end if

   select no_documento,fecha_suscripcion
     into _no_documento,_fecha_suscripcion
	 from emipomae
	where no_poliza = _no_poliza;

   return _no_poliza,_no_unidad,_no_documento,_fecha_suscripcion with resume;
   		   
end foreach

end

end procedure