-- Procedimiento que genera los registros contables de cada factura de produccion
-- 
-- Creado     : 24/10/2002 - Autor: Marquelda Valdelamar
-- Modificado :	27/10/2002 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par146;		

CREATE PROCEDURE "informix".sp_par146(a_periodo char(7))
returning char(20),
		  char(10),
		  dec(16,2),   
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(5),
		  char(50),
		  dec(5,2),
		  dec(5,2),
		  smallint,
		  smallint;
		  	
DEFINE a_no_poliza        CHAR(10); 
DEFINE a_no_endoso        CHAR(5);
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

define _reas_cedido		 dec(16,2);
define _reas_impuesto	 dec(16,2);
define _reas_comision	 dec(16,2);
define _reas_por_pagar	 dec(16,2);
define _nombre_contrato	 char(50);

define _no_documento	 char(20);
define _no_factura		 char(10);
define _serie			 smallint;

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
------------------------------------------------------------------------------

--Set Debug File To "sp_par59.trc";
--trace on;

Set Isolation To Dirty Read;

-- Generacion de Registros Contables de las Facturas

foreach
 SELECT	prima_suscrita,
		prima_bruta,
		impuesto,
		prima_neta,
		cod_tipoprod,
		cod_endomov,
		gastos,
		no_documento,
		no_factura,
		no_poliza,
		no_endoso
   INTO	_prima_suscrita,
		_prima_bruta,
		_impuesto,
		_prima_neta,
		_cod_tipoprod,
		_cod_endomov,
		_gastos_manejo,
		_no_documento,
		_no_factura,
		a_no_poliza,
		a_no_endoso
   FROM	endedmae
  WHERE	periodo     = a_periodo
    AND actualizado = 1
--    and no_factura not in ("01-332401", "01-332409", "01-332400", "01-332442", "01-332445", "01-332446")

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _cod_endomov = "018" then
		continue foreach;
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
		       porc_impuesto,
			   nombre,
			   serie
		  Into _tipo_contrato,
		       _factor_impuesto,
			   _nombre_contrato,
			   _serie
		  From reacomae
		 Where cod_contrato = _cod_contrato;

		If _tipo_contrato = 1 Then

			continue foreach;

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

					let _reas_cedido    = _monto;
					let _reas_comision  = _monto * _porc_comis_agt / 100;
					let _reas_impuesto  = _monto * _factor_impuesto / 100;
					let _reas_por_pagar = _reas_cedido - _reas_comision - _reas_impuesto;

					return _no_documento,
					       _no_factura,
						   _reas_cedido,   
						   _reas_comision, 
						   _reas_impuesto, 
						   _reas_por_pagar,
						   _cod_contrato,
						   _nombre_contrato,
						   _porc_comis_agt,
						   _factor_impuesto,
						   _serie,
						   _tipo_contrato
						   with resume;

				

				End Foreach

			Else

				let _reas_cedido    = _monto;
				let _reas_comision  = _monto * _porc_comis_agt / 100;
				let _reas_impuesto  = _monto * _factor_impuesto / 100;
				let _reas_por_pagar = _reas_cedido - _reas_comision - _reas_impuesto;

				return _no_documento,
				       _no_factura,
					   _reas_cedido,   
					   _reas_comision, 
					   _reas_impuesto, 
					   _reas_por_pagar,
					   _cod_contrato,
					   _nombre_contrato,
					   _porc_comis_agt,
					   _factor_impuesto,
					   _serie,
					   _tipo_contrato
					   with resume;
			End If

		End If

	End Foreach

End Foreach

END PROCEDURE;
