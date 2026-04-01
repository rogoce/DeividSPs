-- Procedimiento Para Borrar transacciones de auto sin # de incidente
-- 
-- Creado    : 17/12/2004 - Autor: Amado Perez
-- Modificado: 17/12/2004 - Autor: Amado Perez
-- mODIFICADO: 10/08/2005 - Autor: Amado Perez -- Ahora borra la transaccion, no actualizada, que no se usara
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE dup_chqcomis;

CREATE PROCEDURE "informix".dup_chqcomis()
RETURNING CHAR(15),
          CHAR(10),
          CHAR(10),
		  date,
		  decimal(16,2),
		  decimal(16,2),
		  decimal(5,2),
		  decimal(5,2),
		  decimal(16,2),
		  char(50),
		  char(20),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  char(10),
		  smallint,
		  date,
		  date,
		  date,
		  char(10),
		  char(1),
          INT;

DEFINE _cod_agente    CHAR(15); 
DEFINE _no_poliza     CHAR(10); 
DEFINE _no_recibo     CHAR(10); 
DEFINE _fecha         date;
DEFINE _monto         decimal(16,2);
DEFINE _prima         decimal(16,2);
DEFINE _porc_partic   decimal(5,2);
DEFINE _porc_comis    decimal(5,2);
DEFINE _comision      decimal(16,2);
DEFINE _nombre        char(50);
DEFINE _no_documento  char(20);
DEFINE _monto_vida    decimal(16,2);
DEFINE _monto_danos   decimal(16,2);
DEFINE _monto_fianza  decimal(16,2);
DEFINE _no_licencia   char(10);
DEFINE _seleccionado  smallint;
DEFINE _fecha_desde   date;
DEFINE _fecha_hasta   date;
DEFINE _fecha_genera  date;
DEFINE _no_requis     char(10);
DEFINE _tipo_requis   char(1);
DEFINE _cant     	  INT; 

DEFINE _error, _actualizado	    SMALLINT; 

--SET DEBUG FILE TO "sp_sis27.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_rectr1(
			cod_agente     CHAR(15),
			no_poliza      CHAR(10),
			no_recibo      CHAR(10),
			fecha          date,
			monto          decimal(16,2),
			prima          decimal(16,2),
			porc_partic    decimal(5,2),
			porc_comis     decimal(5,2),
			comision       decimal(16,2),
			nombre         char(50),
			no_documento   char(20),
			monto_vida     decimal(16,2),
			monto_danos    decimal(16,2),
			monto_fianza   decimal(16,2),
			no_licencia    char(10),
			seleccionado   smallint,
			fecha_desde    date,
			fecha_hasta    date,
			fecha_genera   date,
			no_requis      char(10),
			tipo_requis    char(1),
			cant           INTEGER,   
			PRIMARY KEY (cod_agente,no_poliza,no_recibo,fecha)
			) WITH NO LOG;


FOREACH
	SELECT cod_agente, 
	       no_poliza, 
	       no_recibo,
		   fecha,       
		   monto,       
		   prima,       
		   porc_partic, 
		   porc_comis,  
		   comision,    
		   nombre,      
		   no_documento,
		   monto_vida,  
		   monto_danos, 
		   monto_fianza,
		   no_licencia, 
		   seleccionado,
		   fecha_desde, 
		   fecha_hasta, 
		   fecha_genera,
		   no_requis,   
		   tipo_requis 
	  INTO _cod_agente, 
	       _no_poliza, 
	       _no_recibo,
	       _fecha,       
	       _monto,       
	       _prima,       
	       _porc_partic, 
	       _porc_comis,  
	       _comision,    
	       _nombre,      
	       _no_documento,
	       _monto_vida,  
	       _monto_danos, 
	       _monto_fianza,
	       _no_licencia,
	       _seleccionado,
	       _fecha_desde, 
	       _fecha_hasta, 
	       _fecha_genera,
	       _no_requis,  
	       _tipo_requis 
	  FROM chqcomis


	BEGIN

	    ON EXCEPTION IN(-268, -239)	
			UPDATE tmp_rectr1
			   SET cant = cant + 1
			 WHERE cod_agente = _cod_agente
			   AND no_poliza  = _no_poliza
			   AND no_recibo  = _no_recibo;

		END EXCEPTION

	    INSERT INTO tmp_rectr1(
		cod_agente,
		no_poliza,
		no_recibo, 
		fecha,       
		monto,       
		prima,       
		porc_partic, 
		porc_comis,  
		comision,    
		nombre,      
		no_documento,
		monto_vida,  
		monto_danos, 
		monto_fianza,
		no_licencia, 
		seleccionado,
		fecha_desde, 
		fecha_hasta, 
		fecha_genera,
		no_requis,   
		tipo_requis, 
		cant
		)
		VALUES
		(
		_cod_agente,
		_no_poliza,
		_no_recibo,
		_fecha,       
		_monto,       
		_prima,       
		_porc_partic, 
		_porc_comis,  
		_comision,    
		_nombre,      
		_no_documento,
		_monto_vida,  
		_monto_danos, 
		_monto_fianza,
		_no_licencia,
		_seleccionado,
		_fecha_desde, 
		_fecha_hasta, 
		_fecha_genera,
		_no_requis,  
		_tipo_requis, 
		1
		);
	END

END FOREACH

FOREACH	WITH HOLD
	SELECT cod_agente,
		   no_poliza,
		   no_recibo, 
		   fecha,       
		   monto,       
		   prima,       
		   porc_partic, 
		   porc_comis,  
		   comision,    
		   nombre,      
		   no_documento,
		   monto_vida,  
		   monto_danos, 
		   monto_fianza,
		   no_licencia, 
		   seleccionado,
		   fecha_desde, 
		   fecha_hasta, 
		   fecha_genera,
		   no_requis,   
		   tipo_requis, 
	       cant
	  INTO _cod_agente,
		   _no_poliza,
		   _no_recibo,
		   _fecha,       
		   _monto,       
		   _prima,       
		   _porc_partic, 
		   _porc_comis,  
		   _comision,    
		   _nombre,      
		   _no_documento,
		   _monto_vida,  
		   _monto_danos, 
		   _monto_fianza,
		   _no_licencia,
		   _seleccionado,
		   _fecha_desde, 
		   _fecha_hasta, 
		   _fecha_genera,
		   _no_requis,  
		   _tipo_requis, 
	       _cant
	  FROM tmp_rectr1
	 WHERE cant > 1

    RETURN _cod_agente,
		   _no_poliza,
		   _no_recibo,
		   _fecha,       
		   _monto,       
		   _prima,       
		   _porc_partic, 
		   _porc_comis,  
		   _comision,    
		   _nombre,      
		   _no_documento,
		   _monto_vida,  
		   _monto_danos, 
		   _monto_fianza,
		   _no_licencia,
		   _seleccionado,
		   _fecha_desde, 
		   _fecha_hasta, 
		   _fecha_genera,
		   _no_requis,  
		   _tipo_requis, 
	 	   _cant
	with resume;
END FOREACH
DROP TABLE tmp_rectr1;

END PROCEDURE;
