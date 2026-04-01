-- Detalle de Facturas/Fianzas (Cumulos) por Asegurado
--
-- Creado    : 16/01/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/01/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_pro57_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro57;

CREATE PROCEDURE "informix".sp_pro57(
a_compania  CHAR(3), 
a_sucursal  CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_asegurado CHAR(255)
) RETURNING CHAR(20),
            DATE,
            DATE,
            CHAR(10),
			DEC(16,2),
			DEC(16,2),
			CHAR(100),
			CHAR(50),             
			CHAR(255),
			CHAR(10);            

DEFINE _cod_cliente      CHAR(10); 
DEFINE _no_documento     CHAR(20);
DEFINE _no_factura       CHAR(10); 
DEFINE _suma             DEC(16,2);
DEFINE _prima            DEC(16,2); 
DEFINE _nombre           CHAR(100);
DEFINE _vigencia_inic    DATE;     
DEFINE _vigencia_final   DATE;     

DEFINE v_compania_nombre CHAR(50); 
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro57.trc";
--TRACE ON;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_fianzas(
nombre         CHAR(100),
no_documento   CHAR(20), 
no_factura     CHAR(10), 
suma           DEC(16,2),
prima          DEC(16,2), 
vigencia_inic  DATE,     
vigencia_final DATE,
cod_cliente    CHAR(10),
seleccionado   SMALLINT     
) WITH NO LOG;

FOREACH
 SELECT	p.cod_contratante,
        e.no_factura,
		e.suma_asegurada,
		e.prima_suscrita,
		p.no_documento,
		p.vigencia_inic,
		p.vigencia_final
   INTO	_cod_cliente,
        _no_factura,
		_suma,
		_prima,
		_no_documento,
		_vigencia_inic,
		_vigencia_final
   FROM	endedmae e, emipomae p, prdramo r
  WHERE e.periodo     >= a_periodo1	
    AND e.periodo     <= a_periodo2
	AND e.actualizado  = 1
	AND e.no_poliza    = p.no_poliza
	AND p.cod_ramo     = r.cod_ramo
	AND r.ramo_sis     = 3
	and p.cod_compania = a_compania

	SELECT nombre
	  INTO _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
	 INSERT INTO tmp_fianzas
	 VALUES(
	 _nombre,
	 _no_documento,
	 _no_factura,
	 _suma,
	 _prima,
	 _vigencia_inic,     
	 _vigencia_final,
	 _cod_cliente,
	 1
	 ); 	

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_asegurado <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Asegurado: " ||  TRIM(a_asegurado);

	LET _tipo = sp_sis04(a_asegurado);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_fianzas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_fianzas
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	nombre,
        no_documento,
		no_factura,
		suma,
		prima,
	    vigencia_inic,     
	    vigencia_final,
		cod_cliente
   INTO	_nombre,
        _no_documento,
		_no_factura,
		_suma,
		_prima,
	    _vigencia_inic,     
	    _vigencia_final,
		_cod_cliente
   FROM	tmp_fianzas
  WHERE seleccionado = 1
  ORDER BY nombre, no_documento, no_factura

	RETURN _no_documento,
	       _vigencia_inic,     
	       _vigencia_final,
		   _no_factura,
		   _suma,
		   _prima,
		   _nombre,
		   v_compania_nombre,
		   v_filtros,
		   _cod_cliente
		   WITH RESUME;

END FOREACH

END PROCEDURE;
