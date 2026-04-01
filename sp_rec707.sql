DROP PROCEDURE sp_rec707;

CREATE PROCEDURE "informix".sp_rec707(
a_compania CHAR(3), 
a_agencia  CHAR(3), 
a_periodo1 CHAR(7), 
a_periodo2 CHAR(7)
) 

-- Procedimiento que Carga el Incurrido de Reclamos	por Transaccion
-- en un Periodo Dado
-- Creado    : 01/08/2009 - Autor: Henry Giron
-- Modificado: 01/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;      
DEFINE _porc_reas       DECIMAL;      

DEFINE _cod_coasegur    CHAR(3);      
DEFINE _ajust_interno   CHAR(3);      

DEFINE _no_reclamo,_no_recpdt      CHAR(10);     
DEFINE _transaccion     CHAR(10);     
DEFINE _no_poliza       CHAR(10);     
DEFINE _periodo         CHAR(7);      
DEFINE _numrecla        CHAR(18);     
DEFINE _cod_sucursal    CHAR(3);      
DEFINE _cod_ramo        CHAR(3);      
DEFINE _cod_grupo       CHAR(5);      
DEFINE _fecha           DATE;         
DEFINE _fecha_siniestro DATE;         
DEFINE _cod_tipotran    CHAR(3);
DEFINE _no_tranrec      CHAR(10);     

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion 

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal 

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10),
		transaccion          CHAR(10),
		fecha                DATE,
		fecha_siniestro      DATE,
		no_poliza            CHAR(10),
		cod_sucursal         CHAR(3),
		cod_ramo             CHAR(3),
		cod_grupo			 CHAR(5),	
		periodo              CHAR(7),
		numrecla             CHAR(18),
		pagado_total         DEC(16,2) NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_total        DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_total      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
		cod_tipotran         CHAR(3),
		ajust_interno        CHAR(3),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo, transaccion)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(ajust_interno);

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

--- Determinar los reclamos con reserva pendiente

FOREACH 
 SELECT no_reclamo		
   INTO _no_recpdt
   FROM rectrmae 
  WHERE cod_compania = a_compania
--    AND periodo     BETWEEN a_periodo1 AND a_periodo2 
    AND periodo  <= a_periodo2 
	AND actualizado  = 1
  GROUP BY no_reclamo
 HAVING SUM(variacion) > 0 


		FOREACH WITH HOLD
		 SELECT a.no_reclamo,	   
		 		a.transaccion,	   
		 		a.fecha,		
		 		a.cod_tipotran,		
		 		a.monto,
		 		a.no_tranrec 
		   INTO _no_reclamo,	
		   		_transaccion,		
		   		_fecha,		
		   		_cod_tipotran,		
		   		_monto_total,
				_no_tranrec
		   FROM rectrmae a
		  WHERE a.cod_compania = a_compania
		--    AND a.cod_tipotran = b.cod_tipotran
			AND a.actualizado  = 1
		--    AND a.cod_tipotran IN ("004","005","006","007") 
--		    AND a.periodo   BETWEEN a_periodo1 AND a_periodo2
		    AND a.periodo   <= a_periodo2
			and a.no_reclamo = _no_recpdt
--			and a.variacion > 0 

			-- Lectura de la Tablas de Reclamos

			SELECT no_poliza,	
				   periodo,	
				   numrecla,	
				   fecha_siniestro,
				   ajust_interno
			  INTO _no_poliza,	
			  	   _periodo,	
			  	   _numrecla,	
			  	   _fecha_siniestro,
				   _ajust_interno
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;

			IF _no_poliza IS NULL THEN
				LET _no_poliza    = '1';
				LET _cod_sucursal = '001';
				LET _periodo      = a_periodo1;
			END IF

			-- Informacion de Polizas

			SELECT cod_ramo,
			       cod_grupo,
				   cod_sucursal
			  INTO _cod_ramo,
			  	   _cod_grupo,
				   _cod_sucursal
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			-- Informacion de Coseguro
		                                                                                                                
			SELECT porc_partic_coas 
			  INTO _porc_coas
		      FROM reccoas 
		     WHERE no_reclamo   = _no_reclamo
		       AND cod_coasegur = _cod_coasegur;

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF

			-- Informacion de Reaseguro

			SELECT porc_partic_suma
			  INTO _porc_reas
			  FROM rectrrea
			 WHERE no_tranrec    = _no_tranrec
			   AND tipo_contrato = 1;

			IF _porc_reas IS NULL THEN
				LET _porc_reas = 0;
			END IF;

			-- Calculos

			LET _monto_bruto = _monto_total / 100 * _porc_coas;                                                                                              
			LET _monto_neto  = _monto_bruto / 100 * _porc_reas;                                                                                              

			-- Actualizacion del Movimiento

			INSERT INTO tmp_sinis(
			no_reclamo,			
			transaccion,
			fecha,
			pagado_total,  		
			pagado_bruto,			
			pagado_neto,
			reserva_total,		
			reserva_bruto,			
			reserva_neto,
			incurrido_total,	
			incurrido_bruto,		
			incurrido_neto,
			no_poliza,				
			cod_ramo,
			periodo,			
			numrecla,				
			cod_grupo,
			fecha_siniestro,
			cod_tipotran,
			cod_sucursal,
			ajust_interno
			)
			VALUES(
			_no_reclamo,		
			_transaccion,
			_fecha,
			_monto_total,		
			_monto_bruto,			
			_monto_neto,
			0,					
			0,						
			0,
			0,					
			0,						
			0,
			_no_poliza,				
			_cod_ramo,
			_periodo,			
			_numrecla,				
			_cod_grupo,
			_fecha_siniestro,
			_cod_tipotran,
			_cod_sucursal,
			_ajust_interno
			);

		END FOREACH
END FOREACH


-- Variacion de Reserva                                                                                                        
                                                                                                     
LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

--- Determinar los reclamos con reserva pendiente

FOREACH 
 SELECT no_reclamo		
   INTO _no_recpdt
   FROM rectrmae 
  WHERE cod_compania = a_compania
    AND periodo     BETWEEN a_periodo1 AND a_periodo2 
	AND actualizado  = 1
  GROUP BY no_reclamo
 HAVING SUM(variacion) > 0 


		FOREACH
		 SELECT no_reclamo,		
		 		transaccion,		
		 		fecha,		
		 		cod_tipotran,  
		 		variacion,
		 		no_tranrec 
		   INTO _no_reclamo,	
		   		_transaccion,		
		   		_fecha,		
		   		_cod_tipotran, 
		   		_monto_total,
		 		_no_tranrec 
		   FROM rectrmae 
		  WHERE cod_compania = a_compania
			AND actualizado  = 1
		    AND periodo      BETWEEN a_periodo1 AND a_periodo2
			and no_reclamo = _no_recpdt
		    and variacion    <> 0                                                                                                                

			-- Lectura de la Tablas de Reclamos

			SELECT no_poliza,	
				   periodo,	
				   numrecla,	
				   fecha_siniestro,
				   cod_sucursal,
				   ajust_interno
			  INTO _no_poliza,	
			  	   _periodo,	
			  	   _numrecla,	
			  	   _fecha_siniestro,
				   _cod_sucursal,
				   _ajust_interno
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;
			
			IF _no_poliza IS NULL THEN
				LET _no_poliza = '1';
				LET _cod_sucursal = '001';
				LET _periodo      = a_periodo1;
			END IF

			-- Informacion de Polizas

			SELECT cod_ramo,	cod_grupo
			  INTO _cod_ramo,	_cod_grupo
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			-- Informacion de Coseguro
		                                                                                                                
			SELECT porc_partic_coas 
			  INTO _porc_coas
		      FROM reccoas 
		     WHERE no_reclamo   = _no_reclamo
		       AND cod_coasegur = _cod_coasegur;

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF

			-- Informacion de Reaseguro

			SELECT porc_partic_suma
			  INTO _porc_reas
			  FROM rectrrea
			 WHERE no_tranrec    = _no_tranrec
			   AND tipo_contrato = 1;

			IF _porc_reas IS NULL THEN
				LET _porc_reas = 0;
			END IF;

			-- Calculos

			LET _monto_bruto = _monto_total / 100 * _porc_coas;                                                                                              
			LET _monto_neto  = _monto_bruto / 100 * _porc_reas;                                                                                              
		                                                                                                                 
			-- Actualizacion del Movimiento

			BEGIN
			ON EXCEPTION IN(-239)

				UPDATE tmp_sinis
				   SET reserva_total = _monto_total,
				       reserva_bruto = _monto_bruto,
				       reserva_neto  = _monto_neto
				 WHERE no_reclamo    = _no_reclamo
				   AND transaccion   = _transaccion;

			END EXCEPTION

				INSERT INTO tmp_sinis(
				no_reclamo,
				transaccion,			
				fecha,
				pagado_total,  		
				pagado_bruto,			
				pagado_neto,
				reserva_total,		
				reserva_bruto,			
				reserva_neto,
				incurrido_total,	
				incurrido_bruto,		
				incurrido_neto,
				no_poliza,				
				cod_ramo,
				periodo,			
				numrecla,				
				cod_grupo,
				fecha_siniestro,
				cod_tipotran,
				cod_sucursal,
				ajust_interno
				)
				VALUES(
				_no_reclamo,
				_transaccion,		
				_fecha,
				0,					
				0,						
				0,
				_monto_total,		
				_monto_bruto,			
				_monto_neto,
				0,					
				0,						
				0,
				_no_poliza,				
				_cod_ramo,
				_periodo,			
				_numrecla,				
				_cod_grupo,
				_fecha_siniestro,
				_cod_tipotran,
				_cod_sucursal,
				_ajust_interno
				);

			END 
		                                                                                                                 
		END FOREACH
END FOREACH

-- Actualizacion del Incurrido 

UPDATE tmp_sinis
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;
                                                     
END PROCEDURE;
