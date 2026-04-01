--drop procedure sp_leg_conductor;

create procedure sp_leg_conductor()
returning smallint;

define _numrecla    CHAR(20);
define _conductor   CHAR(100);
define _cuenta      SMALLINT;

LET _conductor = "";

FOREACH 
	
	SELECT conductor,
	       numrecla
	  INTO _conductor,
	       _numrecla
	FROM conductores
	
		foreach
			
			SELECT count(*) 
			 INTO _cuenta
			FROM legdeman
			WHERE numrecla = _numrecla
			
			IF _cuenta > 0 THEN 
				UPDATE legdeman SET conductor = UPPER (_conductor)
				WHERE numrecla = _numrecla;
			END IF
			
		END FOREACH;
		
END FOREACH
	return 0;
END PROCEDURE
