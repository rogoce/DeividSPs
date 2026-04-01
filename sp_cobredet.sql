-- Reporte para Jesus
-- creado:	16/10/2023 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_cobredet;

CREATE PROCEDURE "informix".sp_cobredet()
		RETURNING CHAR(10)		, 
		          SMALLINT		, 
		          CHAR(3)		, 
		          CHAR(3)		, 
		          CHAR(10)		, 
		          CHAR(5)		, 
		          CHAR(10)		, 
		          CHAR(10)		, 
		          CHAR(10)		, 
		          CHAR(5)		, 
		          CHAR(10)		, 
		          CHAR(30)		, 
		          CHAR(1)		, 
		          DECIMAL(16,2)	, 
		          DECIMAL(16,2)	, 
		          DECIMAL(16,2)	, 
		          DECIMAL(16,2)	, 
		          SMALLINT		, 
		          VARCHAR(100)	, 
		          DECIMAL(16,2)	, 
		          CHAR(7)		, 
		          DATE			, 
		          SMALLINT		, 
		          CHAR(5)		, 
		          CHAR(5)		, 
		          SMALLINT 		, 
		          SMALLINT		, 
		          SMALLINT		, 
		          CHAR(10)		, 
		          DECIMAL(16,2) , 
		          CHAR(1) 		;
		
DEFINE _no_remesa 			CHAR(10)		; 
DEFINE _renglon 			SMALLINT		; 
DEFINE _cod_compania 		CHAR(3)			; 
DEFINE _cod_sucursal 		CHAR(3)			; 
DEFINE _no_poliza 			CHAR(10)		; 
DEFINE _no_unidad 			CHAR(5)			; 
DEFINE _no_tranrec 			CHAR(10)		; 
DEFINE _cod_recibi_de 		CHAR(10)		; 
DEFINE _no_reclamo 			CHAR(10)		; 
DEFINE _cod_cobertura 		CHAR(5)			; 
DEFINE _no_recibo 			CHAR(10)		; 
DEFINE _doc_remesa 			CHAR(30)		; 
DEFINE _tipo_mov 			CHAR(1)			; 
DEFINE _monto 				DECIMAL(16,2)	; 
DEFINE _prima_neta 			DECIMAL(16,2)	; 
DEFINE _impuesto 			DECIMAL(16,2)	; 
DEFINE _monto_descontado 	DECIMAL(16,2)	; 
DEFINE _comis_desc 			SMALLINT		; 
DEFINE _desc_remesa 		VARCHAR(100)	; 
DEFINE _saldo 				DECIMAL(16,2)	; 
DEFINE _periodo 			CHAR(7)			; 
DEFINE _fecha 				DATE			; 
DEFINE _actualizado 		SMALLINT		; 
DEFINE _cod_agente 			CHAR(5)			; 
DEFINE _cod_auxiliar 		CHAR(5)			; 
DEFINE _sac_asientos 		SMALLINT 		; 
DEFINE _subir_bo 			SMALLINT		; 
DEFINE _flag_web_corr 		SMALLINT		; 
DEFINE _no_recibo2 			CHAR(10)		; 
DEFINE _gastos_manejo 		DECIMAL(16,2) 	; 
DEFINE _nueva_renov 		CHAR(1) 		;		
		
 
SET ISOLATION TO DIRTY READ; 
foreach

 select no_remesa, 
		renglon, 
		cod_compania,
		cod_sucursal, 
		no_poliza, 
		no_unidad, 
		no_tranrec, 
		cod_recibi_de, 
		no_reclamo, 
		cod_cobertura, 
		no_recibo, 
		doc_remesa, 
		tipo_mov, 
		monto, 
		prima_neta, 
		impuesto, 
		monto_descontado, 
		comis_desc, 
		desc_remesa, 
		saldo, 
		periodo, 
		fecha,
		actualizado,
		cod_agente, 
		cod_auxiliar, 
		sac_asientos, 
		subir_bo, 
		flag_web_corr, 
		no_recibo2, 
		gastos_manejo,
		nueva_renov
   into _no_remesa, 		
        _renglon, 		
        _cod_compania, 	
        _cod_sucursal, 	
        _no_poliza, 		
        _no_unidad, 		
        _no_tranrec, 		
        _cod_recibi_de, 	
        _no_reclamo, 		
        _cod_cobertura, 	
        _no_recibo, 		
        _doc_remesa, 		
        _tipo_mov, 		
        _monto, 			
        _prima_neta, 		
        _impuesto, 		
        _monto_descontado,
        _comis_desc, 		
        _desc_remesa, 	
        _saldo, 			
        _periodo, 		
        _fecha, 			
        _actualizado, 	
        _cod_agente, 		
        _cod_auxiliar, 	
        _sac_asientos, 	
        _subir_bo, 		
        _flag_web_corr, 	
        _no_recibo2, 		
        _gastos_manejo, 	
        _nueva_renov 	
   from cobredet 
  where no_remesa in (select no_remesa from migrarremesas)

  let _desc_remesa 			= UPPER(sp_cleaner(_desc_remesa));		
		

	RETURN	_no_remesa, 		
	        _renglon, 		
	        _cod_compania, 	
	        _cod_sucursal, 	
	        _no_poliza, 		
	        _no_unidad, 		
	        _no_tranrec, 		
	        _cod_recibi_de, 	
	        _no_reclamo,		
	        _cod_cobertura, 	
	        _no_recibo, 		
	        _doc_remesa, 		
	        _tipo_mov, 		
	        _monto, 			
	        _prima_neta, 		
	        _impuesto, 		
	        _monto_descontado,
	        _comis_desc, 		
	        _desc_remesa, 	
	        _saldo, 			
	        _periodo, 		
	        _fecha, 			
	        _actualizado, 	
	        _cod_agente, 		
	        _cod_auxiliar, 	
	        _sac_asientos, 	
	        _subir_bo, 		
	        _flag_web_corr, 	
	        _no_recibo2, 		
	        _gastos_manejo, 	
	        _nueva_renov 	
			WITH RESUME;
end foreach

END PROCEDURE;		