-- Reporte de las bonificaciones de cobranza por Corredor - Detallado

-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_boni2;

CREATE PROCEDURE sp_boni2() 
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
define _estatus_licencia smallint;


--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

let	_pol_corr = 0;
let	_pol_0045 = 0;
let	_pol_4690 = 0;
let _comision1 = 0;
let _comision2 = 0;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		monto,
		prima,
		comision,
		nombre,
		no_documento,
		moro_045,
		moro_4690,
		porc_045,
		porc_4690,
		pol_corr,
		pol_0045,
		pol_4690,
		comis0045,
		comis4690,
		nombre_cte
   INTO	v_cod_agente,
   		v_no_poliza,
		v_monto,
		v_prima,
		v_comision,
		v_nombre_agt,
		v_no_documento,
		_moro_045,
		_moro_4690,
		_porc_045,
		_porc_4690,
		_pol_corr,
		_pol_0045,
		_pol_4690,
        _comision2,
		_comision1,
		v_nombre_clte
   FROM	chqboni
  WHERE seleccionado = 0
	and periodo      = '2009-03'
	and tipo_requis  = 'A'
	order by cod_agente

	SELECT count(*)
	  INTO _estatus_licencia
	  FROM chqchmae
	 WHERE cod_agente = v_cod_agente
	   and no_cheque = 274;

	if _estatus_licencia = 0 then

	RETURN  v_no_documento,
			v_nombre_clte,
			v_monto,
			v_prima,
			v_comision,
			v_nombre_agt,
			'',
			_porc_045,
			_moro_045,
			_porc_4690,
			_moro_4690,
			_pol_corr,
			_pol_0045,
			_pol_4690,
			_comision2,
			_comision1
			WITH RESUME;
	end if
	
END FOREACH

END PROCEDURE;