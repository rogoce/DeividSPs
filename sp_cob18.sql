-- Reporte de Recibos por Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob18_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob18;

CREATE PROCEDURE "informix".sp_cob18(
a_compania 	CHAR(3), 
a_remesa 	CHAR(10)
) RETURNING SMALLINT,	-- Renglon
		  	CHAR(10),	-- Recibo
		  	CHAR(1),	-- Tipo Movimiento
		  	CHAR(30),	-- Documento
		  	CHAR(100),  -- Descripcion	
		  	DEC(16,2),  -- Monto Banco
		  	DEC(16,2),  -- Prima
		  	DEC(16,2),  -- Impuesto
		  	DEC(16,2),  -- Monto Descontado
		  	DATE,		-- Fecha
		  	CHAR(7),	-- Periodo
		  	CHAR(50),	-- Nombre Banco
		  	CHAR(1),	-- Tipo Remesa
		  	SMALLINT,	-- Actualizado
		  	CHAR(50),   -- Nombre Compania    
			CHAR(10);	-- Numero de Remesa

DEFINE v_renglon		 SMALLINT;	
DEFINE v_no_recibo		 CHAR(10);
DEFINE v_tipo_mov        CHAR(1);
DEFINE v_doc_remesa      CHAR(30);
DEFINE v_desc_remesa     CHAR(100);
DEFINE v_monto_banco     DEC(16,2);
DEFINE v_prima           DEC(16,2);
DEFINE v_impuesto        DEC(16,2);
DEFINE v_descontada      DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_nombre_banco    CHAR(50);
DEFINE v_tipo_remesa     CHAR(1);
DEFINE v_actualizado     SMALLINT;
DEFINE v_compania_nombre CHAR(50); 

DEFINE _cod_banco        CHAR(3);
DEFINE _monto            DEC(16,2);
DEFINE _monto_cobros     DEC(16,2);

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Lectura de la Tabla de Remesas

SELECT fecha,
	   periodo,
	   cod_banco,
	   tipo_remesa,
	   actualizado
  INTO v_fecha,
	   v_periodo,
	   _cod_banco,
	   v_tipo_remesa,
	   v_actualizado	
  FROM cobremae
 WHERE no_remesa = a_remesa;	   	

SELECT nombre
  INTO v_nombre_banco
  FROM chqbanco
 WHERE cod_banco = _cod_banco;
 
IF v_nombre_banco IS NULL THEN
	LET v_nombre_banco = '... Banco No Definido ...';
END IF

-- Recibos por Remesa

FOREACH 
 SELECT renglon,
		no_recibo,
		tipo_mov,
		doc_remesa,
		desc_remesa,
		monto,
		prima_neta,
		impuesto,
		monto_descontado
   INTO	v_renglon,
		v_no_recibo,
		v_tipo_mov,
		v_doc_remesa,
		v_desc_remesa,
		v_monto_banco,
		v_prima,
		v_impuesto,
		v_descontada	 		
   FROM cobredet
  WHERE no_remesa = a_remesa
	AND renglon   <> 0
  ORDER BY no_recibo, renglon

	-- Obtiene el Monto del Banco

	IF v_tipo_mov   = 'M' AND
	   v_descontada <> 0  THEN
		LET _monto = 0;
	ELSE
		LET _monto = v_monto_banco;
	END IF

	LET v_monto_banco = _monto - v_descontada;
			
	RETURN v_renglon,			
		   v_no_recibo,			 
		   v_tipo_mov,        
		   v_doc_remesa,      
		   v_desc_remesa,     
		   v_monto_banco,    
		   v_prima,          
		   v_impuesto,       
		   v_descontada,     
		   v_fecha,          
		   v_periodo,		
		   v_nombre_banco,   
		   v_tipo_remesa,    
		   v_actualizado,    
		   v_compania_nombre,
		   a_remesa
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

