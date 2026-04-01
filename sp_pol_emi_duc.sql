-- Envios masivos de correos por prioridad de envio
-- Creado por :    Roman Gordon		 08/04/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pol_emi_duc;

create procedure "informix".sp_pol_emi_duc() 
returning	char(21),		--_no_documento,
			char(50),		--_no_motor,
			date,			--_vigencia_inic,
			date,			--_vigencia_final
			varchar(100),	--_nom_cliente,
			varchar(100),	--_cliente_ape,
			varchar(100),	--_cliente_ape_seg,
			varchar(30),	--_cedula,
			varchar(30),	--_ruc
			varchar(30),	--_pasaporte
			dec(16,2),		--_prima_sin_desc,
			dec(16,2),		--_porc_descuento,
			dec(16,2),		--_descuento,
			dec(16,2),		--_prima_neta,
			dec(16,2),		--_porc_impuesto,
			dec(16,2),		--_impuesto,
			dec(16,2),		--_prima_bruta,
			date,			--_fecha_registro,
			char(5),		--_num_carga,
			smallint,		--_renglon
			char(21),		--_no_documento_dup,
			date,			--_vig_final_dup,
			char(5),		--_no_unidad_dup
			char(1);		--_emitida
			
		  	

define _cliente_ape_seg		varchar(100);
define _nom_cliente			varchar(100);
define _cliente_ape			varchar(100);
define _pasaporte			varchar(30);
define _cedula				varchar(30);
define _ruc					varchar(30);
define _no_motor			char(50);
define _no_documento_dup	char(20);
define _no_documento		char(20);
define _enviado				char(20);
define _no_poliza			char(10);
define _no_unidad_dup		char(5);
define _num_carga			char(5);
define _emitida				char(1);
define _prima_sin_desc		dec(16,2);
define _porc_descuento		dec(16,2);
define _porc_impuesto		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _descuento			dec(16,2);
define _impuesto			dec(16,2);
define _renglon				smallint;
define _return				smallint;
define _vigencia_final		date;
define _fecha_registro		date;
define _vig_final_dup		date;
define _vigencia_inic		date;

set isolation to dirty read;
--set debug file to "sp_par319.trc";
--trace on;

foreach
	select distinct no_documento,
		   trim(no_motor),
		   vigencia_inic,
		   vigencia_final,
		   cliente_nom,
		   cliente_ape,
		   cliente_ape_seg,
		   cedula,
		   ruc,
		   pasaporte,
		   prima_sin_desc,
		   porc_descuento,
		   descuento,
		   prima_neta,
		   porc_impuesto,
		   tot_impuesto,
		   prima_bruta,
		   fecha_registro,
		   num_carga,
		   renglon
	  into _no_documento,
		   _no_motor,
		   _vigencia_inic,
		   _vigencia_final,
		   _nom_cliente,
		   _cliente_ape,
		   _cliente_ape_seg,
		   _cedula,
		   _ruc,
		   _pasaporte,
		   _prima_sin_desc,
		   _porc_descuento,
		   _descuento,
		   _prima_neta,
		   _porc_impuesto,
		   _impuesto,
		   _prima_bruta,
		   _fecha_registro,
		   _num_carga,
		   _renglon
	  from prdemielctdet
	 where cod_agente = '00035'
	   and proceso = 'N'
	
	call sp_sis21(_no_documento) returning _no_poliza;
	
	let _emitida = 'S';
	let _no_documento_dup	= '';
	let _vig_final_dup		= '01/01/1900';
	let _no_unidad_dup		= '';	
	
	if _no_poliza is null then
		let _emitida = 'N';
		let _return = 0;
		call sp_proe23('00000',_no_motor,_vigencia_inic) returning _return,_no_documento_dup,_vig_final_dup,_no_unidad_dup;
		
		if _return = 1 then
			let _emitida = 'M';
		end if
	end if
	
	return	_no_documento,
			_no_motor,
			_vigencia_inic,
			_vigencia_final,
			_nom_cliente,
			_cliente_ape,
			_cliente_ape_seg,
			_cedula,
			_ruc,
			_pasaporte,
			_prima_sin_desc,
			_porc_descuento,
			_descuento,
			_prima_neta,
			_porc_impuesto,
			_impuesto,
			_prima_bruta,
			_fecha_registro,
			_num_carga,
			_renglon,
			_no_documento_dup,
			_vig_final_dup,
			_no_unidad_dup,
			_emitida with resume;	
end foreach
end procedure
