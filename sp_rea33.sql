--------------------------------------------
--Verificación de series contrato vs series ruta con respecto a la vigencia de la póliza
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_rea33()
--------------------------------------------
drop procedure sp_rea33;
create procedure sp_rea33()
returning	smallint	as error,
			smallint	as estatus_poliza,
			char(10)	as no_poliza,
			char(5)		as no_unidad,
			date		as vigencia_inic,
			date		as vigencia_final;

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ramo			char(3);
define _estatus_poliza		smallint;
define _cnt_emireaco		smallint;
define _no_cambio			smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea33.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error,0,_no_poliza,_error_desc,null,null;
end exception  

set isolation to dirty read;

foreach
	select distinct no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from camrea
	 where periodo in ('2016-07','2016-08')

	insert into semifacon
	select * 
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
end foreach

foreach
	select distinct no_poliza
	  into _no_poliza
	  from camrea

	foreach
		select c.no_remesa,
			   c.renglon
		  into _no_remesa,
			   _renglon
		  from camcobreaco c, cobredet d
		 where c.no_remesa = d.no_remesa
		   and c.renglon = d.renglon
		   and c.no_poliza = _no_poliza
		   and d.periodo < ('2016-09')

		insert into scobreaco
		select *
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon = _renglon;
	end foreach
end foreach

end
end procedure;