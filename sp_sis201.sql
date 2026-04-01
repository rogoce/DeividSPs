-- Procedimiento que Arregla la Distribución de Reaseguro en los Reclamos de Auto
-- 
-- Creado    : 03/02/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis201;
create procedure sp_sis201(a_no_reclamo char(10))
returning integer,
          char(50);

{
returning	char(10),	--1._no_reclamo
			char(3),	--2._cod_ramo
			char(5),	--3._cod_cobertura
			char(50),	--4._nom_cobertura
			char(3),	--5._cod_cober_reas
			char(3),	--6._cod_ramo_reas
			char(5),	--7._cod_ruta
			smallint,	--8._ctn_ruta
			date;
}

define _error_desc			char(250);
define _nom_cobertura		char(50);
define _no_documento		char(21);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _cod_cobertura		char(5);
define _cod_contrato		char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_cober_reas_r	char(3);
define _cod_ramo_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _cnt_cober_reas		smallint;
define _cnt_ruta			smallint;
define _cnt_fac				smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_transaccion	date;
define _fecha_reclamo2		date;
define _fecha_reclamo		date;
define _vigencia_inic		date;

set isolation to dirty read;

--set debug file to "sp_sis121.trc";
--trace on;

begin
--{
on exception set _error,_error_isam,_error_desc
	

	return _error, _error_desc;

	{
	return	_no_reclamo,
			"",
			"",
			_error_desc,
			"",
			"",
			"",
			_error,
			_fecha_reclamo;
	}

end exception
--}

let _cnt_fac = 0;

foreach
	select r.no_reclamo,
		   r.fecha_reclamo,
		   e.cod_ramo,
		   e.no_poliza,
		   e.vigencia_inic
	  into _no_reclamo,
		   _fecha_reclamo,
		   _cod_ramo,
		   _no_poliza,
		   _vigencia_inic
	  from recrcmae r, emipomae e
	 where e.no_poliza  = r.no_poliza
	   and r.no_reclamo = a_no_reclamo

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		select nombre,
			   cod_cober_reas
		  into _nom_cobertura,
			   _cod_cober_reas
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

		let _cnt_cober_reas = 0;

		select count(*)
		  into _cnt_cober_reas
		  from recreaco
		 where no_reclamo = _no_reclamo
		   and cod_cober_reas = _cod_cober_reas;

		select cod_ramo
		  into _cod_ramo_reas
		  from reacobre
		 where cod_cober_reas = _cod_cober_reas;

		if _cnt_cober_reas is null or _cnt_cober_reas = 0 then
			if _cod_ramo = _cod_ramo_reas then
				foreach
					select cod_ruta
					  into _cod_ruta
					  from rearumae
					 where cod_ramo = _cod_ramo
					   and vig_inic <= _fecha_reclamo
					   and vig_final >= _fecha_reclamo
					   and activo = 1
					 order by vig_inic desc
					exit foreach;
				end foreach

				--{
				if _vigencia_inic < '01/07/2014' then
					if _cod_ramo = '002' then
						let  _cod_ruta = '00487';
					elif _cod_ramo = '023' then
						let _cod_ruta = '00538';
					end if				
				end if
				--}

				delete from recreaco 
				 where no_reclamo = _no_reclamo;
				
				foreach
					select cod_contrato,
						   porc_partic_prima,
						   orden,
						   porc_partic_suma,
						   cod_cober_reas
					  into _cod_contrato,
						   _porc_partic_prima,
						   _orden,
						   _porc_partic_suma,
						   _cod_cober_reas_r
					  from rearucon
					 where cod_ruta = _cod_ruta

					insert into recreaco(
					no_reclamo,
					orden,
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima,
					cod_cober_reas)
					values(
					_no_reclamo,
					_orden,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima,
					_cod_cober_reas_r);
				end foreach
				
				call sp_sis119e(_no_reclamo) returning	_error,_error_desc;
				
				{
				return	_no_reclamo,
						_cod_ramo,
						_cod_cobertura,
						_nom_cobertura,
						_cod_cober_reas,
						_cod_ramo_reas,
						_cod_ruta,
						_cnt_fac,
						_fecha_reclamo	with resume;
				}

			end if

		end if

	end foreach

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure 