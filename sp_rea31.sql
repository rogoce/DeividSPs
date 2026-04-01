--------------------------------------------
--Verificación de series contrato vs series ruta con respecto a la vigencia de la póliza
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_rea31()
--------------------------------------------
drop procedure sp_rea31;
create procedure sp_rea31()
returning	smallint	as error,
			smallint	as estatus_poliza,
			char(10)	as no_poliza,
			char(5)		as no_unidad,
			date		as vigencia_inic,
			date		as vigencia_final;

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_ramo			char(3);
define _estatus_poliza		smallint;
define _cnt_emireaco		smallint;
define _no_cambio			smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error,0,'',_error_desc,null,null;
end exception  

set isolation to dirty read;

foreach
	select no_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   estatus_poliza
	  into _no_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza
	  from emipomae
	 where cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
	   and actualizado = 1
	   --and no_poliza in (select distinct no_poliza from rea_saldo2 where cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1) and periodo = '2018-02')
	 order by estatus_poliza,vigencia_inic desc

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and _vigencia_inic between vig_inic  and vig_final
	   and activo = 1;

	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			return 2,_estatus_poliza,_no_poliza,_no_unidad,_vigencia_inic,_vigencia_final with resume;
		end if

		select count(*)
		  into _cnt_emireaco
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio
		   and cod_contrato not in (select distinct cod_contrato from rearucon where cod_ruta = _cod_ruta);

		if _no_cambio is null then
			let _cnt_emireaco = 0;
		end if

		if _cnt_emireaco <> 0 then
			return 1,_estatus_poliza,_no_poliza,_no_unidad,_vigencia_inic,_vigencia_final with resume;
		end if
	end foreach
end foreach

return 0,0,'','Verificación Exitosa',null,null;

end
end procedure;