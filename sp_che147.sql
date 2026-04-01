-- Reporte de Pólizas descartadas por el proceso Bonificación de Cobranza
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che147;
create procedure sp_che147(
a_cod_agente	char(5),
a_periodo_desde	char(8),
a_periodo_hasta	char(8))
returning	char(8)			as Periodo,
			char(20)		as Poliza,
			varchar(100)	as Motivo_Descarte,
			dec(16,2)		as Monto;

define _error_desc		varchar(100);
define _desc_boni		varchar(100);
define _no_documento	char(20);
define _no_remesa		char(10);
define _no_poliza		char(10);
define _periodo			char(8);
define _ano_periodo		char(4);
define _cod_tipoprod	char(3);
define _cod_chequera	char(3);
define _cod_formapag	char(3);
define _cod_subramo		char(3);
define _cod_banco		char(3);
define _cod_ramo		char(3);
define _porc_partic		dec(5,2);
define _porc_coas_ancon	dec(7,4);
define _formula_a		dec(16,2);
define _monto_p			dec(16,2);
define _prima_r			dec(16,2);
define _prima			dec(16,2);
define _porc_comis2		smallint;
define _tipo_forma		smallint;
define _tipo_prod		smallint;
define _forma_pag		smallint;
define _concurso		smallint;
define _contado			smallint;
define _pago			smallint;
define _error_isam		integer;
define _error			integer;
	
set isolation to dirty read;

--set debug file to "sp_che147.trc";	 																						 
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	return cast(_error as char(5)),'',_error_desc,0.00;
end exception

create temp table tmp_boni(
no_poliza	char(10),
prima		dec(16,2),
descripcion	varchar(100),
periodo		char(8),
contado		smallint	default 0,
primary key	(periodo,no_poliza,descripcion,contado)) with no log;

{create temp table tmp_bonibita(
poliza		char(10),
descripcion	varchar(100),
periodo		char(8)) with no log;

foreach
	select distinct b.poliza,
		   b.periodo
		   --trim(b.descripcion)
	  into _no_documento,
		   _periodo
		   --_desc_boni
	  from bonibita b, emipomae e, emipoagt a
	 where b.poliza = e.no_documento
	   and a.no_poliza = e.no_poliza
	   and a.cod_agente = a_cod_agente
	   and (b.periodo >= a_periodo_desde
	   and b.periodo <= a_periodo_hasta)
	 order by 1
	
	foreach
		select descripcion
		  into _desc_boni
		  from bonibita
		 where poliza = _no_documento
		   and periodo = _periodo
		exit foreach;
	end foreach
	
	insert into tmp_bonibita
	values (_no_documento,_periodo,_desc_boni);
end foreach

foreach
	select e.no_documento,
		   m.periodo
	  into _no_documento,
		   _periodo
	  from cobredet d, cobremae m, cobreagt c, emipomae e, prdsubra s
	 where d.no_remesa    = m.no_remesa
	   and d.no_remesa    = c.no_remesa
	   and d.renglon      = c.renglon
	   and e.no_poliza = d.no_poliza
	   and e.cod_ramo = s.cod_ramo
	   and e.cod_subramo = s.cod_subramo
	   and s.concurso = 0
	   and d.cod_compania = '001'
	   and d.actualizado  = 1
	   and d.tipo_mov     in ('P','N')
	   and (month(d.fecha) >= _periodo[6,7]
	   and  month(d.fecha) <= _periodo[6,7])
	   and year(d.fecha)  = 2014
	   and m.tipo_remesa  in ('A', 'M', 'C')
	   and c.cod_agente   = a_cod_agente
	
	insert into tmp_bonibita
	values (_no_documento,_periodo,'El Subramo no Participa en la Bonifiación.');
end foreach}

foreach
	select distinct b.poliza,
		   b.periodo
		   --trim(b.descripcion)
	  into _no_documento,
		   _periodo
		   --_desc_boni
	  from bonibita b, emipomae e, emipoagt a
	 where b.poliza = e.no_documento
	   and a.no_poliza = e.no_poliza
	   and a.cod_agente = a_cod_agente
	   and (b.periodo >= a_periodo_desde
	   and b.periodo <= a_periodo_hasta)
	   and upper(b.descripcion) like '%MOROSIDAD%'
	 order by 1
	
	foreach
		select descripcion
		  into _desc_boni
		  from bonibita
		 where poliza = _no_documento
		   and periodo = _periodo
		exit foreach;
	end foreach
	
	let _ano_periodo = _periodo[1,4];
	
	foreach
		select d.no_poliza,
			   d.no_remesa,
			   d.prima_neta,
			   m.cod_banco,
			   m.cod_chequera,
			   c.porc_partic_agt
		  into _no_poliza,
			   _no_remesa,
			   _prima,
			   _cod_banco,
			   _cod_chequera,
			   _porc_partic
		  from cobredet d, cobremae m, cobreagt c
		 where d.no_remesa    = m.no_remesa
		   and d.no_remesa    = c.no_remesa
		   and d.renglon      = c.renglon
		   and d.cod_compania = '001'
		   and d.actualizado  = 1
		   and d.tipo_mov     in ('P','N')
		   and (month(d.fecha) >= _periodo[6,7]
		   and  month(d.fecha) <= _periodo[6,7])
		   and year(d.fecha)  = _ano_periodo
		   and m.tipo_remesa  in ('A', 'M', 'C')
		   and c.cod_agente   = a_cod_agente
		   and d.doc_remesa = _no_documento

		select cod_ramo,
			   cod_subramo
		  into _cod_ramo,
			   _cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select concurso
		  into _concurso
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

		if _concurso is null then
			let _concurso = 0;
		end if

		if _concurso = 0 then
			continue foreach;
		end if

		let _contado = 0;
		let _pago    = 0;
		
		if _ano_periodo = '2012' then
			if _cod_banco = "146" then -- caja
				if _cod_chequera in("025","026","027","041") then  --Pago por cobrador rutero
					let _contado = 1;
				elif _cod_chequera = "023" then  --comprobantes
				    select count(*)
					  into _pago
					  from cobpaex0
					 where no_remesa_ancon = _no_remesa
					   and tipo_formato    = 1;
						
					if _pago > 0 then
						let _contado = 2; --remesa de comprobante que viene de pago externo
					end if
				end if
			end if
		elif _ano_periodo in ('2013','2014') then		
			if _cod_banco = "146" then -- caja
				if _cod_chequera = "023" then  --comprobantes
					select count(*)
					  into _pago
					  from cobpaex0
					 where no_remesa_ancon = _no_remesa
					   and tipo_formato    = 1;

					if _pago > 0 then
						let _contado = 2; --remesa de comprobante que viene de pago externo
					end if
				elif _cod_chequera = "039" then  --Rey Pago
					let _contado = 1; --remesa de Rey pago(electronico)
				end if
			end if
		end if

		let _monto_p = _prima * (_porc_partic / 100);

		begin
			on exception in(-239)
				update tmp_boni
				   set prima      = prima + _monto_p
				 where periodo = _periodo
				   and no_poliza = _no_poliza
				   and descripcion = _desc_boni
				   and contado = _contado;
			end exception

			insert into tmp_boni(no_poliza,prima,descripcion,periodo,contado)
			values(_no_poliza,_monto_p,_desc_boni,_periodo,_contado);
		end
	end foreach
end foreach

foreach
	select periodo,
		   no_poliza,
		   contado,
		   descripcion,
		   sum(prima)
	  into _periodo,
		   _no_poliza,
		   _contado,
		   _desc_boni,
		   _monto_p
	  from tmp_boni
	 group by 1,2,3,4

	select no_documento,
		   cod_tipoprod,
		   cod_formapag
	  into _no_documento,
		   _cod_tipoprod,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

	select tipo_produccion
	  into _tipo_prod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_prod = 2 then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
	else
		let _porc_coas_ancon = 100;
	end if

	--buscar forma de pago
	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma not in (2,3,4) then	--2=visa,3=desc salario,4=ach
		let _forma_pag = 0;		--es voluntario
	else
		let _forma_pag = 1;		--es electronico
	end if
	
	let _prima_r     = 0;
	let _formula_a   = 0;
	let _porc_comis2 = 0;
	let _prima_r = _monto_p;
	let _prima_r = (_porc_coas_ancon * _prima_r) / 100;

    if _prima_r is null then
		let _prima_r = 0;
	end if
	
	if _ano_periodo = '2012' then
		if _contado = 1 or _forma_pag = 1 then --pago por cobrador rutero o electronico
			let _porc_comis2 = 1;
		else
			if _tipo_forma = 6 then -- COR CORREDOR REMESA
				let _porc_comis2 = 3;
			else
				if _contado = 2 then
					let _porc_comis2 = 3;
				else
					let _porc_comis2 = 2;  --VENTANILLA
				end if
			end if
		end if
	elif _ano_periodo in ('2013','2014') then
		if _forma_pag = 1 then --electronico
			let _porc_comis2 = 2;
		else
			if _tipo_forma = 6 then -- COR CORREDOR REMESA
				let _porc_comis2 = 3;
			else
				if _contado = 2 then
					let _porc_comis2 = 3;  --Remesa de pago externo
				elif _contado = 1 then --Reypago electronico
					let _porc_comis2 = 2;
				else
					let _porc_comis2 = 1;  --VENTANILLA
				end if
			end if
		end if
	end if
	let _formula_a = _prima_r * (_porc_comis2 / 100);
	
	return	_periodo,
			_no_documento,
			_desc_boni,
			_formula_a with resume;
end foreach

drop table tmp_boni;
end 
end procedure 