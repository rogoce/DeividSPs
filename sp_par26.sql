-- Verificacion de Facturas de Salud con forma
-- de pago no mensuales

-- Creado    : 16/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_sp_par26_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par26;

CREATE PROCEDURE sp_par26(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3)
) RETURNING CHAR(20),
			CHAR(10),
			DATE,
			DATE,
			CHAR(50),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			CHAR(50);

{
CREATE PROCEDURE sp_pro30(
a_compania 		 CHAR(3) DEFAULT '001', 
a_sucursal 		 CHAR(3) DEFAULT '001',
a_vigencia_desde DATE    DEFAULT '01/12/2000',
a_vigencia_hasta DATE    DEFAULT '15/12/2000',
a_usuario        CHAR(8) DEFAULT 'LARISSA'
)
}

DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _cod_tipoprod1   CHAR(3);  
DEFINE _cod_tipoprod2   CHAR(3);  
DEFINE _prima_neta      DEC(16,2);
DEFINE _fecha1          DATE;     
DEFINE _fecha2          DATE;     
DEFINE _cod_perpago     CHAR(3);  
DEFINE _cod_formapag    CHAR(3);  
DEFINE _cod_endomov     CHAR(3);  
DEFINE _meses           SMALLINT; 
DEFINE _no_documento    CHAR(20); 
DEFINE _periodo         CHAR(7);  
DEFINE _no_endoso_int   INTEGER;  
DEFINE _no_endoso_char  CHAR(5);  
DEFINE _no_factura      CHAR(10); 
DEFINE _descuento       DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _cod_impuesto    CHAR(3);  
DEFINE _monto_impuesto  DEC(16,2);
DEFINE _factor_impuesto DEC(5,2); 
DEFINE _no_unidad       CHAR(5);
DEFINE _tiene_impuesto  SMALLINT;
DEFINE _porc_coas       DEC(7,4);
DEFINE _tipo_produccion CHAR(3);
DEFINE _cod_coasegur    CHAR(3);
DEFINE _factor_imp_tot  DEC(5,2);
DEFINE _no_endoso       CHAR(5);
DEFINE _vigencia_inic   DATE;
DEFINE _porc_descuento  DEC(5,2);
DEFINE _porc_recargo    DEC(5,2);
DEFINE _prima_certif    DEC(16,2);
DEFINE _cod_cliente     CHAR(10);
DEFINE _nombre_cliente  CHAR(50);
DEFINE _nombre_compania CHAR(50);
DEFINE _cod_subramo		CHAR(50);
DEFINE _nombre_subramo  CHAR(50);
DEFINE _prima_aseg	    DEC(16,2);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro30.trc";

{
DROP TABLE tmp_certif;

CREATE TEMP TABLE tmp_certif(
	no_poliza	CHAR(10),
	no_unidad   CHAR(5),
	nombre		CHAR(100),
	plan		CHAR(1),
	cedula		CHAR(30),
	fecha_nac	DATE,
	fecha_emis	DATE,
	fecha_efec	DATE,
	prima_net   DEC(16,2),
	impuesto	DEC(16,2),
	prima_bru	DEC(16,2),
	contratante CHAR(100),
    doc_poliza  CHAR(20),
	vigen_inic	DATE,
	subramo		CHAR(50),
	compania    CHAR(50),
	PRIMARY KEY	(no_poliza, no_unidad)
	) WITH NO LOG;

}
-- Nombre de la Compania

LET _nombre_compania = sp_sis01(a_compania); 

-- Coaseguradora Lider
-- Periodo de Facturacion

SET ISOLATION TO DIRTY READ;

SELECT par_ase_lider,
       emi_periodo
  INTO _cod_coasegur,
	   _periodo
  FROM parparam
 WHERE cod_compania = a_compania;

-- Ramo de Salud

SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

-- Tipo de Produccion Sin Coaseguro y Coaseguro Mayoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;

-- Movimiento de Facturacion de Salud

SELECT cod_endomov
  INTO _cod_endomov
  FROM endtimov
 WHERE tipo_mov = 14;

-- Seleccion de las Polizas

LET _no_factura = '';

FOREACH
 SELECT no_poliza,
		cod_perpago,
		vigencia_final,
		cod_formapag,
		no_documento,
		cod_tipoprod,
		vigencia_inic,
		cod_contratante,
		cod_subramo
   INTO _no_poliza,
		_cod_perpago,
		_fecha1,
		_cod_formapag,
		_no_documento,
		_tipo_produccion,
		_vigencia_inic,
		_cod_cliente,
		_cod_subramo
   FROM emipomae
  WHERE cod_compania   = a_compania
    AND cod_ramo       = _cod_ramo
    AND vigencia_final >= "01/01/2001"
    AND estatus_poliza IN (1,3)
    AND actualizado    = 1
	AND cod_perpago    NOT IN("002", "006")
    AND (cod_tipoprod  = _cod_tipoprod1 OR
 	     cod_tipoprod  = _cod_tipoprod2)
--  WHERE no_poliza = '52425'
ORDER BY no_documento

	-- Nombre del Subramo

	SELECT nombre
	  INTO _nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	-- Nombre del Cliente

	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	-- Se Determina el Porcentaje de Descuento

	SELECT SUM(porc_descuento)
	  INTO _porc_descuento
	  FROM emipolde
	 WHERE no_poliza = _no_poliza;

	IF _porc_descuento IS NULL THEN
		LET _porc_descuento = 0;
	END IF

	-- Se Determina el Porcentaje de Recargo

	SELECT SUM(porc_recargo)
	  INTO _porc_recargo
	  FROM emiporec
	 WHERE no_poliza = _no_poliza;

	IF _porc_recargo IS NULL THEN
		LET _porc_recargo = 0;
	END IF

	-- Verificacion si es Coaseguro Mayoritario

	IF _tipo_produccion = _cod_tipoprod2 THEN

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF

	-- Se determina la nueva vigencia final de la poliza

	SELECT meses
	  INTO _meses
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

	if _meses = 0 then
		if _cod_perpago = '008' then
			let _meses = 12;
		else
			let _meses = 1;
		end if
	end if

	LET _fecha2 = _fecha1 + _meses UNITS MONTH;

	-- Se Determina la Prima a Facturar

	SELECT SUM(prima_total),
		   SUM(prima_asegurado)	
	  INTO _prima_certif,
		   _prima_aseg	
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND activo    = 1;

	IF _prima_certif IS NULL THEN
		LET _prima_certif = 0;
	END IF

	LET _prima_aseg = _prima_aseg * _meses;

	IF _prima_certif = 0 THEN
		UPDATE emipouni
		   SET prima_total = prima_asegurado * _meses
		 WHERE no_poliza   = _no_poliza;
	END IF

	LET _descuento      = _prima_certif / 100 * _porc_descuento;
	LET _recargo        = (_prima_certif - _descuento) / 100 * _porc_recargo;
	LET _prima_neta     = _prima_certif - _descuento + _recargo;

	-- Impuestos por Endoso

	BEGIN

	DEFINE _pagado_por CHAR(1);
	DEFINE _impuesto   DEC(16,2);
	
	LET _monto_impuesto = 0;
	LET _tiene_impuesto = 0;
	LET _factor_imp_tot = 0;

	FOREACH
	 SELECT	cod_impuesto
	   INTO	_cod_impuesto
	   FROM	emipolim
	  WHERE	no_poliza = _no_poliza

		SELECT factor_impuesto,
		       pagado_por
		  INTO _factor_impuesto,
			   _pagado_por	
		  FROM prdimpue
		 WHERE cod_impuesto = _cod_impuesto;

		LET _impuesto = _prima_neta / 100 * _factor_impuesto;

--		IF _pagado_por = 'A' THEN
			LET _tiene_impuesto = 1;
			LET _monto_impuesto = _monto_impuesto + _impuesto;		
			LET _factor_imp_tot = _factor_imp_tot + _factor_impuesto;
--		END IF

	END FOREACH

	END

--	IF _prima_neta = 0 THEN

	IF _prima_aseg = _prima_certif THEN

		RETURN _no_documento,
			   _no_factura,
			   _vigencia_inic,
			   _fecha1,
			   _nombre_cliente,
			   _prima_neta,
			   _monto_impuesto,
			   (_prima_neta + _monto_impuesto),
			   _nombre_compania
			   WITH RESUME;

	END IF

END FOREACH

END PROCEDURE;
