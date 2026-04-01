-- Procedimiento que busca las polizas para los ramos indicados cuya vigencia inicial >= 01/07/2015 para ser insertados en tabla CAMREA
-- para el cambio en la distribución por la eliminacion de la SWISSRE
-- Creado     : 27/08/2015 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119h;
create procedure sp_sis119h()
returning	integer,
			char(200),
			char(5);

define _descripcion		char(200);
define _error_desc		char(50);
define _no_documento	char(20);
define _no_factura		char(10);
define _no_poliza		char(10);
define _no_endoso_ext	char(5);
define _no_endoso		char(5);
define _cod_tipocalc	char(3);
define _no_unidad		char(5);
define _cod_impuesto	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _null			char(1);
define _periodo         char(7);
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

--set debug file to "sp_pro518.trc";
--trace on;
begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;


let _suma_asegurada	= 0;
let _cantidad		= 0;
let _cod_tipocalc	= "001"; -- Prorrata
let _cod_endomov	= "017"; -- Cambio de Reaseguro Individual
let _cod_tipocan	= ""; 
let _no_endoso		= '00000';
let _null			= null;  -- Para campos null



delete from camrea;

	{select e.no_poliza,
	       e.no_endoso,
	       e.no_documento,
		   e.periodo
	  into _no_poliza,
	       _no_endoso,
	       _no_documento,
		   _periodo
	  from endedmae e, emipomae r
	 where e.no_poliza = r.no_poliza
	   and e.actualizado   = 1
	   and r.vigencia_inic >= "01/07/2014"
	   and r.cod_ramo      in('002','023')}
foreach

	select e.no_poliza,
	       e.no_endoso,
	       e.no_documento,
		   e.periodo,
		   f.no_unidad
	  into _no_poliza,
	       _no_endoso,
	       _no_documento,
		   _periodo,
		   _no_unidad
	  from endedmae e, emipomae r, emifacon  f
	 where e.no_poliza = r.no_poliza
           and e.no_poliza = f.no_poliza
           and e.no_endoso = f.no_endoso
           and f.porc_partic_prima = 75
	   and e.actualizado   = 1
	   and r.vigencia_inic >= "01/07/2015"
	   and r.cod_ramo      in('002','023')

	   
	   select count(*)
	     into _cnt
  	     from emifacon
        where no_poliza = _no_poliza
          and no_endoso = _no_endoso;
		  
		if _cnt is null then
			let _cnt = 0;
		end if
        if _cnt > 0 then
        else
           continue foreach;
		end if   

	{foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		select count(*)
		  into _cnt
		  from emireaco
 		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and porc_partic_prima = 75;

		if _cnt > 0 then
            select periodo into _periodo from endedmae where no_poliza = _no_poliza and no_endoso = _no_endoso;
			--return 0,_no_poliza || '-' || _no_endoso, _periodo with resume;}
			insert into camrea
			values(_no_poliza,_no_unidad,0,_no_endoso,_periodo,_no_documento);
		{else
			continue foreach;
		end if
		
	end foreach}

{   	foreach
		 select no_endoso
		   into _no_endoso
		   from endedmae
		  where no_poliza   = _no_poliza
		    and actualizado = 1

			insert into camreadet
			values(_no_poliza,_no_unidad,_no_endoso);

    end foreach	}
end foreach

end
return 0, "Actualizacion Exitosa", _no_endoso;
end procedure