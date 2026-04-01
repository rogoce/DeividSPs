-- Procedimiento que determina la serie minima y maxima de una poliza a lo largo de sus vigencias
-- Creado    : 15/03/2012 - autor: Roman Gordon

drop procedure sp_pro358;

create procedure sp_pro358(a_no_poliza char(10))
returning smallint,	 -- _serie1
		  smallint;  -- _serie2
									 
define _no_documento	char(20);
define _no_poliza		char(10);   
define _cod_ruta		char(5);
define _vig_fin_year	smallint;
define _serie			smallint;
define _serie1			smallint;
define _serie2			smallint;
define _vigencia_final	date;



--set debug file to "sp_pro358.trc";-- nombre de la compania
--trace on;

set isolation to dirty read;

create temp table tmp_poliza(no_poliza char(10)) with no log; 


select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;


select min(serie),
	   max(serie),
	   max(vigencia_final)
  into _serie1,
  	   _serie2,
	   _vigencia_final
  from emipomae 
 where no_documento = _no_documento;

let _vig_fin_year = year(_vigencia_final);

if _vig_fin_year > _serie2 then
	let _serie2 = _vig_fin_year;
end if
  
foreach
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where no_documento = _no_documento

	insert into tmp_poliza(no_poliza)
	values (_no_poliza);
end foreach	
	
foreach
	select distinct cod_ruta
	  into _cod_ruta
	  from endeduni
	 where no_poliza in (select no_poliza from tmp_poliza)

	select serie
	  into _serie
	  from rearumae
	 where cod_ruta = _cod_ruta;

	if _serie < _serie1 then
		let _serie1 = _serie;
	end if
	
	if _serie > _serie2 then
		let _serie2 = _serie;
	end if
end foreach

drop table tmp_poliza;

return _serie1,
	   _serie2;

end procedure