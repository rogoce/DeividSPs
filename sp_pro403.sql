-- Procedimiento que Busca las pólizas Emitidas desde la carga masiva de Pólizas
-- Creado    : 28/10/2011 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro403;

create procedure "informix".sp_pro403()
returning	char(21)		as Poliza,				--_no_documento,
			char(30)		as Motor,				--_no_motor,
			date			as Vigencia_Inicial,	--_vigencia_inic,
			date			as Vigencia_Final,		--_vigencia_final,
			varchar(100)	as Cliente,				--_nom_cliente,
			varchar(30)		as Cedula,				--_cedula,
			varchar(30)		as Pasaporte,			--_pasaporte,
			varchar(30)		as Ruc,					--_ruc,
			dec(16,2)		as Prima_Anual,			--_prima_sin_desc,
			dec(16,2)		as Porc_Descuento,		--_proc_descuento,
			dec(16,2)		as Descuento,			--_descuento,
			dec(16,2)		as Prima_Neta,			--_prima_neta,
			dec(16,2)		as Porc_Impuesto,		--_porc_impuesto,
			dec(16,2)		as Impuesto,			--_impuesto,
			dec(16,2)		as Prima_Bruta,			--_prima_bruta,
			date			as Fecha_Registro,		--_date_added,
			char(5)			as Carga,				--_num_carga,
			smallint		as Renglon,				--_renglon
			char(21)		as Poliza_Duplicada,	--_no_documento_m,
			date			as Vigencia_Duplicada,	--_vig_final_dup,
			char(5)			as Unidad_Duplicada;	--_no_unidad_dup

define _nom_cliente			varchar(100);
define _cliente_ape_seg		varchar(30);
define _cliente_nom			varchar(30);
define _cliente_ape			varchar(30);
define _pasaporte			varchar(30);
define _cedula				varchar(30);
define _ruc					varchar(30);
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
define _prima_sin_desc		dec(16,2);
define _proc_descuento		dec(16,2);
define _porc_impuesto		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _descuento			dec(16,2);
define _impuesto			dec(16,2);
define _monto_pagado		dec(16,2);
define _monto_endoso		dec(16,2);
define _monto				dec(16,2);
define _vigencia_final		date;
define _vig_final_dup		date;
define _vigencia_inic		date;
define _date_added			date;
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
{on exception set _error_code, _error_isam, _error_desc
 	return '',_error_code, _error_desc,'01/01/1900','01/01/1900','','','','01/01/1900',0;         
end exception}

foreach
	select distinct no_documento
	  into _no_documento
	  from prdemielctdet
	 where no_documento not in (select no_documento
								  from emipomae e, emipoagt a
								 where e.no_poliza = a.no_poliza
								   and a.cod_agente = '00035'
								   and e.cod_ramo in ('002','020')
								   and e.actualizado = 1
								   and e.fecha_impresion >= '22/09/2012')
	   and cod_agente = '00035'
	   and proceso = 'N'
	   and num_carga not in ('00307')
	 order by 1
	
	select max(num_carga)
	  into _num_carga
	  from prdemielctdet
	 where cod_agente = '00035'
	   and no_documento = _no_documento;

	let _cliente_ape_seg	= '';
	let _cliente_nom		= '';
	let _cliente_ape		= '';
	let _pasaporte			= '';
	let _no_motor			= '';
	let _cedula				= '';
	let _ruc				= '';
	let _renglon			= 0;
	let _prima_sin_desc		= 0.00;
	let _proc_descuento		= 0.00;
	let _porc_impuesto		= 0.00;
	let _prima_bruta		= 0.00;
	let _prima_neta			= 0.00;
	let _descuento			= 0.00;
	let _impuesto			= 0.00;
	let _vigencia_inic		= '01/01/1900';
	let _vigencia_final		= '01/01/1900';

	foreach
		select cliente_nom,
			   cliente_ape,
			   cliente_ape_seg,
			   cedula,
			   pasaporte,
			   ruc,
			   vigencia_inic,
			   vigencia_final,
			   no_motor,
			   num_carga,
			   renglon,
			   prima_sin_desc,
			   porc_impuesto,
			   porc_descuento,
			   prima_neta,
			   descuento,
			   tot_impuesto,
			   prima_bruta
		  into _cliente_nom,
			   _cliente_ape,
			   _cliente_ape_seg,
			   _cedula,
			   _pasaporte,
			   _ruc,
			   _vigencia_inic,
			   _vigencia_final,
			   _no_motor,
			   _num_carga,
			   _renglon,
			   _prima_sin_desc,
			   _porc_impuesto,
			   _proc_descuento,
			   _prima_neta,
			   _descuento,
			   _impuesto,
			   _prima_bruta
		  from prdemielctdet
		 where cod_agente = '00035'
		   and no_documento = _no_documento
		 order by num_carga desc
		exit foreach;
	end foreach

	if  _cliente_nom is null then
		let _cliente_nom = '';
	end if

	if _cliente_ape is null then
		let _cliente_ape = '';
	end if

	if _cliente_ape_seg is null then
		let _cliente_ape_seg = '';
	end if
	
	let _nom_cliente = trim(_cliente_nom) || ' ' || trim(_cliente_ape) || ' ' || trim(_cliente_ape_seg);
	
	select date_added
	  into _date_added
	  from prdemielect
	 where cod_agente = '00035'
	   and num_carga = _num_carga
	   and proceso = 'N';

	let _cnt = 0;
	let _no_documento_m = '';
	let _no_unidad_dup = '';
	let _vig_final_dup = '01/01/1900';
	
	call sp_proe23('00000',_no_motor,_vigencia_inic) returning _cnt,_no_documento_m,_vig_final_dup,_no_unidad_dup;
	
	if _cnt = 0 then
		let _vig_final_dup = '01/01/1900';
		let _no_unidad_dup = '00000';
	end if
	
	return	_no_documento,
			_no_motor,
			_vigencia_inic,
			_vigencia_final,
			_nom_cliente,
			_cedula,
			_pasaporte,
			_ruc,
			_prima_sin_desc,
			_proc_descuento,
			_descuento,
			_prima_neta,
			_porc_impuesto,
			_impuesto,
			_prima_bruta,
			_date_added,
			_num_carga,
			_renglon,
			_no_documento_m,
			_vig_final_dup,
			_no_unidad_dup with resume;
end foreach
end
end procedure 