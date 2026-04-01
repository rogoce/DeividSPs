-- Procedimiento que genera solo los errores de produccion
-- 
-- Creado     : 07/01/2003 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par64;		

CREATE PROCEDURE "informix".sp_par64(a_no_poliza CHAR(10), a_no_endoso CHAR(5))
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
DEFINE _cantidad		 INTEGER;

Set Isolation To Dirty Read;

BEGIN

--ON EXCEPTION SET _error_cod 
-- 	RETURN _error_cod, 'Error al Actualizar el Endoso ...';         
--END EXCEPTION           

 SELECT	prima_suscrita,
		prima_bruta,
		impuesto,
		prima_neta,
		cod_tipoprod
   INTO	_prima_suscrita,
		_prima_bruta,
		_impuesto,
		_prima_neta,
		_cod_tipoprod
   FROM	endedmae
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = a_no_endoso;

	SELECT cod_ramo,
		   cod_compania	
	  INTO _cod_ramo,
		   _cod_compania	
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT par_ase_lider
	  INTO _cod_lider
	  FROM parparam
	 WHERE cod_compania = _cod_compania;



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

			Select tipo_contrato,
			       porc_impuesto
			  Into _tipo_contrato,
			       _factor_impuesto
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			If _tipo_contrato = 1 Then
				Continue Foreach;
			End If

			Select Count(*)
			  Into _cantidad
			  From reacocob
			 Where cod_contrato   = _cod_contrato
			   And cod_cober_reas = _cod_cober_reas;

			If _cantidad = 0 Then
				insert into reacocob
				values (_cod_contrato, _cod_cober_reas, 0.00, 0.00, 0.00, 0, 0.00, 0.00, "");
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

			If _factor_impuesto is null Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato " || _cod_contrato || " No Existe Cuenta Reaseguro x Pagar para Cobertura " || _cod_cober_reas;
				Return _error_cod, _error_desc with resume;
			End If
			
			If _cuenta_cat is null Then
				Let _error_cod  = 1;
				Let _error_desc = "Para el Contrato " || _cod_contrato || " No Existe Cuenta Reaseguro x Pagar para Cobertura " || _cod_cober_reas;
				Return _error_cod, _error_desc with resume;
			End If

		end foreach


	Let _error_cod  = 0;
	Let _error_desc = "Actualizacion Exitosa ...";
	Return _error_cod, _error_desc;

END

END PROCEDURE;
