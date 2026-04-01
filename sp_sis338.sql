-- Procedimiento para sacar el anno del deducible cuando es por vigencia
--
-- creado    : 13/03/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_sis338;
create procedure "informix".sp_sis338(a_no_documento char(20),a_fecha_factura date)
returning   integer;


define _vig_ini			date;
define _vig_fin			date;
define _vig_ini_fin     date;
define _cant,i          integer;

begin

set isolation to dirty read;

--set debug file to "sp_sis338.trc"; 
--trace on;

 CREATE TEMP TABLE tmp_serie
           (fecha1		     DATE,
			fecha2  	     DATE,
			anno	 		 integer
			) WITH NO LOG;


select vigencia_inic,
       vigencia_final
  into _vig_ini,
       _vig_fin
  from emipomae
 where no_documento = a_no_documento;

let _cant = year(_vig_fin) - year(_vig_ini);

if _cant = 0 then
	let _cant = 1;
end if

for i = 1 to _cant

	let _vig_ini_fin = _vig_ini + 1 units year;


		insert into tmp_serie(
		fecha1,
		fecha2,
		anno)
		values(
		_vig_ini,
		_vig_ini_fin,
		year(_vig_ini)
		);

		let _vig_ini = _vig_ini_fin;

end for


foreach

	select fecha1,
	       fecha2,
		   anno
	  into _vig_ini,
		   _vig_ini_fin,
		   _cant
	  from tmp_serie

	if a_fecha_factura >= _vig_ini and a_fecha_factura < _vig_ini_fin then
		exit foreach;
	end if 
	
end foreach

drop table tmp_serie;

return _cant;
end
end procedure