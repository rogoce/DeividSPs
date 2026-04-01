-- Este procedimiento es fiel copia del sp_che06.sql , y fue creado con la finalidad de procesar las 
-- sobre-comisiones por corredor
-- Cread por: Rub‚n Dar¡o Arn ez S nchez. el 19 junio 2006 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che74;

CREATE PROCEDURE sp_che74(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_banco			    CHAR(3),
a_chequera		    CHAR(3),
a_periodo	        CHAR(7),
a_usuario           CHAR(8)
) RETURNING INTEGER, CHAR(100);   				   

DEFINE _no_poliza       CHAR(10);
DEFINE _no_remesa       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _gen_cheque      SMALLINT;
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2);
DEFINE _porc_comis      DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _no_documento    CHAR(20);
DEFINE _cod_tipoprod    CHAR(3);   
DEFINE _tipo_prod       SMALLINT;
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);
DEFINE _tipo_ramo       SMALLINT;
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _fecha_ult_comis DATE;
DEFINE _incobrable		SMALLINT;     
DEFINE _nombre2         CHAR(50);
DEFINE _nombre_clte     CHAR(100); 
DEFINE _cod_cliente     CHAR(10);
DEFINE _tipo           	CHAR(1);
define a_fecha_desde 	DATE;
define a_fecha_hasta 	DATE;
define _nombre_agente   CHAR(50);
DEFINE _no_licencia2    CHAR(10);
DEFINE _comision 		DEC(16,2);
DEFINE _comision2 		DEC(16,2);
DEFINE _monto_banco		DEC(16,2);
DEFINE _no_requis		CHAR(10);
DEFINE _nombre      	CHAR(50);
DEFINE _periodo     	CHAR(7);
DEFINE _cod_ramo    	CHAR(3);
DEFINE _cod_subramo 	CHAR(3);
DEFINE _saldo       	DEC(16,2);
DEFINE _descripcion 	CHAR(60);
DEFINE _cuenta      	CHAR(25);
DEFINE _tipo_agente 	CHAR(1);
DEFINE _tipo_pago   	SMALLINT;
DEFINE _tipo_requis 	CHAR(1);
DEFINE _quincena    	CHAR(3);
DEFINE _fecha_letra 	CHAR(10);
define _cod_origen		char(3);
define _renglon			smallint;
DEFINE _ano         	CHAR(4);  
DEFINE _banco       	CHAR(3);
DEFINE _banco_ach   	CHAR(3);
DEFINE _chequera    	CHAR(3);
define _origen_banc		char(3);
define _autorizado  	smallint;
define _autorizado_por	char(8);
define _origen_cheque   CHAR(1);
DEFINE _alias     		CHAR(50);
define _fecha_ult_comis_orig date;
define _cant_sobrecomis integer;
DEFINE _cod_agente		CHAR(5);
DEFINE _cod_agente1		CHAR(5);
define _agente_agrupado CHAR(5);
define _cob_periodo		char(7);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

-- SET DEBUG FILE TO "sp_che06.trc"; 
-- TRACE ON;                                                                

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Validaciones de Cierre

SELECT che_banco_ach,
       cob_periodo
  INTO _banco_ach,
	   _cob_periodo
  FROM parparam
 WHERE cod_compania = a_compania;											 

if a_periodo >= _cob_periodo then
	return 1, "El Periodo " || a_periodo || " No se ha Cerrado, Por Favor Verifique";
end if

SELECT valor_parametro
  INTO _cob_periodo
  FROM parcont
 WHERE cod_compania    = a_compania
   AND aplicacion      = "CHE"
   AND version         = "02"
   AND cod_parametro   = "par_sobrecomis";

if _cob_periodo is null then

	insert into parcont
	values (a_compania, "CHE", "02", "par_sobrecomis", a_periodo);
	
else

	if a_periodo <= _cob_periodo then
	
		return 1, "Las Sobre-Comisiones para " || a_periodo || " Ya se Procesaron, Por Favor Verifique";
		
	end if	

end if 

return 0, "Actualizacion Exitosa";

call sp_che73("001", "001", a_periodo);

foreach
 SELECT SUM(comision),
        agente_agrupado
   INTO _comision,
        _cod_agente
   FROM tmp_sobrecom
  GROUP BY agente_agrupado
  
	-- Numero Interno de Requisicion
 
	LET _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');   -- activar esta linea recordar 
  
	 SELECT nombre,
		   tipo_pago
	  INTO _nombre,
		   _tipo_pago
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	LET _fecha_letra = sp_sac18(a_periodo[6,7]);
	LET _ano         = a_periodo[1,4];

	LET _descripcion = 'PAGO DE SOBRE-COMISIONIONES DEL MES DE ' || trim(_fecha_letra) || ' DE ' || _ano;

    LET _origen_cheque = '2';

	let _tipo_pago = 2;

	IF _tipo_pago = 1 THEN -- Pago por ACH

		LET _tipo_requis = "A";

		LET _banco = _banco_ach;

	    SELECT cod_chequera
		  INTO _chequera
		  FROM chqchequ
		 WHERE cod_banco = _banco_ach
		   AND cod_chequera <> "006";

		LET _autorizado     = 1; 	
		let _autorizado_por	= a_usuario;

	else -- Pago por Cheque

		LET _tipo_requis    = "C";
		LET _banco          = a_banco;
		LET _chequera       = a_chequera;
		LET _autorizado     = 0; 	
		LET _autorizado_por	= NULL;

	END IF

 	LET _monto_banco = _comision;

	-- Encabezado del Cheque
--   {
	INSERT INTO chqchmae(
	no_requis,
	cod_cliente,
	cod_agente,
	cod_banco,
	cod_chequera,
	cuenta,
	cod_compania,
	cod_sucursal,
	origen_cheque,
	no_cheque,
	fecha_impresion,
	fecha_captura,
	autorizado,
	pagado,
	a_nombre_de,
	cobrado,
	fecha_cobrado,
	anulado,
	fecha_anulado,
	anulado_por,
	monto,
	periodo,
	user_added,
	autorizado_por,
	tipo_requis
	)
	VALUES(
	_no_requis,
	NULL,
	_cod_agente,
	_banco,
	_chequera,
	NULL,
	a_compania,
	a_sucursal,
	_origen_cheque,
	0,
	CURRENT,
	CURRENT,
	_autorizado,
	0,
	_nombre,
	0,
	NULL,
	0,
	NULL,
	NULL,
	_comision,
	a_periodo,
	a_usuario,
	_autorizado_por,
	_tipo_requis
	);	 

	-- Descripcion del Cheque

	INSERT INTO chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	VALUES(
	_no_requis,
	1,
	_descripcion
	);

  -- Hiostorico de Sobre-Comisiones

  foreach 
   select
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
		no_licencia,    
		nombre_clte,
		nombre_agente,
		agente_agrupado,
		cod_ramo,
		cod_subramo,
		cod_origen
   into _cod_agente,    
      	_no_poliza,	 
		_no_recibo,	 
		_fecha,		 
		_monto,      
		_prima, 	 
		_porc_partic,
		_sobrecomision,	
		_comision,	 
		_nombre2,	 	
		_no_documento,
		_no_licencia2,    
		_nombre_clte,
		_nombre_agente,
		_agente_agrupado,
		_cod_ramo,
		_cod_subramo,
		_cod_origen
   from tmp_sobrecom   
  WHERE agente_agrupado = _cod_agente	 

	insert into agtscdhi(
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
			no_licencia,    
			nombre_clte,
			nombre_agente,
			agente_agrupado,
			cod_ramo,
			cod_subramo,
			no_requis,
			cod_origen
			)    
	 VALUES(_cod_agente, 
			_no_poliza,	 
			_no_recibo,	 
			_fecha,		 
			_monto,      
			_prima, 	 
			_porc_partic,
			_sobrecomision,	
			_comision,	 
			_nombre2,	 	
			_no_documento,
			_no_licencia2,    
			_nombre_clte,
			_nombre_agente,
			_agente_agrupado,
			_cod_ramo,
			_cod_subramo,
			_no_requis,
			_cod_origen
			);    

	end foreach 
  
--	}

-- Registros Contables de Cheques de Comisiones

	call sp_par249(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if

END FOREACH 

end

DROP TABLE tmp_sobrecom;

RETURN 0, "Actualizacion Exitosa ...";

END PROCEDURE;






 
