-- Procedimiento que genera el Endoso de Cambio de Reaseguro Individual para las polizas automovil vigencia desde 01/07/2013
-- 
-- Creado     : 18/09/2013 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119bkk;

create procedure sp_sis119bkk()
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
define _ruta            char(5);
define _cod_ramo        char(3);

--set debug file to "sp_sis119bk.trc";
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
let _periodo2   = "2014-11";


foreach

	select no_poliza,
	       no_unidad
	  into _no_poliza,
	       _no_unidad
	  from camrea
	 where actualizado = 0
	   and no_poliza   = '821964'
	 order by 1,2

    select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_ramo = '002' then
	   let _ruta = '00557';	   --ruta Automovil

         update emireaco
		    set porc_partic_suma  = 50,
			    porc_partic_prima = 50
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and cod_cober_reas = '031';

	elif _cod_ramo = '023' then
	   let _ruta = '00558';   --ruta Automovil flotas

         update emireaco
		    set porc_partic_suma  = 50,
			    porc_partic_prima = 50
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and cod_cober_reas = '034';

	end if

  foreach

		select no_endoso
		  into _no_endoso
		  from endedmae
		 where no_poliza   = _no_poliza
		   and actualizado = 1



		foreach

			 select suma_asegurada
			   into _suma_asegurada
			   from endeduni
			  where no_poliza = _no_poliza
			    and no_unidad = _no_unidad
				and no_endoso = _no_endoso

			 let _error = sp_proe05bk3(_no_poliza, _no_unidad, _ruta, _suma_asegurada, _no_endoso);

		 	update camrea
			   set actualizado = 1
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;


        end foreach


  end foreach

end foreach

end

return 0, "Actualizacion Exitosa, " || _cantidad || " Registros Procesados", _no_endoso;

end procedure