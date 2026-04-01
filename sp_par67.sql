
drop procedure sp_par67;
create procedure sp_par67()
returning char(10),
		  char(10),
          char(5),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  smallint,
		  dec(16,2),
		  char(5);


DEFINE _no_factura       CHAR(10); 
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

DEFINE _monto_ced		 DEC(16,2);
DEFINE _monto_imp		 DEC(16,2);
DEFINE _monto_com		 DEC(16,2);
DEFINE _monto_pag		 DEC(16,2);

define _porc_com_cal     dec(16,2);

foreach
 SELECT	prima_suscrita,
		prima_bruta,
		impuesto,
		prima_neta,
		cod_tipoprod,
		no_poliza,
		no_endoso,
		no_factura
   INTO	_prima_suscrita,
		_prima_bruta,
		_impuesto,
		_prima_neta,
		_cod_tipoprod,
		_no_poliza,
		_no_endoso,
		_no_factura
   FROM	endedmae
  WHERE	periodo     = "2002-11"
    AND actualizado = 1

	SELECT cod_ramo,
		   cod_compania	
	  INTO _cod_ramo,
		   _cod_compania	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

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

	if _cod_ramo <> "008" then
	   continue foreach;
	end if

	SELECT par_ase_lider
	  INTO _cod_lider
	  FROM parparam
	 WHERE cod_compania = "001";

 	-- Sin Coaseguro

	If _tipo_produccion = 1 Or 
	   _tipo_produccion = 2 Or
	   _tipo_produccion = 3 Then

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
		  Where no_poliza = _no_poliza
		    And no_endoso = _no_endoso

			Select tipo_contrato,
			       porc_impuesto
			  Into _tipo_contrato,
			       _factor_impuesto
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			-- El Contrato de Retencion No se Incluye en el Proceso

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

			-- Reaseguro Cedido
			Let _monto3    = _monto;
			Let _monto_ced = _monto;

			-- Para los Contratos Facultativos

			Let _monto_com = 0.00;
			Let _monto_imp = 0.00;

			If _tipo_contrato = 3 Then

				let _tipo_comp = 2;

				Foreach
				 Select prima,
				        porc_impuesto,
						porc_comis_fac
				   Into _monto,
						_factor_impuesto,
				   		_porc_comis_agt
				   From emifafac
				  Where no_poliza      = _no_poliza
				    And no_endoso      = _no_endoso
					And no_unidad      = _no_unidad
					And cod_cober_reas = _cod_cober_reas
					And orden		   = _orden

					-- Comision Ganada
					If _porc_comis_agt <> 0.00 Then
						Let _monto2    = _monto * _porc_comis_agt / 100;
						Let _monto_com = _monto_com + _monto2;
						Let _monto3    = _monto3 - _monto2;
					End If

					-- Impuesto Recuperado
					If _factor_impuesto <> 0.00 Then
						Let _monto2    = _monto * _factor_impuesto / 100;
						Let _monto_imp = _monto_imp + _monto2;
						Let _monto3    = _monto3 - _monto2;
					End If

				End Foreach

			Else

				let _tipo_comp = 1;

				-- Comision Ganada
				If _porc_comis_agt <> 0.00 Then
					Let _monto2    = _monto * _porc_comis_agt / 100;
					Let _monto_com = _monto2;
					Let _monto3    = _monto3 - _monto2;
				End If

				-- Impuesto Recuperado
				If _factor_impuesto <> 0.00 Then
					Let _monto2    = _monto * _factor_impuesto / 100;
					Let _monto_imp = _monto2;
					Let _monto3    = _monto3 - _monto2;
				End If

			End If

			-- Reaseguro por Pagar
			Let _cuenta    = _cuenta_cat;   
			Let _debito    = 0.00;
			Let _credito   = _monto3;
			Let _monto_pag = _monto3;
			
			
			If _monto_ced = 0.00 Then
				Let _porc_com_cal = 0.00;
			Else
				Let _porc_com_cal = _monto_com / _monto_ced * 100;
			End If

			If _monto_ced = 0.00 and
			   _monto_com = 0.00 and
			   _monto_imp = 0.00 and
			   _monto_pag = 0.00 Then
			   continue foreach;
			end if

			return _no_factura,
				   _no_poliza,
			       _no_endoso,
				   _monto_ced,
				   _monto_com,
				   _monto_imp,
				   _monto_pag,
				   _cod_ramo,
				   _tipo_comp,
				   _porc_com_cal,
				   _cod_contrato
				   with resume;

		End Foreach

	End If

end foreach

end procedure
