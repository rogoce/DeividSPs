-- Procedimiento que genera los registros contables de cada factura de produccion
-- 
-- Creado     : 24/10/2002 - Autor: Marquelda Valdelamar
-- Modificado :	27/10/2002 - Autor: Demetrio Hurtado Almanza

-- Modificado :	18/03/2006 - Autor: Demetrio Hurtado Almanza

--            Se incluyo la validacion para solo generar registros contables de comisiones a los
--            corredores que son Agentes (A), los especiales y oficina no se genera registros

-- Modificado :	16/08/2006 - Autor: Demetrio Hurtado Almanza

			-- Las primas por cobrar se calculan ahora de la prima neta y no de la prima bruta
			-- Los impuestos por pagar de los clientes se generan ahora desde cobros y no desde produccion.

-- Modificado :	03/08/2007 - Autor: Demetrio Hurtado Almanza

			-- Se Incluyo la modificacion al reaseguro por pagar para que incluyera la estructura del INUSE y 
			-- tambien incluyera el auxiliar

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par59a;
create procedure "informix".sp_par59a(a_no_poliza char(10), a_prima_bruta dec(16,2))
returning	integer,
			char(100);

define _error_desc			char(100);
define _cuenta				char(25);
define _cuenta_inc			char(25);
define _cuenta_dan			char(25);
define _cuenta_cat			char(25); 
define _no_factura_canc		char(10);  
define _cod_cliente			char(10);
define _no_factura			char(10);
define _no_poliza			char(10); 
define _cod_contrato		char(5);
define _cod_traspaso		char(5);
define _cod_auxiliar		char(5);
define _aux_bouquet			char(5);
define _cod_agente			char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_origen_aseg		char(3);
define _cod_cober_reas		char(3);
define _cod_impuesto		char(3);
define _cod_tipoprod		char(3);
define _cod_compania		char(3);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_endomov			char(3);
define _cod_origen			char(3);
define _cod_lider			char(3);
define _cod_ramo			char(3);
define _tipo_agente			char(1);
define _porc_cont_partic	dec(5,2);
define _factor_impuesto		dec(5,2);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_reser_est		dec(5,2);  -- porcentaje de reserva estadistica
define _porc_reser_cat		dec(5,2);	-- porcentaje de reserva catastrofica
define _porc_partic_coas	dec(7,4);
define _prima_bruta_canc	dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_impuesto		dec(16,2);
define _gastos_manejo		dec(16,2);
define _credito_sus			dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _debito_sus			dec(16,2);
define _impuesto			dec(16,2);
define _credito				dec(16,2);
define _debito				dec(16,2);
define _monto2				dec(16,2);
define _monto3				dec(16,2);
define _monto				dec(16,2);
define _monto_reas			dec(16,2);
define _fac_comision		dec(16,2);
define _fac_impuesto		dec(16,2);
define _tiene_comis_rea		smallint;
define _tipo_produccion		smallint;
define _aplica_impuesto		smallint;
define _consolida_mayor		smallint;
define _cant_impuestos		smallint;
define _cant_reaseguro		smallint;
define _tipo_contrato		smallint;
define _tipo_comp			smallint;
define _ramo_sis			smallint;
define _traspaso			smallint;
define _decision			smallint;
define _imp_gob				smallint;
define _bouquet				smallint;
define _cantleg				smallint;
define _orden				smallint;
define _error_cod			integer;

------------------------------------------------------------------------------
--                          Tipos de Comprobantes
------------------------------------------------------------------------------
-- 1. Prima Suscrita     
-- 2. Comisiones		 
-- 3. Reaseguro Cedido	 
-- 4. Reaseguro Asumido         
-- 5. Reaseguro Retrocedido	  
-- 6. Reserva Estadistica
-- 7. Reserva Catastrofica
-- 8. Exceso de Perdida
-- 9. Consolidacion entre Compañias
-- 10. Comprobante de Produccion Incendio
-- 11. Comprobante de Produccion Automovil
-- 12. Comprobante de Produccion Fianzas
-- 13. Comprobante de Produccion Personas
-- 14. Comprobante de Produccion Patrimoniales
------------------------------------------------------------------------------

--Set Debug File To "sp_par59.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error_cod 
 	return _error_cod, 'Error al Actualizar el Endoso ' || a_no_poliza || " " || _no_endoso;         
end exception           

{delete from dep_endasiau
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

delete from dep_endasien
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;}

-- generacion de registros contables de las facturas
{select prima_suscrita,
	   prima_bruta,
	   impuesto,
	   prima_neta,
	   cod_tipoprod,
	   cod_endomov,
	   gastos,
	   no_factura
  into _prima_suscrita,
	   _prima_bruta,
	   _impuesto,
	   _prima_neta,
	   _cod_tipoprod,
	   _cod_endomov,
	   _gastos_manejo,
	   _no_factura
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;}

select distinct no_endoso
  into _no_endoso
  from tmp_venc
 where no_poliza = a_no_poliza;

let _prima_neta = 0.00;
let _prima_suscrita = 0.00;
let _no_factura = '';

select sum(y.factor_impuesto) 
  into _factor_impuesto
  from emipolim x, prdimpue y
 where x.no_poliza    = a_no_poliza
   and x.cod_impuesto = y.cod_impuesto
   and y.pagado_por   = "C";

if _factor_impuesto is null then
	let _factor_impuesto = 0.00;
end if

let _factor_impuesto = _factor_impuesto + 100;
let _prima_neta = a_prima_bruta / (_factor_impuesto / 100);

select sum(prima)
  into _prima_suscrita
  from dep_emifacon
 where no_poliza = a_no_poliza;

select cod_ramo,
	   cod_compania,
	   cod_origen,
	   cod_subramo,
	   cod_pagador,
	   cod_tipoprod,
	   gastos
  into _cod_ramo,
	   _cod_compania,
	   _cod_origen,
	   _cod_subramo,
	   _cod_cliente,
	   _cod_tipoprod,
	   _gastos_manejo
  from emipomae
 where no_poliza = a_no_poliza;

-- Tipo de Comprobante
if _cod_ramo in ("001","003") then		
	let _tipo_comp = 10;				-- Incendio
elif _cod_ramo in ("002","020","023") then	
	let _tipo_comp = 11;				-- Autos
elif _cod_ramo in ("008") then			
	let _tipo_comp = 12;				-- Fianzas
elif _cod_ramo in ("004","016","018","019") then	
	let _tipo_comp = 13;				-- Personas
else
	let _tipo_comp = 14;				-- Patrimoniales
end if

select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

select ramo_sis,
	   imp_gob
  into _ramo_sis,
	   _imp_gob
  from prdramo
 where cod_ramo = _cod_ramo;

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = _cod_compania;

select aplica_impuesto
  into _aplica_impuesto
  from parorig
 where cod_origen = _cod_origen;

let _porc_reser_est = 1;
let _porc_reser_cat = 1;

let _porc_reser_est = _porc_reser_est/100;
let _porc_reser_cat = _porc_reser_cat/100;

-- Sin Coaseguro
if _tipo_produccion in (1,2,3) then

	-- Comprobante de Prima Suscrita
	if _tipo_produccion = 2 then -- Coaseguro Mayoritario

		-- Coaseguro por Pagar
		foreach	
			select cod_coasegur,
				   porc_partic_coas
			  into _cod_coasegur,
				   _porc_partic_coas
			  from emicoama
			 where no_poliza    = a_no_poliza
			   and cod_coasegur <> _cod_lider

			let _monto = _prima_neta * (_porc_partic_coas /100);

			if _monto <> 0.00 then

				let _monto   = _monto * -1;
				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0.00 then
					let _debito  = _monto;
				else
					let _credito = _monto;
				end if

				let _cuenta    = sp_sis15("PPCOAMDIF", '01', a_no_poliza);   
				call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
				call sp_par144a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _cod_coasegur, _tipo_comp);
			end if
		end foreach

		-- Prima Bruta
		if a_prima_bruta <> 0.00 then

			let _monto   = _prima_neta;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PAPXCSD', '01', a_no_poliza);
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if			
	elif _tipo_produccion = 3 then -- Coaseguro Minoritario

		-- Cuentas por Cobrar Coaseguro
		if a_prima_bruta <> 0.00 then

			let _monto   = _prima_neta;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15("PACXCC", '01', a_no_poliza);   
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if

	elif _tipo_produccion = 1 then -- Sin Coaseguro

		-- Prima Bruta
		if a_prima_bruta <> 0.00 then

			let _monto   = _prima_neta;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PAPXCSD', '01', a_no_poliza);
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if
	end if

	if _prima_suscrita <> 0.00 then

		let _monto   = _prima_suscrita;
		let _monto   = _monto * -1;
		let _debito  = 0.00;
		let _credito = 0.00;

		if _monto > 0.00 then
			let _debito  = _monto;
		else
			let _credito = _monto;
		end if

		let _cuenta    = sp_sis15('PIPSSD' , '01', a_no_poliza);
		call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
	end if

	if _gastos_manejo <> 0.00 then

--			let _cod_auxiliar = sp_sac203(_cod_cliente);
--			let _cuenta   = sp_sis15('pxcgasma', '01', a_no_poliza); -- esta es la cuenta que falta

		let  _cuenta   = sp_sis15('PGGASMA', '01', a_no_poliza); -- Esta es la cuenta que falta
		let  _debito   = _gastos_manejo;
		let  _credito  = 0;
		call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
--			call sp_par339(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _cod_auxiliar, _tipo_comp);

		let  _cuenta   = sp_sis15('PGGASMA', '01', a_no_poliza);
		let  _debito   = 0;
		let  _credito  = _gastos_manejo * -1;
		call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
	end if

	-- Comprobante de Comisiones			
	foreach 
		select porc_comis_agt,
			   porc_partic_agt,
			   cod_agente
		  into _porc_comis_agt,
			   _porc_partic_agt,
			   _cod_agente
		  from emipoagt
		 where no_poliza = a_no_poliza
		   --and no_endoso = _no_endoso

		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		if _tipo_agente = "O" then
			continue foreach;
		end if

		let _monto = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

		if _monto <> 0.00 then

			-- Gastos de Comision del corredor
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PGCOMCO', '01', a_no_poliza);   
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			-- Honorarios por Pagar Agentes y Corredores (Provision)
			let _monto   = _monto * -1;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PPCOMXPCO', '01', a_no_poliza); 
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if
	end foreach

	if _aplica_impuesto = 1 then -- verifica si a la poliza se le aplican los impuestos (exterior no llevan) 
		if _imp_gob = 1 then -- Verifica si al Ramo se le Aplican los Impuestos

			foreach
				select factor,
					   cta_debito,
					   cta_credito
				  into _factor_impuesto,
					   _cuenta_inc,
					   _cuenta_dan
				  from parimpgo

				let _monto = _prima_suscrita * _factor_impuesto / 100;
				
				if _monto <> 0.00 then

					-- Impuesto 2% sobre gasto para el gobierno
					let _debito  = 0.00;
					let _credito = 0.00;

					if _monto > 0.00 then
						let _debito  = _monto;
					else
						let _credito = _monto;
					end if

					let _cuenta    = sp_sis15(_cuenta_inc, '01', a_no_poliza);    
					call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

					 -- Impuestos Sobre Primas por Pagar 2% del gobierno
					let _monto   = _monto * -1;
					let _debito  = 0.00;
					let _credito = 0.00;

					if _monto > 0.00 then
						let _debito  = _monto;
					else
						let _credito = _monto;
					end if

					let _cuenta    = sp_sis15(_cuenta_dan, '01', a_no_poliza);   
					call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
				end if
			end foreach
		end if
	end if

	select count(*)  	   -- se debe buscar por numero de factura y no por poliza, ya que generaba dos asientos amado 22/05/2013
	  into _cantleg
	  from coboutleg
	 where no_factura = _no_factura;

	if _cantleg > 0 then
		if a_prima_bruta <> 0.00 then

			let _monto   = a_prima_bruta * -1;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PCANCOBL8', '01', a_no_poliza);
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			let _monto   = a_prima_bruta;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PCANCOBL9', '01', a_no_poliza);
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if
	end if
	
	-- Rehabilitación de Pólizas con cancelaciones por Falta de Pago (Cobros Legales) Version 2
	let _cantleg = 0;
	
	select count(*)
	  into _cantleg
	  from coboutlegh
	 where no_factura_rehab = _no_factura;

	if _cantleg > 0 then
		if a_prima_bruta <> 0.00 then

			select decision,
				   no_factura			   
			  into _decision,
				   _no_factura_canc
			  from coboutlegh
			 where no_poliza = a_no_poliza;
			
			foreach
				select prima_bruta
				  into _prima_bruta_canc
				  from endedmae
				 where no_poliza = a_no_poliza
				   and no_factura = _no_factura_canc
				 order by no_endoso desc
			end foreach
			
			if _decision = 1 then
				let a_prima_bruta = _prima_bruta_canc * -1;
			end if
			
			let _monto   = a_prima_bruta;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PCANCOBL9', '01', a_no_poliza);
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			let _monto   = a_prima_bruta * -1;
			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0.00 then
				let _debito  = _monto;
			else
				let _credito = _monto;
			end if

			let _cuenta    = sp_sis15('PCANCOBL8', '01', a_no_poliza);
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		end if
	end if

-- Reaseguro Asumido
elif _tipo_produccion = 4 then 	 

	-- Prima Suscrita Reaseguro Asumido
	if _prima_suscrita <> 0.00 then
		let _monto2    = _prima_suscrita;
		let _cuenta    = sp_sis15('PIPSRA' , '01', a_no_poliza);
		let _debito    = 0.00;
		let _credito   = _prima_suscrita;
		let _tipo_comp = 4;
		call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		select porc_comis_ra,
			   porc_impuesto
		  into _porc_comis_agt,
			   _porc_partic_agt
		  from emiciara
		 where no_poliza = a_no_poliza;

		-- Comisiones Pagadas Reaseguro Asumido
		let _monto = (_porc_comis_agt / 100) * _prima_suscrita;
		if _monto <> 0.00 then
			let _monto2    = _monto2 - _monto;
			let _cuenta    = sp_sis15('PPCPRA' , '01', a_no_poliza);
			let _debito    = _monto;
			let _credito   = 0.00;
			let _tipo_comp = 4;
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if

		-- Impuesto sobre prima reaseguro asumido
		let _monto = (_porc_partic_agt / 100) * _prima_suscrita;
		if _monto <> 0.00 then
			let _monto2    = _monto2 - _monto;
			let _cuenta    = sp_sis15('PPIPRA' , '01', a_no_poliza);
			let _debito    = _monto;
			let _credito   = 0.00;
			let _tipo_comp = 4;
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if

		-- Primas por Cobrar Reaseguro Asumido
		let _cuenta    = sp_sis15('PAPXCRA' , '01', a_no_poliza);
		let _debito    = _monto2;
		let _credito   = 0.00;
		let _tipo_comp = 4;
		call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
	end if

	-- Comprobante de Retrocesion
	foreach
		select cod_contrato,
			   prima,
			   cod_cober_reas
		  into _cod_contrato,
			   _monto,
			   _cod_cober_reas
		  from dep_emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = _no_endoso

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 then
			continue foreach;
		end if

		select porc_impuesto,
			   porc_comision,
			   cuenta
		  into _factor_impuesto,
			   _porc_comis_agt,
			   _cuenta_cat	
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;
		
		if _monto <> 0.00 then
			-- Reaseguro Cedido en Retrocesion
			let _monto3    = _monto;
			let _cuenta    = sp_sis15("PGREARET", '01', a_no_poliza);   
			let _debito    = _monto;
			let _credito   = 0.00;
			let _tipo_comp = 5;
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			-- Comision Ganada
			let _monto2 = _monto * _porc_comis_agt / 100;

			if _monto2 <> 0.00 then
				let _monto3    = _monto3 - _monto2;
				let _cuenta    = sp_sis15("PICGRET", '01', a_no_poliza);   
				let _debito    = 0.00;
				let _credito   = _monto2;
				let _tipo_comp = 5;
				call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			end if

			-- Impuesto Recuperado
			let _monto2 = _monto * _factor_impuesto / 100;
			if _monto2 <> 0.00 then
				let _monto3    = _monto3 - _monto2;
				let _cuenta    = sp_sis15("PIIRRET", '01', a_no_poliza);   
				let _debito    = 0.00;
				let _credito   = _monto2;
				let _tipo_comp = 5;
				call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			end if

			-- Reaseguro por Pagar
			let _cuenta    = _cuenta_cat;   
			let _debito    = 0.00;
			let _credito   = _monto3;
			let _tipo_comp = 5;
			call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
		end if
	end foreach
end if

select sum(debito + credito)
  into _monto
  from dep_endasien
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

if _monto <> 0.00 then
	let _cuenta  = sp_sis15('PAPXCSD', '01', a_no_poliza);
	let _debito  = 0.00;
	let _credito = 0.00;

	select debito,
		   credito
	  into _debito_sus,
		   _credito_sus
	  from dep_endasien
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cuenta    = _cuenta;

	if _debito_sus <> 0.00 then
		let _debito  = _monto * -1;
	else
		let _credito = _monto * -1;
	end if

	call sp_par60a(a_no_poliza, _no_endoso, _cuenta, _debito, _credito, _tipo_comp);
end if
 		
delete from dep_endasien
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso
   and debito    = 0.00
   and credito   = 0.00;

let _error_cod  = 0;
let _error_desc = "Actualizacion Exitosa ...";

return _error_cod, _error_desc;

end
end procedure;