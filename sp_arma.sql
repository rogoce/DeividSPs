

DROP PROCEDURE sp_arma;
CREATE PROCEDURE sp_arma()
 RETURNING  char(5),
  		    DATE,
  		    CHAR(50);

DEFINE _cod_agente  char(5);
DEFINE _date_added  DATE;
define _fecha_char  char(4);
DEFINE _nombre      char(50);


--set debug file to "sp_arma.trc";
--trace on;
FOREACH 

	SELECT date_added,
	       cod_agente,
	       nombre
	  INTO _date_added,
	       _cod_agente,
	       _nombre
	  FROM agtagent
	 WHERE tipo_agente = 'A'
	 
    if year(_date_added) = 2022 then
		RETURN _cod_agente,_date_added,_nombre WITH RESUME;
	end if

END FOREACH
END PROCEDURE;
