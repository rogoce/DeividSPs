-- Buscar relay

DROP PROCEDURE sp_par383;

CREATE PROCEDURE "informix".sp_par383() RETURNING VARCHAR(30) as smtp,
			VARCHAR(5) as puerto,
			VARCHAR(30) as identificador,
			VARCHAR(30) as pw;

DEFINE _cod_relay		CHAR(3);
DEFINE _smtp		    VARCHAR(30);
DEFINE _puerto		    SMALLINT;
DEFINE _identificador	VARCHAR(30);
DEFINE _pw			    VARCHAR(30);
DEFINE _puerto_str      VARCHAR(5);

SET ISOLATION TO DIRTY READ;

SELECT cod_relay
  INTO _cod_relay
  FROM parparam;

SELECT smtp,
       puerto,
	   identificador,
	   pw
  INTO _smtp,
       _puerto,
	   _identificador,
	   _pw
  FROM parrelay
 WHERE cod_relay = _cod_relay;
 
LET _puerto_str = _puerto; 
  
RETURN _smtp,
       _puerto,
	   _identificador,
	   _pw;  

END PROCEDURE;
