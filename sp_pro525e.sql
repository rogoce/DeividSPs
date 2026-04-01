-- Inserta en emiletra las pólizas que no tengan registros.
-- Creado    : 20/12/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro525e;

create procedure sp_pro525e()
returning	int,
			char(50),
			dec(16,2);

define _error_desc		char(50);
define _no_documento	char(20);
define _documento		char(10);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_endoso		char(5);
define _tipo_doc		char(1);
define _monto_pendiente	dec(16,2);
define _prima_emipomae	dec(16,2);
define _monto_pagado	dec(16,2);
define _monto_letra		dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_orig		dec(16,2);
define _prima_acum		dec(16,2);
define _cnt_endoso		smallint;
define _cnt_flag		smallint;
define _renglon			smallint;
define _flag			smallint;
define _fecha_emision	date;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_movimiento;
	let _error_desc = 'Poliza: ' || trim(_no_poliza) || trim(_error_desc);
	rollback work;
	return _error, _error_desc,0.00;
end exception

--set debug file to "sp_pro525e.trc";
--trace on;

create temp table tmp_movimiento (
no_documento	char(20),
no_poliza		char(10),
documento		char(10),
renglon			smallint,
fecha			date,
tipo			char(1),
prima			dec(16,2),
flag			char(1),
diferencia		dec(16,2),
primary key (no_poliza, documento,renglon)) with no log;

let _no_poliza = '';

foreach with hold
	select distinct l.no_documento
	  into _no_documento
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2014'))
	   --and e.cod_ramo = '018'
	   --and l.no_poliza = '835398'
	   --and fecha_impresion >= '01/01/2000'
	   --and fecha_impresion <= '01/01/2010'
	 order by 1

	begin work;
	
	select sum(monto_letra),
		   sum(monto_pag),
		   sum(monto_pen)
	  into _monto_letra,
		   _monto_pagado,
		   _monto_pendiente
	  from emiletra
	 where no_documento = _no_documento;
	
	let _no_endoso = '';
	let _no_remesa = '';
	let _renglon = 0;
	
	foreach
		select no_poliza,
			   no_endoso,
			   fecha_emision,
			   prima_bruta
		  into _no_poliza,
			   _no_endoso,
			   _fecha_emision,
			   _prima_bruta
		  from endedmae
		 where no_documento = _no_documento
		   and actualizado = 1
		   and activa = 1
		   --and cod_endomov <> '014'
		 order by fecha_emision

		insert into tmp_movimiento
		values(_no_documento,_no_poliza,_no_endoso,0,_fecha_emision,'E',_prima_bruta,'',0.00);
	end foreach
	
	foreach
		select d.no_remesa,
			   d.renglon,
			   d.no_poliza,
			   m.date_posteo,
			   d.monto
		  into _no_remesa,
			   _renglon,
			   _no_poliza,
			   _fecha_emision,
			   _prima_bruta
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and d.doc_remesa = _no_documento
		   and m.actualizado = 1
		   and m.tipo_remesa in ('A','M','C','J','H','T','B','F')
		   and d.tipo_mov in ('P','N','X')
		 order by date_posteo
		
		insert into tmp_movimiento
		values(_no_documento,_no_poliza,_no_remesa,_renglon,_fecha_emision,'C',_prima_bruta,'',0.00);
	end foreach

	let _prima_bruta = 0.00;
	let _prima_acum = 0.00;
	let _flag = 0;
{
	select count(*)
	  into _cnt_endoso
	  from tmp_movimiento
	 where no_poliza = _no_poliza
	   and documento <> '00000'
	   and tipo = 'E';

	if _cnt_endoso is null then
		let _cnt_endoso = 0;
	end if
	
	if _cnt_endoso = 0 then
		
		select prima
		  into _prima_orig
		  from tmp_movimiento
		 where no_poliza = _no_poliza
		   and documento = '00000'
		   and tipo = 'E';
		
		select prima_bruta
		  into _prima_emipomae
		  from emipomae
		 where no_poliza = _no_poliza;

		if _prima_orig <> _prima_emipomae then
			update tmp_movimiento
			   set prima = _prima_emipomae
			 where no_poliza = _no_poliza
			   and documento = '00000'
			   and tipo = 'E';
		end if
	end if
}
	foreach
		select tipo,
			   sum(prima)
		  into _tipo_doc,
			   _prima_bruta
		  from tmp_movimiento
		 where no_documento = _no_documento
		 group by tipo

		if _tipo_doc = 'E' and _prima_bruta <> _monto_letra then
			update tmp_movimiento
			   set flag = 'E',
				   diferencia = _prima_bruta - _monto_letra
			 where no_poliza = _no_poliza;

			let _flag = 1;
			return 1,'no_poliza: ' || trim(_no_poliza) || ' E', _prima_bruta - _monto_letra with resume;
		elif _tipo_doc = 'C' and _prima_bruta <> _monto_pagado then
			update tmp_movimiento
			   set flag = 'C',
				   diferencia = _prima_bruta - _monto_pagado
			 where no_poliza = _no_poliza;
			 
			let _flag = 1;
			return 1,'no_poliza: ' || trim(_no_poliza) || ' C', _prima_bruta - _monto_pagado with resume;
		else
			let _prima_acum = _prima_acum + _prima_bruta;
		end if
	end foreach
	
	delete from tmp_movimiento
	 where no_poliza = _no_poliza
	   and flag = '';
	
	select count(*)
	  into _cnt_flag
	  from tmp_movimiento
	 where no_poliza = _no_poliza;

	if _cnt_flag is null then
		let _cnt_flag = 0;
	end if
	
	if _cnt_flag <> 0 then
		--call sp_pro525f(_no_poliza) returning _error,_error_desc;
		call sp_pro545(_no_documento) returning _error,_error_desc;

		if _error <> 0 then
			drop table tmp_movimiento;
			rollback work;
			return _error, _error_desc,0.00;
		else
			select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza = _no_poliza;

			call sp_cob346a(_no_documento) returning _error,_error_desc;

			if _error <> 0 then
				drop table tmp_movimiento;
				rollback work;
				return _error, _error_desc,0.00;
			end if

			call sp_pro544(_no_documento) returning _error,_error_desc;

			if _error <> 0 then
				drop table tmp_movimiento;
				rollback work;
				return _error, _error_desc,0.00;
			end if
		end if
	end if

	delete from tmp_movimiento;
	commit work;
end foreach
end

--drop table tmp_movimiento;
return 0, "Actualizacion Exitosa",0.00;
end procedure
