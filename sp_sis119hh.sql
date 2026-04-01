-- Procedimiento que busca las polizas con vigencia inicial >= 01/07/2016 para los ramos seleccionados para el cambio de reaseguro.
-- Creado     : 07/09/2016 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119hh;
create procedure sp_sis119hh()
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

foreach

	select r.no_poliza,
		   r.no_documento,
		   e.periodo,
		   f.no_unidad,f.no_endoso
	  into _no_poliza,_no_documento,_periodo,_no_unidad,_no_endoso	   
	  from emipomae r, emifacon  f , endedmae e
	 where r.no_poliza = f.no_poliza
	   and f.no_poliza = e.no_poliza
	   and f.no_endoso = e.no_endoso
	   and f.cod_contrato in('00656','00657')
	   and r.actualizado   = 1
	   and r.vigencia_inic >= "01/07/2016"
	   and r.cod_ramo      in('006','008','001','003','010','011','012','013','014','021','022')
	group by r.no_poliza,r.no_documento,e.periodo,f.no_unidad,f.no_endoso
	
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
	insert into camrea
	values(_no_poliza,_no_unidad,0,_no_endoso,_periodo,_no_documento);
end foreach

end
return 0, "Actualizacion Exitosa", _no_endoso;
end procedure