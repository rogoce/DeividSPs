-- Cambio en distribucion de reaseguro, 	PRODUCCION
-- 
-- Creado     : 27/08/2015 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis202a;

create procedure sp_sis202a()
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
define _cod_cober_reas  char(3);
DEFINE _porc_partic_suma, _porc_partic_prima  DECIMAL(10,4);

--set debug file to "sp_sis119bk.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

let _cod_endomov  = "017"; -- Cambio de Reaseguro Individual
let _cod_tipocan  = ""; 
let _cod_tipocalc = "001"; -- Prorrata
let _null		  = null;  -- Para campos null
let _suma_asegurada = 0;
let _no_endoso      = '00000';

let _cantidad   = 0;
--let _periodo2   = "2014-11";
let _porc_partic_suma  = 0;
let _porc_partic_prima = 0;


foreach WITH HOLD
 select no_poliza,
        no_unidad,
	    no_endoso,
	    periodo
   into _no_poliza,
        _no_unidad,
	    _no_endoso,
	    _periodo
   from camrea
  where actualizado = 0
  order by 1,3,2

	 begin work;
	 
    select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _cantidad  = _cantidad + 1;
	
    if _cod_ramo in('006','008') then
	   --let _ruta = '00557';	   --ruta

        update emireaco
		   set cod_contrato = '00646'		--CP actual
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_contrato = '00641';	--CP anterior

		update emifacon
		   set cod_contrato = '00646'		--CP actual
		 where no_poliza	= _no_poliza
		   and no_endoso	= _no_endoso
		   and no_unidad	= _no_unidad
		   and cod_contrato = '00641';	--CP anterior		   
			
	elif _cod_ramo  in('010','011','012','013','014','021','022') then
	   --let _ruta = '00558';   --ruta Automovil flotas

         update emireaco
		    set cod_contrato = '00645'		--Excedente actual
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and cod_contrato = '00640';		--Excedente Anterior
			
		update emifacon
		   set cod_contrato = '00645'		--CP actual
		 where no_poliza	= _no_poliza
		   and no_endoso	= _no_endoso
		   and no_unidad	= _no_unidad
		   and cod_contrato = '00640';	--CP anterior
	
    elif _cod_ramo  in('001','003') then
	    if _cod_ramo = '001' then
		   let _cod_cober_reas = '021';	--terremoto incendio
		else
			let _cod_cober_reas = '022';	--terremoto multiriesgo
        end if		
         update emireaco
		    set cod_contrato = '00645'		--Excedente actual
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and cod_contrato = '00640';		--Excedente Anterior
			
         update emifacon
		    set cod_contrato = '00645'		--Excedente actual
		  where no_poliza = _no_poliza
			and no_endoso = _no_endoso
		    and no_unidad = _no_unidad
			and cod_contrato = '00640';		--Excedente Anterior
			
		select sum(porc_partic_suma),sum(porc_partic_prima),sum(suma_asegurada),sum(prima)
		  into _porc_partic_suma,_porc_partic_prima,_suma_asegurada,_prima
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato in('00638','00645');
		   
         update emifacon
		    set porc_partic_suma  = _porc_partic_suma,
			    porc_partic_prima = _porc_partic_prima,
				suma_asegurada    = _suma_asegurada,
				prima             = _prima
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		    and no_unidad = _no_unidad
			and cod_contrato = '00638'		--Retencion 100	
            and cod_cober_reas = _cod_cober_reas;

		delete from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_contrato = '00645'			--Excedente actual
		   and cod_cober_reas = _cod_cober_reas;
		   
		let _prima = 0;
		
		select sum(prima)   
		  into _prima
		  from emifacon
		where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		    and no_unidad = _no_unidad
			and cod_contrato = '00638';		--Retencion 100
		
		update endedmae
		   set prima_retenida = _prima
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
		   
		select sum(porc_partic_suma),sum(porc_partic_prima)
		  into _porc_partic_suma,_porc_partic_prima
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato in('00638','00645');		   

		update emireaco
		   set porc_partic_suma  = _porc_partic_suma,		--Excedente actual
			   porc_partic_prima = _porc_partic_prima
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_contrato = '00638'			--Excedente actual
		   and cod_cober_reas = _cod_cober_reas;

		delete from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_contrato = '00645'			--Excedente actual
		   and cod_cober_reas = _cod_cober_reas;		   
	end if
	
	update camrea
	   set actualizado = 1
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_endoso = _no_endoso;

	--Verificar esto cuando es en dataserver
	if _periodo >= '2015-09' then

		update sac999:reacomp
		   set sac_asientos = 0
		 where no_poliza     = _no_poliza
		   and no_endoso     = _no_endoso
		   and tipo_registro = 1;
	end if	   

	commit work;

	if _cantidad >= 500 then
		exit foreach;
	end if
end foreach

end

return 0, "Actualizacion Exitosa, " || _cantidad || " Registros Procesados", _no_endoso;

end procedure