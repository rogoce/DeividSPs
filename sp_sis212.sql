-- Procedimiento que Cambia la distribución de reaseguro de las pólizas de Auto en un rango de vigencia inicial
-- execute procedure sp_sis212('01/01/2000','31/12/2005')
drop procedure sp_sis212;
create procedure "informix".sp_sis212(a_fecha_desde	date, a_fecha_hasta	date)
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo_corte		char(7);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _ult_no_cambio		smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_corte			date;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	rollback work;
 	return _error, _error_desc;         
end exception

let _fecha_corte = '01/07/2015';

foreach with hold
	select no_poliza,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where cod_ramo in ('002','020','023')
	   and vigencia_inic between a_fecha_desde and a_fecha_hasta
	   and no_poliza not in (select no_poliza from t_camreaco)

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and cod_ruta >= '00595'
	   and _vigencia_inic between vig_inic and vig_final
	   and activo = 1;

	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		drop table if exists tmp_dist_rea;
		call sp_sis188e(_no_poliza,_no_unidad) returning _error, _error_desc;

		if _error <> 0 then
			let _error_desc = trim(_error_desc) || ' no_poliza: ' ||trim(_no_poliza);
			rollback work
			return _error,_error_desc with resume;
			continue foreach;
		end if

		let _ult_no_cambio = 0;
		let _no_cambio = 0;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			let _no_cambio = 0;
		end if

		let _ult_no_cambio = _no_cambio + 1;

		foreach
			select cod_cober_reas
			  into _cod_cober_reas
			  from tmp_dist_rea
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and porc_cober_reas <> 0

			insert into emireama(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					vigencia_inic,
					vigencia_final)
			values(	_no_poliza, 
					_no_unidad,
					_ult_no_cambio,
					_cod_cober_reas,
					_vigencia_inic,
					_vigencia_final);
			foreach
				select cod_cober_reas,
					   orden,
					   cod_contrato,
					   porc_partic_prima,
					   porc_partic_suma
				  into _cod_cober_reas,
					   _orden,
					   _cod_contrato,
					   _porc_partic_prima,
					   _porc_partic_suma
				  from rearucon
				 where cod_ruta = _cod_ruta
				   and cod_cober_reas = _cod_cober_reas

				insert into emireaco(
						no_poliza,
						no_unidad,
						no_cambio,
						cod_cober_reas,
						orden,
						cod_contrato,
						porc_partic_prima,
						porc_partic_suma)
				values(	_no_poliza,
						_no_unidad,
						_ult_no_cambio,
						_cod_cober_reas,
						_orden,
						_cod_contrato,
						_porc_partic_prima,
						_porc_partic_suma);
			end foreach
		end foreach
	end foreach
	commit work;
end foreach

return 0,'Actualización Exitosa.';

end 
end procedure;