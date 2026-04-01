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

DROP PROCEDURE sp_sis3en101;		

CREATE PROCEDURE "informix".sp_sis3en101(a_no_poliza CHAR(10), a_no_endoso CHAR(5))
RETURNING INTEGER,
		  CHAR(100);
		  	
DEFINE _no_poliza        CHAR(10); 
DEFINE _no_endoso        CHAR(5);
DEFINE _cuenta           CHAR(25);
DEFINE _debito           DEC(16,2);
DEFINE _credito          DEC(16,2);
DEFINE _tipo_comp        SMALLINT;

DEFINE _prima_suscrita	 DEC(16,2);
DEFINE _prima_bruta  	 DEC(16,2);
DEFINE _prima_neta  	 DEC(16,2);
DEFINE _impuesto		 DEC(16,2);
DEFINE _suma_impuesto	 DEC(16,2);
DEFINE _gastos_manejo  	 DEC(16,2);
define _cod_cliente		 char(10);

DEFINE _cod_impuesto	 CHAR(3);
DEFINE _cod_tipoprod	 CHAR(3);
DEFINE _tipo_produccion  SMALLINT;
DEFINE _monto			 DEC(16,2);
DEFINE _monto2			 DEC(16,2);
DEFINE _monto3			 DEC(16,2);

DEFINE _factor_impuesto	 DEC(5,2);

DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);

DEFINE _porc_comis_agt   DECIMAL(5,2);
DEFINE _porc_comis_ase   DECIMAL(5,2);
define _tiene_comis_rea	 smallint;
DEFINE _porc_partic_agt	 DECIMAL(5,2);
DEFINE _cuenta_inc       CHAR(25);
DEFINE _cuenta_dan       CHAR(25);
DEFINE _ramo_sis		 SMALLINT;
DEFINE _cod_contrato	 CHAR(5);
DEFINE _cod_traspaso	 CHAR(5);
define _traspaso		 smallint;

DEFINE _tipo_contrato    SMALLINT;
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _cuenta_cat       CHAR(25);   
DEFINE _cod_lider		 CHAR(3);
DEFINE _cod_compania	 CHAR(3);
DEFINE _error_cod		 INTEGER;
DEFINE _error_desc		 CHAR(100);
DEFINE _imp_gob          SMALLINT;
DEFINE _no_unidad		 CHAR(5);
DEFINE _orden			 SMALLINT;
DEFINE _porc_reser_est   DECIMAL(5,2);  -- Porcentaje de Reserva Estadistica
DEFINE _porc_reser_cat   DECIMAL(5,2);	-- Porcentaje de Reserva Catastrofica
DEFINE _cod_origen		 CHAR(3);
DEFINE _cod_origen_aseg	 CHAR(3);
DEFINE _aplica_impuesto  SMALLINT;
DEFINE _cant_impuestos   SMALLINT;
DEFINE _cant_reaseguro   SMALLINT;

define _debito_sus		 dec(16,2);
define _credito_sus		 dec(16,2);
define _cod_endomov		 char(3);
define _cod_coasegur	 char(3);
define _consolida_mayor	 smallint;
define _tipo_agente		 char(1);
define _cod_agente		 char(5);
define _cod_auxiliar	 char(5);

define _porc_cont_partic	dec(5,2);
define _monto_reas		 dec(16,2);
define _fac_comision	 dec(16,2);
define _fac_impuesto	 dec(16,2);
define _bouquet			 smallint;
define _aux_bouquet		 char(5);

define _no_factura			char(10);
define _no_factura_canc		char(10);
define _cantleg				smallint;
define _decision			smallint;
define _prima_bruta_canc	dec(16,2);

------------------------------------------------------------------------------
--                          Tipos de Comprobantes
------------------------------------------------------------------------------
-- 1. 	Prima Suscrita     
-- 2. 	Comisiones		 
-- 3. 	Reaseguro Cedido	 
-- 4. 	Reaseguro Asumido         
-- 5. 	Reaseguro Retrocedido	  
-- 6. 	Reserva Estadistica
-- 7. 	Reserva Catastrofica
-- 8. 	Exceso de Perdida
-- 9. 	Consolidacion entre Compañias

-- 10.	Comprobante de Produccion Incendio
-- 11.	Comprobante de Produccion Automovil
-- 12.	Comprobante de Produccion Fianzas
-- 13.	Comprobante de Produccion Personas
-- 14.	Comprobante de Produccion Patrimoniales
 
------------------------------------------------------------------------------

--Set Debug File To "sp_par59.trc";
--trace on;

Set Isolation To Dirty Read;

BEGIN

ON EXCEPTION SET _error_cod 
 	RETURN _error_cod, 'Error al Actualizar el Endoso ' || a_no_poliza || " " || a_no_endoso;         
END EXCEPTION           

delete from endasiau
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endasien
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

-- Generacion de Registros Contables de las Facturas

 SELECT	cod_endomov,
		no_factura,
		cod_tipoprod
   INTO	_cod_endomov,
		_no_factura,
		_cod_tipoprod
   FROM	endedmae
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = a_no_endoso;

	SELECT cod_ramo,
		   cod_compania,
		   cod_origen,
		   cod_subramo,
		   cod_pagador	   
	  INTO _cod_ramo,
		   _cod_compania,
		   _cod_origen,
		   _cod_subramo,
		   _cod_cliente	   
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;
	
foreach
		 SELECT no_unidad,
				prima_suscrita,
				prima_bruta,
				impuesto,
				prima_neta,
				gastos
		   into _no_unidad,
		        _prima_suscrita,
				_prima_bruta,
				_impuesto,
				_prima_neta,
				_gastos_manejo
		   FROM	endeduni
          WHERE	no_poliza = a_no_poliza
            AND no_endoso = a_no_endoso
			
		select cod_ramo
		  into _cod_ramo
		  from emipouni
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;
	
	-- Tipo de Comprobante

	if _cod_ramo in ("001", "003") then		
		let _tipo_comp = 10;				-- Incendio
	elif _cod_ramo in ("002", "020", "023") then	
		let _tipo_comp = 11;				-- Autos
	elif _cod_ramo in ("008") then			
		let _tipo_comp = 12;				-- Fianzas
	elif _cod_ramo in ("004", "016", "018", "019") then	
		let _tipo_comp = 13;				-- Personas
	else
		let _tipo_comp = 14;				-- Patrimoniales
	end if

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	SELECT ramo_sis,
	       imp_gob
	  INTO _ramo_sis,
	       _imp_gob
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT par_ase_lider
	  INTO _cod_lider
	  FROM parparam
	 WHERE cod_compania = _cod_compania;

	SELECT aplica_impuesto
	  INTO _aplica_impuesto
	  FROM parorig
	 WHERE cod_origen = _cod_origen;

	let _porc_reser_est = 1;
	let _porc_reser_cat = 1;

	let _porc_reser_est = _porc_reser_est/100;
	let _porc_reser_cat = _porc_reser_cat/100;

 	-- Sin Coaseguro

	If _tipo_produccion = 1 Or 
	   _tipo_produccion = 2 Or
	   _tipo_produccion = 3 Then
	
		-- Comprobante de Prima Suscrita

		If _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

			-- Coaseguro por Pagar

		   foreach	
			select cod_coasegur,
			       prima
			  into _cod_coasegur,
			       _monto
			  from endcoama
			 where no_poliza    = a_no_poliza
		   	   and no_endoso    = a_no_endoso
	    	   and cod_coasegur <> _cod_lider

				If _monto <> 0.00 Then

					Let _monto   = _monto * -1;
					Let _debito  = 0.00;
					Let _credito = 0.00;

					if _monto > 0.00 then
						Let _debito  = _monto;
					else
						Let _credito = _monto;
					end if

					--Let _cuenta    = sp_sis15("PPCOAMDIF", '01', a_no_poliza); 
					Let  _cuenta    = sp_sis15("PPCOAMDIF", '04', _cod_origen,_cod_ramo,_cod_subramo); 
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
					CALL sp_par144(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _cod_coasegur, _tipo_comp);

				End If

			end foreach

			-- Prima Bruta

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_neta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15('PAPXCSD', '01', a_no_poliza);
				Let _cuenta    = sp_sis15('PAPXCSD', '04', _cod_origen,_cod_ramo,_cod_subramo);
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If	
		
		Elif _tipo_produccion = 3 THEN -- Coaseguro Minoritario

			-- Cuentas por Cobrar Coaseguro

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_neta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15("PACXCC", '01', a_no_poliza); 
				Let _cuenta    = sp_sis15("PACXCC", '04', _cod_origen,_cod_ramo,_cod_subramo);				
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If

		Elif _tipo_produccion = 1 THEN -- Sin Coaseguro

			-- Prima Bruta

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_neta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15('PAPXCSD', '01', a_no_poliza);
				Let _cuenta    = sp_sis15('PAPXCSD', '04', _cod_origen,_cod_ramo,_cod_subramo);
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If

		End If

		If _prima_suscrita <> 0.00 Then

	    	Let _monto   = _prima_suscrita;
			Let _monto   = _monto * -1;
			Let _debito  = 0.00;
			Let _credito = 0.00;

			if _monto > 0.00 then
				Let _debito  = _monto;
			else
				Let _credito = _monto;
			end if

			--Let _cuenta    = sp_sis15('PIPSSD' , '01', a_no_poliza);
			Let _cuenta    = sp_sis15('PIPSSD', '04', _cod_origen,_cod_ramo,_cod_subramo);
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		End If

		if _gastos_manejo <> 0.00 then

--			let _cod_auxiliar = sp_sac203(_cod_cliente);
--			let _cuenta   = sp_sis15('PXCGASMA', '01', a_no_poliza); -- Esta es la cuenta que falta

			--LET  _cuenta   = sp_sis15('PGGASMA', '01', a_no_poliza); -- Esta es la cuenta que falta
			LET  _cuenta   = sp_sis15('PGGASMA', '04', _cod_origen,_cod_ramo,_cod_subramo); -- Esta es la cuenta que falta
			LET  _debito   = _gastos_manejo;
			LET  _credito  = 0;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
--			CALL sp_par339(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _cod_auxiliar, _tipo_comp);

			--LET  _cuenta   = sp_sis15('PGGASMA', '01', a_no_poliza);
			LET  _cuenta   = sp_sis15('PGGASMA', '04', _cod_origen,_cod_ramo,_cod_subramo);
			LET  _debito   = 0;
			LET  _credito  = _gastos_manejo * -1;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		end if

		-- Comprobante de Comisiones
			
	    Foreach 
		 Select	porc_comis_agt,
				porc_partic_agt,
				cod_agente
		   Into	_porc_comis_agt,
				_porc_partic_agt,
				_cod_agente
		   From endmoage
		  Where	no_poliza = a_no_poliza
		    and no_endoso = a_no_endoso

			select tipo_agente
			  into _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			if _tipo_agente = "O" then
				continue foreach;
			end if

			Let _monto = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

			If _monto <> 0.00 Then

				-- Gastos de Comision del corredor

				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15('PGCOMCO', '01', a_no_poliza);  
				Let _cuenta    = sp_sis15('PGCOMCO', '04', _cod_origen,_cod_ramo,_cod_subramo); 				
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
																			  
				-- Honorarios por Pagar Agentes y Corredores (Provision)

				Let _monto   = _monto * -1;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15('PPCOMXPCO', '01', a_no_poliza); 
				Let _cuenta    = sp_sis15('PPCOMXPCO', '04', _cod_origen,_cod_ramo,_cod_subramo); 
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If

	    End Foreach

		If _aplica_impuesto = 1 Then -- Verifica si a la Poliza se le Aplican los Impuestos (Exterior No Llevan) 

			If _imp_gob = 1 Then -- Verifica si al Ramo se le Aplican los Impuestos

				Foreach
				 Select factor,
				        cta_debito,
						cta_credito
				   Into _factor_impuesto,
						_cuenta_inc,
						_cuenta_dan
				   From parimpgo

					Let _monto = _prima_suscrita * _factor_impuesto / 100;
					
					If _monto <> 0.00 Then

						-- Impuesto 2% sobre gasto para el gobierno

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto > 0.00 then
							Let _debito  = _monto;
						else
							Let _credito = _monto;
						end if

						--Let _cuenta    = sp_sis15(_cuenta_inc, '01', a_no_poliza);
						Let _cuenta    = sp_sis15(_cuenta_inc, '04', _cod_origen,_cod_ramo,_cod_subramo); 					
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

						 -- Impuestos Sobre Primas por Pagar 2% del gobierno

						Let _monto   = _monto * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto > 0.00 then
							Let _debito  = _monto;
						else
							Let _credito = _monto;
						end if

						--Let _cuenta    = sp_sis15(_cuenta_dan, '01', a_no_poliza);   
						Let _cuenta    = sp_sis15(_cuenta_dan, '04', _cod_origen,_cod_ramo,_cod_subramo);  
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
					End If

				End Foreach

			End If

		End If

	-- Cancelaciones por Falta de Pago (Cobros Legales)	
--Set Debug File To "sp_par59.trc";
--trace on;
	-- Verificacion a la tabla de cobros legales
	--    SELECT count(*)  
	--      INTO _cantleg
	--	  FROM coboutleg
	--	 WHERE no_poliza = a_no_poliza;

	    SELECT count(*)  	   -- Se debe buscar por numero de factura y no por poliza, ya que generaba dos asientos Amado 22/05/2013
	      INTO _cantleg
		  FROM coboutleg
		 WHERE no_factura = _no_factura;

		If _cantleg > 0 Then 

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_bruta * -1;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15('PCANCOBL8', '01', a_no_poliza);
				Let _cuenta    = sp_sis15('PCANCOBL8', '04', _cod_origen,_cod_ramo,_cod_subramo);  
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		    	Let _monto   = _prima_bruta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				--Let _cuenta    = sp_sis15('PCANCOBL9', '01', a_no_poliza);
				Let _cuenta    = sp_sis15('PCANCOBL9', '04', _cod_origen,_cod_ramo,_cod_subramo);
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If
		End If
		
		-- Rehabilitación de Pólizas con cancelaciones por Falta de Pago (Cobros Legales) Version 2
		let _cantleg = 0;
		
		select count(*)
		  into _cantleg
		  from coboutlegh
		 where no_factura_rehab = _no_factura;

		if _cantleg > 0 then
			if _prima_bruta <> 0.00 then
								
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
					let _prima_bruta = _prima_bruta_canc * -1;
				end if
				
				let _monto   = _prima_bruta;
				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0.00 then
					let _debito  = _monto;
				else
					let _credito = _monto;
				end if

				--let _cuenta    = sp_sis15('PCANCOBL9', '01', a_no_poliza);
				let _cuenta    = sp_sis15('PCANCOBL9', '04', _cod_origen,_cod_ramo,_cod_subramo);
				call sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				let _monto   = _prima_bruta * -1;
				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0.00 then
					let _debito  = _monto;
				else
					let _credito = _monto;
				end if

				--let _cuenta    = sp_sis15('PCANCOBL8', '01', a_no_poliza);
				let _cuenta    = sp_sis15('PCANCOBL8', '04', _cod_origen,_cod_ramo,_cod_subramo);
				call sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			end if
		end if

	-- Reaseguro Asumido

	Elif _tipo_produccion = 4 THEN 	 

		-- Prima Suscrita Reaseguro Asumido

		If _prima_suscrita <> 0.00 Then
			Let _monto2    = _prima_suscrita;
			--Let _cuenta    = sp_sis15('PIPSRA' , '01', a_no_poliza);
			Let _cuenta    = sp_sis15('PIPSRA' , '04', _cod_origen,_cod_ramo,_cod_subramo);
			Let _debito    = 0.00;
			Let _credito   = _prima_suscrita;
			Let _tipo_comp = 4;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			Select porc_comis_ra,
			       porc_impuesto
		      into _porc_comis_agt,
			       _porc_partic_agt
			  from emiciara
			 where no_poliza = a_no_poliza;

		    -- Comisiones Pagadas Reaseguro Asumido
			Let _monto = (_porc_comis_agt / 100) * _prima_suscrita;
			If _monto <> 0.00 Then
				Let _monto2    = _monto2 - _monto;
				--Let _cuenta    = sp_sis15('PPCPRA' , '01', a_no_poliza);
				Let _cuenta    = sp_sis15('PPCPRA', '04', _cod_origen,_cod_ramo,_cod_subramo);
				Let _debito    = _monto;
				Let _credito   = 0.00;
				Let _tipo_comp = 4;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			End If

			-- Impuesto sobre prima reaseguro asumido
			Let _monto = (_porc_partic_agt / 100) * _prima_suscrita;
			If _monto <> 0.00 Then
				Let _monto2    = _monto2 - _monto;
				--Let _cuenta    = sp_sis15('PPIPRA' , '01', a_no_poliza);
				Let _cuenta    = sp_sis15('PPIPRA', '04', _cod_origen,_cod_ramo,_cod_subramo);
				Let _debito    = _monto;
				Let _credito   = 0.00;
				Let _tipo_comp = 4;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			End If

			-- Primas por Cobrar Reaseguro Asumido
		--	Let _cuenta    = sp_sis15('PAPXCRA' , '01', a_no_poliza);
			Let _cuenta    = sp_sis15('PAPXCRA', '04', _cod_origen,_cod_ramo,_cod_subramo);			
			Let _debito    = _monto2;
			Let _credito   = 0.00;
			Let _tipo_comp = 4;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		End If

	    -- Comprobante de Retrocesion

  		Foreach
		 Select cod_contrato,
		        prima,
				cod_cober_reas
		   Into _cod_contrato,
		        _monto,
				_cod_cober_reas
		   From emifacon
		  Where no_poliza = a_no_poliza
		    And no_endoso = a_no_endoso

			Select tipo_contrato
			  Into _tipo_contrato
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			If _tipo_contrato = 1 Then
				Continue Foreach;
			End If

			Select porc_impuesto,
			       porc_comision,
				   cuenta
			  Into _factor_impuesto,
				   _porc_comis_agt,
				   _cuenta_cat	
			  From reacocob
			 Where cod_contrato   = _cod_contrato
			   And cod_cober_reas = _cod_cober_reas;
			
			If _monto <> 0.00 Then
				-- Reaseguro Cedido en Retrocesion
				Let _monto3    = _monto;
				--Let _cuenta    = sp_sis15("PGREARET", '01', a_no_poliza);  
				Let _cuenta    = sp_sis15("PGREARET", '04', _cod_origen,_cod_ramo,_cod_subramo);				
				Let _debito    = _monto;
				Let _credito   = 0.00;
				Let _tipo_comp = 5;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				-- Comision Ganada
				Let _monto2 = _monto * _porc_comis_agt / 100;
				If _monto2 <> 0.00 Then
					Let _monto3    = _monto3 - _monto2;
					--Let _cuenta    = sp_sis15("PICGRET", '01', a_no_poliza);   
					Let _cuenta    = sp_sis15("PICGRET", '04', _cod_origen,_cod_ramo,_cod_subramo); 
					Let _debito    = 0.00;
					Let _credito   = _monto2;
					Let _tipo_comp = 5;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
				End If

				-- Impuesto Recuperado
				Let _monto2 = _monto * _factor_impuesto / 100;
				If _monto2 <> 0.00 Then
					Let _monto3    = _monto3 - _monto2;
					--Let _cuenta    = sp_sis15("PIIRRET", '01', a_no_poliza);   
					Let _cuenta    = sp_sis15("PIIRRET", '04', _cod_origen,_cod_ramo,_cod_subramo); 
					Let _debito    = 0.00;
					Let _credito   = _monto2;
					Let _tipo_comp = 5;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
				End If

				-- Reaseguro por Pagar
				Let _cuenta    = _cuenta_cat;   
				Let _debito    = 0.00;
				Let _credito   = _monto3;
				Let _tipo_comp = 5;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			End If
		End Foreach
	End If

 	select sum(debito + credito)
	  into _monto
	  from endasien
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;

	If _monto <> 0.00 Then
		--Let _cuenta  = sp_sis15('PAPXCSD', '01', a_no_poliza);
		Let _cuenta  = sp_sis15('PAPXCSD', '04', _cod_origen,_cod_ramo,_cod_subramo); 
		Let _debito  = 0.00;
		Let _credito = 0.00;

		select debito,
		       credito
		  into _debito_sus,
		       _credito_sus
		  from endasien
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and cuenta    = _cuenta;

		if _debito_sus <> 0.00 then
			Let _debito  = _monto * -1;
		else
			Let _credito = _monto * -1;
		end if

		CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
	End If
 		
	delete from endasien
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and debito    = 0.00
	   and credito   = 0.00;
	   
end foreach	

	Let _error_cod  = 0;
	Let _error_desc = "Actualizacion Exitosa ...";
	Return _error_cod, _error_desc;

END

END PROCEDURE;
