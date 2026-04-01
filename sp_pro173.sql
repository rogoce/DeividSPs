-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 22/08/2006 - Autor: Amado Perez M.
-- Modificado: 22/08/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro173;

CREATE PROCEDURE sp_pro173()

RETURNING integer,
		  integer;

DEFINE _error smallint; 
DEFINE _cant_dias int; 
DEFINE _cant_cartas int; 
DEFINE _fecha_aniv DATE;
DEFINE _hoy        DATE;


CREATE TEMP TABLE temp_carta
     (cant_dias        integer,
      cant_cartas      integer,
	  fecha_aniv	   date,
      PRIMARY KEY (fecha_aniv)) WITH NO LOG;

--set debug file to "sp_pro173.trc";
--trace on;

LET _hoy = CURRENT;

SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
	SELECT fecha_aniv
	  INTO _fecha_aniv
	  FROM emicartasal
	 WHERE entregado = 'NO'
	    OR entregado Is null
		OR TRIM(entregado) = ""

	LET _cant_dias = _fecha_aniv - _hoy;

	BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_carta
                    SET cant_cartas  = cant_cartas + 1
                  WHERE fecha_aniv       = _fecha_aniv;

          END EXCEPTION

	  INSERT INTO temp_carta(
	  cant_dias,
	  cant_cartas,
	  fecha_aniv
	  )
	  VALUES(
	  _cant_dias,
	  1,
	  _fecha_aniv
	  );

	END
END FOREACH

FOREACH WITH HOLD
	SELECT cant_dias,
		   cant_cartas
	  INTO _cant_dias,
	       _cant_cartas
	  FROM temp_carta
  ORDER BY cant_dias

    RETURN _cant_dias,
		   _cant_cartas
	  WITH RESUME;

END FOREACH

DROP TABLE temp_carta;


END PROCEDURE;