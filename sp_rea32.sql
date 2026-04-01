--------------------------------------------
--Proceso de Reversión masiva de notrx
--execute procedure sp_rea32()
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea32;
create procedure sp_rea32()
returning	smallint	as error,
			varchar(50)	as desc_error;

define _error_desc			varchar(100);
define _nom_contrato		varchar(50);
define _no_documento		char(20);
define _no_registro			char(10);
define _no_factura			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _periodo_inicio		char(8);
define _periodo				char(8);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _serie_contrato		smallint;
define _cnt_notrx			smallint;
define _serie				smallint;
define _error_isam			integer;
define _notrx				integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error,_error_desc;
end exception  

set isolation to dirty read;

foreach
	select distinct res_notrx
	  into _notrx
	  from cglresumen
	 where res_notrx in (1848423,
1848432,
1848440,
1848447,
1848457,
1848469,
1848480,
1848491,
1848503,
1848510,
1848516,
1848521,
1848523,
1848531,
1848537,
1852290,
1852291,
1852292,
1852293,
1852294,
1852295,
1852296,
1852297,
1852298,
1852299,
1852300,
1852301,
1852302,
1852303,
1852304)

	{select distinct sac_notrx
	  into _notrx
	  from deivid_tmp:remesas t, cobasien e
	 where t.no_remesa = e.no_remesa}

	call sp_sac77(_notrx) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if
end foreach;

{foreach
	select distinct no_registro
	  into _no_registro
	  from deivid_tmp:remesas t, sac999:reacomp r
	 where t.no_remesa = r.no_remesa

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	select count(*)
	  into _cnt_notrx
	  from sac999:reacompasie
	 where no_registro = _no_registro;

	if _cnt_notrx is null then
		let _cnt_notrx = 0;
	end if

	if _cnt_notrx = 0 then
		update sac999:reacomp
		   set sac_asientos = 0
		 where no_registro = _no_registro;
	else
		foreach
			select distinct sac_notrx
			  into _notrx
			  from sac999:reacompasie
			 where no_registro = _no_registro

			call sp_sac77(_notrx) returning _error,_error_desc;
		end foreach
	end if
end foreach}

return 0,'Actualización Exitosa';
end
end procedure;