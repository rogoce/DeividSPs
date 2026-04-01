-- Reporte de los Bonificacion de Rentabilidad	GLOBAL
-- Creado    : 19/02/2009 - Autor: Henry Giron
-- Modificado: 19/02/2009 - Autor: Henry Giron


DROP PROCEDURE sp_che96;

CREATE PROCEDURE sp_che96(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
  RETURNING CHAR(20),	-- Poliza	  
			CHAR(100),	-- Asegurado  
			DEC(16,2),	-- Monto	  
			DEC(16,2),	-- Prima	  
			DEC(16,2),	-- Comision	   
			CHAR(50),  
			CHAR(50),  			   
			DEC(16,2),  			   
			DEC(16,2), 	   
			DEC(16,2),  	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			CHAR(3),
			DEC(16,2),
			CHAR(50);


DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(16,2); 
DEFINE v_porc_cre	  DEC(16,2); 
DEFINE v_porc_sin	  DEC(16,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _fecha_comis   DATE;
define _porc_persis   DEC(16,2);
define _porcentaje    DEC(16,2);
define _estatus_licencia char(1);
define _cod_ramo	  char(3);
define _prima_ap      DEC(16,2);
define _nombre_ramo   CHAR(50);
define  _sini_g       DEC(16,2);



--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_porc_persis = 0;
let	_porcentaje = 0;

{ dado que los valores es por ramo se adiciono los datos globales que permiten validar la condicion esto es _g
{FOREACH
 SELECT	cod_agente,
 		no_poliza,
		prima_neta,
		comision,
		nombre,
		no_documento,
		nombre_cte,
		por_persistencia,
		porcentaje,
		por_cre,
		por_sin,
		cod_ramo,
		prima_ap,
		nombre_ramo	}
FOREACH
    SELECT	distinct cod_agente,
 		no_poliza,
		prima_neta_g,
		comision_g,
		nombre,
		no_documento,
		nombre_cte,
		por_persistencia,
		porcentaje_g,
		por_cre_g,
		por_sin_g,
		tipo_g,
		prima_ap_g,
		nombre_tipo_g,
		sini_g
   INTO	v_cod_agente,
   		v_no_poliza,
		v_prima,
		v_comision,
		v_nombre_agt,
		v_no_documento,
		v_nombre_clte,
		_porc_persis,
		_porcentaje,
        v_porc_cre,
        v_porc_sin,
		_cod_ramo,
		_prima_ap,
		_nombre_ramo,
		_sini_g
   FROM	chqrenta3
  WHERE cod_agente   matches a_cod_agente
	and periodo      = a_periodo
--    and seleccionado = 0

	{select sum(comision)
	  into v_comision
	  from chqrenta3
	 where cod_agente = v_cod_agente
  	   and periodo      = a_periodo;}

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
			_sini_g,
			0,
			0,
			0,
			0,
			0,
            v_porc_cre,
            v_porc_sin,
			_cod_ramo,
		    _prima_ap,
		    _nombre_ramo
			WITH RESUME;
	
END FOREACH
{
UPDATE chqrenta3
   SET seleccionado = 1
 WHERE cod_agente = a_cod_agente
   and periodo    = a_periodo;}


END PROCEDURE;