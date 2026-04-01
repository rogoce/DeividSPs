--***************************************************************--
-- Procedimiento que acumula primas cobradas del mes que se esta pagando a la tabla chqboagt   2013
--
-- se modifico para que la prima a usar sea la de nuestra participacion. 24/02/2010
--***************************************************************--

-- Creado    : 11/03/2013 - Autor: Armando Moreno M.
-- Modificado: 11/03/2013 - Autor: Armando Moreno M.
--execute procedure sp_che108as('001','001','2016-01','2016-12')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che108as;
create procedure sp_che108as(a_compania char(3),a_sucursal char(3), a_periodo char(7), a_periodo_hasta char(7))
returning integer;

define _cod_agente      char(5);  
define _no_poliza       char(10);
define _cod_origen      char(3); 
define _monto           dec(16,2);
define _fecha           date;     
define _prima           dec(16,2);
define _porc_partic     dec(5,2); 
define _porc_comis      dec(5,2);
define _porc_comis2     dec(5,2);
define _porc_coas_ancon		dec(5,2);
define _nombre          char(50); 
define _cod_tipoprod    char(3);  
define _tipo_prod       smallint; 
define _monto_vida      dec(16,2);
define _monto_danos     dec(16,2);
define _monto_fianza    dec(16,2);
define _cod_tiporamo    char(3);  
define _tipo_ramo       smallint; 
define _cod_ramo        char(3);  
define _no_licencia     char(10); 
define _tipo_mov        char(1);  
define _incobrable		smallint;
define _tipo_pago     	smallint;
define _tipo_agente     char(1);
define _cod_producto	char(5);
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define _no_licencia2    char(10); 
define _nombre2         char(50); 
define _forma_pag		smallint;
define _fecha_desde     date;
define _fecha_hasta     date;
define _cedula_paga			char(30);
define _cedula_cont			char(30);
define _cedula_agt			char(30);
define _cod_contratante		char(10);
define _cod_pagador			char(10);
define _no_requis			char(10);
define _periodo_ant			char(7);
define _cod_grupo			char(5);
define _estatus_licencia	char(1);
define _nueva_renov			char(1);
define _porc_partic_prima	dec(16,2);
define _porc_proporcion		dec(16,2);
define _monto_fac_ac		dec(16,2);
define v_por_vencer			dec(16,2);
define _prima_neta			dec(16,2);
define v_corriente			dec(16,2);
define v_exigible			dec(16,2);
define v_monto_30			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_45			dec(16,2);
define _monto_dev			dec(16,2);
define _monto_fac			dec(16,2);
define v_saldo				dec(16,2);
define _saldo				dec(16,2);
define v_corr				dec(16,2);
define _renglon				smallint;
define _mes_ant				smallint;
define _ano_ant				smallint;
define _flag				smallint;
define _vigencia_inic		date;
define _vigencia_final		date;
define _fecha_cancelacion	date;
define _per_cero        char(7);
define _no_remesa       char(10);
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         dec(16,2);
define _monto_b         dec(16,2);
define _prima_n         dec(16,2);
define _cod_subramo     char(3);
define _concurso        smallint;
define _declarativa     smallint;
define _agente_agrupado char(5);
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _es_mensual      smallint ;
define _periodo_pago	char(7);
define _desde			char(7);
define _hasta           char(7);
define _fecha_ini		date;
define _fecha_fin		date;
define _fecha_anulado   date;
define _pagado          smallint;


on exception set _error, _error_isam, _error_desc
   return _error;
end exception


--SET DEBUG FILE TO "sp_che108a.trc";
--TRACE ON;

let _porc_partic_prima = 0;
let _porc_coas_ancon = 0;
let _porc_proporcion = 0;
let _monto_fac_ac = 0;
let v_por_vencer = 0;
let _declarativa = 0;
let	v_corriente = 0;
let _prima_neta = 0;
let	v_exigible = 0;
let	v_monto_30 = 0;
let	v_monto_60 = 0;
let _monto_dev = 0;
let _monto_fac = 0;
let _prima_r = 0;
let _monto_b = 0;
let _prima_n = 0;
let	v_saldo = 0;
let _error = 0;
let _cnt = 0;

let _desde = null;
let _hasta = null;

set isolation to dirty read;

let _fecha_ini = sp_sis40b(a_periodo);

select *
  from chqboagt
 where 1=2
  into temp tmp_chqboagt;

select *
  from chqbonoc
 where 1=2
  into temp tmp_chqbonoc;  

foreach
	select d.no_poliza,
		   d.no_remesa,
		   d.renglon,
		   d.no_recibo,
		   d.fecha,
		   d.monto,
		   d.prima_neta,
		   d.tipo_mov,
		   m.periodo
	  into _no_poliza,
		   _no_remesa,
		   _renglon,
		   _no_recibo,
		   _fecha,
		   _monto,
		   _prima,
		   _tipo_mov,
		   _periodo_pago
	  from cobredet d, cobremae m
	 where d.cod_compania = a_compania
	   and d.actualizado  = 1
	   and d.tipo_mov in ('P','N')
	   --and month(d.fecha) = a_periodo[6,7]
	   and year(d.fecha)  = a_periodo[1,4]
	   and d.no_remesa    = m.no_remesa
	   and m.tipo_remesa  in ('A', 'M', 'C')
	   and d.doc_remesa in (select distinct no_documento from tmp_pol_transf)
	 order by d.fecha,d.no_recibo,d.no_poliza

	
	select cod_grupo,
	       cod_ramo,
	       cod_pagador,
	       cod_contratante,
	       cod_subramo,
		   declarativa,
		   no_documento,
		   cod_formapag
	  into _cod_grupo,
	       _cod_ramo,
	       _cod_pagador,
	       _cod_contratante,
	       _cod_subramo,
		   _declarativa,
		   _no_documento,
		   _cod_formapag
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

	if _concurso = 0 then		 --excluir Ramos
		continue foreach;
	end if

  {	if _cod_grupo = "00000" or _cod_grupo = "1000" then --excluir estado
		continue foreach;
	end if }

	{select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	if _cnt > 0 then		--excluir los facultativos
		continue foreach;
	end if}

	if _cod_ramo = '009' then	  --No va poliza declarativa de Transporte
		if _declarativa = 1 then
			continue foreach;
		end if
	end if

	if _cod_ramo in('019','018','016','008') then	  --No va poliza de vida individual ni Salud ni colectivas de salud ni fianzas
		continue foreach;
	end if

	if _cod_ramo = '001' and _cod_subramo = '006' then	  --No va poliza de Incendio subramo ZonaLibre
		continue foreach;
	end if

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	select tipo_produccion
	  into _tipo_prod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_prod = 4 then	-- excluir reaseguro asumido
		continue foreach;
	end if

	if _tipo_prod = 3 then	-- excluir coas minoritario
	   continue foreach;
	end if

	if _tipo_prod = 2 then  -- coas mayoritario
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

	let _prima_r = (_porc_coas_ancon * _prima) / 100;

   	call sp_cob33e(a_compania,a_sucursal,_no_documento,_periodo_pago,_fecha) 
	returning	v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_45,
				v_monto_60,
				v_saldo;

	let v_monto_30  = (v_monto_30  * _porc_coas_ancon) / 100;
	let v_monto_45  = (v_monto_45  * _porc_coas_ancon) / 100;
	let v_monto_60  = (v_monto_60  * _porc_coas_ancon) / 100;

	let _fecha_fin = sp_sis36(_periodo_pago);
	-- devoluciones de prima
	foreach
		select monto,
			   no_requis
		  into _monto_dev, 
			   _no_requis
		  from chqchpol
		 where no_poliza = _no_poliza
		 
		select pagado,
			   fecha_anulado
		  into _pagado,
			   _fecha_anulado
		  from chqchmae
		 where no_requis = _no_requis
		   and fecha_impresion between _fecha_ini and _fecha_fin;

		if _pagado = 1 then
			if _fecha_anulado is not null then
				if _fecha_anulado >= _fecha_ini and _fecha_anulado <= _fecha_fin then
					let _monto_dev = 0;
				end if
			end if			
		else
			let _monto_dev = 0;
		end if	

		if _monto_dev is null then
			let _monto_dev = 0;
		end if
		let _prima_r = _prima_r - _monto_dev;
	end foreach

	--fin de devoluciones de primas 
	let _monto_fac_ac = 0.00;

	--Quitar facultativo cedido
	foreach
		select porc_partic_prima,
			   porc_proporcion
		  into _porc_partic_prima,
			   _porc_proporcion
		  from cobreaco c, reacomae r
		 where c.no_remesa = _no_remesa
		   and c.renglon = _renglon
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3

		if _porc_partic_prima is null then
			let _porc_partic_prima = 0.00;
		end if
		
		let _monto_fac = _prima_r * (_porc_partic_prima/100) * (_porc_proporcion/100);
		let _monto_fac_ac = _monto_fac_ac + _monto_fac;
	end foreach
	
	let _prima_r = _prima_r - _monto_fac_ac;
	
	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic,
			   _porc_comis
		  from cobreagt
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		
		select nombre,
		       no_licencia,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado
		  into _nombre,
		       _no_licencia,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		if _agente_agrupado in('00035') then --ducruet
			if v_monto_60 > 0 then	 
				continue foreach;
			end if
		else	
			if _tipo_forma = 6 then		--corredor remesa
				if v_monto_45 + v_monto_60 > 0 then	 --morosidad > 45 no se debe tomar en cuenta
					continue foreach;
				end if	
			else
				if v_monto_30 + v_monto_45 + v_monto_60 > 0 then	 --morosidad > 30 no se debe tomar en cuenta
					continue foreach;
				end if
			end if
		end if
		
		if _cod_agente in("02302","02354") then --Lizsenell Bernal Ramírez , código 02302 se excluye segun correo del 18/05/2016 Analisa Stanziola y 02354 segun correo Analisa 19/05/2016
			continue foreach;
		end if

		--EXCLUIR DEL CORREDOR TECNICA GRUPO SUNCTRACS RAMO COLECTIVO DE VIDA
		if _cod_agente = "00180" and  -- tecnica de seguros	--puesto por armando, solicitado por demetrio segun correo enviado por meleyka 08/09/2011
		   _cod_ramo   = "016"	 and  -- colectivo de vida
		   _cod_grupo  = "01016" then -- grupo suntracs

		   continue foreach;
		end if

		if _tipo_agente <> "A" then	--solo agentes
			continue foreach;
		end if

		{IF _estatus_licencia <> "A" then  --El corredor debe estar activo
			continue foreach;
		END IF}

		let _prima_neta = 0;
		let _monto_b    = 0;
		let _prima_n    = 0;
		let _prima_neta = _prima_r * (_porc_partic / 100);
		let _monto_b    = _monto   * (_porc_partic / 100);
		let _prima_n    = _prima   * (_porc_partic / 100);

		if _prima_neta is null then
			let _prima_neta = 0;
		end if

		let _es_mensual = 1;
		let _desde = null;
		let _hasta = null;

		if _cod_agente = '00141' then --Si es Uniseguros, No es mensual, se le paga en Enero del sig anno.
			let _es_mensual = 0;
			let _desde      = '2017-01';
			let _hasta      = '2017-12';
		end if

		begin
		on exception in(-239,-268)
			update tmp_chqboagt
			   set prima_cobrada = prima_cobrada + _prima_neta,
				   monto         = monto         + _monto_b,
				   prima_neta    = prima_neta    + _prima_n
			 where cod_agente    = _cod_agente;
		end exception

			insert into tmp_chqboagt(
					cod_agente,
					prima_cobrada,
					monto,
					prima_neta,
					agente_agrupado,
					es_mensual,
					desde,
					hasta)
			values(	_cod_agente,
					_prima_neta,
					_monto_b,
					_prima_n,
					_agente_agrupado,
					_es_mensual,
					_desde,
					_hasta);
		end

		insert into tmp_chqbonoc(
				cod_agente,
				prima_cobrada,
				periodo,
				no_documento)
		values(	_cod_agente,
				_prima_neta,
				_periodo_pago,
				_no_documento);
	end foreach
end foreach

return 0;
end procedure;