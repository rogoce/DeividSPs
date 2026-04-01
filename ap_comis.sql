
DROP procedure ap_comis;
CREATE procedure "informix".ap_comis()

RETURNING char(15),
          char(10),
		  char(10),
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
		  smallint,
		  smallint,
		  smallint,
		  decimal(5,2),
		  decimal(16,2);

DEFINE  _cod_agente           char(15);
DEFINE 	_no_poliza            char(10);
DEFINE 	_no_recibo            char(10);
DEFINE 	_fecha                date;
DEFINE 	_monto                decimal(16,2);
DEFINE 	_prima                decimal(16,2);
DEFINE 	_porc_partic          decimal(5,2);
DEFINE 	_porc_comis, _porc_comis2 decimal(5,2);
DEFINE 	_comision, _comision2             decimal(16,2);
DEFINE 	_nombre               char(50);
DEFINE 	_no_documento         char(20);
DEFINE 	_monto_vida           decimal(16,2);
DEFINE 	_monto_danos          decimal(16,2);
DEFINE 	_monto_fianza         decimal(16,2);
DEFINE 	_no_licencia          char(10);
DEFINE 	_seleccionado         smallint;
DEFINE 	_fecha_desde          date;
DEFINE 	_fecha_hasta          date;
DEFINE 	_fecha_genera         date;
DEFINE 	_no_requis            char(10);
DEFINE 	_tipo_requis          char(1);
DEFINE 	_flag_web_corr        smallint;
DEFINE 	_anticipo_comis       smallint;
DEFINE 	_bono_salud           smallint;	
DEFINE  _cod_ramo, _cod_subramo char(3);

	
   SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
	SELECT	cod_agente,
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
			flag_web_corr,
			anticipo_comis,
			bono_salud	  
	 INTO   _cod_agente,
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
			_flag_web_corr,
			_anticipo_comis,
			_bono_salud	  
	 FROM	chqcomis   
	WHERE   fecha_genera >= '01/01/2016'
      AND   fecha_genera <= '19/02/2016'	
	  AND   seleccionado = 1
	  AND   no_poliza <> '00000'
--	  AND   porc_partic <> 100
--	  AND   porc_comis >= 25
	  AND   anticipo_comis = 0
	 ORDER BY 11, 3, 1
	  
	SELECT cod_ramo,
	       cod_subramo
	  INTO _cod_ramo,
	       _cod_subramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
	
      LET _porc_comis2 = 0;
      LET _comision2 = 0;

      LET _porc_comis2 = sp_pro305(_cod_agente, _cod_ramo, _cod_subramo);
	  LET _comision2 = _prima * _porc_partic / 100 * _porc_comis2 / 100;
	  
--	  IF _comision = _comision2 THEN
--		continue foreach;
--	  END IF
	
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
			_flag_web_corr,
			_anticipo_comis,
			_bono_salud,	  
			_porc_comis2,
			_comision2 WITH RESUME;
	  


   END FOREACH

END PROCEDURE