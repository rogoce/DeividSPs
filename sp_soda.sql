-- Procedimiento para calculo de tarifas e indices
-- Creado    : 22/01/2009 - Autor: Ricardo Jim‚nez B.
-- SIS v.2.0 d_- DEIVID, S.A.


DROP PROCEDURE sp_sis51c;

CREATE PROCEDURE "informix".sp_sis51c(a_busqueda CHAR(1), a_producto CHAR(5), a_cobertura CHAR(5), a_anos SMALLINT, a_suma DECIMAL(16,2))
RETURNING DECIMAL(16,2);

DEFINE _valor DECIMAL(16,2);

SET ISOLATION TO DIRTY READ;

LET _valor = 00.00;

IF a_busqueda = "3" THEN

   SELECT  valor
     INTO _valor
     FROM prdtasec
    WHERE cod_producto  = a_producto
      AND cod_cobertura = a_cobertura
      AND renglon       = a_anos;

END IF
--
IF a_busqueda = "4" THEN

   SELECT valor
     INTO _valor
     FROM prdtasec
    WHERE cod_producto   = a_producto
      AND cod_cobertura  = a_cobertura
      AND rango_monto1  <= a_suma
	  AND rango_monto2  >= a_suma;

END IF
RETURN _valor;

END PROCEDURE;