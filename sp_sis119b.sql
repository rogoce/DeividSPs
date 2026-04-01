-- Procedimiento que genera el Endoso de Cambio de Reaseguro Individual para las polizas automovil vigencia desde 01/07/2013
-- Creado     : 18/09/2013 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sis119b;
create procedure sp_sis119b(a_usuario char(8))
returning	integer,
			char(200),
			char(5);

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
	       no_documento,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where actualizado   = 1
	   and vigencia_inic >= "01/07/2013"
	   and cod_ramo      = '002'
		   
	foreach
		select no_unidad,suma_asegurada
		  into _no_unidad,_suma_asegurada
		  from emipouni
		 where no_poliza = _no_poliza

		select count(*)
		  into _cnt
		  from emireaco
 		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = '031';

		if _cnt > 0 then
			continue foreach;
		end if

	 	select count(*)
		  into _cnt
		  from emipocob	   
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
	 	   and cod_cobertura in('00903','00121','00606','00118','00900','00120','00902','01146','01233','00103','00901','00904');

		if _cnt > 0 then
			insert into camrea
			values(_no_poliza,_no_unidad,0);
		end if
	end foreach
end foreach

{foreach
	select no_poliza
	  into _no_poliza
	  from tmp_camrea

	select count(*)
	  into _cnt
	  from camrea
	 where no_poliza = _no_poliza;

	if _cnt > 0 then
	else
		return 0,_no_poliza,'' with resume;
	end if
end foreach	}
end
return 0, "Actualizacion Exitosa", _no_endoso;
end procedure