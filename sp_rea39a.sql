--------------------------------------------
--Procedure que Cambia los contratos 2017 de reaseguro de Auto, Auto Flota y Soda 
--execute procedure sp_rea39()
--25/03/2017 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea39a;
create procedure sp_rea39a(a_no_poliza char(10))
returning	smallint		as code_error,
			varchar(150)	as error_desc;

define _error_desc2			varchar(100);
define _error_desc			varchar(100);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _no_remesa			char(10);
define _cod_contrato_n		char(5);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _cnt_cober_reas		smallint;
define _tipo_contrato		smallint;
define _max_no_cambio		smallint;		
define _ramo_sis			smallint;		
define _renglon				smallint;		
define _serie				smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea39a.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc2
    --rollback work;
	let _error_desc = _error_desc || _error_desc2;
	
	return	_error,_error_desc;
end exception  

set isolation to dirty read;

--begin work;

select cod_ramo,
	   vigencia_inic
  into _cod_ramo,
	   _vigencia_inic
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis <> 1 then
	return 1,'Póliza no es Auto';
	--commit work;
	--continue foreach;
end if

select cod_ruta,
	   serie
  into _cod_ruta,
	   _serie
  from rearumae
 where cod_ramo = _cod_ramo
   and _vigencia_inic between vig_inic and vig_final
   and activo = 1;

update emipomae
   set serie = _serie
 where no_poliza = a_no_poliza;

let _error_desc = 'Ciclo Emireaco';

foreach
	select distinct no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

	select max(no_cambio)
	  into _max_no_cambio
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	if _max_no_cambio is null then
		let _max_no_cambio = 0;
	end if

	delete emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad
	   and no_cambio = _max_no_cambio;

	foreach
		select cod_cober_reas,
			   cod_contrato,
			   orden,
			   porc_partic_suma,
			   porc_partic_prima
		  into _cod_cober_reas,
			   _cod_contrato,
			   _orden,
			   _porc_partic_suma,
			   _porc_partic_prima
		  from rearucon
		 where cod_ruta = _cod_ruta
		 order by cod_cober_reas,orden

		let _cnt_cober_reas = 0;

		select count(*)
		  into _cnt_cober_reas
		  from emireama
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas;

		if _cnt_cober_reas is null then
			let _cnt_cober_reas = 0;
		end if

		if _cnt_cober_reas > 0 then
			insert into emireaco(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					orden,
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima)
			values(	a_no_poliza,
					_no_unidad,
					_max_no_cambio,
					_cod_cober_reas,
					_orden,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima);
		end if
	end foreach
end foreach

let _error_desc = 'Ciclo Endosos';
foreach
	select no_endoso
	  into _no_endoso
	  from endedmae
	 where no_poliza = a_no_poliza

	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = _no_endoso

		update endeduni
		   set cod_ruta = _cod_ruta
		 where no_poliza = a_no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		{delete from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;}
		foreach
			select cod_cober_reas,
				   cod_contrato
			  into _cod_cober_reas,
				   _cod_contrato
			  from emifacon
			 where no_poliza = a_no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			select r.cod_contrato
			  into _cod_contrato_n
			  from rearucon r, reacomae c
			 where c.cod_contrato = r.cod_contrato
			   and cod_ruta = _cod_ruta
			   and cod_cober_reas = _cod_cober_reas
			   and tipo_contrato = _tipo_contrato;

			update emifacon
			   set cod_contrato = _cod_contrato_n,
				   cod_ruta = _cod_ruta
			 where no_poliza = a_no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato = _cod_contrato;
		end foreach --Ciclo emifacon
	end foreach --Ciclo endeduni
end foreach --Ciclo endedmae

let _error_desc = 'Ciclo Cobreaco';
foreach
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from cobredet
	 where no_poliza = a_no_poliza

	foreach
		select cod_cober_reas,
			   cod_contrato
		  into _cod_cober_reas,
			   _cod_contrato
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon = _renglon

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		select r.cod_contrato
		  into _cod_contrato_n
		  from rearucon r, reacomae c
		 where c.cod_contrato = r.cod_contrato
		   and cod_ruta = _cod_ruta
		   and cod_cober_reas = _cod_cober_reas
		   and tipo_contrato = _tipo_contrato;

		update cobreaco
		   set cod_contrato = _cod_contrato_n
		 where no_remesa = _no_remesa
		   and renglon = _renglon
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato = _cod_contrato;
	end foreach --Ciclo cobreaco
end foreach --Ciclo cobredet

let _error_desc = 'Ciclo Reclamos';
foreach
	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where no_poliza = a_no_poliza

	foreach
		select cod_cober_reas,
			   cod_contrato
		  into _cod_cober_reas,
			   _cod_contrato
		  from recreaco
		 where no_reclamo = _no_reclamo

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		select r.cod_contrato
		  into _cod_contrato_n
		  from rearucon r, reacomae c
		 where c.cod_contrato = r.cod_contrato
		   and cod_ruta = _cod_ruta
		   and cod_cober_reas = _cod_cober_reas
		   and tipo_contrato = _tipo_contrato;

		update recreaco
		   set cod_contrato = _cod_contrato_n
		 where no_reclamo = _no_reclamo
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato = _cod_contrato;
	end foreach --Ciclo recreaco

	foreach
		select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where no_reclamo = _no_reclamo

		foreach
			select cod_cober_reas,
				   cod_contrato
			  into _cod_cober_reas,
				   _cod_contrato
			  from rectrrea
			 where no_tranrec = _no_tranrec

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			select r.cod_contrato
			  into _cod_contrato_n
			  from rearucon r, reacomae c
			 where c.cod_contrato = r.cod_contrato
			   and cod_ruta = _cod_ruta
			   and cod_cober_reas = _cod_cober_reas
			   and tipo_contrato = _tipo_contrato;

			update rectrrea
			   set cod_contrato = _cod_contrato_n
			 where no_tranrec = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato = _cod_contrato;
		end foreach --Cliclo rectrrea
	end foreach --Ciclo rectrmae
end foreach --Ciclo recrcmae

let _error_desc = 'Ciclo Cheques';

foreach
	select distinct no_requis,
		   cod_cober_reas,
		   cod_contrato
	  into _no_requis,
		   _cod_cober_reas,
		   _cod_contrato
	  from chqreaco
	 where no_poliza = a_no_poliza

	select tipo_contrato
	  into _tipo_contrato
	  from reacomae
	 where cod_contrato = _cod_contrato;

	select r.cod_contrato
	  into _cod_contrato_n
	  from rearucon r, reacomae c
	 where c.cod_contrato = r.cod_contrato
	   and cod_ruta = _cod_ruta
	   and cod_cober_reas = _cod_cober_reas
	   and tipo_contrato = _tipo_contrato;

	update chqreaco
	   set cod_contrato = _cod_contrato_n
	 where no_requis = _no_requis
	   and no_poliza = a_no_poliza
	   and cod_cober_reas = _cod_cober_reas
	   and cod_contrato = _cod_contrato;
end foreach --Ciclo chqreaco

--commit work;
return 0,'Actualización Exitosa';
end
end procedure;