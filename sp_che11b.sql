-- Cheques Pagados a Proveedores de Salud

-- Creado    : 01/02/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 01/02/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che11_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che11b;

CREATE PROCEDURE sp_che11b(
a_compania		CHAR(3), 
a_sucursal		CHAR(3), 
a_fecha_desde	DATE, 
a_fecha_hasta	DATE, 
a_cod_cliente	CHAR(255), 
a_firma			char(50), 
a_cargo			char(50)
) RETURNING CHAR(100),	-- Nombre Asegurado
			CHAR(30),	-- Cedula
			DEC(16,2),	-- Monto
			CHAR(50),	-- Compania
			CHAR(50),	-- Firma
			CHAR(50),	-- Cargo
			CHAR(100);	-- Fecha

DEFINE _nombre          CHAR(100);
DEFINE _cedula          CHAR(30); 
DEFINE _monto           DEC(16,2);
DEFINE v_nombre_cia     CHAR(50); 
DEFINE _fecha_char		CHAR(100);
DEFINE _cod_cliente     CHAR(10); 
define _tipo			char(1);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_nombre_cia = sp_sis01(a_compania); 

let _fecha_char = sp_sis20(today);

-- Separa los valores en una tabla de codigos

IF a_cod_cliente <> "*" THEN

	LET _tipo = sp_sis04(a_cod_cliente);  -- Separa los Valores del String en una tabla de codigos

END IF

foreach
 SELECT t.cod_cliente,
        sum(t.monto)
   into _cod_cliente,
        _monto
   FROM chqchmae c, chqchrec r, rectrmae t
  WHERE c.no_requis        = r.no_requis
    and r.transaccion      = t.transaccion
    and c.pagado           = 1
    AND c.origen_cheque    = 3
    AND c.anulado          = 0
    and t.cod_tipopago     in ("001", "002")
    AND c.fecha_impresion  >= a_fecha_desde
    AND c.fecha_impresion  <= a_fecha_hasta
    and t.cod_cliente      IN (SELECT codigo FROM tmp_codigos)
  group by t.cod_cliente

	SELECT cedula,
		   nombre	
	  INTO _cedula,
	       _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente; 		

	RETURN _nombre,
		   _cedula,
		   _monto,
		   v_nombre_cia,
		   a_firma,
		   a_cargo,
		   _fecha_char
		   WITH RESUME;	

end foreach

IF a_cod_cliente <> "*" THEN
	DROP TABLE tmp_codigos;
END IF

END PROCEDURE;