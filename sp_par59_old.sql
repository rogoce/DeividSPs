-- Procedimiento que genera los registros contables de cada factura de produccion
-- 
-- Creado     : 24/10/2002 - Autor: Marquelda Valdelamar
-- Modificado :	27/10/2002 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par59;		

CREATE PROCEDURE "informix".sp_par59(a_no_poliza CHAR(10), a_no_endoso CHAR(5))
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

DEFINE _porc_comis_agt   DECIMAL(5,2);
DEFINE _porc_partic_agt	 DECIMAL(5,2);
DEFINE _cuenta_inc       CHAR(25);
DEFINE _cuenta_dan       CHAR(25);
DEFINE _ramo_sis		 SMALLINT;
DEFINE _cod_contrato	 CHAR(5);
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
DEFINE _aplica_impuesto  SMALLINT;
DEFINE _cant_impuestos   SMALLINT;

define _debito_sus		 dec(16,2);
define _credito_sus		 dec(16,2);
define _cod_endomov		 char(3);

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

 SELECT	prima_suscrita,
		prima_bruta,
		impuesto,
		prima_neta,
		cod_tipoprod,
		cod_endomov,
		gastos
   INTO	_prima_suscrita,
		_prima_bruta,
		_impuesto,
		_prima_neta,
		_cod_tipoprod,
		_cod_endomov,
		_gastos_manejo
   FROM	endedmae
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = a_no_endoso;

	if _cod_endomov = "018" then

		Let _error_cod  = 0;
		Let _error_desc = "Actualizacion Exitosa ...";
		Return _error_cod, _error_desc;

	end if

	SELECT cod_ramo,
		   cod_compania,
		   cod_origen	
	  INTO _cod_ramo,
		   _cod_compania,
		   _cod_origen	
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;

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

			select sum(porc_partic_coas)
			  into _porc_partic_agt
			  from endcoama
			 where no_poliza    = a_no_poliza
		   	   and no_endoso    = a_no_endoso
	    	   and cod_coasegur <> _cod_lider;

			IF _porc_partic_agt IS NULL THEN
				LET _porc_partic_agt = 0;
			END IF

			-- Coaseguro por Pagar

	    	Let _monto = (_prima_neta * _porc_partic_agt / 100);

		    -- Calculo del impuesto

			If _impuesto <> 0.00 then

				Let _suma_impuesto = 0.00;

				Foreach	
				 Select cod_impuesto
				   Into _cod_impuesto
				   From endedimp
				  Where no_poliza = a_no_poliza
				    And no_endoso = a_no_endoso

					Select factor_impuesto
					  Into _factor_impuesto
					  From prdimpue
					 Where cod_impuesto = _cod_impuesto;
						    
					Let _monto2        = _monto * _factor_impuesto / 100;
					Let _suma_impuesto = _suma_impuesto  + _monto2;

				End Foreach

				let _monto = _monto + _suma_impuesto;

			end if

			If _monto <> 0.00 Then

				Let _monto   = _monto * -1;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _cuenta    = sp_sis15("PPCOASXP", '01', a_no_poliza);   
				Let _tipo_comp = 1;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
				CALL sp_par144(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _cod_lider);

			End If

			-- Prima Bruta

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_bruta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _cuenta    = sp_sis15('PAPXCSD', '01', a_no_poliza);
				Let _tipo_comp = 1;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If	
		
		Elif _tipo_produccion = 3 THEN -- Coaseguro Minoritario

			-- Cuentas por Cobrar Coaseguro

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_bruta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _cuenta    = sp_sis15("PACXCC", '01', a_no_poliza);   
				Let _tipo_comp = 1;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

			End If

		Elif _tipo_produccion = 1 THEN -- Sin Coaseguro

			-- Prima Bruta

			If _prima_bruta <> 0.00 Then

		    	Let _monto   = _prima_bruta;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _cuenta    = sp_sis15('PAPXCSD', '01', a_no_poliza);
				Let _tipo_comp = 1;
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

			Let _cuenta    = sp_sis15('PIPSSD' , '01', a_no_poliza);
			Let _tipo_comp = 1;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		End If

		if _gastos_manejo <> 0.00 then

			LET  _cuenta   = sp_sis15('PGGASMA', '01', a_no_poliza);
			LET  _debito   = 0;
			LET  _credito  = _gastos_manejo * -1;
			Let _tipo_comp = 1;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		end if

	    -- Calculo del impuesto

		If _impuesto <> 0.00 then

			Let _suma_impuesto = 0.00;

			 Select count(*)
			   Into _cant_impuestos
			   From endedimp
			  Where no_poliza = a_no_poliza
			    And no_endoso = a_no_endoso;

			Foreach	
			 Select cod_impuesto
			   Into _cod_impuesto
			   From endedimp
			  Where no_poliza = a_no_poliza
			    And no_endoso = a_no_endoso

				Select factor_impuesto,
				       cta_incendio,
					   cta_danos
				  Into _factor_impuesto,
				       _cuenta_inc,
					   _cuenta_dan
				  From prdimpue
				 Where cod_impuesto = _cod_impuesto;
					    
				if _cant_impuestos = 1 then
					let _monto = _impuesto;
				else
					let _monto = _prima_suscrita * _factor_impuesto / 100;
				end if

				Let _suma_impuesto = _suma_impuesto + _monto;

				If _ramo_sis = 2 or
				   _ramo_sis = 8 then
					Let _cuenta = sp_sis15(_cuenta_inc); 
				Else
					Let _cuenta = sp_sis15(_cuenta_dan); 
				End If

				If _monto <> 0.00 Then

					Let _monto   = _monto * -1;
					Let _debito  = 0.00;
					Let _credito = 0.00;

					if _monto > 0.00 then
						Let _debito  = _monto;
					else
						Let _credito = _monto;
					end if

					Let _tipo_comp = 1;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				End If

			End Foreach

			if _cod_tipoprod = "001"  and 
			   _cod_endomov  <> "014" then

				select sum(debito + credito)
				  into _monto
				  from endasien
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso;

				let _monto = _monto * -1;

				If _monto <> 0.00 Then

					Let _debito  = 0.00;
					Let _credito = 0.00;

					if _impuesto > 0.00 then -- Valores al Credito
						Let _credito = _monto;
					else
						Let _debito  = _monto;
					end if

					Let _tipo_comp = 1;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				End If

			end if

			if _cod_tipoprod = "005"  or 
			   _cod_tipoprod = "002"  then

				if _cod_endomov  <> "014" then

					let _cuenta = _cuenta;
					let _suma_impuesto = _suma_impuesto;
					let _impuesto = _impuesto;

					Let _monto = (_suma_impuesto - _impuesto);

					If _monto <> 0.00 Then

						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _impuesto > 0.00 then -- Valores al Credito
							Let _credito = _monto;
						else
							Let _debito  = _monto;
						end if

						Let _tipo_comp = 1;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

					End If

				end if

			end if

	     End If

		-- Comprobante de Comisiones
			
	    Foreach 
		 Select	porc_comis_agt,
				porc_partic_agt
		   Into	_porc_comis_agt,
				_porc_partic_agt
		   From endmoage
		  Where	no_poliza = a_no_poliza
		    and no_endoso = a_no_endoso

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

				Let _cuenta    = sp_sis15('PGCOMCO', '01', a_no_poliza);   
				Let _tipo_comp = 2;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				-- Honorarios por Pagar Agentes y Corredores

				Let _monto   = _monto * -1;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _cuenta    = sp_sis15('PPCOMXPCO', '01', a_no_poliza); 
				Let _tipo_comp = 2;
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

						Let _cuenta    = sp_sis15(_cuenta_inc, '01', a_no_poliza);    
						Let _tipo_comp = 2;
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

						Let _cuenta    = sp_sis15(_cuenta_dan, '01', a_no_poliza);   
						Let _tipo_comp = 2;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
					End If

				End Foreach

			End If

		End If

	    -- Comprobante de Reaseguro Cedido

  		Foreach
		 Select cod_contrato,
		        prima,
				cod_cober_reas,
				no_unidad,
				orden
		   Into _cod_contrato,
		        _monto,
				_cod_cober_reas,
				_no_unidad,
				_orden
		   From emifacon
		  Where no_poliza = a_no_poliza
		    And no_endoso = a_no_endoso

			Select tipo_contrato,
			       porc_impuesto
			  Into _tipo_contrato,
			       _factor_impuesto
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			If _tipo_contrato = 1 Then

				-- Reservas Estadisticas y Catastroficas

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

						Let _cuenta    = sp_sis15("PGRPPDE", '01', a_no_poliza);   
						Let _tipo_comp = 6;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

						let _monto3  = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PPRPPDE", '01', a_no_poliza);   
						Let _tipo_comp = 6;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

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

						Let _cuenta    = sp_sis15("PGRPRC", '01', a_no_poliza);   
						Let _tipo_comp = 7;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

						let _monto3  = _monto3 * -1;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						if _monto3 > 0.00 then
							Let _debito  = _monto3;
						else
							Let _credito = _monto3;
						end if

						Let _cuenta    = sp_sis15("PPRPRC", '01', a_no_poliza);   
						Let _tipo_comp = 7;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);


					end if

				end if

			Else

				Select porc_impuesto,
				       porc_comision,
					   cuenta
				  Into _factor_impuesto,
					   _porc_comis_agt,
					   _cuenta_cat
				  From reacocob
				 Where cod_contrato   = _cod_contrato
				   And cod_cober_reas = _cod_cober_reas;

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

					Let _cuenta    = sp_sis15("PGRCSD", '01', a_no_poliza);   
					Let _tipo_comp = 3;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				End If

				-- Para los Contratos Facultativos

				If _tipo_contrato = 3 Then

					Foreach
					 Select prima,
					        porc_impuesto,
							porc_comis_fac
					   Into _monto,
							_factor_impuesto,
					   		_porc_comis_agt
					   From emifafac
					  Where no_poliza      = a_no_poliza
					    And no_endoso      = a_no_endoso
						And no_unidad      = _no_unidad
						And cod_cober_reas = _cod_cober_reas
						And orden		   = _orden

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

							Let _cuenta    = sp_sis15("PICGRCSD", '01', a_no_poliza);   
							Let _tipo_comp = 3;
							CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

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

							Let _cuenta    = sp_sis15("PIIRRCSD", '01', a_no_poliza);   
							Let _tipo_comp = 3;
							CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

						End If

					End Foreach

				Else

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

						Let _cuenta    = sp_sis15("PICGRCSD", '01', a_no_poliza);   
						Let _tipo_comp = 3;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

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

						Let _cuenta    = sp_sis15("PIIRRCSD", '01', a_no_poliza);   
						Let _tipo_comp = 3;
						CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

					End If

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

					Let _cuenta    = _cuenta_cat;   
					Let _tipo_comp = 3;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				End If

			End If

		End Foreach

	-- Reaseguro Asumido

	Elif _tipo_produccion = 4 THEN 	 

		-- Prima Suscrita Reaseguro Asumido

		If _prima_suscrita <> 0.00 Then
			Let _monto2    = _prima_suscrita;
			Let _cuenta    = sp_sis15('PIPSRA' , '01', a_no_poliza);
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
				Let _cuenta    = sp_sis15('PPCPRA' , '01', a_no_poliza);
				Let _debito    = _monto;
				Let _credito   = 0.00;
				Let _tipo_comp = 4;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			End If

			-- Impuesto sobre prima reaseguro asumido
			Let _monto = (_porc_partic_agt / 100) * _prima_suscrita;
			If _monto <> 0.00 Then
				Let _monto2    = _monto2 - _monto;
				Let _cuenta    = sp_sis15('PPIPRA' , '01', a_no_poliza);
				Let _debito    = _monto;
				Let _credito   = 0.00;
				Let _tipo_comp = 4;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
			End If

			-- Primas por Cobrar Reaseguro Asumido
			Let _cuenta    = sp_sis15('PAPXCRA' , '01', a_no_poliza);
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
				Let _cuenta    = sp_sis15("PGREARET", '01', a_no_poliza);   
				Let _debito    = _monto;
				Let _credito   = 0.00;
				Let _tipo_comp = 5;
				CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

				-- Comision Ganada
				Let _monto2 = _monto * _porc_comis_agt / 100;
				If _monto2 <> 0.00 Then
					Let _monto3    = _monto3 - _monto2;
					Let _cuenta    = sp_sis15("PICGRET", '01', a_no_poliza);   
					Let _debito    = 0.00;
					Let _credito   = _monto2;
					Let _tipo_comp = 5;
					CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);
				End If

				-- Impuesto Recuperado
				Let _monto2 = _monto * _factor_impuesto / 100;
				If _monto2 <> 0.00 Then
					Let _monto3    = _monto3 - _monto2;
					Let _cuenta    = sp_sis15("PIIRRET", '01', a_no_poliza);   
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

		if abs(_monto) <= 0.03 then

			Let _cuenta  = sp_sis15('PAPXCSD', '01', a_no_poliza);
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

			Let _tipo_comp = 1;
			CALL sp_par60(a_no_poliza, a_no_endoso, _cuenta, _debito, _credito, _tipo_comp);

		End If

	End If
 		
	delete from endasien
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and debito    = 0.00
	   and credito   = 0.00;
	
	Let _error_cod  = 0;
	Let _error_desc = "Actualizacion Exitosa ...";
	Return _error_cod, _error_desc;

END

END PROCEDURE;
