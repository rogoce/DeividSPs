--------------------------------------------
--Verificación de series contrato vs series ruta con respecto a la vigencia de la póliza
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_rea30()
--------------------------------------------
drop procedure sp_rea30;
create procedure sp_rea30()
returning	char(7)		as periodo,
			char(10)	as no_poliza,
			char(5)		as no_endoso,
			char(20)	as poliza,
			char(10)	as no_factura,
			date		as vigencia_inic,
			date		as vigencia_final,
			char(5)		as no_unidad,
			smallint	as serie,
			char(5)		as cod_contrato,
			varchar(50)	as nom_contrato,
			char(3)		as tipo_mov,
			smallint	as serie_contrato;

define _error_desc			varchar(100);
define _nom_contrato		varchar(50);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_poliza			char(10);
define _periodo_inicio		char(8);
define _periodo				char(8);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _serie_contrato		smallint;
define _serie				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea30.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return '','','','','',_vigencia_inic,null,'',_error,'',_error_desc,'',_error_isam;
end exception  

set isolation to dirty read;

let _periodo_inicio = '2016-11';

drop table if exists tmp_reas;
create temp table tmp_reas(
periodo				char(7),
no_poliza			char(10),
no_endoso			char(5),
poliza				char(20),
no_factura			char(10),
vigencia_inic		date,
vigencia_final		date,
no_unidad			char(5),
serie				smallint,
cod_contrato		char(5),
nom_contrato		varchar(50),
tipo_mov			char(3),
serie_contrato		smallint) with no log;

foreach
	select no_poliza,
		   no_endoso,
		   no_factura,
		   periodo,
		   cod_endomov
	  into _no_poliza,
		   _no_endoso,
		   _no_factura,
		   _periodo,
		   _cod_endomov
	  from endedmae
	 where periodo >= _periodo_inicio
	   and actualizado = 1
	   and cod_endomov in ('004','011')
	 order by periodo,no_documento

	select no_documento,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final
	  into _no_documento,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ('001','003','006','008','010','011','012','013','014','021','022') then
		--continue foreach;
	end if
	
	if _cod_ramo in ('018') then
		continue foreach;
	end if

	foreach
		select cod_ruta,
			   serie
		  into _cod_ruta,
			   _serie
		  from rearumae
		 where cod_ramo = _cod_ramo
		   and _vigencia_inic between vig_inic and vig_final
		   and activo = 1
		 order by cod_ruta desc
		exit foreach;
	end foreach

	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		foreach
			select cod_cober_reas,
				   cod_contrato
			  into _cod_cober_reas,
				   _cod_contrato
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad

			select nombre,
				   serie
			  into _nom_contrato,
				   _serie_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _serie <> _serie_contrato then

				insert into tmp_reas(
						periodo,
						no_poliza,
						no_endoso,
						poliza,
						no_factura,
						vigencia_inic,
						vigencia_final,
						no_unidad,
						serie,
						cod_contrato,
						nom_contrato,
						tipo_mov,
						serie_contrato)
				values(	_periodo,
						_no_poliza,
						_no_endoso,
						_no_documento,
						_no_factura,
						_vigencia_inic,
						_vigencia_final,
						_no_unidad,
						_serie,
						_cod_contrato,
						_nom_contrato,
						_cod_endomov,
						_serie_contrato);

				return	_periodo,
						_no_poliza,
						_no_endoso,
						_no_documento,
						_no_factura,
						_vigencia_inic,
						_vigencia_final,
						_no_unidad,
						_serie,
						_cod_contrato,
						_nom_contrato,
						_cod_endomov,
						_serie_contrato with resume;
			end if
		end foreach
	end foreach
end foreach

return '','','','','',null,null,'',0,'','','Verificación Exitosa',0;

end
end procedure;