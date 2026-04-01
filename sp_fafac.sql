DROP PROCEDURE sp_fafac;
CREATE PROCEDURE sp_fafac()	RETURNING CHAR(03),CHAR(10),CHAR(05),CHAR(05),CHAR(10),CHAR(20),DEC(16,2);

DEFINE v_cod_contrato       CHAR(05);
DEFIne v_prima,v_prima1,v_prima2 DEC(16,2);
DEFINE v_no_poliza,y_no_poliza   CHAR(10);
DEFINE v_no_endoso,y_no_endoso,v_no_unidad   CHAR(05);
DEFINE v_cobertura,v_cod_ramo          CHAR(03);
DEFINE v_orden              SMALLINT;
DEFINE v_no_documento       CHAR(20);
DEFINE v_no_factura         CHAR(10);

LET v_prima = 0;
LET v_prima1 = 0;
LET v_prima2 = 0;

foreach
  Select a.prima,a.cod_contrato,a.no_poliza,a.no_endoso,a.no_unidad,
         a.cod_cober_reas,a.orden
          INTO v_prima,v_cod_contrato,v_no_poliza,v_no_endoso,v_no_unidad,
               v_cobertura,v_orden 
         FROM emifacon a,reacomae b,endedmae c
        WHERE a.cod_contrato = b.cod_contrato
          AND b.tipo_contrato = 3
		  AND c.periodo >= "2000-12"
		  AND c.periodo <= "2000-12"
		  AND c.actualizado = 1
		  AND a.no_poliza = c.no_poliza
		  AND a.no_endoso = c.no_endoso

      	 FOREACH
          SELECT prima,no_poliza,no_endoso
		         INTO v_prima1,y_no_poliza,y_no_endoso
                 FROm emifafac
				WHERE cod_contrato = v_cod_contrato
				  AND no_poliza    = v_no_poliza
				  AND no_endoso    = v_no_endoso
                  AND no_unidad    = v_no_unidad
                  AND cod_cober_reas = v_cobertura
				  AND orden          = v_orden

          
 		  LET v_prima2 = v_prima2 + v_prima1;

		END FOREACH
		      
	  IF v_prima2 IS NULL THEN
		LET v_prima2 = 0;
	  END IF  

	  IF v_prima = v_prima2 THEN
	     LET v_prima = 0;
         LET v_prima1 = 0;
         LET v_prima2 = 0;
	     CONTINUE FOREACH;
	  ELSE
	     SELECT cod_ramo,no_factura,no_documento
		        INTO v_cod_ramo,v_no_factura,v_no_documento
				FROM emipomae
			   WHERE no_poliza = v_no_poliza;

	   	 RETURN v_cod_ramo,v_no_poliza,v_no_endoso,v_cod_contrato,
	   	        v_no_factura,v_no_documento,v_prima WITH RESUME;
	  END IF
	  LET v_prima = 0;
      LET v_prima1 = 0;
      LET v_prima2 = 0;
				 		
	END FOREACH

foreach
  Select a.prima,a.cod_contrato,a.no_poliza,a.no_endoso,a.no_unidad,
         a.cod_cober_reas,a.orden
          INTO v_prima,v_cod_contrato,v_no_poliza,v_no_endoso,v_no_unidad,
               v_cobertura,v_orden 
         FROM emifafac a,endedmae c
        WHERE c.periodo >= "2000-12"
		  AND c.periodo <= "2000-12"
		  AND c.actualizado = 1
		  AND a.no_poliza = c.no_poliza
		  AND a.no_endoso = c.no_endoso

          SELECT prima,no_poliza,no_endoso
		         INTO v_prima1,y_no_poliza,y_no_endoso
                 FROm emifacon
				WHERE no_poliza    = v_no_poliza
				  AND no_endoso    = v_no_endoso
                  AND no_unidad    = v_no_unidad
                  AND cod_cober_reas = v_cobertura
				  AND orden          = v_orden;

		IF	y_no_poliza IS NULL THEN
          
		     SELECT cod_ramo,no_factura,no_documento
			        INTO v_cod_ramo,v_no_factura,v_no_documento
					FROM emipomae
				   WHERE no_poliza = v_no_poliza;

		   	 RETURN v_cod_ramo,v_no_poliza,v_no_endoso,v_cod_contrato,
		   	        v_no_factura,v_no_documento,v_prima WITH RESUME;
	    END IF
				 		
END FOREACH

END PROCEDURE
