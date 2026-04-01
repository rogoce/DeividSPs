-- Procedimiento que determina las variables para el descuento por siniestralidad

-- Tarifas Agosto 2015

drop procedure sp_sis213;
create procedure "informix".sp_sis213(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _ult_no_cambio		smallint;
define _cnt_existe			smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _fecha_proceso		date;
define _vigencia_inic		date;

set isolation to dirty read;

--set debug file to "sp_sis213.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	rollback work;
 	return _error, _error_desc;         
end exception

foreach with hold
	select e.no_poliza,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.cod_ramo,
		   u.no_unidad
	  into _no_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _no_unidad
	  from emipomae e, emipouni u
	 where e.no_poliza = u.no_poliza
	   and e.cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
	   --and estatus_poliza <> 1
	   and e.no_poliza in (select distinct no_poliza from rea_saldo2 where cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1) and vigencia_inic <= '01/01/2016' and periodo = '2018-02')
	   and e.actualizado = 1
	   --and e.periodo between a_periodo_desde and a_periodo_hasta
	 order by e.vigencia_inic desc
	
	begin work;

	select count(*)
	  into _cnt_existe
	  from emireaco_transf
	 where no_poliza = _no_poliza;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe <> 0 then
		--commit work;
		--continue foreach;
	else
		insert into emireaco_transf
		select *
		  from emireaco
		 where no_poliza = _no_poliza;
	end if

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and _vigencia_inic between vig_inic and vig_final
	   and activo = 1;

	if _cod_ruta is null then
		rollback work;
		return 1,'No se encontro Ruta para el no_poliza: ' || trim(_no_poliza) || ' no_unidad: ' || trim(_no_unidad);
	end if

	{foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza}

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
			select distinct cod_cober_reas
			  into _cod_cober_reas
			  from rearucon
			 where cod_ruta = _cod_ruta

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
				select orden,
					   cod_contrato,
					   porc_partic_prima,
					   porc_partic_suma
				  into _orden,
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
	--end foreach

	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure

