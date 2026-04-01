-- Procedimiento para consultar si las unidades están ubicadas en ZONA LIBRE
--
-- Creado    : 27/07/2009 - Autor: Roberto Silvera
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro857;

CREATE PROCEDURE "informix".sp_pro857(a_poliza CHAR(10))
	   RETURNING SMALLINT;
	   
DEFINE _cod_manzana     char(15);
DEFINE v_bandera		SMALLINT;
	   
LET _cod_manzana = "";
LET v_bandera = 0;
	   
	    FOREACH

			  select cod_manzana
				into _cod_manzana
				from emipouni
			   where no_poliza = a_poliza

			  if _cod_manzana[1,12] = '030010020103' then

					LET v_bandera = 1;

					exit FOREACH;

			  end if
			  
		END FOREACH
	   

	   RETURN v_bandera;
END PROCEDURE
