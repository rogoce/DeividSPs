-- Preliminar de primas devolucion por poliza cancelada

-- Creado    : 26/01/2015 - Autor: Armando Moreno
-- Modificado: 26/01/2015 - Autor: Armando Moreno



--DROP PROCEDURE sp_cob349;

CREATE PROCEDURE "informix".sp_cob349()
  RETURNING CHAR(10),
			CHAR(20),
			CHAR(10),
			DECIMAL(16,2),
			VARCHAR(50),
			DATE,
			CHAR(10),
			CHAR(2),
			CHAR(10),
			SMALLINT,
			VARCHAR(100),
			VARCHAR(50),
			CHAR(2),	 
			DATE;	 


define	_no_devleg      char(10);
define	_no_documento	char(20);
define	_no_poliza      char(10);
define	_monto			decimal(16,2);
define	_email			varchar(50);
define	_fecha_pago		date;
define	_no_recibo		char(10);
define	_ck_devuelto    smallint;
define	_no_requis		char(10);
define	_envio_email	smallint;
define	_n_cliente		varchar(100);
define	_n_corredor     varchar(50);
define	_anulado		smallint;
define	_fecha_anulado	date;
DEFINE _ck_dev_char     CHAR(2);
DEFINE _anulado_char    CHAR(2);


FOREACH
 SELECT  cobdevleg.no_devleg,   
         cobdevleg.no_documento,   
         cobdevleg.no_poliza,   
         cobdevleg.monto,   
         cobdevleg.e_mail,   
         cobdevleg.fecha_pago,   
         cobdevleg.no_recibo,   
         cobdevleg.ck_devuelto,   
         cobdevleg.no_requis,   
         cobdevleg.envio_email,   
         cliclien.nombre,   
         agtagent.nombre,   
         chqchmae.anulado,   
         chqchmae.fecha_anulado
   INTO _no_devleg,
		_no_documento,
		_no_poliza,
		_monto,
		_email,
		_fecha_pago,
		_no_recibo,
		_ck_devuelto,
		_no_requis,
		_envio_email,
		_n_cliente,
		_n_corredor,
		_anulado,
		_fecha_anulado
    FROM cobdevleg,   
         cliclien,   
         agtagent,   
         emipoagt,   
         chqchmae  
   WHERE ( cobdevleg.cod_asegurado = cliclien.cod_cliente ) and  
         ( cobdevleg.no_poliza = emipoagt.no_poliza ) and  
         ( emipoagt.cod_agente = agtagent.cod_agente ) and  
         ( cobdevleg.no_requis = chqchmae.no_requis )

	if _ck_devuelto = 1 then
		let _ck_dev_char = 'SI';
	else
		let _ck_dev_char = 'NO';
	end if
	if _anulado = 1 then
		let _anulado_char = 'SI';
	else
		let _anulado_char = 'NO';
	end if	

 	RETURN _no_devleg,
		   _no_documento,
		   _no_poliza,
		   _monto,
		   _email,
		   _fecha_pago,
		   _no_recibo,
			_ck_dev_char,
			_no_requis,
			_envio_email,
			_n_cliente,
			_n_corredor,
			_anulado_char,
			_fecha_anulado
		   WITH RESUME;

END FOREACH    
END PROCEDURE;
