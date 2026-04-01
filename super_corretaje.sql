-- Procedimiento que trae las polizas cuyo periodo de pago sea <> de 30 dias
-- y el corredor sea Super Corretaje
--
-- Creado    : 06/07/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 06/07/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE supercor;

CREATE PROCEDURE "informix".supercor()
   RETURNING  CHAR(10),
              CHAR(20),
			  DATE,
			  DATE,
			  INT,
			  DATE,
			  CHAR(7),
			  DEC(16,2),
			  CHAR(3),
			  CHAR(50),
			  INT,
			  DATE;

  DEFINE v_poliza 											CHAR(10);
  DEFINE v_documento 										CHAR(20);
  DEFINE v_primer_pago, v_vigencia_ini, v_vigencia_final  	DATE;
  DEFINE v_primer_pago_nuevo                                DATE;
  DEFINE v_periodo                      					CHAR(7);
  DEFINE v_nopagos, v_nopagos_nuevo        					INT;
  DEFINE v_saldos                       					DEC(16,2);
  DEFINE v_codperpago                  						CHAR(3);
  DEFINE v_perpago											CHAR(50);

CREATE TEMP TABLE tmp_arreglo(
		no_poliza        CHAR(10), 
		no_documento	 CHAR(20), 
		vigen_ini        DATE,
		pagos            INT,
		primer_pago      DATE
		) WITH NO LOG;


	FOREACH WITH HOLD
		SELECT 	Emipomae.no_poliza, Emipomae.no_documento,
		  		Emipomae.vigencia_inic, Emipomae.vigencia_final,Emipomae.no_pagos,
		  		Emipomae.fecha_primer_pago, Emipomae.periodo,
		  		Emipomae.saldo, Emipomae.cod_perpago, Cobperpa.nombre
		  INTO 	v_poliza, v_documento, 					
		  		v_vigencia_ini, v_vigencia_final, v_nopagos, 
		  	   	v_primer_pago, v_periodo,                    
		  	   	v_saldos, v_codperpago, v_perpago						
		 FROM Emipomae, Emipoagt, Cobperpa
		 WHERE Emipoagt.no_poliza = Emipomae.no_poliza
		   AND Cobperpa.cod_perpago = Emipomae.cod_perpago
		   AND Emipoagt.cod_agente = '00001'
		   AND Emipomae.actualizado = 1
		   AND Emipomae.estatus_poliza = 1
		   AND Emipomae.fecha_cancelacion IS NULL

		LET v_nopagos_nuevo = (v_vigencia_final - v_vigencia_ini) / 30;

		LET v_primer_pago_nuevo   = v_vigencia_ini + 30;

        IF v_primer_pago_nuevo > v_vigencia_final THEN
		   LET v_primer_pago_nuevo = v_vigencia_final;
		   LET v_nopagos_nuevo = 1;
		END IF        
							  
		INSERT INTO tmp_arreglo(
		no_poliza,   
		no_documento,
		vigen_ini,   
		pagos,       
		primer_pago
		)
		VALUES(
		v_poliza,
		v_documento,
		v_vigencia_ini,
		v_nopagos_nuevo,
		v_primer_pago_nuevo
		);

      RETURN v_poliza, 
      		 v_documento, 				
			 v_vigencia_ini, 
			 v_vigencia_final,
			 v_nopagos, 
			 v_primer_pago, 
			 v_periodo,        
			 v_saldos, 
			 v_codperpago, 
			 v_perpago,
			 v_nopagos_nuevo,
			 v_primer_pago_nuevo
		   	 WITH RESUME; 
			 
    END FOREACH

 {	FOREACH WITH HOLD

		SELECT no_poliza,   
			   no_documento,
			   vigen_ini,   
			   pagos,       
			   primer_pago
		  INTO v_poliza,
			   v_documento,
			   v_vigencia_ini,
			   v_nopagos_nuevo,
	  		   v_primer_pago_nuevo
		  FROM tmp_arreglo

		UPDATE emipomae
		   SET fecha_primer_pago = v_primer_pago_nuevo,
		       no_pagos 		 = v_nopagos_nuevo,
			   cod_perpago 		 = '002'
		 WHERE no_poliza = v_poliza;
         
		UPDATE endedmae
		   SET fecha_primer_pago = v_primer_pago_nuevo,
		       no_pagos 		 = v_nopagos_nuevo,
			   cod_perpago 		 = '002'
		 WHERE no_poliza = v_poliza;


	END FOREACH}

  DROP TABLE tmp_arreglo; 
END PROCEDURE
