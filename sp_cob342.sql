-- Procedure para el Reporte de Morosidad de Pólizas con Adelanto de Comisión 
-- Creado     : 19/08/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob342;

create procedure "informix".sp_cob342()
returning	char(21),		--1. _no_documento
			date,			--2. _fecha_adelanto
			dec(16,2),		--3. _comis_adelanto
			dec(16,2),		--4. _comis_saldo
			dec(16,2),		--5. _por_vencer
			dec(16,2),		--6. _exigible
			dec(16,2),		--7. _corriente
			dec(16,2),		--8. _monto_30
			dec(16,2),		--9. _monto_60
			dec(16,2),		--10. _saldo
			varchar(50),	--11. _nom_agente
			dec(16,2),		--12. _prima_suscrita
			dec(16,2),		--13. _prima_neta
			smallint,		--14. _cant_pagos
			varchar(50),	--15._nombre_cia
			varchar(100);	--16._nom_cliente

define _error_desc			varchar(100);
define _nom_cliente			varchar(100);
define _nombre_cia			varchar(50);
define _nom_agente			varchar(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _periodo				char(8);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo			char(3);
define _tipo				char(1);
define _comision_devengada	dec(16,2);
define _prima_suscrita		dec(16,2);
define _comis_adelanto		dec(16,2);
define _comis_saldo			dec(16,2);
define _prima_neta			dec(16,2);
define _corriente			dec(16,2);
define _monto_120			dec(16,2);
define _monto_150			dec(16,2);
define _monto_180			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _exigible			dec(16,2);
define _monto				dec(16,2);
define _saldo				dec(16,2);
define _por_vencer			dec(16,2);
define _comis_saldo_calc	dec(16,2);
define _porc_comis_agt		dec(5,2);
define _poliza_cancelada	smallint;
define _cant_pagos			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_adelanto		date;
define _fecha				date;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_isam,_error_desc;
end exception

set isolation to dirty read;

--set debug file to "sp_cob334.trc";
--trace on;

let _fecha = current;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if


foreach
	select no_documento
	  into _no_documento
	  from cobtacre

	call sp_sis21(_no_documento) returning _no_poliza;
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ('018') then
		continue foreach;
	end if

	call sp_cob33('001','001',_no_documento,_periodo,_fecha)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;
end foreach

end 
end procedure;