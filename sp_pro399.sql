-- Procedimiento que carga los asientos del Proceso de NIIF de prima no devengada
-- Creado    : 06/08/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro399;

create procedure sp_pro399()
returning integer,
	      char(100);

define _error_desc			char(100);
define _cuenta				char(25);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _no_endoso			char(5);
define _centro_costo		char(3);
define _cod_ramo			char(3);
define _porc_comis_agt		dec(5,2);
define _comis_no_dev_agt_ac	dec(16,2);
define _comis_no_dev_agt	dec(16,2);
define _prima_no_dev		dec(16,2);
define _imp_no_dev			dec(16,2);
define _credito				dec(16,2);
define _debito				dec(16,2);
define _tipo_comp			smallint;
define _dias				smallint;
define _error_isam			integer;
define _sac_notrx			integer;
define _error				integer;
define _vigencia_final 		date;
define _vigencia_inic 		date;
define _fecha				date;

set isolation to dirty read;

--set debug file to "sp_pro399.trc";
--trace on;

begin

on exception set _error,_error_isam,_error_desc
  --rollback work;	
  return _error,_error_desc;
end exception

let _comis_no_dev_agt_ac = 0.00;
let _comis_no_dev_agt = 0.00;
let _prima_no_dev = 0.00;
let _imp_no_dev = 0.00;
let _credito = 0.00;
let _debito = 0.00;
let _sac_notrx = 0;
let _tipo_comp = 0;

foreach
	select no_poliza,
		   no_endoso,
		   fecha,
		   prima_no_devengada,
		   monto_rcnd_pri,
		   monto_rcnd_com,
		   monto_rcnd_imp,
		   monto_psnd_imp,
		   monto_psnd_com
	  into _no_poliza,
		   _no_endoso,
		   _fecha,
		   _prima_no_dev
	  from prdprinode
	 where sac_asientos = 0
	   and fecha = a_fecha
	   
--Busqueda del Centro de Costo
	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then
		let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza;
		return _error, _error_desc;
	end if
	
--Determinar el Tipo de Comprobante
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _cod_ramo in ("001", "003") then		
		let _tipo_comp = 10;				-- Incendio
	elif _cod_ramo in ("002", "020") then	
		let _tipo_comp = 11;				-- Autos
	elif _cod_ramo in ("008") then			
		let _tipo_comp = 12;				-- Fianzas
	elif _cod_ramo in ("004", "016", "018", "019") then	
		let _tipo_comp = 13;				-- Personas
	else
		let _tipo_comp = 14;				-- Patrimoniales
	end if

--Impuesto de 2% de Prima no Devengada	
	let _imp_no_dev = _prima_no_dev * 0.02;
	
	if _imp_no_dev <> 0.00 then
		let _debito  = 0.00;
		let _credito = 0.00;

		if _imp_no_dev >= 0.00 then
			let _debito  = _imp_no_dev;
		else
			let _credito = _imp_no_dev;
		end if

		let _cuenta    = sp_sis15('RGADRST', '01', _no_poliza); Falta saber como sacar la cuenta.
		call sp_par338(_cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha,_sac_notrx);		
	end if

--Comision de Corredores no Devengada
	foreach
		select porc_comis_agt
		  into _porc_comis_agt
		  from emipoagt
		 where no_poliza = _no_poliza

		let _comis_no_dev_agt = 0.00;
		let _comis_no_dev_agt = _porc_comis_agt * _prima_no_dev;
		let _comis_no_dev_agt_ac = _comis_no_dev_agt_ac + _comis_no_dev_agt;
	end foreach
	
	if _comis_no_dev_agt_ac <> 0.00 then
		let _debito  = 0.00;
		let _credito = 0.00;

		if _comis_no_dev_agt_ac >= 0.00 then
			let _debito  = _comis_no_dev_agt_ac;
		else
			let _credito = _comis_no_dev_agt_ac;
		end if

		let _cuenta    = sp_sis15('RGADRST', '01', _no_poliza); Falta saber como sacar la cuenta.
		call sp_par338(_cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha,_sac_notrx);
	end if
	
	if _prima_no_dev <> 0.00 then
		let _debito  = 0.00;
		let _credito = 0.00;

		if _prima_no_dev >= 0.00 then
			let _debito  = _prima_no_dev;
		else
			let _credito = _prima_no_dev;
		end if

		let _cuenta    = sp_sis15('RGADRST', '01', _no_poliza); Falta saber como sacar la cuenta.
		call sp_par338(_cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha,_sac_notrx);	
	end if	
end foreach
end
end procedure

