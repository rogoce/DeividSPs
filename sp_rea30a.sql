--------------------------------------------
--Verificación de series contrato vs series ruta con respecto a la vigencia de la póliza
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_rea30()
--------------------------------------------
drop procedure sp_rea30a;
create procedure sp_rea30a(a_no_poliza char(10))
returning	char(7)		as periodo,
			char(10)	as no_poliza,
			char(5)		as no_endoso,
			char(20)	as poliza,
			char(10)	as no_factura,
			date		as vigencia_inic,
			date		as _vigencia_final,
			char(5)		as no_unidad,
			smallint	as serie,
			char(5)		as cod_contrato,
			varchar(50)	as nom_contrato,
			smallint	as serie_contrato;

define _error_desc			varchar(100);
define _nom_contrato		varchar(50);
define _no_documento		char(20);
define _no_factura			char(10);
define _periodo_inicio		char(8);
define _periodo				char(8);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_ramo			char(3);
define _serie_contrato		smallint;
define _serie				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return '','','','','',null,null,'',_error,'',_error_desc,_error_isam;
end exception  

set isolation to dirty read;

let _periodo_inicio = '2016-01';

select cod_ramo,
	   vigencia_inic,
	   vigencia_final
  into _cod_ramo,
	   _vigencia_inic,
	   _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza;

select cod_ruta,
	   serie
  into _cod_ruta,
	   _serie
  from rearumae
 where cod_ramo = _cod_ramo
   and _vigencia_inic between vig_inic and vig_final
   and activo = 1;

foreach
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

	foreach
		select cod_contrato
		  into _cod_contrato
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad

		select nombre,
			   serie
		  into _nom_contrato,
			   _serie_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _serie <> _serie_contrato then
			let _error_desc = 'Por Favor ingrese el Reaseguro de a Unidad ' || trim(_no_unidad) || '. '
			return	_periodo,
					_vigencia_inic,
					_no_unidad,
					_serie,
					_cod_contrato,
					_nom_contrato,
					_serie_contrato with resume;
		end if
	end foreach
end foreach

return '','','','','',null,null,'',0,'','Verificación Exitosa',0;

end
end procedure;