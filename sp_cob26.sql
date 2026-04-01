-- Procedimiento que extrae los datos del Rutero (Cobruter)
-- 
-- Creado    : 20/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 20/11/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob26;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_cob26(a_cobrador CHAR(3), a_dia INT) 
       RETURNING	    INT,  	  	-- Dia Uno
						INT,	  	-- Dia Dos
						CHAR(3),    -- cod_motiv
						CHAR(20), 	-- Documento
						CHAR(100),	-- Asegurado
						DATE,	  	-- Vigencia Inicial
						DATE,	  	-- Vigencia Final
						DEC(16,2),	-- Saldo
						DEC(16,2),	-- Por vencer
						DEC(16,2),	-- Exigible
						DEC(16,2),	-- Corriente
						DEC(16,2),	-- Monto 30
						DEC(16,2),	-- Monto 60
						DEC(16,2),	-- Monto 90
						DEC(16,2),	-- A_pagar
						CHAR(10), 	-- no_poliza
						DATETIME YEAR TO FRACTION(5), -- fecha
						CHAR(5),
						INT;  	  	-- Dia Uno otro

DEFINE _ramo_sis,_estatus SMALLINT;
DEFINE v_orden2,v_orden1  SMALLINT;
DEFINE v_dia1			  INT;
DEFINE v_dia2             INT;
DEFINE v_motiv,_cod_ramo  CHAR(3);
DEFINE _cia		          CHAR(3);
DEFINE _suc		          CHAR(3);
DEFINE v_documento        CHAR(20);
DEFINE v_asegurado        CHAR(100);
DEFINE v_vigen_ini        DATE;
DEFINE v_vigen_fin        DATE;
DEFINE v_prima_orig       DEC(16,2);
DEFINE v_saldo            DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);	 
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente		  DEC(16,2);
DEFINE v_monto_30		  DEC(16,2);
DEFINE v_monto_60		  DEC(16,2);
DEFINE v_monto_90		  DEC(16,2);
DEFINE v_apagar           DEC(16,2);
DEFINE _code_agente       CHAR(5);				  
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_cliente       CHAR(10);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _fecha_dt          DATETIME YEAR TO FRACTION(5);
DEFINE _periodo           CHAR(7);
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);

CREATE TEMP TABLE tmp_arreglo(
		orden_1			SMALLINT,
		orden_2			SMALLINT,
		no_poliza       CHAR(10),
		cod_cobrador    CHAR(3) NOT NULL,
		cod_motiv     	CHAR(3),
		a_pagar         DEC(16,2),
		saldo           DEC(16,2),     
		por_vencer      DEC(16,2),
		exigible        DEC(16,2),  
		corriente       DEC(16,2),	
		monto_30        DEC(16,2),	
		monto_60        DEC(16,2),	
		monto_90        DEC(16,2),	
		dia_cobros1		INT,
		dia_cobros2		INT,
		fecha           DATETIME YEAR TO FRACTION(5),
		cod_agente		CHAR(5)
		) WITH NO LOG;   

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;

FOREACH
 -- Lectura de Cobruter	
		SELECT no_poliza,   
			   cod_cobrador,
			   cod_motiv,
			   a_pagar,      
			   saldo,       
			   por_vencer,  
			   exigible,    
			   corriente,   
			   monto_30,    
			   monto_60,    
			   monto_90,    
			   dia_cobros1,	
			   dia_cobros2,
			   fecha,
			   orden_1,
			   orden_2,
			   cod_agente	
		  INTO _no_poliza,
		       _cod_cobrador,
		       v_motiv,
			   v_apagar,
			   v_saldo,     
			   v_por_vencer,
			   v_exigible,  
			   v_corriente,	
			   v_monto_30,	
			   v_monto_60,	
			   v_monto_90,	
			   v_dia1,
			   v_dia2,
			   _fecha_dt,
			   v_orden1,
			   v_orden2,
			   _code_agente
		  FROM cobruter
		 WHERE cod_cobrador = a_cobrador
		   AND (dia_cobros1 = a_dia
		   OR  dia_cobros2  = a_dia)

			IF _no_poliza IS NOT NULL THEN

				SELECT no_documento,
					   cod_compania,
					   cod_sucursal,
					   cod_ramo,
					   estatus_poliza,
					   saldo
				  INTO v_documento,
					   _cia,
					   _suc,
					   _cod_ramo,
					   _estatus,
					   v_saldo
				  FROM emipomae
				 WHERE no_poliza = _no_poliza
				   AND actualizado = 1;

				SELECT ramo_sis
				  INTO _ramo_sis
				  FROM prdramo
				 WHERE cod_ramo = _cod_ramo;

				IF v_saldo <= 0 THEN
					IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
						CONTINUE FOREACH;
					END IF
					IF _estatus = 2 THEN --Cancelada
						DELETE FROM cobruter WHERE no_poliza = _no_poliza;
						CONTINUE FOREACH;
					END IF
				END IF

					CALL sp_cob33(
					_cia,
					_suc,
					v_documento,
					_periodo,
					today
					) RETURNING v_por_vencer,
							    v_exigible,  
							    v_corriente, 
							    v_monto_30,  
							    v_monto_60,  
							    v_monto_90,
							    v_saldo
							    ;

				IF v_saldo <= 0 THEN 
					IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
						CONTINUE FOREACH;
					END IF
					IF _estatus = 2 THEN --Cancelada
						DELETE FROM cobruter WHERE no_poliza = _no_poliza;
						CONTINUE FOREACH;
					END IF
				END IF
				LET v_apagar = v_exigible;
			END IF

			INSERT INTO tmp_arreglo(
			no_poliza,   
			cod_cobrador,   	
			cod_motiv,
			a_pagar,      
			saldo,       
			por_vencer,  
			exigible,    
			corriente,   
			monto_30,    
			monto_60,    
			monto_90,    
			dia_cobros1,	
			dia_cobros2,
			fecha,
			orden_1,
			orden_2,
			cod_agente	
			)
			VALUES(
			_no_poliza,
			_cod_cobrador,
			v_motiv,    
			v_apagar,
			v_saldo,     
			v_por_vencer,
			v_exigible,  
			v_corriente,	
			v_monto_30,	
			v_monto_60,	
			v_monto_90,	
			v_dia1,
			v_dia2,
			_fecha_dt,
			v_orden1,
			v_orden2,
			_code_agente
		    );
END FOREACH;

FOREACH WITH HOLD
      SELECT no_poliza,   
             cod_cobrador,
             cod_motiv,
             a_pagar,      
             saldo,          
			 por_vencer,  
			 exigible,    
			 corriente,   
			 monto_30,    
			 monto_60,    
			 monto_90,    
			 dia_cobros1,	
			 dia_cobros2,
			 fecha,
			 orden_2,
			 orden_1,
			 cod_agente
	    INTO _no_poliza,
	         _cod_cobrador,
			 v_motiv,    
			 v_apagar,
			 v_saldo,     
			 v_por_vencer,
			 v_exigible,  
			 v_corriente,	
			 v_monto_30,	
			 v_monto_60,	
			 v_monto_90,	
			 v_dia1,
			 v_dia2,
			 _fecha_dt,
			 v_orden2,
			 v_orden1,
			 _code_agente
        FROM tmp_arreglo
	   ORDER BY orden_2,orden_1

		--Lectura de Poliza
		SELECT cod_contratante,
		       no_documento,
			   vigencia_inic,
			   vigencia_final
		  INTO _cod_cliente,
		       v_documento,
			   v_vigen_ini,
			   v_vigen_fin
		  FROM emipomae
		 WHERE no_poliza = _no_poliza
		   AND actualizado = 1;

		--Lectura de Corredor si la poliza es null
		 IF _no_poliza IS NULL THEN
		   SELECT nombre
		     INTO v_asegurado
		     FROM agtagent
		    WHERE cod_agente = _code_agente;
		 ELSE
			--Lectura de Asegurado
			SELECT nombre
			  INTO v_asegurado
			  FROM cliclien
			 WHERE cod_cliente = _cod_cliente;
		 END IF		 

	RETURN v_dia1,	   
		   v_dia2,      
		   v_motiv,
		   v_documento, 
		   v_asegurado, 
		   v_vigen_ini, 
		   v_vigen_fin, 
		   v_saldo,     
		   v_por_vencer,
		   v_exigible,  
		   v_corriente,	
		   v_monto_30,	
		   v_monto_60,	
		   v_monto_90,	
		   v_apagar,
		   _no_poliza,
		   _fecha_dt,
		   _code_agente,
		   v_dia1
		   WITH RESUME;

END FOREACH;

DROP TABLE tmp_arreglo;

END PROCEDURE