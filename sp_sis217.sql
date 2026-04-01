-- Procedimiento que genera las pólizas vencidas o por vencer a una fecha especifica
-- creado: 08/10/2015 - autor: Román Gordón

drop procedure sp_sis217;

create procedure "informix".sp_sis217()
returning	varchar(50)	as Cliente,
			char(20)	as Poliza,
			date		as Vigencia_Inicial,
			date		as Vigencia_Final,
			dec(16,2)	as Prima_Bruta,
			dec(16,2)	as Saldo,
			smallint	as No_Pagos,
			date		as Fecha_Proceso_Renov,
			date		as Fecha_Aviso_Cancelacion,
			date		as Fecha_Ult_Pago,
			varchar(50)	as Motivo_No_Renovacion,
			varchar(50)	as Sucursal,
			varchar(50)	as Ramo,
			varchar(50)	as Forma_de_Pago,
			varchar(50)	as Corredor,
			varchar(50)	as Tipo_Produccion,
			integer		as Dias_Vencida;

define _nom_no_renovacion	varchar(50);
define _tipo_produccion		varchar(50);
define _nom_formapag		varchar(50);
define _nom_sucursal		varchar(50);
define _nom_cliente			varchar(50);
define _nom_agente			varchar(50);
define _nom_ramo			varchar(50);
define _error_desc			char(100);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _new_no_poliza		char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_no_renov		char(3);
define _cod_sucursal		char(3);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_ramo			char(3);
define _prima_bruta			dec(16,2);
define _saldo				dec(16,2);
define _dias_vencida		integer;
define _error_isam			integer;
define _error				integer;
define _fecha_aviso_canc	date;
define _fecha_ult_pago		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_renov			date;
define _fecha_hoy			date;
define _no_pagos			smallint;

on exception set _error, _error_isam, _error_desc
	return _error_desc,'','01/01/1900','01/01/1900',0.00,0.00,_error,'01/01/1900','01/01/1900','01/01/1900','','','','','','',0;
end exception

set isolation to dirty read;
begin

let _fecha_hoy = current;

foreach
	select no_poliza,
		   cod_contratante,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   prima_bruta,
		   no_pagos,
		   fecha_renov,
		   fecha_aviso_canc,
		   fecha_ult_pago,
		   cod_no_renov,
		   cod_sucursal,
		   cod_ramo,
		   cod_formapag,
		   cod_tipoprod
	  into _no_poliza,
		   _cod_contratante,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _no_pagos,
		   _fecha_renov,
		   _fecha_aviso_canc,
		   _fecha_ult_pago,
		   _cod_no_renov,
		   _cod_sucursal,
		   _cod_ramo,
		   _cod_formapag,
		   _cod_tipoprod
	  from emipomae
	 where cod_ramo in ('002','023')
	   and actualizado = 1
	   and renovada = 0
	   and ((estatus_poliza = 3 and today - vigencia_final <= 30)
		or (estatus_poliza = 1 and vigencia_final <= '31/10/2015'))
	 order by cod_ramo,vigencia_inic

	let _new_no_poliza = sp_sis21(_no_documento);
	
	if _new_no_poliza <> _no_poliza then
		return	'No es la última Vigencia',
				_no_documento,
				'01/01/1900',
				'01/01/1900',
				0.00,
				0.00,
				0,
				'01/01/1900',
				'01/01/1900',
				'01/01/1900',
				_no_poliza,
				_new_no_poliza,
				'',
				'',
				'',
				'',
				0 with resume;
		continue foreach;
	end if
	
	call sp_cob115b('001',"",_no_documento,"") returning _saldo;

	let _dias_vencida = _fecha_hoy - _vigencia_final;

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

	select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	select nombre
	  into _nom_no_renovacion
	  from eminoren
	 where cod_no_renov = _cod_no_renov;

	if _nom_no_renovacion is null then
		let _nom_no_renovacion = '';
	end if

	select descripcion
	  into _nom_sucursal
	  from insagen
	 where codigo_agencia = _cod_sucursal;

	return _nom_cliente,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _saldo,
		   _no_pagos,
		   _fecha_renov,
		   _fecha_aviso_canc,
		   _fecha_ult_pago,
		   _nom_no_renovacion,
		   _nom_sucursal,
		   _nom_ramo,
		   _nom_formapag,
		   _nom_agente,
		   _tipo_produccion,
		   _dias_vencida with resume;
end foreach

end
end procedure;