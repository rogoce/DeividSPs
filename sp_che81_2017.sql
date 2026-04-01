--************************************************************
-- Procedimiento que Carga las Bonificaciones de cobranza 2017
--************************************************************

-- Creado    : 04/01/2017 - Autor: Armando Moreno M.
-- Modificado: 04/01/2017 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_che81("001","001","2010-02","informix")

drop procedure sp_che81;
create procedure sp_che81(
a_compania          char(3),
a_sucursal          char(3),
a_periodo		    char(7),
a_usuario           char(8))
returning smallint;

define v_nombre_clte		char(100);
define _cod_contr			char(10);
define _nombre2				char(50); 
define _nombre				char(50);
define _cedula_cont			char(30);
define _cedula_paga			char(30);
define _cedula_agt			char(30);
define _no_documento		char(20); 
define _cod_contratante		char(10);
define _no_licencia2		char(10); 
define _cod_pagador			char(10);
define _no_licencia			char(10); 
define _no_poliza			char(10);
define _no_recibo			char(10); 
define _no_remesa			char(10); 
define _no_requis			char(10); 
define _ult_per_boni		char(7);
define a_periodo_ini		char(7);
define _agente_agrupado		char(5);
define _cod_producto		char(5);
define _cod_agente1			char(5);
define _cod_agente			char(5);  
define _cod_grupo			char(5);
define _cod_chequera		char(3);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3); 
define _suc_origen			char(3);
define _cod_origen			char(3); 
define _cod_banco			char(3);
define _ultmes				char(2);
define _cod_tiporamo		char(3);  
define _cod_ramo			char(3);  
define _estatus_licencia	char(1);				   
define _tipo_agente			char(1);
define _tipo_mov			char(1);  
define _porc_partic			dec(5,2); 
define _porc_comis2			dec(5,2);
define _porc_comis			dec(5,2);
define _porc_coas_ancon		dec(5,2);
define _prima_cobrada2		dec(16,2);
define _prima_cobrada3		dec(16,2);
define _prima_cobrada4		dec(16,2);
define _prima_cobrada5		dec(16,2);
define _prima_cobrada6		dec(16,2);
define _prima_cobrada7		dec(16,2);
define _prima_cobrada8		dec(16,2);
define _prima_cobrada		dec(16,2);
define _sobrecomision		dec(16,2);
define _monto_fianza		dec(16,2);
define v_prima_orig			dec(16,2);
define v_por_vencer			dec(16,2);
define v_monto_30bk			dec(16,2);
define _monto_danos			dec(16,2);
define _prima_bruta			dec(16,2);
define v_corriente			dec(16,2);
define _monto_vida			dec(16,2);
define v_exigible			dec(16,2);
define _formula_a			dec(16,2);
define _formula_b			dec(16,2);
define v_monto_30			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_45			dec(16,2);
define _comision1			dec(16,2);
define _comision2			dec(16,2);
define _prima_90			dec(16,2);
define _prima_45			dec(16,2);
define _prima_rr			dec(16,2);
define _monto_m				dec(16,2);
define _monto_p				dec(16,2);
define _prima_r				dec(16,2);
define v_saldo				dec(16,2);
define _monto				dec(16,2);
define v_corr				dec(16,2);
define _prima				dec(16,2);
define _declarativa			smallint;
define _beneficios			smallint;
define _tipo_forma			smallint;
define _incobrable			smallint;
define _tipo_prod			smallint;
define _tipo_ramo			smallint; 
define _tipo_pago			smallint;
define _forma_pag			smallint;
define _concurso			smallint;
define _renglon				smallint; 
define _contado				smallint;
define _retro				smallint;
define _error				smallint;
define _valor				integer;
define _dias				integer;
define _mess				integer;
define _anno				integer;
define _cnt					integer;
define _pago				integer;
define _f_decla_ult			date;
define _fecha_decla			date;
define _fecha_hoy			date;
define _f_ult				date;
define _fecha				date;
define _periodo_pag         char(7);
define _comis				decimal(5,2);
define _adicional           smallint;
define _fecha_ini			date;
define _fecha_fin			date;
define _porc_proporcion     dec(16,2);
define _monto_dev           dec(16,2);
define _pagado 				smallint;
define _fecha_anulado       date;
define _monto_fac_ac		date;
define _porc_partic_prima   dec(16,2);
define _monto_fac			dec(16,2);

--SET DEBUG FILE TO "sp_che81.trc";
--TRACE ON;

let _porc_coas_ancon	= 0;
let _prima_cobrada2		= 0;
let _prima_cobrada3		= 0;
let _prima_cobrada4		= 0;
let _prima_cobrada5		= 0;
let _prima_cobrada6		= 0;
let _prima_cobrada7		= 0;
let _prima_cobrada8		= 0;
let _prima_cobrada		= 0;
let _porc_comis2		= 0;
let _prima_bruta		= 0;
let _declarativa		= 0;
let _porc_comis			= 0;
let _forma_pag			= 0;
let _prima_90			= 0;
let _prima_45			= 0;
let _monto_p			= 0;
let _monto_m			= 0;
let _valor				= 0;
let _retro				= 0;
let _error				= 0;
let _cnt				= 0;
let a_periodo_ini		= "2017-01";
let _monto_fac          = 0;

select ult_per_boni
  into _ult_per_boni
  from parparam;

let _ultmes = _ult_per_boni[6,7];

if _ultmes = '12' then
	return 1;
end if

create temp table tmp_boni(
cod_agente	char(15),
no_poliza	char(10),
monto		dec(16,2),
prima		dec(16,2),
fecha		date,
contado		smallint default 0,
periodo     char(7),
primary key	(cod_agente, no_poliza, periodo)) with no log;

create index i_boni1 on tmp_boni(cod_agente);
create index i_boni2 on tmp_boni(no_poliza);
create index i_boni3 on tmp_boni(periodo);

set isolation to dirty read;

delete from chqboni
 where periodo = a_periodo;

let _valor = sp_che108a(a_compania,a_sucursal,a_periodo); --06/04/2010,acumula prima cobrada hasta mes que se va a pagar, para luego evaluar si cumple para el bono.

if _valor <> 0 then
	return 2;
end if

{select sum(c.prima_cobrada)
  into _prima_cobrada2
  from chqboagt c, agtagent h
 where c.cod_agente = h.cod_agente
   and h.agente_agrupado = "01727";	}--01221 maribel pineda a 01727 pj seg.asemar	:10/06/2010 gina

select sum(c.prima_cobrada)
  into _prima_cobrada3
  from chqboagt c, agtagent h
 where c.cod_agente = h.cod_agente
   and h.agente_agrupado = "01068";	--unificar ff seguros

select sum(prima_cobrada)
  into _prima_cobrada4															 
  from chqboagt																	
 where cod_agente in('01480','01479','00492'); --unificar ricardo caballero y los ases del seguro a patrticia caballero 

select sum(prima_cobrada)
  into _prima_cobrada5					
  from chqboagt							
 where cod_agente in('01481','01555'); --unificar jose caballero a marta caballero

select sum(prima_cobrada)
  into _prima_cobrada6
  from chqboagt							
 where cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005'); --unificar felix abadia
 
 select sum(prima_cobrada)
  into _prima_cobrada7					
  from chqboagt							
 where cod_agente in('01371','02242'); --unificar Edgar Martinez a Gestion de Seguros, S.A.
 
 select sum(prima_cobrada)
  into _prima_cobrada8					
  from chqboagt							
 where cod_agente in('00473','02243'); --unificar Inv. y seg. panamericanos

foreach
	select cod_agente,
	       sum(prima_cobrada),
		   retroactivo
	  into _cod_agente,
	       _prima_cobrada,
		   _retro
	  from chqboagt
	 group by cod_agente,retroactivo
	 order by cod_agente,retroactivo

	{if _cod_agente in("01221","01727") then 	   --01221 maribel pineda a 01727 pj seg.asemar	:10/06/2010 gina 
		let _prima_cobrada = _prima_cobrada2;
	end if}

	if _cod_agente in('01480','01479') then 	   
		let _prima_cobrada = _prima_cobrada4;
	end if

	if _cod_agente in('01481','01555') then 	   
		let _prima_cobrada = _prima_cobrada5;
	end if

    if _cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005') then
		let _prima_cobrada = _prima_cobrada6;
	end if
	
	if _cod_agente in('01371','02242') then
		let _prima_cobrada = _prima_cobrada7;
	end if
	if _cod_agente in('00473','02243') then
		let _prima_cobrada = _prima_cobrada8;
	end if
    select agente_agrupado
	  into _agente_agrupado
	  from agtagent
     where cod_agente = _cod_agente;

	if _agente_agrupado = '01068' then             --ff seguros
		let _prima_cobrada = _prima_cobrada3;
	end if

	if _prima_cobrada >= 35000 or _retro = 1 then	--si es >= a 35000, se toma en cuenta al corredor para el pago.
	else
		continue foreach;
	end if

	if _retro = 0 then  --Le voy a pagar retroactivo
		update chqboagt
		   set retroactivo   = 1,
		       periodo_hasta = a_periodo
		 where cod_agente    = _cod_agente;

		let a_periodo_ini  = "2017-01";
	else
		let a_periodo_ini  = a_periodo;
	end if

	let _fecha_fin = sp_sis36(a_periodo);	--31/01/2016
	let _fecha_ini = sp_sis40b(a_periodo_ini);
	foreach
		select d.no_poliza,
			   d.no_remesa,
			   d.renglon,
			   d.no_recibo,
			   d.fecha,
			   d.monto,
			   d.prima_neta,
			   d.tipo_mov,
			   m.cod_banco,
			   m.cod_chequera,
			   c.porc_partic_agt
		  into _no_poliza,
			   _no_remesa,
			   _renglon,
			   _no_recibo,
			   _fecha,
			   _monto,
			   _prima,
			   _tipo_mov,
			   _cod_banco,
			   _cod_chequera,
			   _porc_partic
		  from cobredet d, cobremae m, cobreagt c
		 where	d.no_remesa    = m.no_remesa
		   and d.no_remesa    = c.no_remesa
		   and d.renglon      = c.renglon
		   and d.cod_compania = a_compania
		   and d.actualizado  = 1
		   and d.tipo_mov     in ('P','N')
		   and (month(d.fecha) >= a_periodo_ini[6,7]
		   and  month(d.fecha) <= a_periodo[6,7])
		   and year(d.fecha)  = a_periodo[1,4]
		   and m.tipo_remesa  in ('A', 'M', 'C')
		   and c.cod_agente   = _cod_agente
		 order by d.fecha,d.no_recibo,d.no_poliza
		 
		 let _periodo_pag = sp_sis39(_fecha);

		select cod_grupo,
			   cod_ramo,
			   cod_pagador,
			   cod_contratante,
			   no_documento,
			   sucursal_origen,
			   prima_bruta,
			   cod_subramo,
			   declarativa
		  into _cod_grupo,
			   _cod_ramo,
			   _cod_pagador,
			   _cod_contratante,
			   _no_documento,
			   _suc_origen,
			   _prima_bruta,
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
			continue foreach;
		end if

		let _contado = 0;
		let _pago    = 0;

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

		if _cod_ramo = '009' then	  --No va poliza declarativa de Transporte
			if _declarativa = 1 then
				insert into bonibita(periodo,poliza,descripcion)
				values (a_periodo,_no_documento,'Se excluye Pol. Declarativa Transporte.');
				continue foreach;
			end if
		end if

		if _cod_ramo in('019','018','016','008') then	  --No va poliza de vida individual ni Salud, ni colectivas de salud ni fianzas
			insert into bonibita(periodo,poliza,descripcion)
			values (a_periodo,_no_documento,'Se excluye Pol. Fianza,Vida Ind.,Salud y Col.');
			continue foreach;
		end if

		if _cod_ramo = '001' and _cod_subramo = '006' then	  --No va poliza de Incendio subramo ZonaLibre y France Field y cocosolito
			insert into bonibita(periodo,poliza,descripcion)
			values (a_periodo,_no_documento,'Se excluye Pol.Inc. Zona Libre y France F.');
			continue foreach;
		end if

		select cedula
		  into _cedula_paga
		  from cliclien
		  where cod_cliente = _cod_pagador;

		select cedula
		  into _cedula_cont
		  from cliclien
		 where cod_cliente = _cod_contratante;
		   
		 --Se quita esta condicion, segun doc. Act. de plan de neg. Leticia 19/03/2014
		 { if _cod_grupo = "00000" or _cod_grupo = '1000' then --excluir estado
			INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Grupo del Estado.');
			continue foreach;
		  end if}

		-- devoluciones de prima
		foreach
				SELECT monto,
					   no_requis
				  into _monto_dev, 
					   _no_requis
				  FROM chqchpol
				 WHERE no_poliza = _no_poliza
				 
				SELECT pagado,
					   fecha_anulado
				  INTO _pagado,
					   _fecha_anulado
				  FROM chqchmae
				 WHERE no_requis = _no_requis
				   and fecha_impresion between _fecha_ini and _fecha_fin;
				IF _pagado = 1 THEN
					IF _fecha_anulado IS NOT NULL THEN
						IF _fecha_anulado >= _fecha_ini and _fecha_anulado <= _fecha_fin THEN
							LET _monto_dev = 0;
						END IF
					END IF			
				ELSE
					LET _monto_dev = 0;
				END IF	
		
				IF _monto_dev IS NULL THEN
					LET _monto_dev = 0;
				END IF
				let _prima = _prima - _monto_dev;
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
			
			let _monto_fac = _prima * (_porc_partic_prima/100) * (_porc_proporcion/100);
			let _monto_fac_ac = _monto_fac_ac + _monto_fac;
		end foreach
		
		let _prima = _prima - _monto_fac_ac;		

		--EXCLUIR DEL CORREDOR TECNICA GRUPO SUNCTRACS RAMO COLECTIVO DE VIDA
		if	_cod_agente  = "00180" and  -- Tecnica de Seguros	--Puesto por Armando, Solicitado por Demetrio segun correo enviado por meleyka 08/09/2011
			_cod_ramo    = "016"	and  -- Colectivo de vida
			_cod_grupo   = "01016" then -- Grupo Suntracs

			 continue foreach;
		end if

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

		{if _cod_agente in("01221","01727") then 	   --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 
			let _cod_agente = _agente_agrupado; 
		end if}

		if _agente_agrupado = "01068" then	 --FF SEG
			let _cod_agente = _agente_agrupado;
		end if

		if _cod_agente in("01480",'00492') then 
			let _cod_agente = '01479';		
		end if
		
		if _cod_agente in('01371','02242') then		--Edgar Martinez hacia Gestion de Seguros, s.a.
			let _cod_agente = '02242';
		end if
		if _cod_agente in('00473','02243') then		--Inv. y seg Panamericanos unificarlo con el de chorrera 12/10/2017
			let _cod_agente = '00473';
		end if
		if _cod_agente in("01481") then 	   --01481 Jose Caballero a 01555 Marta Caballero
			let _cod_agente = '01555'; 
		end if

		if _cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005') then
			let _cod_agente = '01001';				
		end if

		if _tipo_agente <> "A" then	--solo agentes
			insert into bonibita(periodo,poliza,descripcion)
			values (a_periodo,_no_documento,'Solo se permite Corredores, en el tipo de Agente.');
			continue foreach;
		end if

		if _estatus_licencia <> "A" then  --El corredor debe estar activo
			insert into bonibita(periodo,poliza,descripcion)	
			values (a_periodo,_no_documento,'El Corredor debe estar activo.');
			--continue foreach;
		end if

		let _monto_m = _monto * (_porc_partic / 100);
		let _monto_p = _prima * (_porc_partic / 100);

		begin
			on exception in(-239)
				update tmp_boni
				   set monto      = monto + _monto_m,
					   prima      = prima + _monto_p
				 where cod_agente = _cod_agente
				   and no_poliza  = _no_poliza;
			end exception

			insert into tmp_boni(cod_agente,no_poliza,monto,prima,fecha,contado,periodo)
			values(_cod_agente,_no_poliza,_monto_m,_monto_p,_fecha,_contado,_periodo_pag);
		end
	end foreach
end foreach

foreach
	select cod_agente,
		   no_poliza,
		   periodo,
		   sum(monto),
		   sum(prima)
	  into _cod_agente,
		   _no_poliza,
		   _periodo_pag,
		   _monto_m,
		   _monto_p
	  from tmp_boni
	 group by 1,2,3
	 order by 1,2,3

	select fecha,
		   contado
	  into _fecha_hoy,
		   _contado
	  from tmp_boni
	 where cod_agente = _cod_agente
	   and no_poliza  = _no_poliza
	   and periodo    = _periodo_pag;

	select nombre,
		   no_licencia,
		   agente_agrupado
	  into _nombre,
		   _no_licencia,
		   _agente_agrupado
	  from agtagent
	 where cod_agente = _cod_agente;

	select no_documento,
		   cod_tipoprod,
		   cod_ramo,
		   incobrable,
		   cod_formapag,
		   cod_subramo,
		   cod_origen,
		   cod_contratante
	  into _no_documento,
		   _cod_tipoprod,
		   _cod_ramo,	
		   _incobrable,
		   _cod_formapag,
		   _cod_subramo,
		   _cod_origen,
		   _cod_contr
	  from emipomae
	 where no_poliza = _no_poliza;

	if _monto_m <= 0 then
		insert into bonibita(periodo,poliza,descripcion)
		values (a_periodo,_no_documento,'No se perimite montos menores o igual a cero.');
		continue foreach;
	end if

	select tipo_produccion
	  into _tipo_prod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_prod = 4 then	-- no incluye reaseguro asumido
	   insert into bonibita(periodo,poliza,descripcion)	values (a_periodo,_no_documento,'Se excluye reaseguro asumido.');
	   continue foreach;
	end if

	if _tipo_prod = 3 then	--no incluye coas minoritario
	   insert into bonibita(periodo,poliza,descripcion)	values (a_periodo,_no_documento,'Se excluye Coaseg. Minoritario.');
	   continue foreach;
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
	
	select cod_tiporamo
	  into _cod_tiporamo
	  from prdramo
	 where cod_ramo = _cod_ramo; 	

	select tipo_ramo
	  into _tipo_ramo
	  from prdtiram
	 where cod_tiporamo = _cod_tiporamo;

	--buscar forma de pago
	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma <> 2 and _tipo_forma <> 3 and _tipo_forma <> 4 then	--2=visa,3=desc salario,4=ach
		let _forma_pag = 0;		--es voluntario
	else
		let _forma_pag = 1;		--es electronico
	end if

	let _prima_r     = 0;
	let _prima_rr    = 0;
	let _formula_a   = 0;
	let _porc_comis  = 0;
	let _porc_comis2 = 0;
	let _prima_45    = 0;
	let _prima_90    = 0;
	let _formula_b   = 0;
	let v_corriente  = 0;
	let v_monto_30   = 0;
	let v_monto_60   = 0;
	let v_monto_45   = 0;
	let v_corr       = 0;
	let v_monto_30bk = 0;
	let _prima_r = _monto_p;
	let _prima_r = (_porc_coas_ancon * _prima_r) / 100;

    if _prima_r is null then
		let _prima_r = 0;
	end if

   	call sp_cob33e(a_compania,a_sucursal,_no_documento,a_periodo,_fecha_hoy) returning v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_45,v_monto_60,v_saldo;

	let v_corr       = v_corriente;
	let v_monto_30bk = v_monto_30;
	
	if _agente_agrupado in('00035') then --DUCRUET
		if v_monto_60 > 0 then
			insert into bonibita(periodo,poliza,descripcion)
			values (a_periodo,_no_documento,'Se excluye Morosidad a mas de 60 para Ducruet.');
			continue foreach;
		end if
	else	
		if _tipo_forma = 6 then		--corredor remesa
			if v_monto_45 + v_monto_60 > 0 then	 --Morosidad > 45 no se debe tomar en cuenta
				insert into bonibita(periodo,poliza,descripcion)
				values (a_periodo,_no_documento,'Se excluye Morosidad a mas de 45, para corredor remesa.');
				continue foreach;
			end if	
		else
			if v_monto_30 + v_monto_45 + v_monto_60 > 0 then	 --Morosidad > 30 no se debe tomar en cuenta
				insert into bonibita(periodo,poliza,descripcion)
				values (a_periodo,_no_documento,'Se excluye Morosidad a mas de 30.');
				continue foreach;
			end if
		end if
	end if

	let v_corriente = (v_corriente * _porc_coas_ancon) / 100;
	
	if _forma_pag = 1 then --electronico

		--let _porc_comis2 = 3;
		call sp_sis203(_no_documento, _contado, _periodo_pag) returning _comis, _adicional;

		let _porc_comis2 = _comis + _adicional;
		let _porc_comis  = _adicional;
		
		if _adicional = 1 then
			update cobcampl2
			   set procesado = 1
			 where no_documento = _no_documento;  
		end if
	else
		if _tipo_forma = 6 then -- COR CORREDOR REMESA
			let _porc_comis2 = 2.5;
		else
			if _contado = 2 then
				let _porc_comis2 = 2.5;  --Remesa de pago externo
			else
				let _porc_comis2 = 1;  --VENTANILLA
			end if
		end if
	end if

	let _formula_a = _prima_r * (_porc_comis2 / 100);

    select nombre
      into v_nombre_clte
      from cliclien
     where cod_cliente = _cod_contr;

	let v_corriente = v_corr;

		insert into chqboni(
				cod_agente,
				no_poliza,
				monto,
				prima,
				comision,
				nombre,
				no_documento,
				no_licencia,
				seleccionado,
				periodo,
				fecha_genera,
				moro_045,
				moro_4690,
				porc_045,
				porc_4690,
				pol_corr,
				pol_0045,
				pol_4690,
				cod_ramo,
				cod_subramo,
				cod_origen,
				comis0045,
				comis4690,
				nombre_cte)
		VALUES(	_cod_agente,
				_no_poliza,
				_monto_m,
				_monto_p,
				_formula_a,
				_nombre,
				_no_documento,
				_no_licencia,
				0,
				a_periodo,
				current,
				_prima_r,
				_prima_90,
				_porc_comis,
				_porc_comis2,
				v_corriente,
				v_monto_30,
				v_monto_60,
				_cod_ramo,
				_cod_subramo,
				_cod_origen,
				_formula_b,
				_formula_a,
				v_nombre_clte);
end foreach

{if a_periodo = '2015-11' then
	update chqbonibk2
	   set fecha_genera = current;

	insert into chqboni
	select * from chqbonibk2;
end if}

foreach
	select cod_agente
	  into _cod_agente
	  from chqboni
     where periodo = a_periodo
	 group by cod_agente
	 order by cod_agente
	 
	select estatus_licencia
	  into _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _estatus_licencia = 'A' then 
		call sp_che82(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;
	end if

	if _error <> 0 then
		return _error;
	end if
end foreach

update parparam
   set ult_per_boni = a_periodo
 where cod_compania = a_compania;

drop table tmp_boni; 

return 0;
end procedure;