-- Reporte de los Incentivos de Fidelidad por Corredor - Detallado

-- Creado    : 13/01/2009 - Autor: Armando Moreno
-- Modificado: 13/01/2009 - Autor: Armando Moreno


DROP PROCEDURE sp_che93;

CREATE PROCEDURE sp_che93(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
  RETURNING CHAR(20),	-- Poliza	  
			CHAR(100),	-- Asegurado  
			DEC(16,2),	-- Monto	  
			DEC(16,2),	-- Prima	  
			DEC(16,2),	-- Comision	   
			CHAR(50),  
			CHAR(50),  			   
			DEC(5,2),  			   
			DEC(16,2), 	   
			DEC(5,2),  	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2);

DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _fecha_comis   DATE;
define _porc_persis   DEC(5,2);
define _porcentaje    DEC(16,2);
define _estatus_licencia char(1);


--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_porc_persis = 0;
let	_porcentaje = 0;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		prima_neta,
		comision,
		nombre,
		no_documento,
		nombre_cte,
		por_persistencia,
		porcentaje
   INTO	v_cod_agente,
   		v_no_poliza,
		v_prima,
		v_comision,
		v_nombre_agt,
		v_no_documento,
		v_nombre_clte,
		_porc_persis,
		_porcentaje
   FROM	chqfidel
  WHERE cod_agente   matches a_cod_agente
    and seleccionado = 0
	and periodo      = a_periodo

	RETURN  v_no_documento,
			v_nombre_clte,
			0,
			v_prima,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			_porcentaje,
			v_comision,
			_porc_persis,
			0,
			0,
			0,
			0,
			0,
			0
			WITH RESUME;
	
END FOREACH

UPDATE chqfidel
   SET seleccionado = 1
 WHERE cod_agente = a_cod_agente
   and periodo    = a_periodo;


END PROCEDURE;