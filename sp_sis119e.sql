-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 29/01/2002 - Autor: Amado Perez M.

-- Adicion de la verif. de la ced. del Asegurado y Conductor; el motor, marca, modelo,
-- ano del auto y placa del vehiculo cuando es automovil.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119e;
create procedure sp_sis119e(a_no_reclamo char(10))
returning	integer,
			char(250);		--5._fecha_transaccion;

define _mensaje				char(250);
define _no_documento		char(20);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _no_cambio			char(3);
define _cnt_cober_reas		smallint;
define _cnt_dist			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_transaccion	date; 
define _vigencia_final		date;
define _fecha_reclamo		date;
define _vigencia_inic		date;

set isolation to dirty read;

--set debug file to "sp_sis119d.trc";
--trace on;
begin
on exception set _error,_error_isam,_mensaje
	return _error, "Error al Generar el Reaseguro de la Transaccion";
end exception

--Lectura del Reclamo
foreach
	select r.no_reclamo,
		   r.fecha_reclamo,
		   t.no_tranrec,
		   r.no_poliza,
		   r.no_documento,
		   r.no_unidad,
		   t.fecha
	  into _no_reclamo,
		   _fecha_reclamo,
		   _no_tranrec,
		   _no_poliza,
		   _no_documento,
		   _no_unidad,
		   _fecha_transaccion		   
	  from recrcmae r, rectrmae t, emipomae e
	 where t.no_reclamo = r.no_reclamo
	   and e.no_poliza = r.no_poliza
	   and e.cod_ramo in('002','023')
	   and t.periodo >= '2013-07'
	   and r.actualizado = 1
	   and t.actualizado = 1
	   and r.no_reclamo = a_no_reclamo
	 order by t.fecha

	--begin work;
	--Reaseguradoras
	let _no_cambio = null;
		
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
		let _error = -1;
		return _error,_mensaje;
	end if

	select count(*)
	  into _cnt_cober_reas
	  from rectrrea
	 where no_tranrec = _no_tranrec
	   and cod_cober_reas in('031','034');

	if _cnt_cober_reas is null then
		let _cnt_cober_reas = 0;
	end if

	if _cnt_cober_reas > 0 then
		continue foreach;
	end if
	
	call sp_sis58_ajuste(_no_tranrec) returning _error, _mensaje;
	
	if _error <> 0 then
		return	_error,
				_mensaje;
	end if
	
	{if _cnt_dist = 0 then
		insert into tmp_dist_tranrec(no_documento,no_reclamo,no_tranrec)
		values (_no_documento,_no_reclamo,_no_tranrec);
	end if}
	
	--commit work;
end foreach

return 0,'Actualización Exitosa';
end		   
end procedure;