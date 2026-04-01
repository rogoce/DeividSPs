-- Procedimiento que Determina el Coaseguro y el Reaseguro para un Reclamo
-- 
-- Creado    : 07/11/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 29/01/2002 - Autor: Amado Perez M.

-- Adicion de la verif. de la ced. del Asegurado y Conductor; el motor, marca, modelo,
-- ano del auto y placa del vehiculo cuando es automovil.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119d2;
create procedure "informix".sp_sis119d2()
returning	char(20),	--1._no_documento
			date,
			char(10),	--2._no_reclamo
			date,		--3._fecha_reclamo,
			char(10),	--4._no_tranrec,
			date;		--5._fecha_transaccion;

define v_filtros			char(250);
define _mensaje				char(250);
define _no_documento		char(20);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _no_cambio			char(3);
define _cnt_cober_reas		smallint;
define _error				integer;
define _fecha_transaccion	date; 
define _vigencia_final		date;
define _fecha_reclamo		date;
define _vigencia_inic		date;

set isolation to dirty read;

--set debug file to "sp_sis119d.trc";
--trace on;
CALL sp_rec02('001','001', '2013-09','*','*','*','002;','*') RETURNING v_filtros;

--Lectura del Reclamo
foreach with hold
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
	  from recrcmae r, rectrmae t, tmp_sinis s
	 where s.no_reclamo = r.no_reclamo
	   and t.no_reclamo = r.no_reclamo
	   and r.actualizado = 1
	   and t.actualizado = 1
	   and s.seleccionado = 1
	   --and t.fecha < '05/07/2013'
	 order by t.fecha

	begin work;
	--Reaseguradoras
	let _no_cambio = null;
	
	select vigencia_inic
	  into _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;
	
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para Este Reclamo, Por Favor Verifique ...';
		return _mensaje,'01/01/1900','','01/01/1900','','01/01/1900' with resume;
		rollback work;
		continue foreach;
	end if

	select count(*)
	  into _cnt_cober_reas
	  from rectrrea
	 where no_tranrec = _no_tranrec
	   and cod_cober_reas = '031';

	if _cnt_cober_reas is null then
		let _cnt_cober_reas = 0;
	end if

	if _cnt_cober_reas > 0 then
		rollback work;
		continue foreach;
	end if
	
	call sp_sis58_ajuste(_no_tranrec) returning _error, _mensaje;
	
	if _error <> 0 then
		return	cast(_error as char(5)),
				'01/01/1900',
				_mensaje,
				'01/01/1900',
				_no_tranrec,
				'01/01/1900' with resume;
		rollback work;
		continue foreach;
	end if
	
	commit work;
	return _no_documento,
		   _vigencia_inic,
		   _no_reclamo,
		   _fecha_reclamo,
		   _no_tranrec,
		   _fecha_transaccion
	with resume;		   

	{insert into camrecreaco(
		no_poliza,
		no_unidad,
		no_reclamo,
		no_tranrec)
	values(	_no_poliza,
			_no_unidad,
			a_no_reclamo,null);}
end foreach
end procedure;