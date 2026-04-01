--************************************************************
-- Procedimiento que Carga las Bonificaciones de cobranza 2012
--************************************************************

-- Creado    : 15/02/2012 - Autor: Armando Moreno M.
-- Modificado: 15/02/2012 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_che81("001","001","2010-02","informix")

drop procedure sp_che147_2012;

create procedure sp_che147_2012
(a_cod_agente	char(5),
a_fecha_desde	date,
a_fecha_hasta	date)

returning smallint;

define _descripcion		varchar(100);
define _no_documento	char(20); 
define _no_poliza		char(10);
define _no_remesa		char(10); 
define _no_recibo		char(10); 
define _periodo			char(7);
define _cod_agente		char(5);  
define _cod_grupo		char(5);
define _cod_tipoprod	char(3);
define _cod_formapag	char(3);
define _cod_chequera	char(3);
define _cod_subramo		char(3); 
define _cod_banco		char(3);
define _cod_ramo		char(3);
define _porc_coas_ancon dec(5,2);
define _porc_comis2		dec(5,2);
define _porc_partic		dec(5,2); 
define _porc_comis		dec(5,2);
define v_por_vencer		dec(16,2);
define v_corriente		dec(16,2);
define v_exigible		dec(16,2);
define v_monto_30		dec(16,2);
define v_monto_60		dec(16,2);
define _formula_a		dec(16,2);
define _prima_r			dec(16,2);
define _monto_m			dec(16,2);
define _monto_p			dec(16,2);
define v_saldo			dec(16,2);
define _monto			dec(16,2);
define _prima			dec(16,2);
define _declarativa		smallint;
define _tipo_forma		smallint;
define _tipo_prod		smallint;
define _forma_pag		smallint;
define _concurso		smallint;
define _contado			smallint;
define _error			smallint;
define _pago			integer;
define _cnt				integer;
define _fecha_hoy		date;
define _fecha			date;

--SET DEBUG FILE TO "sp_che81.trc";
--TRACE ON;

let _error   = 0;
let _porc_coas_ancon = 0;
let _forma_pag      = 0;
let _porc_comis     = 0;
let _porc_comis2    = 0;
let _cnt            = 0;
let _monto_m        = 0;
let _monto_p        = 0;
let _declarativa    = 0;

create temp table tmp_boni(
cod_agente	char(15),
no_poliza	char(10),
no_recibo	char(10),
prima		dec(16,2),
monto		dec(16,2),
fecha		date,
contado		smallint default 0,
primary key	(cod_agente, no_poliza,no_recibo)) with no log;
create index i_boni1 on tmp_boni(cod_agente);
create index i_boni2 on tmp_boni(no_poliza);

create temp table tmp_bonibita(
periodo			char(7),
no_documento	char(20),
no_recibo		char(10),
prima			dec(16,2),
fecha			date,
descripcion		varchar(100)) with no log;
--primary key	(periodo,no_documento,no_recibo,fecha)

create temp table tmp_chqboni(
no_poliza		char(10),
comision		dec(16,2),
no_documento	char(20),
no_recibo		char(10),
periodo			char(7)) with no log;

set isolation to dirty read;

foreach
	select d.no_poliza,
		   d.no_remesa,
		   d.no_recibo,
		   d.fecha,
		   d.prima_neta,
		   d.monto,
		   m.cod_banco,
		   m.cod_chequera,
		   c.porc_partic_agt
	  into _no_poliza,
		   _no_remesa,
		   _no_recibo,
		   _fecha,
		   _prima,
		   _monto,
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
	   and d.fecha between a_fecha_desde and a_fecha_hasta
	   and m.tipo_remesa  in ('A', 'M', 'C')
	   and c.cod_agente   = a_cod_agente
	 order by d.fecha,d.no_recibo,d.no_poliza
	
	call sp_sis39(_fecha) returning _periodo;
	
	let _descripcion = '';
	select cod_grupo,
		   cod_ramo,
		   no_documento,
		   cod_subramo,
		   declarativa
	  into _cod_grupo,
		   _cod_ramo,
		   _no_documento,
		   _cod_subramo,
		   _declarativa
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
		let _descripcion = 'El Subramo no Participa en la Bonificación.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha,_descripcion);
		--continue foreach;
	end if

	let _contado = 0;
	let _pago    = 0;
	
	if _cod_banco = "146" then -- caja
		if _cod_chequera in ("025","026","027","041") then  --Pago por cobrador rutero
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

	if _cod_ramo = '009' then	  --No va poliza declarativa de Transporte
		if _declarativa = 1 then
			let _descripcion = 'Se excluye Pol. Declarativa Transporte.';
			insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
			values(_periodo,_no_documento,_no_recibo,0,_fecha,_descripcion);
			--continue foreach;
		end if
	end if

	if _cod_ramo = '008' or _cod_ramo = '019' or _cod_ramo = '018' or _cod_ramo = "016" then	  --No va poliza de Fianzas ni vida individual ni Salud, ni colectivas
		let _descripcion = 'Se excluye Pol. Fianza,Vida Ind.,Salud y Col.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha,_descripcion);
		--continue foreach;
	end if

	if _cod_ramo = '001' and _cod_subramo = '006' then	  --No va poliza de Incendio subramo ZonaLibre
		let _descripcion = 'Se excluye Pol.Inc. Zona Libre.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha,_descripcion);
		--continue foreach;
	end if

	if _cod_grupo = "00000" then --excluir estado
		let _descripcion = 'Se excluye Grupo del Estado.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha,_descripcion);
		--continue foreach;
	end if  	

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	if _cnt > 0 then		--los facultativos se excluyen
		let _descripcion = 'No se permite Facultativos.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha,_descripcion);
		--continue foreach;
	end if

	let _monto_p = _prima * (_porc_partic / 100);
	let _monto_m = _monto * (_porc_partic / 100);

	if _descripcion = '' then
		begin
			on exception in(-239)

				update tmp_boni
				   set prima      = prima + _monto_p
				 where cod_agente = a_cod_agente
				   and no_poliza  = _no_poliza;

			end exception

			insert into tmp_boni(cod_agente,no_poliza,no_recibo,monto,prima,fecha,contado)
			values(a_cod_agente,_no_poliza,_no_recibo,_monto_m,_monto_p,_fecha,_contado);
		end
	end if
end foreach

foreach
	select cod_agente,
		   no_poliza,
		   no_recibo,
		   sum(prima),
		   sum(monto)
	  into _cod_agente,
		   _no_poliza,
		   _no_recibo,
		   _monto_p,
		   _monto_m
	  from tmp_boni
	 group by 1,2,3

	let _descripcion = '';

	select fecha
	  into _fecha_hoy
	  from tmp_boni
	 where cod_agente = _cod_agente
	   and no_poliza  = _no_poliza
	   and no_recibo = _no_recibo;

	call sp_sis39(_fecha_hoy) returning _periodo;

	select sum(contado)
	  into _contado
	  from tmp_boni
	 where no_poliza  = _no_poliza;

	select no_documento,
		   cod_tipoprod,
		   cod_formapag		   
	  into _no_documento,
		   _cod_tipoprod,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

	if _monto_m <= 0 then
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha,'No se permite montos menores o igual a cero.');
		
		continue foreach;
	end if

	select tipo_produccion
	  into _tipo_prod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_prod = 4 then	-- no incluye reaseguro asumido
		let _descripcion = 'Se excluye reaseguro asumido.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha_hoy,_descripcion);
		--continue foreach;
	end if

	if _tipo_prod = 3 then	--coas minoritario
		let _descripcion = 'Se excluye Coaseg. Minoritario.';
		insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha_hoy,_descripcion);
		--continue foreach;
	end if

	if _tipo_prod = 2 then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
	else
		let _porc_coas_ancon = 100;
	end if
	
	--Buscar forma de pago
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
	let _porc_comis  = 0;
	let _porc_comis2 = 0;
	let v_corriente  = 0;
	let v_monto_30   = 0;
	let v_monto_60   = 0;

	let _prima_r = _monto_p;
	let _prima_r = (_porc_coas_ancon * _prima_r) / 100;

    if _prima_r is null then
		let _prima_r = 0;
	end if

   	call sp_cob33e('001','001',_no_documento,_periodo,_fecha_hoy) 
	returning	v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_60,
				v_saldo;

	let v_monto_60  = (v_monto_60  * _porc_coas_ancon) / 100;

  	if v_monto_60 > 0 then	 --Morosidad > 90 no se debe tomar en cuenta
		let _descripcion = 'Se excluye Morosidad a mas de 90.';
	    insert into tmp_bonibita(periodo,no_documento,no_recibo,prima,fecha,descripcion)	
		values(_periodo,_no_documento,_no_recibo,0,_fecha_hoy,_descripcion);
		--continue foreach;
	end if
	
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

	let _formula_a = _prima_r * (_porc_comis2 / 100);

	if _descripcion = '' then
		insert into tmp_chqboni(
				no_poliza,
				comision,
				no_documento,
				no_recibo,
				periodo)
		values(	_no_poliza,
				_formula_a,
				_no_documento,
				_no_recibo,
				_periodo);
	end if
end foreach

drop table tmp_boni; 

return 0;
end procedure;