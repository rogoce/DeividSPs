-- Procedimiento que Determina el Reaseguro para un Cobro
-- 
-- Creado    : 02/08/2012 - Autor: Armando Moreno M.
-- Modificado: 02/08/2012 - Autor: Armando Moreno M.

drop procedure sp_sis171bk;
create procedure sp_sis171bk(a_no_remesa char(10), a_renglon smallint)
returning integer, char(250);

define _mensaje				char(250);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_coasegur		char(3);
define _cod_compania		char(3);
define _cod_ramo			char(3);
define _porcentaje			dec(7,4);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_suma	dec(9,6); 
define _porc_partic_reas	dec(9,6);
define _porc_proporcion		dec(9,6);
define _tipo_produccion		smallint;
define _contador_ret		smallint;
define _no_cambio			smallint;
define _ramo_sis			smallint;
define _renglon				smallint;
define _abierta				smallint;
define _orden				smallint;
define _cnt					smallint;
define _error				integer;
define _vigencia_final		date;
define _cod_grupo           char(5);

set isolation to dirty read;

delete from cobreafa 
 where no_remesa = a_no_remesa 
   and renglon = a_renglon;
   
delete from cobreaco 
 where no_remesa = a_no_remesa 
   and renglon = a_renglon;

--set debug file to "sp_sis171.trc";
--trace on;

-- lectura del detalle de la remesa

foreach
	select no_poliza,
		   renglon
	  into _no_poliza,
		   _renglon
	  from cobredet
	 where no_remesa  = a_no_remesa
	   and tipo_mov   in ('P','N')
	   and renglon = a_renglon
	   order by renglon

	select cod_tipoprod,
	       cod_ramo,
		   vigencia_final,
		   abierta,
		   cod_grupo
	  into _cod_tipoprod,
		   _cod_ramo,
		   _vigencia_final,
		   _abierta,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Reaseguro
	let _no_cambio = null;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para Esta Poliza, Por Favor Verifique ...';
		return 1, _mensaje;
	end if

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
	 
	-- contratos
	call sp_sis188(_no_poliza) returning _error,_mensaje;

	if _error <> 0 then
		--let _mensaje = trim(_mensaje) || ' la póliza: ' || trim(_no_documento) || ' en la requisicion: ' || trim (a_no_requis) || ', por favor verifique ...';
		return _error,_mensaje;
	end if
    if a_no_remesa = '2150013' and a_renglon in(2,4) then
		update tmp_dist_rea
		   set porc_cober_reas = 100;	   
	end if
	
	if _cod_grupo <> "77960" then	--Banisi
	
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
			  from emireaco
			 where no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and no_cambio      = _no_cambio

			select porc_cober_reas
			  into _porc_proporcion
			  from tmp_dist_rea
			 where cod_cober_reas = _cod_cober_reas;
			 
			if _porc_proporcion = 0.00 then -- Amado 29-08-2023
				continue foreach;
			end if	
		 
			insert into cobreaco(
					no_remesa,
					renglon,
					orden,
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima,
					subir_bo,
					cod_cober_reas,
					porc_proporcion)
			values(	a_no_remesa,
					_renglon,
					_orden,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima,
					1,
					_cod_cober_reas,
					_porc_proporcion);
		end foreach
	else
		call sp_sis171_banisi(_no_poliza,_no_cambio) returning _error,_mensaje;	---***BANISI
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
			  from tmp_emireaco
			 where no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and no_cambio      = _no_cambio

			select porc_cober_reas
			  into _porc_proporcion
			  from tmp_dist_rea
			 where cod_cober_reas = _cod_cober_reas;
			 
			if _porc_proporcion = 0.00 then -- Amado 29-08-2023
				continue foreach;
			end if	
		 
			insert into cobreaco(
					no_remesa,
					renglon,
					orden,
					cod_contrato,
					porc_partic_suma,
					porc_partic_prima,
					subir_bo,
					cod_cober_reas,
					porc_proporcion)
			values(	a_no_remesa,
					_renglon,
					_orden,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima,
					1,
					_cod_cober_reas,
					_porc_proporcion);
		end foreach
	end if

	drop table tmp_dist_rea;

	delete from cobreaco
	 where no_remesa         = a_no_remesa
	   and porc_partic_suma  = 0.00
	   and porc_partic_prima = 0.00;

	delete from cobreaco
	 where no_remesa       = a_no_remesa
	   and porc_proporcion is null;

	-- Facultativos
	foreach
		select cod_contrato,
			   orden,
			   cod_coasegur,
			   porc_partic_reas
		  into _cod_contrato,
			   _orden,
			   _cod_coasegur,
			   _porc_partic_reas
		  from emireafa
		 where no_poliza      = _no_poliza
		   and no_unidad      = _no_unidad
		   and no_cambio      = _no_cambio

		select count(*)
		  into _cnt
		  from cobreafa
		 where no_remesa = a_no_remesa
		   and renglon	 = _renglon
		   and cod_contrato	= _cod_contrato
		   and cod_coasegur	= _cod_coasegur;
		  --and orden	 = _orden

		if _cnt = 0 then
			insert into cobreafa(
					no_remesa,
					renglon,
					orden,
					cod_contrato,
					cod_coasegur,
					porc_partic_reas)
			values(	a_no_remesa,
					_renglon,
					_orden,
					_cod_contrato,
					_cod_coasegur,
					_porc_partic_reas);
		end if
	end foreach

 	foreach
		select sum(porc_partic_prima)
		  into _porcentaje
		  from cobreaco
		 where no_remesa = a_no_remesa
		 group by no_remesa,renglon,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
			return 1, _mensaje;
		end if
	end foreach
    
	let _cnt = 0;

	foreach
		select sum(porc_partic_suma)
		  into _porcentaje
		  from cobreaco
		 where no_remesa = a_no_remesa
		 group by no_remesa,renglon,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
			return 1, _mensaje;
		end if
		
		let _cnt = _cnt + 1;
	end foreach

	if _cnt = 1 then
		update cobreaco
		   set porc_proporcion = 100
		 where no_remesa = a_no_remesa
		   and renglon   = a_renglon;
	end if
	if (a_no_remesa = '2128026' And a_renglon = 1) then
		update cobreaco
		   set porc_proporcion = 100
		 where no_remesa = a_no_remesa
		   and renglon   = a_renglon;
	end if
	if (a_no_remesa = '1972582' And a_renglon = 7) then
		update cobreaco
		   set porc_partic_suma = 5.988316,
			   porc_partic_prima = 5.988316
		 where no_remesa = a_no_remesa
		   and renglon   = a_renglon
		   and orden = 5;
	end if
	-- verificacion para el facultativo
	select count(*)
	  into _contador_ret 
	  from cobreaco, reacomae
	 where cobreaco.no_remesa     = a_no_remesa
	   and cobreaco.cod_contrato  = reacomae.cod_contrato
	   and reacomae.tipo_contrato = 3; 
	 
	if _contador_ret is null then
		let _contador_ret = 0;
	end if 

	if _contador_ret <> 0 then
		select count(*)
		  into _contador_ret
		  from cobreafa
		 where no_remesa = a_no_remesa;

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
			  from cobreafa
			 where no_remesa = a_no_remesa
			 group by no_remesa,renglon

			if _porcentaje is null then
				let _porcentaje = 0;
			end if

			if _porcentaje <> 100 then
				let _mensaje = _no_poliza || ' Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
				return 1, _mensaje;
			end if
		end foreach
	end if

	-- verificacion de varias retenciones
	foreach
		select count(*) 
		  into _contador_ret 
		  from cobreaco, reacomae
		 where cobreaco.no_remesa     = a_no_remesa
		   and cobreaco.cod_contrato  = reacomae.cod_contrato
		   and reacomae.tipo_contrato = 1
		 group by cobreaco.no_remesa,cobreaco.renglon,cobreaco.cod_cober_reas	    
		 
		if _contador_ret is null then
			let _contador_ret = 0;
		end if 
		 
		if _contador_ret > 1 then
			let _mensaje = 'Existe Mas de Una Retencion ...';
			return 1, _mensaje;
		end if;
	end foreach
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end procedure;