-- Proceso que elimina las Renovaciones de Ducruet ( Soda) del Pool de Renovaciones que tengan 2 periodos de antiguedad 
-- Creado    : 25/04/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro376;

create procedure "informix".sp_pro376(a_compania char(3))
returning	char(20),		--_no_documento,
			char(5),		--_cod_agente,
			char(5),		--_num_carga,
			char(1),		--_opcion,
			smallint,		--_renglon,
			char(30),		--_no_motor
			date,			--_vigencia_inic
			char(20),		--_no_documento_dup
			char(5),		--_no_unidad_dup
			date;			--_vig_final_dup
		  
define _error_desc			char(50);
define _no_motor			char(30);
define _no_documento_dup	char(20);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _no_unidad_dup		char(5);		
define _cod_agente			char(5);
define _num_carga			char(5);
define _ano_char			char(4);
define _cod_ramo			char(3);
define _mes_char			char(2);
define _dia_char			char(2);
define _opcion				char(1);
define _mes					smallint;
define _ano					smallint;
define _dia					smallint;
define _renglon				integer;
define _error				integer;
define _vig_final_dup		date;
define _vigencia_inic		date;
define _fecha_hasta			date;
define _fecha_desde			date;
define _fecha_hoy			date;

--set debug file to "sp_pro376.trc";
--trace on;

set isolation to dirty read;

{begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception}

let _renglon = 0;
let _error = 0;
let _no_documento_dup = '';
let _vig_final_dup = '';
let _no_unidad_dup = '';

foreach
	{select distinct cod_agente,
		   num_carga,
		   proceso,
		   renglon
	  into _cod_agente,
		   _num_carga,
		   _opcion,
		   _renglon
	  from equierror
	 where campo = 'no_motor'}
	select no_documento,
		   no_motor,
		   vigencia_inic,
		   proceso,
		   cod_agente,
		   num_carga,
		   renglon
	  into _no_documento,
		   _no_motor,
		   _vigencia_inic,
		   _opcion,
		   _cod_agente,
		   _num_carga,
		   _renglon
	  from prdemielctdet
	 order by cod_agente
	   
	call sp_proe23('00000',_no_motor,_vigencia_inic) returning _error,_no_documento_dup,_vig_final_dup,_no_unidad_dup;
	
	if _error = 0 then
		continue foreach;
	end if
	
	if _no_documento_dup = _no_documento then
		continue foreach;
	end if
	
	update equierror
	   set proceso = _opcion
	 where cod_agente = _cod_agente
	   and num_carga	= _num_carga
	   and renglon		= _renglon;
	
	--let _cod_agente = '00270';
	return	_no_documento,
			_cod_agente,
			_num_carga,
			_opcion,
			_renglon,
			_no_motor,
			_vigencia_inic,
			_no_documento_dup,
			_no_unidad_dup,
			_vig_final_dup
			with resume;
end foreach
end procedure 