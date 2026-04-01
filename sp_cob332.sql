-- Procedimiento que carga los avisos de cancelación de un corredor por día
-- Creado    : 06/05/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob332;

create procedure sp_cob332(a_cod_agente char(5), a_fecha date)
returning	varchar(50),		--_nom_ramo,
			varchar(100),		--_nom_cliente,
			varchar(20),		--_no_documento,
			varchar(8),			--_vigencia_inic,
			varchar(8),			--_vigencia_final,
			varchar(100);		--_motivo_aviso

define _motivo_aviso		varchar(100);
define _nom_cliente			varchar(100);
define _nom_ramo			varchar(50);
define _no_documento	   	varchar(20);
define _error_desc			char(100);
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_ramo			char(3);
define _exigible			dec(16,2);
define _error_isam			integer;
define _error				integer;
define _vigencia_final 		char(8);
define _vigencia_inic 		char(8);


set isolation to dirty read;

--set debug file to "sp_cob332.trc";
--trace on;

{begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception}

let _cod_compania = '001';
let _cod_sucursal = '001';

foreach
	select distinct no_poliza
	  into _no_poliza
	  from avisocanc
	 where estatus			= 'I'
	   and fecha_imprimir	>= a_fecha
	   and cod_agente		= a_cod_agente
		
	select trim(no_documento),
		   to_char(vigencia_inic,"%Y%m%d"),
		   to_char(vigencia_final,"%Y%m%d"),
		   cod_ramo,
		   cod_pagador
	  into _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	select trim(nombre)
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select trim(nombre)
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_pagador;
	
	select exigible
	  into _exigible
	  from emipoliza
	 where no_documento = _no_documento;
	
	let _motivo_aviso = 'Se Emitio Aviso de Cancelación por Falta de Pago. Refleja atraso de: ' || _exigible;
	
	return	_nom_ramo,
			_nom_cliente,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_motivo_aviso
			with resume;
end foreach	
--end 
end procedure

