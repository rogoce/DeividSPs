-- Procedimiento que Busca las pólizas Emitidas desde la carga masiva de Pólizas
-- Creado    : 28/10/2011 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro378;

create procedure "informix".sp_pro378()
returning	char(5)		as Carga,				--_num_carga
			integer		as Renglon,				--_renglon
			char(21)	as Poliza,				--_no_documento
			date		as Vigencia_Inicial,	--_vigencia_inic
			date		as Vigencia_Final,		--_vigencia_final
			char(30)	as No_Motor,			--_no_motor
			char(21)	as Poliza_Duplicada,	--_no_documento_m
			char(5)		as Unidad,				--_no_unidad_dup
			date		as Vigencia_Duplicada,	--_vigencia_final_dup
			smallint	as Actualizado;

define _descripcion			char(100);
define _mensaje				char(100);
define _error_desc			char(50);
define _no_motor			char(30);
define _no_documento_m		char(21);
define _no_documento		char(21);
define _no_remesa			char(10);
define _cod_agente			char(10);
define _no_poliza			char(10);
define _no_unidad_dup		char(5);
define _num_carga			char(5);
define _cod_formapag		char(3);
define _cod_endomov			char(3);
define _no_pagos			dec(16,2);
define _diferencia			dec(16,2);
define _monto_ult_factura	dec(16,2);
define _monto_descontado	dec(16,2);
define _monto_facturado		dec(16,2);
define _monto_devuelto		dec(16,2);
define _monto_cobrado		dec(16,2);
define _monto_pagado		dec(16,2);
define _monto_endoso		dec(16,2);
define _monto				dec(16,2);
define _vigencia_final		date;
define _vig_final_dup		date;
define _vigencia_inic		date;
define _actualizado			smallint;
define _cnt					smallint;
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;
define _fecha				date;

--set debug file to "sp_pro378.trc"; 
--trace on;

set isolation to dirty read;

begin
on exception set _error_code, _error_isam, _error_desc
 	return '',_error_code, _error_desc,'01/01/1900','01/01/1900','','','','01/01/1900',0;         
end exception

foreach
	select p.no_documento,
		   p.vigencia_inic,
		   p.vigencia_final,
		   p.no_motor,
		   p.num_carga,
		   p.renglon,
		   e.actualizado
	  into _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _no_motor,
		   _num_carga,
		   _renglon,
		   _actualizado
	  from prdemielctdet p
	  left join emipomae e
		on p.no_documento = e.no_documento
	 where p.cod_agente = '00035'
	   and p.proceso = 'N'
	   and p.actualizado = 1
	   and (e.no_documento is null or e.actualizado = 0)
	 order by 2
	
	let _cnt = 0;
	let _no_documento_m = '';
	
	call sp_proe23('00000',_no_motor,_vigencia_inic) returning _cnt,_no_documento_m,_vig_final_dup,_no_unidad_dup;
	
	if _cnt = 0 then
		let _vig_final_dup = '01/01/1900';
		let _no_unidad_dup = '00000';
	end if
	
	{select count(*)
	  into _cnt
	  from emiauto
	 where no_motor = _no_motor;
	
	if _cnt is null then
		let _cnt = 0;
	end if
	
	let _no_documento_m = '';
	if _cnt > 0 then
		foreach
			select no_poliza
			  into _no_poliza
			  from emiauto
			 where no_motor = _no_motor
			 order by no_poliza desc

			exit foreach;
		end foreach
		
		select no_documento
		  into _no_documento_m
		  from emipomae
		 where no_poliza = _no_poliza;
	end if}
	
	return	_num_carga,
			_renglon,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_no_motor,
			_no_documento_m,
			_no_unidad_dup,
			_vig_final_dup,
			_actualizado with resume;
end foreach
end
end procedure 