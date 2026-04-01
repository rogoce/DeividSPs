-- Reporte de las bonificaciones de cobranza por Corredor - Detallado

-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_che93aa;

CREATE PROCEDURE sp_che93aa(a_compania CHAR(3)) 
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
			DEC(16,2),
			char(7);

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
define _moro_045      DEC(16,2); 
define _moro_4690	  DEC(16,2);
define _porc_045	  DEC(5,2);
define _porc_4690	  DEC(5,2);
define _porc_partic   DEC(5,2);
define _045           DEC(16,2);
define _4690		  DEC(16,2);
define _91			  DEC(16,2);
define _pol_corr	  DEC(16,2);
define _pol_0045	  DEC(16,2);
define _pol_4690	  DEC(16,2);
define _comision2	  DEC(16,2);
define _comision1	  DEC(16,2);
define _tipo_pago     smallint;
define _porc_persis   DEC(5,2);
define _porcentaje    DEC(16,2);
define _estatus_licencia char(1);
define _periodo       char(7);

--SET DEBUG FILE TO "\\sp_che93aa.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_pol_corr = 0;
let	_pol_0045 = 0;
let	_pol_4690 = 0;
let _comision1 = 0;
let _comision2 = 0;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		prima_neta,
		comision,
		nombre,
		no_documento,
		nombre_cte,
		por_persistencia,
		porcentaje,
		periodo
   INTO	v_cod_agente,
   		v_no_poliza,
		v_prima,
		v_comision,
		v_nombre_agt,
		v_no_documento,
		v_nombre_clte,
		_porc_persis,
		_porcentaje,
		_periodo
   FROM	chqfidel
  WHERE cod_agente matches "*"
    AND periodo between '2008-01' and '2008-12'

	SELECT cod_contratante
      INTO _cod_cliente
      FROM emipomae
     WHERE no_poliza = v_no_poliza;

    SELECT nombre
      INTO v_nombre_clte
      FROM cliclien
     WHERE cod_cliente = _cod_cliente;

    SELECT tipo_pago
      INTO _tipo_pago
      FROM agtagent
     WHERE cod_agente = v_cod_agente;

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
			0,
			_periodo
			WITH RESUME;

	
END FOREACH

END PROCEDURE;