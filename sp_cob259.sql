-- Reporte de Pagos Externos
-- 
-- Creado    : 27/12/2010 - Autor: Roman Gordon
-- SIS v.2.0 - d_cobr_sp_cob259_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob259;

CREATE PROCEDURE "informix".sp_cob259(a_numero 	CHAR(10), a_compania CHAR(3))
RETURNING	CHAR(80),	 --1  _nom_cliente
			CHAR(50),	 --2  v_compania_nombre
			CHAR(30),	 --3  _nom_agente		
			CHAR(20),	 --4  _no_documento
			CHAR(10),	 --5  a_numero		
			CHAR(10),	 --6  _cod_agente		 
			CHAR(10),	 --7  _no_recibo_ancon		
			CHAR(10),	 --8  _no_cheque       	
			CHAR(10),	 --9  _no_remesa			
			CHAR(10),	 --10 _no_remesa_ancon		
			CHAR(10),	 --11 _no_recibo_det					 			
		   	DEC(16,2),	 --12 _comis_clave_det		
			DEC(16,2),	 --13 _comis_cobro_det		
			DEC(16,2),	 --14 _comis_desc_det		
			DEC(16,2),	 --15 _comis_visa_det		
			DEC(16,2),	 --16 _monto_bruto_det	
			DEC(16,2),	 --17 _monto_cobrado_det
			DEC(16,2),	 --18 _monto_comis_det	
			DEC(16,2),	 --19 _neto_pagado_det	
			DEC(16,2),	 --20 _porc_comis_det		
		   	DATE,		 --21 _fecha_recibo		
			DATE,		 --22 _fecha_remesa		
			DATE,		 --23 _periodo_desde		
			DATE,		 --24 _periodo_hasta		
			DATE,		 --25 _fecha_pago		
			SMALLINT;	 --26 _renglon
		

DEFINE _nom_cliente			CHAR(80);
DEFINE v_compania_nombre	CHAR(50);
DEFINE _nom_agente			CHAR(30);
DEFINE _no_documento		CHAR(20);
DEFINE _cod_agente		 	CHAR(10);
DEFINE _no_recibo_ancon		CHAR(10);
DEFINE _no_cheque       	CHAR(10);
DEFINE _no_remesa			CHAR(10);
DEFINE _no_remesa_ancon		CHAR(10);
DEFINE _no_recibo_det		CHAR(10);
DEFINE _comis_clave_det		DEC(16,2);
DEFINE _comis_cobro_det		DEC(16,2);
DEFINE _comis_desc_det		DEC(16,2);
DEFINE _comis_visa_det		DEC(16,2);
DEFINE _monto_bruto_det		DEC(16,2);
DEFINE _monto_cobrado_det	DEC(16,2);
DEFINE _monto_comis_det		DEC(16,2);
DEFINE _neto_pagado_det		DEC(16,2);
DEFINE _porc_comis_det		DEC(16,2);
DEFINE _fecha_recibo		DATE;
DEFINE _fecha_remesa		DATE;
DEFINE _periodo_desde		DATE;
DEFINE _periodo_hasta		DATE;
DEFINE _fecha_pago			DATE;
DEFINE _renglon				SMALLINT;
DEFINE _tipo_formato		SMALLINT;


SET ISOLATION TO DIRTY READ;

-- Lectura de la Tabla de Pagos Externos

LET _nom_cliente		= '';	 
LET	_nom_agente			= '';
LET	_no_documento		= '';
LET	_cod_agente		 	= '';
LET	_no_recibo_ancon	= '';		
LET	_no_cheque       	= '';	
LET	_no_remesa			= '';
LET	_no_remesa_ancon	= '';	
LET	_no_recibo_det		= '';
LET	_comis_clave_det	= 0.00;		
LET	_comis_cobro_det	= 0.00;	
LET	_comis_desc_det		= 0.00;
LET	_comis_visa_det		= 0.00;
LET	_monto_bruto_det	= 0.00;	
LET	_monto_cobrado_det	= 0.00;
LET	_monto_comis_det	= 0.00;	
LET	_neto_pagado_det	= 0.00;	
LET	_porc_comis_det		= 0.00;
LET	_fecha_recibo		= '01/01/1900';
LET	_fecha_remesa		= '01/01/1900';
LET	_periodo_desde		= '01/01/1900';
LET	_periodo_hasta		= '01/01/1900';
LET	_fecha_pago			= '01/01/1900';
LET	_renglon			= 0;	
LET	_tipo_formato		= 0;

LET  v_compania_nombre = sp_sis01(a_compania); 

SELECT cod_agente,		 
	   no_recibo_ancon,	
	   no_cheque,       	
	   no_remesa,			
	   no_remesa_ancon,	
	   fecha_recibo,	
	   fecha_remesa,	
	   periodo_desde,
	   periodo_hasta	  
  INTO _cod_agente,		 
	   _no_recibo_ancon,		
	   _no_cheque,       	
	   _no_remesa,			
	   _no_remesa_ancon,						
	   _fecha_recibo,	
	   _fecha_remesa,	
	   _periodo_desde,
	   _periodo_hasta	   	
  FROM cobpaex0
 WHERE numero = a_numero;	   	

-- Pagos Externos por cada registro (Detalle)

Select tipo_formato
  into _tipo_formato
  from cobforpaexm
 where cod_agente = _cod_agente;

if _tipo_formato = 1 then
	Select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;
elif _tipo_formato = 2 then
	Select nombre
	  into _nom_agente
	  from emicoase
	 where cod_coasegur = _cod_agente;
elif _tipo_formato = 3 then
	Select nombre
	  into _nom_agente
	  from cliclien
	 where cod_cliente  = _cod_agente;
end if



FOREACH 
 SELECT cliente,	
		no_documento,
		comis_clave,	
		comis_cobro,	
		comis_desc,	
		comis_visa,	
		monto_bruto,	
		monto_cobrado,
		monto_comis,	
		neto_pagado,	
		porc_comis,	
		fecha_pago,
		no_recibo,
		renglon
   INTO	_nom_cliente,	
		_no_documento,
		_comis_clave_det,		
		_comis_cobro_det,		
		_comis_desc_det,		
		_comis_visa_det,		
		_monto_bruto_det,		
		_monto_cobrado_det,
		_monto_comis_det,		
		_neto_pagado_det,		
		_porc_comis_det,		
		_fecha_pago,
		_no_recibo_det,
		_renglon				 		
   FROM cobpaex1
  WHERE numero = a_numero
  ORDER BY renglon

  RETURN _nom_cliente,			 
		 v_compania_nombre,
		 _nom_agente,
		 _no_documento,
		 a_numero,		
		 _cod_agente,		 
		 _no_recibo_ancon,		
		 _no_cheque,       	
		 _no_remesa,				
		 _no_remesa_ancon,		
  		 _no_recibo_det,				 			
		 _comis_clave_det,		
		 _comis_cobro_det,		
		 _comis_desc_det,	
		 _comis_visa_det,	
		 _monto_bruto_det,	
		 _monto_cobrado_det,	
		 _monto_comis_det,		
		 _neto_pagado_det,		
		 _porc_comis_det,		
		 _fecha_recibo,		
		 _fecha_remesa,		
		 _periodo_desde,		
		 _periodo_hasta,		
		 _fecha_pago,			
		 _renglon		 
		 WITH RESUME;	 		

END FOREACH

END PROCEDURE;
