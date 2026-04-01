-- Reporte de los Movimientos de un Recibo
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob19_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob19;

CREATE PROCEDURE "informix".sp_cob19(
a_compania 	CHAR(3), 
a_recibo 	CHAR(10)
) RETURNING CHAR(10),   -- Remesa
			SMALLINT,	-- Renglon
		  	CHAR(10),	-- Recibo
		  	CHAR(1),	-- Tipo Movimiento
		  	CHAR(30),	-- Documento
		  	CHAR(100),  -- Descripcion	
		  	DEC(16,2),  -- Monto Banco
		  	DEC(16,2),  -- Prima
		  	DEC(16,2),  -- Impuesto
		  	DEC(16,2),  -- Monto Descontado
		  	CHAR(50);   -- Nombre Compania    

DEFINE v_remesa 		 CHAR(10);
DEFINE v_renglon		 SMALLINT;	
DEFINE v_no_recibo		 CHAR(10);
DEFINE v_tipo_mov        CHAR(1);
DEFINE v_doc_remesa      CHAR(30);
DEFINE v_desc_remesa     CHAR(100);
DEFINE v_monto_banco     DEC(16,2);
DEFINE v_prima           DEC(16,2);
DEFINE v_impuesto        DEC(16,2);
DEFINE v_descontada      DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 

DEFINE _monto            DEC(16,2);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Recibos por Remesa

FOREACH 
 SELECT no_remesa,
 		renglon,
		no_recibo,
		tipo_mov,
		doc_remesa,
		desc_remesa,
		monto,
		prima_neta,
		impuesto,
		monto_descontado
   INTO	v_remesa,
   		v_renglon,
		v_no_recibo,
		v_tipo_mov,
		v_doc_remesa,
		v_desc_remesa,
		v_monto_banco,
		v_prima,
		v_impuesto,
		v_descontada	 		
   FROM cobredet
  WHERE cod_compania = a_compania
    AND actualizado  = 1
    AND no_recibo    = a_recibo
	AND renglon      <> 0
  ORDER BY no_remesa, renglon

	-- Obtiene el Monto del Banco

	IF v_tipo_mov   = 'M' AND
	   v_descontada <> 0  THEN
		LET _monto = 0;
	ELSE
		LET _monto = v_monto_banco;
	END IF

	LET v_monto_banco = _monto - v_descontada;
			
	RETURN v_remesa,
		   v_renglon,			
		   v_no_recibo,			 
		   v_tipo_mov,        
		   v_doc_remesa,      
		   v_desc_remesa,     
		   v_monto_banco,    
		   v_prima,          
		   v_impuesto,       
		   v_descontada,     
		   v_compania_nombre
		   WITH RESUME;	 		

END FOREACH

END PROCEDURE;

