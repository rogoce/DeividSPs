--  Endosos de Disminucion de vigencia, que que hay que arreglarle el numero de pagos

--  Creado: 05/2002  - Creado: ARMANDO MORENO M.
--  SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_cob86;
CREATE PROCEDURE "informix".sp_cob86(a_compania CHAR(3),a_agencia CHAR(3),a_periodo_desde CHAR(7),a_periodo_hasta CHAR(7))
         RETURNING DATE,
         		   CHAR(20),
         		   CHAR(10),
				   SMALLINT,
         		   CHAR(50),
         		   CHAR(50),
				   SMALLINT,
				   SMALLINT,
				   DATE;

BEGIN
      DEFINE v_nopoliza,_no_factura    CHAR(10);
	  DEFINE v_noendoso     		   CHAR(05);
      DEFINE _no_pagos,_li_dia,_dias_faltan                 SMALLINT;
      DEFINE v_descr_cia,_periodo_pago CHAR(50);
      DEFINE _cod_perpago              CHAR(03);
      DEFINE _no_documento             CHAR(20);
	  DEFINE _fecha_hoy,_vig_final,_vig_final_poliza,_vigencia_inic	DATE;

      LET _li_dia  = 0;

       SET ISOLATION TO DIRTY READ;

	   LET _fecha_hoy = CURRENT;
       LET v_descr_cia = sp_sis01(a_compania);

       FOREACH WITH HOLD
         	SELECT vigencia_inic,
         		   no_poliza,
         		   no_endoso,
         		   no_factura,
         		   no_pagos,
				   cod_perpago
              INTO _vig_final,
              	   v_nopoliza,
              	   v_noendoso,
              	   _no_factura,
              	   _no_pagos,
				   _cod_perpago
              FROM endedmae 
             WHERE periodo >= a_periodo_desde  
               AND periodo <= a_periodo_hasta 
               AND actualizado = 1
			   AND cod_endomov = '019'

			  IF _vig_final IS NULL THEN
				CONTINUE FOREACH;
			  END IF

			  SELECT no_documento,
					 vigencia_final,
					 vigencia_inic
			    INTO _no_documento,
					 _vig_final_poliza,
					 _vigencia_inic
			    FROM emipomae	
			   WHERE no_poliza = v_nopoliza;

			  LET _li_dia = 0;			  
			  LET _dias_faltan = _vig_final_poliza - _vigencia_inic;

			  IF  _dias_faltan < 0 THEN
				  LET _dias_faltan = ABS(_dias_faltan);				
			  END IF

			  IF _cod_perpago = '001' THEN
			  	LET _li_dia = _no_pagos * 15;
			  ELIF _cod_perpago = '002' THEN
				LET _li_dia = _no_pagos * 30;
			  ELIF _cod_perpago = '003' THEN
				LET _li_dia = _no_pagos * 60;
			  ELIF _cod_perpago = '004' THEN
				LET _li_dia = _no_pagos * 90;
			  ELIF _cod_perpago = '005' OR _cod_perpago = '009' THEN
				LET _li_dia = _no_pagos * 120;
			  ELIF _cod_perpago = '007' THEN
				LET _li_dia = _no_pagos * 180;
			  ELIF _cod_perpago = '008' THEN
				LET _li_dia = _no_pagos * 365;
			  END IF

			  {IF _vig_final < _vig_final_poliza THEN
				CONTINUE FOREACH;
			  END IF

			  IF _vig_final < _fecha_hoy THEN
			  	CONTINUE FOREACH;
			  END IF} 

			  FOREACH
				  SELECT nombre
				    INTO _periodo_pago
				    FROM cobperpa	
				   WHERE cod_perpago = _cod_perpago

				   EXIT FOREACH;
			  END FOREACH

			  IF _li_dia > _dias_faltan THEN
				RETURN _vig_final,	   
					   _no_documento,      
					   _no_factura,  
					   _no_pagos, 
					   _periodo_pago,
					   v_descr_cia,
					   _dias_faltan,
					   _li_dia,
					   _vigencia_inic
					   WITH RESUME;
			  END IF
	   END FOREACH
END
END PROCEDURE;
