-- Procedimiento para buscar si existe el numero de motor 
-- en otra poliza
--
-- Creado    : 01/09/2005 - Autor: Armando Moreno
-- Modificado: 01/09/2005
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro82n;

CREATE PROCEDURE "informix".sp_pro82n(a_poliza  CHAR(10))
RETURNING   INTEGER,CHAR(42)		   

DEFINE _no_motor 	 CHAR(30);
DEFINE _cantidad	 INTEGER;
define _no_unidad	 CHAR(5);

BEGIN

SET ISOLATION TO DIRTY READ;

FOREACH
   SELECT no_unidad
     INTO _no_unidad 
     FROM emireaut
    WHERE no_poliza = a_poliza

   SELECT count(*)
     INTO _cantidad
     FROM emipouni
    WHERE no_poliza = a_poliza
	  and no_unidad = _no_unidad;

   IF _cantidad = 0 THEN	    --unidad nva.
	   SELECT count(*)
	     INTO _cantidad
	     FROM emiautor
	    WHERE no_poliza = a_poliza
		  and no_unidad = _no_unidad;
	   IF _cantidad = 0 THEN	--no esta creado el auto
		   RETURN 1, "DEBE CREAR EL AUTO, UNIDAD: " || _no_unidad;
	   ELSE
		   SELECT no_motor
		     INTO _no_motor
		     FROM emiautor
		    WHERE no_poliza = a_poliza
			  and no_unidad = _no_unidad;

		   SELECT count(*)
		     INTO _cantidad
		     FROM emivehic
		    WHERE no_motor = _no_motor;

		   IF _cantidad = 0 THEN	--no esta creado el vehiculo
			   RETURN 1, "DEBE CREAR EL VEHICULO ANTES DE CONTINUAR...";
		   END IF
	   end if
   END IF

END FOREACH

RETURN 0, "";

END

END PROCEDURE;