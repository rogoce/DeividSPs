-- Reporte de Recibos por Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob18_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob249;

CREATE PROCEDURE "informix".sp_cob249(
a_compania 	CHAR(3), 
a_remesa 	CHAR(10)
) RETURNING SMALLINT,	-- Renglon
		  	CHAR(10),	-- Recibo
		  	CHAR(1),	-- Tipo Movimiento
		  	CHAR(30),	-- Documento
		  	DEC(16,2),  -- %comis corredor
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
			CHAR(10),	-- Numero de Remesa
			CHAR(5),
			DEC(16,2),
			char(50);

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
DEFINE _porc_comis_agt   DEC(16,2);
DEFINE _renglon          SMALLINT;
DEFINE _cod_agente       CHAR(5);
DEFINE _com_ganada       DEC(16,2);
DEFINE _porc_partic_agt  DEC(16,2);
define _n_agente         char(50);
define v_prima1          DEC(16,2);
DEFINE v_no_poliza       CHAR(10);
DEFINE _cod_agente_2     CHAR(5);
define _n_agente_2       CHAR(50);
define _monto_calc       dec(16,2);

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
		monto_descontado,
		no_poliza	
   INTO	v_renglon,
		v_no_recibo,
		v_tipo_mov,
		v_doc_remesa,
		v_desc_remesa,
		v_monto_banco,
		v_prima,
		v_impuesto,
		v_descontada,
		v_no_poliza	 		
   FROM cobredet
  WHERE no_remesa = a_remesa
	AND renglon   <> 0
	AND tipo_mov in ("P","N")
  ORDER BY no_recibo, renglon

	-- Obtiene el Monto del Banco

	IF v_tipo_mov   = 'M' AND
	   v_descontada <> 0  THEN
		LET _monto = 0;
	ELSE
		LET _monto = v_monto_banco;
	END IF

	LET v_monto_banco = _monto - v_descontada;

	let _com_ganada = 0.00;
	let v_prima1    = v_prima;
	let _monto_calc = 0.00;

	foreach
		select renglon,
			   cod_agente,
			   porc_comis_agt,
			   porc_partic_agt,
			   monto_calc
		  into _renglon,
		       _cod_agente,
			   _porc_comis_agt,
			   _porc_partic_agt,
			   _monto_calc
		  from cobreagt
		 where no_remesa = a_remesa
		   and renglon   = v_renglon

		 select nombre
		   into _n_agente
		   from agtagent
		  where cod_agente = _cod_agente;

		if v_tipo_remesa = "B" then  --coas minoritario
			let _com_ganada = _monto_calc;
		else
			let _com_ganada = (v_prima * (_porc_partic_agt / 100)) * _porc_comis_agt / 100 ;
		end if


		RETURN v_renglon,			
			   v_no_recibo,			 
			   v_tipo_mov,        
			   v_doc_remesa,      
			   _porc_comis_agt,     
			   v_monto_banco,    
			   v_prima1,
			   _com_ganada,       
			   v_descontada,     
			   v_fecha,          
			   v_periodo,		
			   v_nombre_banco,   
			   v_tipo_remesa,
			   v_actualizado,    
			   v_compania_nombre,
			   a_remesa,
			   _cod_agente,
			   _porc_partic_agt,
			   _n_agente
			   WITH RESUME;

		   if  _porc_partic_agt <> 100 then

				FOREACH
		            SELECT cod_agente
					  INTO _cod_agente_2
		              FROM emipoagt
		             WHERE no_poliza = v_no_poliza
					   AND cod_agente <> _cod_agente

						 select nombre
						   into _n_agente_2
						   from agtagent
						  where cod_agente = _cod_agente_2;

						RETURN v_renglon,			
							   v_no_recibo,			 
							   v_tipo_mov,        
							   v_doc_remesa,      
							   _porc_comis_agt,     
							   v_monto_banco,    
							   0,   -- v_prima1,
							   _com_ganada,       
							   0,   -- v_descontada,     
							   v_fecha,          
							   v_periodo,		
							   v_nombre_banco,   
							   v_tipo_remesa,
							   v_actualizado,    
							   v_compania_nombre,
							   a_remesa,
							   _cod_agente_2,
							   _porc_partic_agt,
							   _n_agente_2
							   WITH RESUME;

				END FOREACH
		  		  

		   end if

		   let v_prima1 = 0	;

	end foreach

END FOREACH

FOREACH 
 SELECT renglon,
		no_recibo,
		tipo_mov,
		doc_remesa,
		desc_remesa,
		monto * -1,		    
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
	AND tipo_mov in ("C")
  ORDER BY no_recibo, renglon

	 RETURN v_renglon,			
			v_no_recibo,			 
			v_tipo_mov,        
			v_doc_remesa,      
			0,     
			0,    
			0,
			0,       
			v_monto_banco,     
			v_fecha,          
			v_periodo,		
			v_nombre_banco,   
			v_tipo_remesa,
			v_actualizado,    
			v_compania_nombre,
			a_remesa,
			'',
			0,
			''
			WITH RESUME;

END FOREACH



END PROCEDURE;
				  