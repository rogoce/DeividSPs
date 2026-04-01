-- Reporte de Cheques por cta - Detallado

-- Creado    : 22/11/2000 - Autor: Amado Perez 
-- Modificado: 22/11/2000 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_cheq_sp_che08_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che09;

CREATE PROCEDURE sp_che09(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_cuenta CHAR(255) DEFAULT "*", a_monto DEC(16,2) DEFAULT 0.00, a_anombrede CHAR(255) DEFAULT "*")
RETURNING CHAR(25),	-- Cuenta
		  CHAR(50),	-- Descripcion
		  DEC(16,2),-- Debito
		  DEC(16,2),-- Credito
		  CHAR(10), -- Cheque
		  CHAR(100), -- Cliente
		  CHAR(10),  -- Anulado
		  DATE,     -- Fecha Impresion
		  CHAR(50); -- Compania

DEFINE v_cuenta		  CHAR(25);  
DEFINE v_descripcion  CHAR(50); 
DEFINE v_debito       DEC(16,2);
DEFINE v_credito      DEC(16,2);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_no_cheque    CHAR(10);
DEFINE v_nombre_ben   CHAR(100);
DEFINE v_anulado, _no_requis CHAR(10);
DEFINE v_filtros      CHAR(255);
DEFINE v_fecha_imp    DATE;
DEFINE _tipo          CHAR(1);

DEFINE _anulado      SMALLINT;
DEFINE _renglon       SMALLINT;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_tabla(
	cuenta		    CHAR(25),
	debito          DEC(16,2),
	credito         DEC(16,2),
	renglon         smallint,
	cheque          CHAR(10),
	anulado         SMALLINT,
	benefi		    CHAR(100),
	seleccionado   	SMALLINT  DEFAULT 1 NOT NULL,
	fecha_impresion DATE
	) WITH NO LOG;
	CREATE INDEX iend1_tmp_tabla ON tmp_tabla(cuenta);

IF a_monto <> 0.00 THEN

	FOREACH
		 SELECT	x.cuenta,
		 		x.debito,
				x.credito,
				x.renglon,
				y.no_cheque,
				y.a_nombre_de,
				y.anulado,
				y.fecha_impresion
				INTO	
				v_cuenta,
		   		v_debito,
				v_credito,
				_renglon,
				v_no_cheque,
				v_nombre_ben,
				_anulado,
				v_fecha_imp
		   FROM	chqchcta x, chqchmae y
		  WHERE x.no_requis = y.no_requis
		    AND y.fecha_impresion >= a_fecha_desde 
		    AND y.fecha_impresion <= a_fecha_hasta
		    AND y.monto = a_monto
		    AND y.a_nombre_de MATCHES a_anombrede
			AND y.pagado = 1
			AND x.tipo = 1
			and x.cuenta <> "1220118" -- No incluir la cuenta de Planilla (Demetrio Hurtado 14/03/2013)
		  ORDER BY x.cuenta

	{	 SELECT	no_cheque,a_nombre_de,anulado,no_requis
	  	   INTO v_no_cheque,v_nombre_ben,_anulado,_no_requis
		   FROM	chqchmae
		  WHERE fecha_impresion >= a_fecha_desde 
		    AND fecha_impresion <= a_fecha_hasta
			AND pagado = 1
	  FOREACH
		 SELECT cuenta,debito,credito,renglon
		   INTO v_cuenta,v_debito,v_credito,_renglon
		   FROM chqchcta
		  WHERE no_requis = _no_requis}
	   
		  INSERT INTO tmp_tabla(
		  cuenta,
		  debito,
		  credito,
		  renglon,
		  cheque,
		  benefi,
		  anulado,
		  seleccionado,
		  fecha_impresion
		  )
		  VALUES(
		  v_cuenta,
		  v_debito,
		  v_credito,
		  _renglon,
		  v_no_cheque,
		  v_nombre_ben,
		  _anulado,
		  1,
		  v_fecha_imp
		  );
	--END FOREACH

	END FOREACH
  
    -- Cheques anulados

	FOREACH
		 SELECT	x.cuenta,
		 		x.debito,
				x.credito,
				x.renglon,
				y.no_cheque,
				y.a_nombre_de,
				y.anulado,
				y.fecha_impresion
				INTO	
				v_cuenta,
		   		v_debito,
				v_credito,
				_renglon,
				v_no_cheque,
				v_nombre_ben,
				_anulado,
				v_fecha_imp
		   FROM	chqchcta x, chqchmae y
		  WHERE x.no_requis = y.no_requis
		    AND y.fecha_anulado >= a_fecha_desde 
		    AND y.fecha_anulado <= a_fecha_hasta
		    AND y.monto = a_monto
		    AND y.a_nombre_de MATCHES a_anombrede
			AND y.pagado = 1
			AND x.tipo = 2
			and x.cuenta <> "1220118" -- No incluir la cuenta de Planilla (Demetrio Hurtado 14/03/2013)
		  ORDER BY x.cuenta
	   
		  INSERT INTO tmp_tabla(
		  cuenta,
		  debito,
		  credito,
		  renglon,
		  cheque,
		  benefi,
		  anulado,
		  seleccionado,
		  fecha_impresion
		  )
		  VALUES(
		  v_cuenta,
		  v_debito,
		  v_credito,
		  _renglon,
		  v_no_cheque,
		  v_nombre_ben,
		  _anulado,
		  1,
		  v_fecha_imp
		  );

	END FOREACH


ELSE

	FOREACH
	 SELECT	x.cuenta,
	 		x.debito,
			x.credito,
			x.renglon,
			y.no_cheque,
			y.a_nombre_de,
			y.anulado,
			y.fecha_impresion
			INTO	
			v_cuenta,
	   		v_debito,
			v_credito,
			_renglon,
			v_no_cheque,
			v_nombre_ben,
			_anulado,
			v_fecha_imp
	   FROM	chqchcta x, chqchmae y
	  WHERE x.no_requis = y.no_requis
	    AND y.fecha_impresion >= a_fecha_desde 
	    AND y.fecha_impresion <= a_fecha_hasta
	    AND y.a_nombre_de MATCHES a_anombrede
		AND y.pagado = 1
		AND x.tipo = 1
		and x.cuenta <> "1220118" -- No incluir la cuenta de Planilla (Demetrio Hurtado 14/03/2013)
	  ORDER BY x.cuenta

{	 SELECT	no_cheque,a_nombre_de,anulado,no_requis
  	   INTO v_no_cheque,v_nombre_ben,_anulado,_no_requis
	   FROM	chqchmae
	  WHERE fecha_impresion >= a_fecha_desde 
	    AND fecha_impresion <= a_fecha_hasta
		AND pagado = 1

  FOREACH
	 SELECT cuenta,debito,credito,renglon
	   INTO v_cuenta,v_debito,v_credito,_renglon
	   FROM chqchcta
	  WHERE no_requis = _no_requis}
   
	  INSERT INTO tmp_tabla(
	  cuenta,
	  debito,
	  credito,
	  renglon,
	  cheque,
	  benefi,
	  anulado,
	  seleccionado,
	  fecha_impresion
	  )
	  VALUES(
	  v_cuenta,
	  v_debito,
	  v_credito,
	  _renglon,
	  v_no_cheque,
	  v_nombre_ben,
	  _anulado,
	  1,
	  v_fecha_imp
	  );
--  END FOREACH

END FOREACH

    -- Cheques anulados

	FOREACH
		 SELECT	x.cuenta,
		 		x.debito,
				x.credito,
				x.renglon,
				y.no_cheque,
				y.a_nombre_de,
				y.anulado,
				y.fecha_impresion
				INTO	
				v_cuenta,
		   		v_debito,
				v_credito,
				_renglon,
				v_no_cheque,
				v_nombre_ben,
				_anulado,
				v_fecha_imp
		   FROM	chqchcta x, chqchmae y
		  WHERE x.no_requis = y.no_requis
		    AND y.fecha_anulado >= a_fecha_desde 
		    AND y.fecha_anulado <= a_fecha_hasta
		    AND y.a_nombre_de MATCHES a_anombrede
			AND y.pagado = 1
			AND x.tipo = 2
			and x.cuenta <> "1220118" -- No incluir la cuenta de Planilla (Demetrio Hurtado 14/03/2013)
		  ORDER BY x.cuenta
	   
		  INSERT INTO tmp_tabla(
		  cuenta,
		  debito,
		  credito,
		  renglon,
		  cheque,
		  benefi,
		  anulado,
		  seleccionado,
		  fecha_impresion
		  )
		  VALUES(
		  v_cuenta,
		  v_debito,
		  v_credito,
		  _renglon,
		  v_no_cheque,
		  v_nombre_ben,
		  _anulado,
		  1,
		  v_fecha_imp
		  );

	END FOREACH


END IF
-- Procesos para Filtros

LET v_filtros = "";

update tmp_tabla
  set seleccionado = 0
where seleccionado = 1
  and cuenta in (select cta_cuenta from cglcuentas where cod_tipo in ('0012','0013','0014','0015','0016','0017','0018','0020','0021','0022','0023','0024'));
  --SALARIOS ,VACACIONES,DECIMO TERCER MES Y AGUINALDO,SEGURO SOCIAL,SEGURO EDUCATIVO,RIESGOS PROFESIONALES ,GASTO DE REPRESENTACION ,FONDO DE CESANTIA,SOBRETIEMPO,
  --|SEGUROS EMPLEADOS,BONO DE PRODUCTIVIDAD,PARTICIPACIÓN UTILIDADES,)

IF a_cuenta <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cuenta: " ||  TRIM(a_cuenta);

	LET _tipo = sp_sis04(a_cuenta);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_tabla
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cuenta NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
		
	   UPDATE tmp_tabla
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cuenta IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


FOREACH	WITH HOLD

	SELECT cuenta,
		   SUM(debito),
		   SUM(credito),
 --		   renglon,
		   cheque,
		   benefi,
		   anulado,
		   fecha_impresion
	  INTO v_cuenta,
		   v_debito,
		   v_credito,
 --		   _renglon,
		   v_no_cheque,
		   v_nombre_ben,
		   _anulado,
		   v_fecha_imp
	  FROM tmp_tabla
	  WHERE seleccionado = 1
	  GROUP BY cuenta, cheque, benefi, anulado, fecha_impresion 
      ORDER BY cuenta, cheque, benefi, anulado, fecha_impresion

	SELECT cta_nombre
	  INTO v_descripcion
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	If _anulado = 1 Then
		let v_anulado = "ANULADO";
	Else
		let v_anulado = "";
	End If

	RETURN  v_cuenta,		 
			v_descripcion,
			v_debito,     
			v_credito, 
			v_no_cheque,
			v_nombre_ben,
			v_anulado,
			v_fecha_imp,
			v_nombre_cia
			WITH RESUME;	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;