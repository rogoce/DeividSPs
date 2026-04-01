-- Reporte de Totales por cuenta

-- Creado    : 22/11/2000 - Autor: Amado Perez 
-- Modificado: 11/12/2000 - Autor: Armando Moreno

-- SIS v.2.0 - d_cheq_sp_che08_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che08;

CREATE PROCEDURE sp_che08(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE)
RETURNING CHAR(25),	-- Cuenta
		  CHAR(50),	-- Descripcion
		  DEC(16,2),-- Debito
		  DEC(16,2),-- Credito
		  CHAR(50), -- Compania
		  smallint;

DEFINE v_cuenta		  	CHAR(25);  
DEFINE v_descripcion	CHAR(50); 
DEFINE v_debito       	DEC(16,2);
DEFINE v_credito      	DEC(16,2);
DEFINE v_nombre_cia   	CHAR(50);

DEFINE _renglon       	SMALLINT;
define _fecha_impresion	date;
define _fecha_anulado	date;
define _periodo1		char(7);
define _periodo2		char(7);
		
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_tabla(
	cuenta		    CHAR(25),
	debito          DEC(16,2),
	credito         DEC(16,2),
	renglon         smallint
	) WITH NO LOG;

-- Cheques Pagados

FOREACH
 SELECT	x.cuenta,
 		x.debito,
		x.credito
   INTO	v_cuenta,
   		v_debito,
		v_credito
   FROM	chqchcta x, chqchmae y
  WHERE x.no_requis        = y.no_requis
    AND y.fecha_impresion >= a_fecha_desde 
    and y.fecha_impresion <= a_fecha_hasta
	AND y.pagado           = 1
	and x.tipo             = 1

  INSERT INTO tmp_tabla(
  cuenta,
  debito,
  credito,
  renglon
  )
  VALUES(
  v_cuenta,
  v_debito,
  v_credito,
  1
  );

END FOREACH

-- Cheques Anulados

FOREACH
 SELECT	x.cuenta,
 		x.debito,
		x.credito,
		y.fecha_impresion,
		y.fecha_anulado
   INTO	v_cuenta,
   		v_debito,
		v_credito,
		_fecha_impresion,
		_fecha_anulado
   FROM	chqchcta x, chqchmae y
  WHERE x.no_requis      = y.no_requis
    AND y.fecha_anulado >= a_fecha_desde 
    and y.fecha_anulado <= a_fecha_hasta
	AND y.pagado         = 1
	AND y.anulado        = 1
	and x.tipo           = 2
	

{
	let _periodo1 = sp_sis39(_fecha_impresion);
	let _periodo2 = sp_sis39(_fecha_anulado);

	if _periodo1 = _periodo2 then
		continue foreach;
	end if
}

	INSERT INTO tmp_tabla(
	cuenta,
	debito,
	credito,
	renglon
	)
	VALUES(
	v_cuenta,
	v_debito,
	v_credito,
	2
	);

END FOREACH

FOREACH
 SELECT cuenta,
  	    debito,
	    credito,
	    renglon
   INTO v_cuenta,
	    v_debito,
	    v_credito,
	    _renglon
   FROM tmp_tabla
--  where renglon = 2
  order by renglon, cuenta

	SELECT cta_nombre
	  INTO v_descripcion
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN  v_cuenta,		 
			v_descripcion,
			v_debito,     
			v_credito,    
			v_nombre_cia,
			_renglon 
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_tabla;

END PROCEDURE;