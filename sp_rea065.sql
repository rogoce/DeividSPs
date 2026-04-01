-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 29/01/2002 - Autor: Amado Perez M.

-- Adicion de la verif. de la ced. del Asegurado y Conductor; el motor, marca, modelo,
-- ano del auto y placa del vehiculo cuando es automovil.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rea065;
create procedure "informix".sp_rea065(a_no_reclamo char(10))
returning	integer,
			char(250);

define _mensaje				char(250);
define _cedula_aseg			char(30);
define _cedula_cond			char(30);
define _no_motor			char(30);
define _cod_asegurado		char(10);
define _cod_conductor		char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _placa				char(10);
define _cod_cober_prod		char(5);
define _cod_contrato		char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_tipoprod		char(3);
define _cod_compania		char(3);
define _no_cambio			char(3);
define _cod_ramo			char(3);
define _tipo_persona		char(1);
define _porcentaje			dec(7,4);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6);
define _porc_partic_reas	dec(9,6);
define _tipo_produccion		smallint;
define _ramo_sis			smallint;
define _contador_ret		smallint;
define _abierta				smallint;
define _ano_auto			smallint;
define _orden				smallint; 
define _incidente			integer;
define _error				integer;
define _vigencia_inic		date; 
define _fecha_siniestro		date; 
define _vigencia_final		date;
define _fecha_reclamo		date;
define _periodo             char(7);
define _cod_ruta            char(5);

set isolation to dirty read;

delete from recreafa where no_reclamo = a_no_reclamo;
delete from recreaco where no_reclamo = a_no_reclamo;

--set debug file to "sp_sis18.trc";
--trace on;

--Lectura del Reclamo
select no_unidad,
	   fecha_siniestro,
	   no_poliza,
	   cod_compania,
	   cod_asegurado,
	   cod_conductor,
	   no_motor,
	   incidente,
	   fecha_reclamo
  into _no_unidad,
	   _fecha_siniestro,
	   _no_poliza,
	   _cod_compania,
	   _cod_asegurado,
	   _cod_conductor,
	   _no_motor,
	   _incidente,
	   _fecha_reclamo
  from recrcmae
 where no_reclamo = a_no_reclamo;
 
 select cod_ramo,
		vigencia_inic
   into _cod_ramo,
	    _vigencia_inic
   from emipomae
  where no_poliza = _no_poliza;
  
{ if _cod_ramo = '002' then
	let _cod_ruta = '00595';
 elif _cod_ramo = '023' then
	let _cod_ruta = '00597';
 elif _cod_ramo = '020' then
	let _cod_ruta = '00596';
 end if}

select cod_ruta
  into _cod_ruta
  from rearumae
 where cod_ramo = _cod_ramo
   and _vigencia_inic between vig_inic and vig_final
   and activo = 1; 


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
		   _cod_cober_reas
	  from rearucon
	 where cod_ruta = _cod_ruta

	insert into recreaco(
		no_reclamo,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		cod_cober_reas,
		subir_bo)
	values(	a_no_reclamo,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima,
			_cod_cober_reas,1);
end foreach

delete from recreaco
 where no_reclamo        = a_no_reclamo
   and porc_partic_suma  = 0.00
   and porc_partic_prima = 0.00;


foreach
	select sum(porc_partic_prima)
	  into _porcentaje
	  from recreaco
	 where no_reclamo = a_no_reclamo
	 group by no_reclamo,cod_cober_reas

	if _porcentaje is null then
		let _porcentaje = 0;
	end if

	if _porcentaje <> 100 then
		let _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end foreach

foreach
	select sum(porc_partic_suma)
	  into _porcentaje
	  from recreaco
	 where no_reclamo = a_no_reclamo
	 group by no_reclamo,cod_cober_reas

	if _porcentaje is null then
		let _porcentaje = 0;
	end if

	if _porcentaje <> 100 then
		let _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
		return 1, _mensaje;
	end if
end foreach

--Verificacion para el Facultativo
select count(*)
  into _contador_ret 
  from recreaco, reacomae
 where recreaco.no_reclamo    = a_no_reclamo 
   and recreaco.cod_contrato  = reacomae.cod_contrato
   and reacomae.tipo_contrato = 3; 
 
if _contador_ret is null then
	let _contador_ret = 0;
end if 

if _contador_ret <> 0 then
	select count(*)
	  into _contador_ret
	  from recreafa
	 where no_reclamo = a_no_reclamo;

	if _contador_ret is null then
		let _contador_ret = 0; 
	end if

	if _contador_ret = 0 then
		let _mensaje = 'No Existe Distribucion de Facultativos, Por Favor Verifique ...';
		return 1, _mensaje;
	end if

	foreach
		select sum(porc_partic_reas)
		  into _porcentaje
		  from recreafa
		 where no_reclamo = a_no_reclamo
		 group by no_reclamo,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _mensaje = 'Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
			return 1, _mensaje;
		end if
	end foreach
end if

--Verificacion de Varias Retenciones
foreach
	select count(*) 
	  into _contador_ret 
	  from recreaco, reacomae
	 where recreaco.no_reclamo    = a_no_reclamo 
	   and recreaco.cod_contrato  = reacomae.cod_contrato
	   and reacomae.tipo_contrato = 1
	 group by recreaco.no_reclamo,recreaco.orden,recreaco.cod_cober_reas	    	    
	    
	 
	if _contador_ret is null then
		let _contador_ret = 0;
	end if 
	 
	if _contador_ret > 1 then
		let _mensaje = 'Existe Mas de Una Retencion ...';
		return 1, _mensaje;
	end if
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end procedure;