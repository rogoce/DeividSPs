-- Actualiza Reservas

-- Creado    : 01/07/2004 - Autor: Amado Perez M.
-- Modificado: 01/07/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf18;

CREATE PROCEDURE sp_rwf18(a_no_reclamo CHAR(10),a_cod_cobertura CHAR(5), a_monto DEC(16,2))
RETURNING char(5),
      	  varchar(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
          dec(16,2);

define _reserva_actual		dec(16,2);
define _reserva_actual2		dec(16,2);
define _variacion			dec(16,2);
define _error               int;

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

SELECT reserva_actual
  INTO _reserva_actual		
  FROM recrccob 		  
 WHERE no_reclamo = a_no_reclamo
   AND cod_cobertura = a_cod_cobertura;

LET _reserva_actual2 = _reserva_actual;

IF _reserva_actual2 < 0 THEN
	LET _reserva_actual2 = 0;
END IF

IF a_monto > 0 THEN
	IF a_monto > _reserva_actual2 THEN
		LET _variacion = _reserva_actual2 * -1;
	ELSE
		LET _variacion = a_monto * -1;
	END IF
ELSE
	LET _variacion = 0.00;
END IF

SET LOCK MODE TO WAIT 60;

BEGIN

	ON EXCEPTION SET _error 
	 --	LET _no_rec_char = _error;
	    LET _no_rec_char = ''; 
		RETURN _no_rec_char; 
	END EXCEPTION           



	UPDATE parconre
	   SET ult_no_reclamo = _no_rec_int
	 WHERE cod_compania   = a_compania
	   AND cod_sucursal   = t_cod_sucursal
	   AND cod_ramo       = t_cod_ramo
	   AND cod_subramo    = t_cod_subramo
	   AND mes            = t_mes
	   AND ano            = t_ano; 

	RETURN v_cod_cobertura, 
	       v_desc_cobertura,
		   v_estimado,       	
		   v_deducible,			
		   v_reserva_inicial,	
		   v_reserva_actual,	
		   v_pagos,				
		   v_salvamento,			
		   v_recupero,				
		   v_deducible_pagado,	
		   v_deducible_devuel	 
	 	   WITH RESUME;

END

	


END PROCEDURE;