
--DROP PROCEDURE sp_re144;

CREATE PROCEDURE "informix".sp_re144(a_periodo1 char(7), a_periodo2 char(7))
RETURNING   CHAR(10),integer,date;

define _transaccion   char(10);
define _cant          integer;
define _fecha		  date;

set isolation to dirty read;

		FOREACH
			 SELECT transaccion,
			        fecha
			   INTO _transaccion,
			        _fecha
			   FROM rectrmae
			  WHERE periodo between a_periodo1 and a_periodo2
			    and actualizado = 1

			  select count(*)
			    into _cant
				from rectrmae
			   where transaccion = _transaccion;

			if _cant > 1 then
			 	
				RETURN  _transaccion,_cant,_fecha
						with resume;
			end if

		END FOREACH

END PROCEDURE;
