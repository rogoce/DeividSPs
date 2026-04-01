-- Procedimiento que Determina el Reaseguro para un Cheque de Devolución de Prima
-- 
-- Creado    : 06/09/2013 - Autor: Román Gordon


drop procedure sp_sis171a;

create procedure "informix".sp_sis171a(a_no_requis char(10))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _no_requis			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _porcentaje			dec(7,4);
define _porc_partic_prima	dec(9,6);
define _porc_partic_reas	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_proporcion		dec(9,6);
define _contador_ret		smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

delete from chqreafa where no_requis = a_no_requis;
delete from chqreaco where no_requis = a_no_requis;


--set debug file to "sp_sis171a.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis);
	--rollback work;
 	return _error,_mensaje;
end exception

let _no_documento = 'INDEFINIDA';
-- Lectura del detalle del Cheque
foreach with hold
	select no_poliza
	  into _no_poliza
	  from chqchpol
	 where no_requis  = a_no_requis
      order by no_requis
	--begin work;
	
	--let a_no_requis = _no_requis;
	
	-- Reaseguro
	let _no_cambio = null;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;
	
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para  la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
		return 1, _mensaje; -- with resume;
	end if

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
	   
	{select min(cod_cober_reas)
	  into _cod_cober_reas
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_cambio = _no_cambio;}
	call sp_sis188(_no_poliza) returning _error,_mensaje;
	
	if _error <> 0 then
		--rollback work;
		let _mensaje = trim(_mensaje) || ' la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
		return _error,_mensaje;
	end if
	
	-- Contratos
	foreach
		select cod_cober_reas,
			   cod_contrato,
			   porc_partic_prima,
			   orden,
			   porc_partic_suma
		  into _cod_cober_reas,
			   _cod_contrato,
			   _porc_partic_prima,
			   _orden,
			   _porc_partic_suma
		  from emireaco
		 where no_poliza      = _no_poliza
		   and no_unidad      = _no_unidad
		   and no_cambio      = _no_cambio
		
		select porc_cober_reas
		  into _porc_proporcion
		  from tmp_dist_rea
		 where cod_cober_reas = _cod_cober_reas;
		
		insert into chqreaco(
		no_requis,
		no_poliza,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		subir_bo,
		cod_cober_reas,
		porc_proporcion)
		values(
		a_no_requis,
		_no_poliza,
		_orden,
		_cod_contrato,
		_porc_partic_suma,
		_porc_partic_prima,
		1,
		_cod_cober_reas,
		_porc_proporcion);
	end foreach

	delete from chqreaco
	 where no_requis         = a_no_requis
	   and porc_partic_suma  = 0.00
	   and porc_partic_prima = 0.00;
	
	drop table tmp_dist_rea;
	
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
		   --and cod_cober_reas = _cod_cober_reas

		insert into chqreafa(
		no_requis,
		no_poliza,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas)
		values(
		a_no_requis,
		_no_poliza,
		_orden,
		_cod_contrato,
		_cod_coasegur,
		_porc_partic_reas);
	end foreach

	foreach
		select sum(porc_partic_prima)
		  into _porcentaje
		  from chqreaco
		 where no_requis = a_no_requis
		 group by no_requis,no_poliza,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _mensaje = 'Distribucion de Reaseguro de Prima No Suma 100% en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
			return 1, _mensaje; -- with resume;
		end if
	end foreach


	foreach
		select sum(porc_partic_suma)
		  into _porcentaje
		  from chqreaco
		 where no_requis = a_no_requis
		 group by no_requis,no_poliza,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _mensaje = 'Distribucion de Reaseguro de Suma No Suma 100% en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
			return 1, _mensaje; -- with resume;
		end if
	end foreach

	-- Verificacion para el Facultativo

	select count(*)
	  into _contador_ret 
	  from chqreaco c, reacomae r
	 where c.no_requis     = a_no_requis
	   and c.cod_contrato  = r.cod_contrato
	   and r.tipo_contrato = 3; 
	 
	if _contador_ret is null then
		let _contador_ret = 0;
	end if 

	if _contador_ret <> 0 then
		select count(*)
		  into _contador_ret
		  from chqreafa
		 where no_requis = a_no_requis;

		if _contador_ret is null then
			let _contador_ret = 0; 
		end if

		if _contador_ret = 0 then
			let _mensaje = 'No Existe Distribucion de Facultativos en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
			return 1, _mensaje; -- with resume;
		end if

		foreach
			select sum(porc_partic_reas)
			  into _porcentaje
			  from chqreafa
			 where no_requis = a_no_requis
			 group by no_requis,no_poliza

			if _porcentaje is null then
				let _porcentaje = 0;
			end if

			if _porcentaje <> 100 then
				let _mensaje = _no_poliza || ' Distribucion de Reaseguro de Facultativos No Suma 100% en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
				return 1, _mensaje; -- with resume;
			end if
	   end foreach
	end if

	-- verificacion de varias retenciones
	foreach
		select count(*) 
		  into _contador_ret 
		  from chqreaco c, reacomae r
		 where c.no_requis     = a_no_requis
		   and c.cod_contrato  = r.cod_contrato
		   and r.tipo_contrato = 1
		 group by c.no_requis,c.no_poliza,c.cod_cober_reas	    
		 
		if _contador_ret is null then
			let _contador_ret = 0;
		end if 
		 
		if _contador_ret > 1 then
			let _mensaje = 'Existe Mas de Una Retencion  en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
			return 1, _mensaje; --with resume;
		end if;
	end foreach
	
	--commit work;
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end
end procedure;
