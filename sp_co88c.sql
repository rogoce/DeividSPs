-- Procedimiento para el concurso de cobros
--
-- Creado    : 31/07/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 31/07/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob88c;

CREATE PROCEDURE "informix".sp_cob88c()
	   RETURNING   CHAR(20);
	               				 
 DEFINE _no_documento   				CHAR(20);
 DEFINE _no_poliza      				CHAR(10);
 DEFINE _fecha_ult_pago 				DATE;
 DEFINE _fecha          				DATE;
 DEFINE _nombre         				CHAR(100);
 DEFINE _cod_pagador    				CHAR(10);
 DEFINE _flag, _incobrable, _tipo_contrato SMALLINT;
 DEFINE _cod_agente     				CHAR(5);
 DEFINE _cod_ramo       				CHAR(3);
 DEFINE _cod_subramo    				CHAR(3);
 DEFINE _cod_formapag					CHAR(3);
 DEFINE _cod_grupo      				CHAR(3);
 DEFINE v_monto         				DEC(16,2);
 DEFINE v_prima_bruta   				DEC(16,2);
 DEFINE _letra          				DEC(16,2);
 DEFINE _por_vencer_tot    				DEC(16,2);
 DEFINE _exigible_tot      				DEC(16,2);
 DEFINE _corriente_tot     				DEC(16,2);
 DEFINE _monto_30_tot      				DEC(16,2);
 DEFINE _monto_60_tot      				DEC(16,2);
 DEFINE _monto_90_tot      				DEC(16,2);
 DEFINE _saldo_tot         				DEC(16,2);
 DEFINE _por_vencer_tot_2    			DEC(16,2);
 DEFINE _exigible_tot_2      			DEC(16,2);
 DEFINE _corriente_tot_2     			DEC(16,2);
 DEFINE _monto_30_tot_2      			DEC(16,2);
 DEFINE _monto_60_tot_2      			DEC(16,2);
 DEFINE _monto_90_tot_2      			DEC(16,2);
 DEFINE _saldo_tot_2         			DEC(16,2);
 DEFINE _monto_30_60_90	   				DEC(16,2);
 DEFINE _no_pagos 						INT;
 DEFINE _residuo, v_letra_pendiente  	DEC(16,7);
 DEFINE _caso, _cantidad, _contador, _i SMALLINT;
 DEFINE _cod_tipoprod                   CHAR(3);

CREATE TEMP TABLE tmp_tabla(
    no_poliza       CHAR(10),
	monto           DEC(16,2), 
	fecha           DATE,
	no_documento    CHAR(20),
	PRIMARY KEY (no_documento)
	) WITH NO LOG;

 BEGIN
 FOREACH WITH HOLD

	SELECT a.fecha,
	       b.no_poliza,
		   b.monto
	  INTO _fecha,
	       _no_poliza,
		   v_monto
	  FROM cobremae a, cobredet b
	 WHERE a.no_remesa = b.no_remesa
	   AND a.fecha >= '01/12/2002'
	   AND a.fecha <= '31/12/2002'
	   AND b.tipo_mov = 'P'
	   AND a.actualizado = 1
	 ORDER BY a.fecha DESC

     SELECT no_documento,
	       	cod_tipoprod
	   INTO _no_documento,
	        _cod_tipoprod
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

	   IF _cod_tipoprod = '002' THEN
	   	   CONTINUE FOREACH;
	   END IF

 		BEGIN
		  ON EXCEPTION IN(-268, -239)

		  	 UPDATE tmp_tabla
		  	    SET monto = monto + v_monto,
				 	no_poliza = _no_poliza
		  	  WHERE no_documento = _no_documento;
		  	   							
		  END EXCEPTION

		  INSERT INTO tmp_tabla(
		  no_poliza,
		  monto,
		  fecha,
		  no_documento
		  )
		  VALUES(
		  _no_poliza,
		  v_monto,
		  _fecha,
		  _no_documento
		  );

		END

 END FOREACH

 FOREACH WITH HOLD
	SELECT no_poliza,
	       monto,
		   fecha
	  INTO _no_poliza,
		   v_monto,
		   _fecha
	  FROM tmp_tabla

 	SELECT no_documento,
	       no_poliza,
 	       cod_pagador,  
	       fecha_ult_pago,
		   cod_ramo,
		   cod_subramo,
		   cod_formapag,
		   cod_grupo,
		   prima_bruta,
		   no_pagos,
		   incobrable
	  INTO _no_documento,
	       _no_poliza,
	       _cod_pagador,
	       _fecha_ult_pago,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_formapag,
		   _cod_grupo,
		   v_prima_bruta,
		   _no_pagos,
		   _incobrable
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

   LET _flag = 0;

   IF  _cod_ramo = '018' OR _cod_ramo = '019' THEN
   		LET _flag = 1;
   END IF

   IF _cod_grupo = '00000' THEN
   		LET _flag = 1;
   END IF

   IF _cod_formapag = '046' THEN
   		LET _flag = 1;
   END IF

   IF _incobrable = 1 THEN
   		LET _flag = 1;
   END IF

   FOREACH
	 SELECT cod_agente
	   INTO _cod_agente
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza

	 IF _cod_agente = '00521' THEN
   		LET _flag = 1;
		EXIT FOREACH;
	 END IF

   END FOREACH

   FOREACH
	 SELECT b.tipo_contrato
	   INTO _tipo_contrato
	   FROM emireaco a, reacomae b
	  WHERE a.no_poliza = _no_poliza
	    AND b.cod_contrato = a.cod_contrato

	 IF _tipo_contrato = 2 THEN
   		LET _flag = 1;
		EXIT FOREACH;
	 END IF

   END FOREACH


   IF _flag = 0 THEN

   LET _cantidad = 0;

   -- Procedimiento que genera la morosidad para una poliza
	CALL sp_cob33(
		 '001',
		 '001',	
		 _no_documento,
		 '2002-12',
		 '31/12/2002'
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;         

	LET _letra = v_prima_bruta / _no_pagos;

	IF _letra IS NULL THEN
	    LET _letra = 0;
	END IF

	IF _saldo_tot IS NULL THEN
		LET _saldo_tot = 0;	
	END IF

    IF _saldo_tot >= 0 THEN
		IF v_monto < _letra THEN
			LET _caso = 1;
			CONTINUE FOREACH;
		ELSE   
			BEGIN
			 ON EXCEPTION IN(-647)

			 END EXCEPTION
				IF _letra <> 0 THEN
					LET _residuo = MOD(ABS(v_monto), ABS(_letra));
				END IF
			END

			IF _residuo = 0 THEN
		    	LET _caso = 2;
			ELSE
		    	LET _caso = 3;
				IF _letra <> 0 THEN
					LET _cantidad = TRUNC(ABS(v_monto) / ABS(_letra) , 0);
				END IF
			END IF
		END IF
	ELSE
		LET _caso = 4;
	END IF


	CALL sp_cob33(
		 '001',
		 '001',	
		 _no_documento,
		 '2002-11',
		 '30/11/2002'
		 ) RETURNING _por_vencer_tot_2,       
    				 _exigible_tot_2,         
    				 _corriente_tot_2,        
    				 _monto_30_tot_2,         
    				 _monto_60_tot_2,         
    				 _monto_90_tot_2,
					 _saldo_tot_2;         

	LET _monto_30_60_90	= _monto_30_tot_2 + _monto_60_tot_2 + _monto_90_tot_2;

	IF _monto_30_60_90 <= 0 THEN
		LET _contador = 2 + _cantidad;
	ELSE
		LET _contador = 1;
	END IF

	FOR _i = 1 TO _contador

		RETURN _no_documento        
	      WITH RESUME;
	END FOR

   END IF

 END FOREACH
 END

DROP TABLE tmp_tabla;

END PROCEDURE
