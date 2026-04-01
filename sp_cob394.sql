-- Procedimiento carga informix coxpaex0,cobpaex1 de deivid_cob   
-- Creado : 07/06/2017 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob394;
CREATE PROCEDURE "informix".sp_cob394(a_usuario	char(8))
returning	integer;
	
define _error_desc			char(100);
DEFINE _nom_cliente			CHAR(80);
DEFINE v_compania_nombre	CHAR(50);
DEFINE _nom_agente			CHAR(30);
DEFINE _no_documento		CHAR(20);
DEFINE _cod_agente		 	CHAR(10);
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
DEFINE _fecha_pago			DATE;
DEFINE _renglon				SMALLINT;

DEFINE _secuencia           INTEGER;
define _error_isam			integer;
define _error				integer;

DEFINE  _numero_rem_agt     CHAR(5);
DEFINE  _numero             CHAR(10);
DEFINE	_secuencia	        INTEGER;
DEFINE	_poliza	            CHAR(20);
DEFINE	_cliente	        CHAR(80);
DEFINE	_monto_cobrado	    DECIMAL(16,2);
DEFINE	_fecha_pago	        DATE;
DEFINE	_prima_neta	        DECIMAL(16,2);
DEFINE	_no_recibo_agt	    CHAR(10);
DEFINE	_porc_comis	        DECIMAL(5,2);
DEFINE	_monto_comis	    DECIMAL(16,2);
DEFINE	_comis_desc	        DECIMAL(16,2);
DEFINE	_comis_cobro	    DECIMAL(16,2);
DEFINE	_comis_visa	        DECIMAL(16,2);
DEFINE	_comis_clave	    DECIMAL(16,2);
DEFINE	_monto_remesar	    DECIMAL(16,2);
DEFINE	_procesado	        SMALLINT;
DEFINE	_fecha_procesado	DATETIME;
DEFINE	_no_remesa	        CHAR(10);
DEFINE	_renglon	        SMALLINT;
DEFINE	_no_remesa_cierre	CHAR(10);
DEFINE	_fecha_cierre	    DATE;
DEFINE _fecha				DATE;
DEFINE _fecha_rem           DATE;
DEFINE _periodo				CHAR(7);
DEFINE _tipo_formato		SMALLINT;

DEFINE	_monto_t_rem	    DECIMAL(16,2);
DEFINE	_monto_t_com	    DECIMAL(16,2);
DEFINE	_monto_t_com_cob	DECIMAL(16,2);
DEFINE	_monto_t_com_vis	DECIMAL(16,2);
DEFINE	_monto_t_com_clve	DECIMAL(16,2);
DEFINE	_monto_b_rem	    DECIMAL(16,2);
DEFINE  _no_cheque          CHAR(8);
DEFINE _no_recibo_ancon		CHAR(10);
DEFINE _periodo_ant			CHAR(7);
DEFINE _periodo_desde		DATE;
DEFINE _periodo_hasta		DATE;

SET ISOLATION TO DIRTY READ;
begin

on exception set _error,_error_isam,_error_desc
  return _error;
end exception

LET _nom_cliente		= '';	 
LET	_nom_agente			= '';
LET	_no_documento		= '';
LET	_cod_agente		 	= '';
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
LET _secuencia          = 0;

LET	_no_recibo_ancon	= '';		
LET	_monto_t_rem	    = 0.00;	
LET	_monto_t_com	    = 0.00;
LET	_monto_t_com_cob	= 0.00;	
LET	_monto_t_com_vis	= 0.00;	
LET	_monto_t_com_clve	= 0.00;
LET	_monto_b_rem	    = 0.00;	
LET _no_cheque          = '000000';

let _fecha = today;
let _periodo = sp_sis39(_fecha);

if month(_fecha) > 1 then
	if  month(_fecha) < 10 then
		let _periodo_ant = year(_fecha) || '-0' || month(_fecha)-1;
	else
		let _periodo_ant = year(_fecha) || '-' || month(_fecha)-1;
	end if
else
	let _periodo_ant = year(_fecha)-1 || '-12' ;	
end if

LET _periodo_desde = null;
LET _periodo_hasta = null;

-- Lectura de la Tabla de Pagos Externos
SELECT cod_agente,		 
	   no_recibo_ancon,	
	   no_remesa,			
	   no_remesa_ancon,	
	   fecha_recibo,	
	   fecha_remesa,	
	   periodo_desde,
	   periodo_hasta	  
  INTO _cod_agente,		 
	   _no_recibo_ancon,		
	   _no_remesa,			
	   _no_remesa_ancon,						
	   _fecha_recibo,	
	   _fecha_remesa,	
	   _periodo_desde,
	   _periodo_hasta	   	
	   
	Select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;			

FOREACH   
  SELECT Distinct no_remesa_agt, 
         fecha_procesado
    INTO _numero_rem_agt,
	     _fecha_rem
    FROM deivid_cob:duc_cob    
   WHERE procesado = 0
--GROUP BY no_remesa_agt, fecha_procesado
ORDER BY 1;	
	
	let _numero = sp_sis13('001', 'COB', '02', 'par_numero');  -- Nuevo Nnumero de cobpaex0
	let _tipo_formato = 1;
	let _periodo_desde = sp_sis36(_periodo_ant);
    let _periodo_hasta = sp_sis36(_periodo);	
	
	SELECT sum(monto_cobrado),
		sum(comis_cobro),
		sum(comis_visa),
		sum(comis_clave),
		sum(monto_remesar),
		sum(monto_comis)
	INTO _monto_t_rem,
		 _monto_t_com_cob,
		 _monto_t_com_vis,
		 _monto_t_com_clve,
		 _monto_b_rem,
		 _monto_t_com
	FROM deivid_cob:duc_cob
	WHERE no_remesa_agt = _numero_rem_agt;	
	
	  Insert Into cobpaex0 (numero,
	            fecha_adicion,
				usuario,
				cod_agente,
				no_remesa,
				fecha_remesa,
				monto_total,
				monto_comis,
				monto_comis_cobro,
				monto_comis_visa,
				monto_comis_clave,
				monto_bruto,
				no_cheque,
				periodo_desde,
				periodo_hasta,
				no_recibo_ancon,
				fecha_recibo,
				tipo_formato)
	Values     (_numero,
	_fecha,
	a_usuario,
	'00035',
	_numero_rem_agt,
	_fecha_rem,
	_monto_t_rem,
	_monto_t_com,
	_monto_t_com_cob,
	_monto_t_com_vis,
	_monto_t_com_clve,
	_monto_b_rem,
	_no_cheque,
	_periodo_desde,
	_periodo_hasta,
	_no_recibo_ancon,
	_fecha,
	_tipo_formato);				
				
				
				
	Values     (:ls_numero,:ld_fecha,:ls_usuario,:ls_agente,:ls_no_rem,:ldt_fecha_rem,:ld_monto_t_rem,&
				:ld_monto_t_com,:ld_monto_t_com_cob,:ld_monto_t_com_vis,:ld_monto_t_com_clve,&
				:ld_monto_b_rem,:ls_no_cheque,:ldt_periodo_desde,:ldt_periodo_hasta,:ls_no_recibo_ancon,:ld_fec_rem,:li_tipo_formato);

	 
	FOREACH 
	 SELECT secuencia,
			poliza,
			cliente,
			monto_cobrado,
			fecha_pago,
			prima_neta,
			no_recibo_agt,
			porc_comis,
			monto_comis,
			comis_desc,
			comis_cobro,
			comis_visa,
			comis_clave,
			monto_remesar,
			procesado,
			fecha_procesado,
			no_remesa,
			renglon,
			no_remesa_cierre,
			fecha_cierre	
	   INTO	_secuencia,
			_poliza,
			_cliente,
			_monto_cobrado,
			_fecha_pago,
			_prima_neta,
			_no_recibo_agt,
			_porc_comis,
			_monto_comis,
			_comis_desc,
			_comis_cobro,
			_comis_visa,
			_comis_clave,
			_monto_remesar,
			_procesado,
			_fecha_procesado,
			_no_remesa,
			_renglon,
			_no_remesa_cierre,
			_fecha_cierre
		FROM deivid_cob:duc_cob 
	 WHERE no_remesa_agt = _numero_rem_agt	   	     

					
					
	Insert Into cobpaex1 (numero,
			renglon,
			no_remesa,
			secuencia,
			no_documento,
			cliente,
			monto_cobrado,
			fecha_pago,
			neto_pagado,
			no_recibo,
			porc_comis,
			monto_comis,
			comis_desc,
			comis_cobro,
			comis_visa,
			comis_clave,
			monto_bruto,
			error,
			prima_suspenso)
		Values     (_numero,
		_renglon,
		_numero_rem_agt,		
		:ls_secuencia,:ls_poliza,&
					:ls_cliente,:ld_monto_cobrado,:ldt_fecha_pago,:ld_neto_pagado,&
					:ls_no_recibo,:ld_porc_comis,:ld_monto_t_com,:ld_comis_desc,:ld_monto_t_com_cob,&
					:ld_monto_t_com_vis,:ld_monto_t_com_clve,:ld_monto_b_rem, :li_error_poliza, 0);  					
					
					
		Values     (:ls_numero,:li_renglon,:ls_no_rem,:ls_secuencia,:ls_poliza,&
					:ls_cliente,:ld_monto_cobrado,:ldt_fecha_pago,:ld_neto_pagado,&
					:ls_no_recibo,:ld_porc_comis,:ld_monto_t_com,:ld_comis_desc,:ld_monto_t_com_cob,&
					:ld_monto_t_com_vis,:ld_monto_t_com_clve,:ld_monto_b_rem, :li_error_poliza, 0);  
	

	END FOREACH
END FOREACH

return 0;
END
END PROCEDURE;
