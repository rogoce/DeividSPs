-- Reporte de la Facturacion de Salud

-- Creado    : 01/01/2013 - Autor: Enocjahaziel Carrasco

DROP PROCEDURE sp_web24;

CREATE PROCEDURE sp_web24(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_periodo        CHAR(7),
a_no_poliza       CHAR(10),
a_no_factura      char(10)
);
{ RETURNING CHAR(20),	-- Poliza
			CHAR(10),	-- Factura
			DATE,		-- Vigencia Inicial
			DATE,		-- Vigencia Final
			CHAR(50),	-- Cliente
			DEC(16,2),	-- Prima Neta
			DEC(16,2),	-- Impuesto
			DEC(16,2),	-- Prima bruta
			CHAR(50),	-- Compania
			DEC(16,2);	-- Prima Retenida}
			
			
DEFINE _no_poliza       CHAR(10); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_factura      CHAR(10); 
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final  DATE;
DEFINE _prima_neta      DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_bruta     DEC(16,2);
DEFINE _prima_retenida, _descuento, _recargof  DEC(16,2);

DEFINE _cod_endomov     CHAR(3);  
DEFINE _cod_cliente     CHAR(10);
DEFINE _nombre_cliente  CHAR(50);
DEFINE _nombre_compania CHAR(50);
DEFINE _no_unidad, _no_endoso  CHAR(5);
DEFINE _porc_descuento  DEC(5,2);
DEFINE _porc_recargo    DEC(5,2);
DEFINE _prima_certif    DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _factor_imp_tot  DEC(5,2);
DEFINE _nombre_subramo  CHAR(50);
DEFINE _cod_impuesto    CHAR(3);  
DEFINE _monto_impuesto  DEC(16,2);
DEFINE _factor_impuesto DEC(5,2); 
DEFINE _tiene_impuesto  SMALLINT;
DEFINE _cod_ramo, _cod_subramo CHAR(3);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro30b.trc"; 
--TRACE ON;                                                                

-- Nombre de la Compania
--let a_compania ='001';
--let a_sucursal='001';
LET _nombre_compania = sp_sis01(a_compania); 
LET _no_unidad       = NULL;
LET _porc_descuento  = 0;
LET _porc_recargo    = 0;
LET _factor_imp_tot  = 0;
LET _nombre_subramo  = '';
--let _no_poliza = '124566';
-- Movimiento de Facturacion de Salud
--begin work;


DELETE FROM tmp_certif;

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;


SELECT cod_endomov
  INTO _cod_endomov
  FROM endtimov
 WHERE tipo_mov = 14;

-- Seleccion de las Facturas

FOREACH
 SELECT a.no_poliza,
        a.no_endoso,
 		a.no_documento,
	    a.no_factura,
	    a.vigencia_inic,
	    a.vigencia_final,
	    a.prima_neta,
	    a.impuesto,
	    a.prima_bruta,
	    a.prima_retenida
   INTO _no_poliza,
        _no_endoso,
 		_no_documento,
	    _no_factura,
	    _vigencia_inic,
	    _vigencia_final,
	    _prima_neta,
	    _impuesto,
	    _prima_bruta,
	    _prima_retenida
   FROM endedmae a, emipomae b
  WHERE a.cod_compania = a_compania
    AND a.periodo      = a_periodo
	AND a.cod_endomov  IN ('014','011','006','015')
	AND a.actualizado  = 1
    AND b.no_poliza = a_no_poliza
    AND a.no_poliza = a_no_poliza
	AND b.cod_ramo =  _cod_ramo
	and a.no_factura = a_no_factura

	SELECT cod_contratante,
	       cod_ramo,
		   cod_subramo
	  INTO _cod_cliente,
	       _cod_ramo,
		   _cod_subramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;


	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	LET _monto_impuesto = 0;
	LET _tiene_impuesto = 0;
	LET _factor_imp_tot = 0;

	FOREACH
	 SELECT	cod_impuesto
	   INTO	_cod_impuesto
	   FROM	emipolim
	  WHERE	no_poliza = _no_poliza

		SELECT factor_impuesto
		  INTO _factor_impuesto
		  FROM prdimpue
		 WHERE cod_impuesto = _cod_impuesto;

		LET _impuesto = _prima_neta / 100 * _factor_impuesto;

--		IF _pagado_por = 'A' THEN
			LET _tiene_impuesto = 1;
			LET _monto_impuesto = _monto_impuesto + _impuesto;		
			LET _factor_imp_tot = _factor_imp_tot + _factor_impuesto;
--		END IF


	END FOREACH

	-- Se Determina el Porcentaje de Descuento

	LET _no_unidad      = NULL;
	LET _porc_descuento = 0;

   FOREACH	
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emiunide
	 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _no_unidad IS NOT NULL THEN		  

		SELECT SUM(porc_descuento)
		  INTO _porc_descuento
		  FROM emiunide
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_descuento IS NULL THEN
			LET _porc_descuento = 0;
		END IF

	END IF

	-- Se Determina el Porcentaje de Recargo

	LET _no_unidad      = NULL;
	LET _porc_recargo   = 0;

   FOREACH	
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emiunire
	 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _no_unidad IS NOT NULL THEN		  

		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF

	END IF


	-- Insercion de las Unidades

	BEGIN 

	DEFINE _suma_asegurada DEC(16,2);
	DEFINE _cod_producto   CHAR(5);  
	DEFINE _cod_cliente    CHAR(10); 
	DEFINE _beneficio_max  DEC(16,2);
	DEFINE _desc_unidad    CHAR(50); 
	DEFINE _impuesto_uni   DEC(16,2);
	DEFINE _prima_brut_uni DEC(16,2);
	DEFINE _facturado      SMALLINT; 
	DEFINE _cant_unidades  SMALLINT;
	DEFINE _cant_depen     SMALLINT;
	DEFINE _fecha_nac	   DATE;
	DEFINE _cedula		   CHAR(30);
	DEFINE _fecha_emis	   DATE;
	DEFINE _fecha_efec	   DATE;
	DEFINE _nombre_cli     CHAR(100);
	DEFINE _plan           CHAR(1);

			--on exception set _error
			on exception IN(-239, -268)
			--	rollback work;
			--	return _no_poliza, ;	
			end exception
		 					
	SELECT COUNT(*)
	  INTO _cant_unidades
	  FROM emipouni
     WHERE no_poliza = _no_poliza
	   AND activo    = 1;

	FOREACH
	 SELECT	no_unidad,
			suma_asegurada,
			cod_producto,
			cod_cliente,
			beneficio_max,
			vigencia_inic,
			prima_neta,
			impuesto,
			prima_bruta
	   INTO	_no_unidad,
			_suma_asegurada,
			_cod_producto,
			_cod_cliente,
			_beneficio_max,
			_fecha_efec,
			_prima_neta,
			_impuesto_uni,
			_prima_brut_uni
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
	    AND no_endoso = _no_endoso
--	    AND activo    = 1

	 SELECT facturado,
			desc_unidad,
			prima_total,
			fecha_emision,
			vigencia_inic
	   INTO	_facturado,
			_desc_unidad,
			_prima_certif,
			_fecha_emis,
			_fecha_efec
	   FROM emipouni
	  WHERE no_poliza = _no_poliza
	    AND no_unidad = _no_unidad;


		IF _facturado = 1 THEN
			LET _suma_asegurada = 0;
		END IF

 {		-- Se Determina el Porcentaje de Descuento

		LET _porc_descuento = 0;

		SELECT SUM(porc_descuento)
		  INTO _porc_descuento
		  FROM emiunide
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_descuento IS NULL THEN
			LET _porc_descuento = 0;
		END IF


		-- Se Determina el Porcentaje de Recargo

		LET _porc_recargo   = 0;

		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF


		LET _descuento      = _prima_certif / 100 * _porc_descuento;
		LET _recargo        = (_prima_certif - _descuento) / 100 * _porc_recargo;
		LET _prima_neta     = _prima_certif - _descuento + _recargo;
		LET _impuesto_uni   = _prima_neta / 100 * _factor_imp_tot;
		LET _prima_brut_uni = _prima_neta + _impuesto_uni;
}	
		IF _cant_unidades >= 1 THEN
			
			SELECT cedula,
				   fecha_aniversario,
				   nombre
			  INTO _cedula,
			  	   _fecha_nac,
				   _nombre_cli
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente; 	   		   	

			SELECT COUNT(*)
			  INTO _cant_depen
			  FROM emidepen
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad
			   AND activo    = 1;

			IF _cant_depen IS NULL THEN
				LET _cant_depen = 0;
			END IF

			IF _cant_depen = 0 THEN
				LET _plan = 'A';
			ELIF _cant_depen = 1 THEN
				LET _plan = 'B';
			ELSE
				LET _plan = 'C';
			END IF

--			LET _error_desc = 'Error al Insertar Certificados(Temporal)';

			INSERT INTO tmp_certif(
			no_poliza,
			no_unidad,
			nombre,
			plan,
			cedula,
			fecha_nac,
			fecha_emis,
			fecha_efec,
			prima_net,
			impuesto,
			prima_bru,
			contratante,
		    doc_poliza,
			vigen_inic,
			subramo,
			compania,
			vigencia_i,
			vigencia_f,
			no_factura
			)
			VALUES(
			_no_poliza,
			_no_unidad,
			_nombre_cli,
			_plan,
			_cedula,
			_fecha_nac,
			_fecha_emis,
			_fecha_efec,
			_prima_neta,
			_impuesto_uni,
			_prima_brut_uni,
			_nombre_cliente,
			_no_documento,
			_vigencia_inic,
			_nombre_subramo,
			_nombre_compania,
	    	_vigencia_inic,
	    	_vigencia_final,
			_no_factura
			);

		END IF

		END FOREACH
	END


END FOREACH

	{RETURN _no_documento,
		   _no_factura,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre_cliente,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta,
		   _nombre_compania,
		   _prima_retenida
		   WITH RESUME;}


--commit work;

END PROCEDURE;
