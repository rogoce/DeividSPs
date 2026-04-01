-- Procedure para el Reporte de Morosidad de Pólizas con Adelanto de Comisión 
-- Creado     : 19/08/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob334;

create procedure "informix".sp_cob334(a_compania char(3), a_cod_agente char(255))
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
	drop table tmp_codigos;
	return _error,current,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,_error_desc,0.00,0.00,_error_isam,'','';
end exception

set isolation to dirty read;

--set debug file to "sp_cob334.trc";
--trace on;

let _nombre_cia = trim(sp_sis01(a_compania)); 
let _fecha = current;
let _periodo = sp_sis39(_fecha);

if a_cod_agente <> "*" then
	let _tipo = sp_sis04(a_cod_agente);  -- separa los valores del string en una tabla de codigos
end if

foreach
	select no_documento,
		   fecha,
		   comision_adelanto,
		   comision_saldo,
		   cod_agente,
		   no_recibo,
		   prima_suscrita,
		   prima_neta,
		   cant_pagos
	  into _no_documento,
		   _fecha_adelanto,
		   _comis_adelanto,
		   _comis_saldo,
		   _cod_agente,
		   _no_recibo,
		   _prima_suscrita,
		   _prima_neta,
		   _cant_pagos
	  from cobadeco
	 order by cod_agente

-- Filtro de Corredores
	if a_cod_agente <> "*" then
		if _tipo <> "E" then -- incluir los registros
			if _cod_agente not in (select codigo from tmp_codigos) then
				continue foreach;
			end if
		else		        -- excluir estos registros
			if _cod_agente in (select codigo from tmp_codigos) then
				continue foreach;
			end if
		end if
	end if
	
-- Información de la Póliza
	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_contratante
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select trim(nombre)
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	
-- Información del Corredor	
	select trim(nombre)
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select porc_comis_agt
	  into _porc_comis_agt
	  from emipoagt
	 where no_poliza = _no_poliza
	   and cod_agente = _cod_agente;
	   
-- Calculo de la Morosidad

	select sum(prima_neta)
	  into _monto
	  from cobremae m, cobredet d
	 where d.no_remesa = m.no_remesa
	   and d.no_poliza = _no_poliza
	   and d.tipo_mov in ('P','N','X')
	   and m.date_posteo >= _fecha_adelanto
	   and m.actualizado = 1;

	let _comision_devengada = _monto * (_porc_comis_agt / 100);
		   	
	let _comis_saldo_calc = _comis_adelanto - _comision_devengada;
	
	{update cobadeco
	   set comision_ganada = _comision_devengada,
		   comision_saldo  = _comis_saldo_calc
	 where no_documento = _no_documento;}

	call sp_cob245(
			 "001",
			 "001",	
			 _no_documento,
			 _periodo,
			 _fecha
			 ) returning _por_vencer,      
						 _exigible,         
						 _corriente,        
						 _monto_30,         
						 _monto_60,         
						 _monto_90,
						 _monto_120,
						 _monto_150,
						 _monto_180,
						 _saldo;
	let _monto_60 = _monto_60 +_monto_90 + _monto_120 + _monto_150 + _monto_180;
	
	return	_no_documento,		--1.
			_fecha_adelanto,	--2.
			_comis_adelanto,	--3.
			_comis_saldo,		--4.
			_por_vencer,		--5.
			_exigible,			--6.
			_corriente,			--7.
			_monto_30,			--8.
			_monto_60,			--9.
			_saldo,				--10.
			_nom_agente,		--11.
			_prima_suscrita,	--12.
			_prima_neta,		--13.
			_cant_pagos,		--14.	
			_nombre_cia,
			_nom_cliente
			with resume;
end foreach
--drop table tmp_codigos;
end
end procedure