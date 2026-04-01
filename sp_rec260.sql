-- Procedimiento que Carga el Informe de Ajustes por Proveedor
-- en un Periodo Dado
-- 
-- Creado    : 26/10/2015 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_rec260;
--DROP TABLE tmp_pos_recob;
CREATE PROCEDURE "informix".sp_rec260(a_periodo1 CHAR(7), a_periodo2 CHAR(7), a_proveedor CHAR(255) DEFAULT '*') 
			RETURNING   CHAR(10), 
						VARCHAR(100),
		            	VARCHAR(100),
						CHAR(10),
		            	DATE,
						DATE,
						DATE,
						DEC(16,2),
						DEC(16,2),
						CHAR(10),
						INTEGER,
						VARCHAR(50),
						VARCHAR(255);
						

DEFINE v_proveedor         VARCHAR(100);
DEFINE v_no_ajus_orden     CHAR(10);
DEFINE v_a_nombre_de       VARCHAR(100);
DEFINE v_fecha_ajuste      DATE;
DEFINE v_fecha_recibido    DATE;
DEFINE v_fecha_actualizado DATE;
DEFINE v_monto_orden       DEC(16,2);
DEFINE v_monto_factura     DEC(16,2);
DEFINE v_no_cheque         INT;
DEFINE v_compania_nombre   VARCHAR(50);
DEFINE v_filtros           VARCHAR(255);

DEFINE _tipo               CHAR(1);
DEFINE _no_requis          CHAR(10);
DEFINE _cod_proveedor      CHAR(10);
DEFINE _fecha_inic         DATE;
DEFINE _fecha_fin          DATE;


-- Nombre de la Compania
--SET DEBUG FILE TO "sp_rec260.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01('001');

CREATE TEMP TABLE tmp_pos_recob(
		cod_proveedor        CHAR(10)     	NOT NULL,
		proveedor            VARCHAR(100) 	NOT NULL,
		a_nombre_de          VARCHAR(100),
		no_ajus_orden        CHAR(10)    	NOT NULL,
		fecha_ajuste         DATE      		NOT NULL,
		fecha_recibido       DATE,
		fecha_actualizado    DATE,
		monto_orden          DEC(16,2),
		monto_factura        DEC(16,2),
		no_requis            CHAR(10),
		no_cheque            INTEGER,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   

let _fecha_inic      = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]); 
let _fecha_fin       = sp_sis36(a_periodo2);

FOREACH	

 SELECT	cod_proveedor,
 		no_ajus_orden,
		DATE(fecha_ajuste),
        DATE(fecha_recibido),
        DATE(fecha_actualizado),
        monto_orden,
        monto_factura,
		no_requis
   INTO	_cod_proveedor,
   		v_no_ajus_orden,
		v_fecha_ajuste,
        v_fecha_recibido,
        v_fecha_actualizado,
        v_monto_orden,
        v_monto_factura,
        _no_requis		
   FROM recordam
  WHERE actualizado = 1
    AND date(fecha_ajuste) >= _fecha_inic
    AND date(fecha_ajuste) <= _fecha_fin	
		
	-- Lectura de Proveedor

	SELECT nombre
	  INTO v_proveedor
 	  FROM cliclien
	 WHERE cod_cliente = _cod_proveedor;
	 
	-- Lectura de 'a nombre de' y número de cheque

	SELECT a_nombre_de,
	       no_cheque
	  INTO v_a_nombre_de,
	       v_no_cheque
 	  FROM chqchmae
	 WHERE no_requis = _no_requis;

	INSERT INTO tmp_pos_recob(
	cod_proveedor,
	proveedor,
	a_nombre_de,
	no_ajus_orden,
	fecha_ajuste,
	fecha_recibido,
	fecha_actualizado,
	monto_orden,
	monto_factura,
	no_requis,
	no_cheque
	)
	VALUES(
	_cod_proveedor,      
	v_proveedor,       
	v_a_nombre_de,
	v_no_ajus_orden,    
	v_fecha_ajuste,
	v_fecha_recibido,
	v_fecha_actualizado,
	v_monto_orden,
	v_monto_factura,
	_no_requis,
	v_no_cheque
	);
END FOREACH;

-- Filtros
LET v_filtros = "";


IF a_proveedor <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Proveedor: " ||  TRIM(a_proveedor);

	LET _tipo = sp_sis04(a_proveedor);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_proveedor NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_proveedor IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT cod_proveedor,
	    proveedor,
	    a_nombre_de,
	    no_ajus_orden,
	    fecha_ajuste,
	    fecha_recibido,
	    fecha_actualizado,
	    monto_orden,
	    monto_factura,
	    no_requis,
	    no_cheque
   INTO _cod_proveedor,      
	    v_proveedor,       
	    v_a_nombre_de,
	    v_no_ajus_orden,    
	    v_fecha_ajuste,
	    v_fecha_recibido,
	    v_fecha_actualizado,
	    v_monto_orden,
	    v_monto_factura,
	    _no_requis,
	    v_no_cheque
   FROM tmp_pos_recob
  WHERE seleccionado = 1
  ORDER BY cod_proveedor, no_ajus_orden

	RETURN _cod_proveedor,      
	       TRIM(v_proveedor),       
	       TRIM(v_a_nombre_de),
	       v_no_ajus_orden,    
	       v_fecha_ajuste,
	       v_fecha_recibido,
	       v_fecha_actualizado,
	       v_monto_orden,
	       v_monto_factura,
	       _no_requis,
	       v_no_cheque,
		   TRIM(v_compania_nombre),
		   TRIM(v_filtros)
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_pos_recob;
END PROCEDURE;