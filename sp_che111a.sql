-- Reporte de los Bonificacion de Rentabilidad x Ramo - totales de comision
-- Creado    : 16/02/2009 - Autor: Henry Giron
-- Modificado: 16/02/2009 - Autor: Henry Giron

DROP PROCEDURE sp_che111a;

CREATE PROCEDURE sp_che111a(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
RETURNING 	CHAR(50),  	-- cia
			CHAR(50), 	-- agente
			CHAR(50), 	-- ramo
			DEC(16,2);	-- comision	 

DEFINE v_nombre_cia      CHAR(50);
DEFINE _nombre_tipo      CHAR(50);
DEFINE _nombre_ramo      CHAR(50);
DEFINE _comision1        DEC(16,2);

--SET DEBUG FILE TO "che111.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let v_nombre_cia = sp_sis01(a_compania); 
let _comision1 = 0;

FOREACH
    SELECT trim(nombre)||'   '||trim(cod_agente), 
           nombre_ramo,
		   sum(comision)
	  into _nombre_tipo,
	       _nombre_ramo,
		   _comision1
      FROM chqrenta3
     WHERE cod_agente  matches a_cod_agente
	   and periodo     = a_periodo
	 group by 1,2
	 order by 1,2

	RETURN v_nombre_cia,
	       _nombre_tipo,
		   _nombre_ramo,
		   _comision1		   
		   WITH RESUME;	
	
END FOREACH

END PROCEDURE;  
