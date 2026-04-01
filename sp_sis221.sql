----------------------------------------------------------
-- Reporte de Provisión de Reaseguro por Reasegurador
-- Creado    : 21/08/2015 - Autor: Román Gordón
----------------------------------------------------------
--execute procedure sp_sis221('2015-12')

drop procedure sp_sis221;
create procedure sp_sis221(a_periodo char(7))
returning	char(21)	as Poliza,				--_no_documento
			varchar(10)	as Estatus_Poliza,		--_estatus
			date		as Vigencia_Inicial,	--_vigencia_inic
			date		as Vigencia_Final,		--_vigencia_final
			char(5)		as Unidad,				--_no_unidad
			dec(16,2)	as Saldo,				--_saldo_255
			varchar(50)	as Cobertura_Reas,		--_nom_cober_reas
			varchar(50)	as Contrato,			--_nom_contrato
			smallint	as Serie,				--_serie
			varchar(50)	as Reasegurador,		--_nom_coasegur
			dec(9,6)	as Porc_Partic_Reas,	--_porc_cont_partic
			dec(5,2)	as Porc_Comision_Reas,	--_porc_comision
			dec(16,2)	as Comision_Reas,		--_comis_coasegur
			dec(16,2)	as Impuesto_Reas,		--_impuesto_coasegur
			dec(16,2)	as Monto_Neto,			--_saldo_reaseg;
			varchar(50)	as Ramo;				--_nom_ramo


define _error_desc			varchar(255);
define _nom_cober_reas		varchar(50);
define _nom_contrato		varchar(50);
define _nom_coasegur		varchar(50);
define _nom_agente			varchar(50);
define _nom_ramo			varchar(50);
define _estatus				varchar(10);
define _no_documento		char(21);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_ramo			char(3);
define _impuesto_coasegur	dec(16,2);
define _porc_partic_reas	dec(16,2);
define _comis_coasegur		dec(16,2);
define _saldo_reaseg		dec(16,2);
define _saldo_neto			dec(16,2);
define _saldo_255			dec(16,2);
define _porc_cont_partic	dec(9,6); 
define _porc_partic_agt		dec(5,2); 
define _porc_comis_agt		dec(5,2); 
define _porc_comision		dec(5,2); 
define _estatus_poliza		smallint;
define _contrato_xl			smallint;
define _serie				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_cancelacion	date;
define _vigencia_final		date;
define _vigencia_inic		date;


set isolation to dirty read;


{on exception set _error,_error_isam,_error_desc
	return '','','01/01/1900','01/01/1900',0.00,'',_error_desc,_error,'',0.00,0.00,0.00,0.00,0.00;
end exception}

--set debug file to "sp_sis221.trc"; 
--trace on;  

foreach
	select no_poliza,
		   no_documento,
		   no_unidad,
		   cod_cober_reas,
		   cod_contrato,
		   cod_coasegur,
		   sum(saldo_tot),
		   sum(saldo_actual),
		   sum(comision),
		   sum(impuesto)
	  into _no_poliza,
		   _no_documento,
		   _no_unidad,
		   _cod_cober_reas,
		   _cod_contrato,
		   _cod_coasegur,
		   _saldo_neto,
		   _saldo_reaseg,
		   _comis_coasegur,
		   _impuesto_coasegur
	  from rea_saldo2
	 where periodo = a_periodo
	   and saldo_tot <> 0
	 group by no_documento,no_poliza,no_unidad,cod_cober_reas,cod_contrato,cod_coasegur
	 order by no_documento,no_poliza,cod_cober_reas,cod_contrato,cod_coasegur

	--let _saldo_255 = _saldo_neto * (_porc_partic_reas/100); 

	select vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   fecha_cancelacion,
		   cod_ramo
	  into _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _fecha_cancelacion,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _fecha_cancelacion is null then
		let _fecha_cancelacion = '';
	end if

	select nombre
	  into _nom_coasegur
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _contrato_xl = 0;

	if _cod_contrato = '00000' then --Participación de Coaseguro
		let _nom_contrato = 'Participación Coaseguro';
		let _porc_cont_partic = 0.00;
		let _porc_comision = 0.00;
	else
		select nombre,
			   serie
		  into _nom_contrato,
			   _serie
		  from reacomae
		 where cod_contrato = _cod_contrato;

		select porc_cont_partic,
			   porc_comision,
			   contrato_xl
		  into _porc_cont_partic,
			   _porc_comision,
			   _contrato_xl
		  from reacoase
		 where cod_contrato = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas
		   and cod_coasegur = _cod_coasegur;

		if _contrato_xl = 1 then
			let _saldo_reaseg = 0.00;
			let _comis_coasegur = 0.00;
			let _impuesto_coasegur = 0.00;
		end if
	end if

	select nombre
	  into _nom_cober_reas
	  from reacobre
	 where cod_cober_reas = _cod_cober_reas;

	let _estatus = '';

	if _estatus_poliza = 1 then
		let _estatus = 'VIGENTE';
	elif _estatus_poliza = 2 then
		let _estatus = 'CANCELADA';
	elif _estatus_poliza = 3 then
		let _estatus = 'VENCIDA';
	elif _estatus_poliza = 4 then
		let _estatus = 'ANULADA';
	end if

	return	_no_documento,		--  1
			_estatus,			--  2
			_vigencia_inic,		--  3
			_vigencia_final,	--  4
			_no_unidad,			--  5	
			_saldo_neto,		--  6
			_nom_cober_reas,	--  7
			_nom_contrato,		--  8
			_serie,				--  9
			_nom_coasegur,		-- 10
			_porc_cont_partic,	-- 11
			_porc_comision,		-- 12
			_comis_coasegur,	-- 13
			_impuesto_coasegur,	-- 14
			_saldo_reaseg, 		-- 15
			_nom_ramo			-- 16
			with resume;
end foreach;
end procedure;