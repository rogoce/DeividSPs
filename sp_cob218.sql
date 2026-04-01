-- Procedimiento que simula la cancelacion de cobros
-- 
-- Creado     : 06/11/2009 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob218;		

CREATE PROCEDURE "informix".sp_cob218()
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

define _porc_cont_partic dec(5,2);
define _monto_reas		 dec(16,2);
define _fac_comision	 dec(16,2);
define _fac_impuesto	 dec(16,2);

define _poliza			 char(20);
define _saldo			 dec(16,2);
define _factor_imp		 dec(16,5);
define _factor_imp_pol	 dec(16,5);
DEFINE _porc_partic_coas DECIMAL(5,2);
define _porc_partic_prima dec(16,6);
DEFINE _porc_partic_reas DECIMAL(5,2);
DEFINE _porc_res_mat	 DECIMAL(5,2);
define _no_cambio 		 smallint;

DEFINE _error_cod		 INTEGER;
DEFINE _error_isam		 INTEGER;
DEFINE _error_desc		 CHAR(100);

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
------------------------------------------------------------------------------

--Set Debug File To "sp_cob218.trc";
--trace on;

Set Isolation To Dirty Read;

BEGIN

ON EXCEPTION SET _error_cod, _error_isam, _error_desc 
 	RETURN _error_cod, _error_desc;         
END EXCEPTION           

delete from deivid_tmp:cobincasi;

foreach
 SELECT	poliza
   INTO	_poliza
   FROM	deivid_tmp:cobinc0911
--  where poliza = "0407-00111-01"

	let _saldo       = sp_cob174(_poliza);
	let _prima_bruta = _saldo;
	let _no_poliza   = sp_sis21(_poliza);

	let _gastos_manejo = 0.00;

	SELECT cod_ramo,
		   cod_compania,
		   cod_origen,
		   cod_subramo,
		   cod_tipoprod	
	  INTO _cod_ramo,
		   _cod_compania,
		   _cod_origen,
		   _cod_subramo,
		   _cod_tipoprod	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	SELECT ramo_sis,
	       imp_gob,
		   porc_res_mat
	  INTO _ramo_sis,
	       _imp_gob,
		   _porc_res_mat
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

	let _factor_imp_pol = 0;

	foreach
	 select cod_impuesto
	   into _cod_impuesto
	   from emipolim
	  where no_poliza = _no_poliza

		select factor_impuesto
		  into _factor_imp
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;

			let _factor_imp_pol = _factor_imp_pol + _factor_imp;

	end foreach

	let _factor_imp_pol = _factor_imp_pol / 100;
	let _factor_imp_pol = _factor_imp_pol + 1;

	let _prima_neta     = _saldo / _factor_imp_pol;

	select porc_partic_coas
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = _cod_lider;

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

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
			       porc_partic_coas
			  into _cod_coasegur,
			       _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
	    	   and cod_coasegur <> _cod_lider

			    -- Calculo del impuesto

				Let _suma_impuesto = 0.00;
				let _monto = _prima_neta * _porc_partic_coas;
				let _monto = _monto + _suma_impuesto;

				If _monto <> 0.00 Then

					Let _monto   = _monto * -1;
					Let _debito  = 0.00;
					Let _credito = 0.00;

					if _monto > 0.00 then
						Let _debito  = _monto;
					else
						Let _credito = _monto;
					end if

					Let _cuenta    = sp_sis15("PPCOASXP", '01', _no_poliza);   
					Let _tipo_comp = 1;
					CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

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

				Let _cuenta    = sp_sis15('PAPXCSD', '01', _no_poliza);
				Let _tipo_comp = 1;
				CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

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

				Let _cuenta    = sp_sis15("PACXCC", '01', _no_poliza);   
				Let _tipo_comp = 1;
				CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

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

				Let _cuenta    = sp_sis15('PAPXCSD', '01', _no_poliza);
				Let _tipo_comp = 1;
				CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

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

			Let _cuenta    = sp_sis15('PIPSSD' , '01', _no_poliza);
			Let _tipo_comp = 1;
			CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

		End If

		if _gastos_manejo <> 0.00 then

			LET  _cuenta   = sp_sis15('PGGASMA', '01', _no_poliza); -- Esta es la cuenta que falta
			LET  _debito   = _gastos_manejo;
			LET  _credito  = 0;
			Let _tipo_comp = 1;
			CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

			LET  _cuenta   = sp_sis15('PGGASMA', '01', _no_poliza);
			LET  _debito   = 0;
			LET  _credito  = _gastos_manejo * -1;
			Let _tipo_comp = 1;
			CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

		end if

		-- Comprobante de Comisiones
			
	    Foreach 
		 Select	porc_comis_agt,
				porc_partic_agt,
				cod_agente
		   Into	_porc_comis_agt,
				_porc_partic_agt,
				_cod_agente
		   From emipoagt
		  Where	no_poliza = _no_poliza

			select tipo_agente
			  into _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			-- Solo procesa las comisiones para los Agentes normales, para los especiales y para oficina,
			-- no genera registro de comisiones

			if _tipo_agente <> "A" then
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

				Let _cuenta    = sp_sis15('PGCOMCO', '01', _no_poliza);   
				Let _tipo_comp = 2;
				CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);
																			  
				-- Honorarios por Pagar Agentes y Corredores (Provision)

				Let _monto   = _monto * -1;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _cuenta    = sp_sis15('PPCOMXPCO', '01', _no_poliza); 
				Let _tipo_comp = 2;
				CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

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

						Let _cuenta    = sp_sis15(_cuenta_inc, '01', _no_poliza);    
						Let _tipo_comp = 2;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

						 -- Impuestos Sobre Primas por Pagar 2% del gobierno

						Let _monto   = _monto * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto > 0.00 then
							Let _debito  = _monto;
						else
							Let _credito = _monto;
						end if

						Let _cuenta    = sp_sis15(_cuenta_dan, '01', _no_poliza);   
						Let _tipo_comp = 2;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);
					End If

				End Foreach

			End If

		End If

	    -- Comprobante de Reaseguro Cedido

		select count(*)
		  into _cant_reaseguro
		  from emireaco
		 where no_poliza = _no_poliza;

		if _cant_reaseguro = 0     and
		   _prima_suscrita <> 0.00 Then

			return 1, "No Existe Distribucion de Reaseguro";

		end if

		select min(no_unidad)
		  into _no_unidad
		  from emireaco
		 where no_poliza = _no_poliza;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		select min(cod_cober_reas)
		  into _cod_cober_reas
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio;

  		Foreach
		 Select cod_contrato,
		        porc_partic_prima,
				cod_cober_reas,
				no_unidad,
				orden
		   Into _cod_contrato,
		        _porc_partic_prima,
				_cod_cober_reas,
				_no_unidad,
				_orden
		   From emireaco
		  Where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and no_cambio = _no_cambio
			and cod_cober_reas = _cod_cober_reas

			let _monto = _prima_suscrita * _porc_partic_prima / 100;

			select traspaso
			  into _traspaso
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			Select tipo_contrato,
			       porc_impuesto,
				   cod_traspaso
		      Into _tipo_contrato,
			       _factor_impuesto,
				   _cod_traspaso
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			if _traspaso = 1 then

				let _cod_contrato = _cod_traspaso;

				Select tipo_contrato,
				       porc_impuesto
				  Into _tipo_contrato,
				       _factor_impuesto
				  From reacomae
				 Where cod_contrato = _cod_contrato;

			end if

			If _tipo_contrato = 1 Then -- Contrato de Retencion

				-- Reservas Estadisticas, Catastroficas y Matematica

				If _monto <> 0.00 then

					-- Reserva Estadistica

					let _monto3 = _monto * _porc_reser_est;

					if _monto3 <> 0.00 then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PGRPPDE", '01', _no_poliza);   
						Let _tipo_comp = 6;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

						let _monto3  = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PPRPPDE", '01', _no_poliza);   
						Let _tipo_comp = 6;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					end if
					
					-- Reserva Catastrofica

					let _monto3 = _monto * _porc_reser_est;

					if _monto3 <> 0.00 then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PGRPRC", '01', _no_poliza);   
						Let _tipo_comp = 7;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

						let _monto3  = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PPRPRC", '01', _no_poliza);   
						Let _tipo_comp = 7;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					end if

					-- Reserva Matematica y Tecnica

					let _monto3 = _monto * _porc_res_mat / 100;

					if _monto3 <> 0.00 then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PGPRMT", '01', _no_poliza);   
						Let _tipo_comp = 6;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

						let _monto3  = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PPPRMT", '01', _no_poliza);   
						Let _tipo_comp = 6;
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					end if

				end if

			elif _tipo_contrato = 3 Then -- Contratos Facultativos

--				return 1, _poliza || " " || _no_poliza || " Hay Contratos Facultativos";

--{
				Foreach
				 Select porc_partic_reas,
				        porc_impuesto,
						porc_comis_fac,
						cod_coasegur
				   Into _porc_partic_reas,
						_factor_impuesto,
				   		_porc_comis_agt,
						_cod_coasegur
				   From emireafa
				  Where no_poliza      = _no_poliza
					And no_unidad      = _no_unidad
					And cod_cober_reas = _cod_cober_reas
					And orden		   = _orden
					
					let _monto = _prima_suscrita * _porc_partic_prima / 100;
					let _monto = _monto * _porc_partic_reas / 100;

					select consolida_mayor,
					       cod_origen
					  into _consolida_mayor,
					       _cod_origen_aseg
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _consolida_mayor = 1 then
						Let _tipo_comp = 9;
					else
						Let _tipo_comp = 3;
					end if

					-- Reaseguro Cedido

					Let _monto3 = _monto;

					If _monto <> 0.00 Then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto > 0.00 then
							Let _debito  = _monto;
						else
							Let _credito = _monto;
						end if

						Let _cuenta    = sp_sis15("PGRCSD", '01', _no_poliza);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

					-- Comision Ganada

					Let _monto2 = _monto * _porc_comis_agt / 100;

					If _monto2 <> 0.00 Then

						Let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto2 > 0.00 then
							Let _debito  = _monto2;
						else
							Let _credito = _monto2;
						end if

						Let _cuenta    = sp_sis15("PICGRCSD", '01', _no_poliza);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

					-- Impuesto Recuperado

					Let _monto2 = _monto * _factor_impuesto / 100;

					If _monto2 <> 0.00 Then

						Let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto2 > 0.00 then
							Let _debito  = _monto2;
						else
							Let _credito = _monto2;
						end if

						Let _cuenta    = sp_sis15("PIIRRCSD", '01', _no_poliza);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

					-- Reaseguro por Pagar

					If _monto3 <> 0.00 Then

						let _monto3	 = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						let _cuenta = sp_sis15("PPRXP", "05", _cod_origen, _cod_ramo, _cod_subramo);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

				End Foreach
--}

			else -- Otros Contratos

				Select porc_impuesto,
				       porc_comision,
					   cuenta,
					   cod_coasegur,
					   tiene_comision
				  Into _factor_impuesto,
					   _porc_comis_agt,
					   _cuenta_cat,
					   _cod_coasegur,
					   _tiene_comis_rea
				  From reacocob
				 Where cod_contrato   = _cod_contrato
				   And cod_cober_reas = _cod_cober_reas;
				
				foreach
				 select cod_coasegur,
				        porc_cont_partic,
						porc_comision
				   into _cod_coasegur,
				        _porc_cont_partic,
						_porc_comis_ase
				   from reacoase
			      where cod_contrato   = _cod_contrato
			        and cod_cober_reas = _cod_cober_reas
					
					-- La comision se calcula por reasegurador

					if _tiene_comis_rea = 2 then 
						let _porc_comis_agt = _porc_comis_ase;
					end if

					select consolida_mayor
					  into _consolida_mayor
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _consolida_mayor = 1 then
						Let _tipo_comp = 9;
					else
						Let _tipo_comp = 3;
					end if

					-- Reaseguro Cedido
					
					let _monto_reas = _monto * _porc_cont_partic / 100;
					let _monto3     = _monto_reas;

					If _monto_reas <> 0.00 Then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto > 0.00 then
							Let _debito  = _monto_reas;
						else
							Let _credito = _monto_reas;
						end if

						Let _cuenta    = sp_sis15("PGRCSD", '01', _no_poliza);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

					-- Comision Ganada

					Let _monto2 = _monto_reas * _porc_comis_agt / 100;

					If _monto2 <> 0.00 Then

						Let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						Let _debito  = 0.00;
					
						Let _credito = 0.00;

						if _monto2 > 0.00 then
							Let _debito  = _monto2;
						else
							Let _credito = _monto2;
						end if

						Let _cuenta    = sp_sis15("PICGRCSD", '01', _no_poliza);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

					-- Impuesto Recuperado

					Let _monto2 = _monto_reas * _factor_impuesto / 100;

					If _monto2 <> 0.00 Then

						Let _monto3  = _monto3 - _monto2;

						let _monto2	 = _monto2 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto2 > 0.00 then
							Let _debito  = _monto2;
						else
							Let _credito = _monto2;
						end if

						Let _cuenta    = sp_sis15("PIIRRCSD", '01', _no_poliza);   
						CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					End If

					-- Reaseguro por Pagar

					if _monto3 <> 0.00 Then

						let _monto3	 = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, _cod_ramo, _cod_subramo);   
						call sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

					end if

				end foreach
						   					
			End If

		End Foreach

	-- Reaseguro Asumido

	Elif _tipo_produccion = 4 THEN 	 

		--

	End If

 	select sum(debito + credito)
	  into _monto
	  from deivid_tmp:cobincasi
	 where no_poliza = _no_poliza;

	If _monto <> 0.00 Then

			Let _cuenta  = sp_sis15('PAPXCSD', '01', _no_poliza);
			Let _debito  = 0.00;
			Let _credito = 0.00;

			select debito,
			       credito
			  into _debito_sus,
			       _credito_sus
			  from deivid_tmp:cobincasi
			 where no_poliza = _no_poliza
			   and cuenta    = _cuenta;

			if _debito_sus <> 0.00 then
				Let _debito  = _monto * -1;
			else
				Let _credito = _monto * -1;
			end if

			Let _tipo_comp = 1;
			CALL sp_cob219(_no_poliza,  _cuenta, _debito, _credito, _tipo_comp);

	End If
 		
	delete from deivid_tmp:cobincasi
	 where no_poliza = _no_poliza
	   and debito    = 0.00
	   and credito   = 0.00;

	update deivid_tmp:cobinc0911
	   set no_poliza = _no_poliza,
	       cod_ramo  = _cod_ramo
	 where poliza    = _poliza;

end foreach

END

Let _error_cod  = 0;
Let _error_desc = "Actualizacion Exitosa ...";
Return _error_cod, _error_desc;


END PROCEDURE;
