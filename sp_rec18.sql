-- Ingresos por Recuperos, Salvamentos y Deducibles
-- 
-- Creado    : 02/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec18_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec18;

CREATE PROCEDURE "informix".sp_rec18(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_ramo CHAR(255) default '*'
) RETURNING	CHAR(10), 	-- Remesa
            SMALLINT,   -- Renglon
			CHAR(10), 	-- Recibo
			CHAR(18),	-- Reclamo
			CHAR(100), 	-- A Nombre De
			DATE,    	-- Fecha 
			DEC(16,2),  -- Monto
			CHAR(50),	-- Tipo Movimiento
			VARCHAR(50), 	-- Compania Nombre   
            CHAR(255);			
 
DEFINE v_no_remesa       CHAR(10); 
DEFINE v_renglon         SMALLINT; 
DEFINE v_recibo          CHAR(10); 
DEFINE v_doc_reclamo     CHAR(18); 
DEFINE v_a_nombre_de     CHAR(100);
DEFINE v_fecha           DATE;     
DEFINE v_monto           DEC(16,2);
DEFINE v_nombre_mov      CHAR(50); 
DEFINE v_compania_nombre VARCHAR(50); 

DEFINE _cod_cliente      CHAR(10); 
DEFINE _tipo_mov         CHAR(1);

DEFINE v_filtros         CHAR(255);
DEFINE v_desc_ramo       VARCHAR(50);
DEFINE _cod_ramo         CHAR(3);
DEFINE _no_reclamo       CHAR(10);
DEFINE _no_poliza        CHAR(10);
DEFINE v_saber          CHAR(2);
DEFINE _tipo            CHAR(1);
DEFINE v_codigo         CHAR(5);

-- Tabla Temporal 

CREATE TEMP TABLE tmp_salva(
		no_remesa       CHAR(10),
		renglon         SMALLINT, 
		recibo          CHAR(10), 
		doc_reclamo     CHAR(18), 
		a_nombre_de     CHAR(100),
		fecha           DATE,     
		monto           DEC(16,2),
		nombre_mov      CHAR(50), 
		cod_ramo        CHAR(3),
		seleccionado    SMALLINT DEFAULT 1,
		PRIMARY KEY (no_remesa, renglon)
		) WITH NO LOG;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

FOREACH 
 SELECT no_remesa,
		fecha
   INTO	v_no_remesa,
   		v_fecha
   FROM cobremae
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND periodo BETWEEN a_periodo1 AND a_periodo2

	FOREACH
	 SELECT renglon,
			no_recibo,
			doc_remesa,
			cod_recibi_de,
			monto,
			tipo_mov,
			no_reclamo
	   INTO	v_renglon,
			v_recibo,
			v_doc_reclamo,
			_cod_cliente,
			v_monto,
			_tipo_mov,
			_no_reclamo
	   FROM	cobredet
	  WHERE	no_remesa = v_no_remesa
	    AND tipo_mov IN ('D', 'S', 'R') 
		
	SELECT no_poliza
      INTO _no_poliza
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo;

    SELECT cod_ramo
      INTO _cod_ramo
      FROM emipomae
     WHERE no_poliza = _no_poliza;	  

			IF _tipo_mov = 'D' THEN
				LET v_nombre_mov = 'Pago de Deducible';
			ELIF _tipo_mov = 'S' THEN
				LET v_nombre_mov = 'Pago de Salvamento';
			ELSE
				LET v_nombre_mov = 'Pago de Recupero';
			END IF

			SELECT nombre
			  INTO v_a_nombre_de
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;

			INSERT INTO tmp_salva(
			no_remesa,       
			renglon,         
			recibo,          
			doc_reclamo,     
			a_nombre_de,     
			fecha,           
			monto,           
			nombre_mov,
            cod_ramo			
			)
			VALUES(
			v_no_remesa,       
			v_renglon,         
			v_recibo,          
			v_doc_reclamo,     
			v_a_nombre_de,     
			v_fecha,           
			v_monto,           
			v_nombre_mov,
            _cod_ramo			
			);


	END FOREACH -- Renglones de la Remesa

END FOREACH	-- Remesas


-- Procesos para Filtros

LET v_filtros = "";

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: "; --|| TRIM(a_agente);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_salva
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_salva
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT prdramo.nombre,tmp_codigos.codigo
          INTO v_desc_ramo,v_codigo
          FROM prdramo,tmp_codigos
         WHERE prdramo.cod_ramo = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ramo) || TRIM(v_saber);
	 END FOREACH

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT	no_remesa,       
		renglon,         
		recibo,          
		doc_reclamo,     
		a_nombre_de,     
		fecha,           
		monto,           
		nombre_mov      
  INTO	v_no_remesa,       
		v_renglon,         
		v_recibo,          
		v_doc_reclamo,     
		v_a_nombre_de,     
		v_fecha,           
		v_monto,           
		v_nombre_mov      
  FROM tmp_salva
 WHERE seleccionado = 1
 ORDER BY nombre_mov, fecha

	RETURN	v_no_remesa,
			v_renglon,
			v_recibo,
			v_doc_reclamo,
			v_a_nombre_de,
			v_fecha,
			v_monto,
			v_nombre_mov,
			TRIM(v_compania_nombre),
			v_filtros
			WITH RESUME;

END FOREACH
					 
DROP TABLE tmp_salva;

END PROCEDURE;

