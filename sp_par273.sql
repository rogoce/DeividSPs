-- Reporte para proceso diario de cheques vencidos

-- Creado    : 28/04/2006 - Autor: Armando Moreno

DROP PROCEDURE sp_par273;

CREATE PROCEDURE sp_par273()
RETURNING char(4),	 -- agno
		  char(12),  -- cuenta
		  char(50),  --	nombre cuenta
		  dec(16,2); -- monto

DEFINE v_agno   	  	CHAR(4);  
DEFINE v_cuenta  		CHAR(12); 
DEFINE v_nombre		    CHAR(50); 
DEFINE v_monto       	DEC(16,2);
		
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "c:\sp_che47.trc";
--TRACE ON;

-- Nombre de la Compania


FOREACH
	SELECT ano,
		   cuenta,
	       monto	  
	  INTO v_agno,
	   	   v_cuenta,
		   v_monto
	  FROM cglprema

	select cta_nombre
	  into v_nombre
	  from cglcuentas
	 where cta_cuenta = v_cuenta;

	RETURN  v_agno,		 
			v_cuenta,
			v_nombre,
			v_monto     
			WITH RESUME;
END FOREACH

END PROCEDURE;