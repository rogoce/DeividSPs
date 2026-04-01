-- Reporte Bono Vida Individual Nuevas
-- Creado    : 15/09/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_cheq_sp_che243_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che243;
CREATE PROCEDURE sp_che243(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
  RETURNING CHAR(20),	-- Poliza	  
			CHAR(100),	-- Asegurado  
			DEC(16,2),	-- Monto	  
			DEC(16,2),	-- Prima
			CHAR(50),  	-- n_agente						 
			CHAR(50),  	-- n_cia
			DEC(16,2),	-- Comision
			DEC(16,2),
			char(7);	-- porc bono

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
DEFINE _cod_cliente   CHAR(10);
define _porc_comis	  DEC(16,2);
define _tipo_pago     smallint;


--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

FOREACH
SELECT	cod_agente,
 		no_poliza,
		comision,
		prima_cobrada,
		comision,	
		no_documento,
		porcentaje
   INTO	v_cod_agente,
   		v_no_poliza,
		v_monto,
		v_prima,
		v_comision,		
		v_no_documento,
		_porc_comis
   FROM	chqboccp
  WHERE cod_agente matches a_cod_agente
    and nvl(seleccionado,0) = 0
	and periodo_pago  = a_periodo

	select nombre
	  into v_nombre_agt
	  from agtagent
	 where cod_agente = v_cod_agente;

	SELECT cod_contratante
      INTO _cod_cliente
      FROM emipomae
     WHERE no_poliza = v_no_poliza;

    SELECT nombre
      INTO v_nombre_clte
      FROM cliclien
     WHERE cod_cliente = _cod_cliente;

	let v_nombre_agt = trim(v_nombre_agt) || " " || (v_cod_agente);

	RETURN  v_no_documento,
			v_nombre_clte,
			v_monto,
			v_prima,
			v_nombre_agt,
			v_nombre_cia,
			_porc_comis,
			v_comision,
			a_periodo
			WITH RESUME;
	
END FOREACH

UPDATE chqboccp
   SET seleccionado = 1
 WHERE cod_agente = a_cod_agente
   and periodo_pago  = a_periodo;


END PROCEDURE;