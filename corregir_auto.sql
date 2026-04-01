-- corregir tipo de auto  
-- 
-- Creado    : 04/01/2017 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_corregir_auto;
CREATE procedure "informix".sp_corregir_auto()
RETURNING CHAR(20),
		  CHAR(1),
		  char(30);

BEGIN
	define v_documento 			CHAR(20);
	define v_no_poliza          char(10);
	define v_no_motor           char(30);
	define v_uso_auto           char(1);
	define v_cod_tipoveh        char(3);

	SET ISOLATION TO DIRTY READ;
	
	foreach
		select no_documento,
			   no_motor
		  into v_documento,
		       v_no_motor
		  from corregir_auto
	
		LET v_no_poliza   	= sp_sis21(v_documento);
		   
		update emiauto
		   set uso_auto = 'C',
		       cod_tipoveh = '003'
		 where no_poliza =  v_no_poliza
		   and no_motor = v_no_motor; 
		      
		update endmoaut
		   set uso_auto = 'C',
		       cod_tipoveh = '003'
		 where no_poliza = v_no_poliza
		   and no_motor = v_no_motor;
		   
		select uso_auto,
		       cod_tipoveh
		  into v_uso_auto,
		       v_cod_tipoveh
		  from emiauto
		 where no_poliza = v_no_poliza
		   and no_motor  = v_no_motor;
	
	return v_documento,
	       v_uso_auto,
		   v_no_motor
           with resume;
	end foreach
END
END PROCEDURE;