-- Este procedimiento es fiel copia del sp_che06.sql , y fue creado con la finalidad de procesar las 
-- sobre-comisiones por corredor
-- Cread por: Rub‚n Dar¡o Arn ez S nchez. el 19 junio 2006 
-- 					  

-- SIS v.2.0 - DEIVID, S.A.

 DROP PROCEDURE sp_che74;

CREATE PROCEDURE sp_che74(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_banco			    CHAR(3),
a_chequera		    CHAR(3),
a_periodo	        char(7)
-- a_cod_agente     CHAR(5)
-- ) RETURNING DEC(16,2),  -- Cantidad de Sobre comisiones a pagar
-- INTEGER,              -- Suma Total de Sobrecomisines
-- CHAR(100);    
 
) RETURNING INTEGER, CHAR(40);   				   

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
define _error			integer;
define _error_desc		char(50);
define _fecha_ult_comis_orig date;
define _cant_sobrecomis integer;
DEFINE _cod_agente		CHAR(5);
define _agente_agrupado CHAR(5);


-- SET DEBUG FILE TO "sp_che06.trc"; 
-- TRACE ON;                                                                

--BEGIN WORK;

let _cod_origen  = "001";

SELECT che_banco_ach
  INTO _banco_ach
  FROM parparam
 WHERE cod_compania = a_compania;											 

SELECT cod_origen
  INTO _origen_banc
  FROM chqbanco
 WHERE cod_banco = a_banco;

call sp_che73("001","001",a_periodo);

-- Setear las variables para realizar las pruebas

LET _cod_agente = "00398";


foreach
SELECT SUM(comision),
       count(*) 
  INTO _comision,
       _cant_sobrecomis
  FROM tmp_sobrecom
   WHERE agente_agrupado = _cod_agente	 
 -- GROUP BY cod_agente

-- Numero Interno de Requisicion
 
	LET _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');   -- activar esta linea recordar 

	SELECT nombre,
		   tipo_pago
	  INTO _nombre,
		   _tipo_pago
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
   
	LET _fecha_letra = sp_sac18(a_periodo[6,7]);
	LET _ano         = YEAR(a_periodo[1,4]);

	LET _descripcion = 'PAGO DE SOBRE-COMISIONIONES DEL MES DE ' || _fecha_letra || ' DE ' || _ano;

    LET _origen_cheque = '2';

	IF _tipo_pago = 1 THEN -- Pago por ACH

		LET _tipo_requis = "A";

		LET _banco = _banco_ach;

	    SELECT cod_chequera
		  INTO _chequera
		  FROM chqchequ
		 WHERE cod_banco = _banco_ach
		   AND cod_chequera <> "006";

		LET _autorizado     = 1; 	
   --	LET _autorizado_por	= a_usuario;

	else -- Pago por Cheque

		LET _tipo_requis    = "C";
		LET _banco          = a_banco;
		LET _chequera       = a_chequera;
		LET _autorizado     = 0; 	
		LET _autorizado_por	= NULL;

	END IF
	-- Preparar el achivo historico de las transacciones de sobrecomisiones
 
	INSERT INTO agtschi( 	   
	    	no_requis,
			cod_cia,       
			cod_sucursal,
	   	    origen_cheque,
			cod_banco,	   	  	 
	  	    cod_chequera,  	 
			monto,		   	 
			periodo,	   	 
			nombre,
		   	cod_agente
		 )
			VALUES(
	    	_no_requis,
			a_compania,	   	   
			a_sucursal,	   
	    	_origen_cheque,
			a_banco,
	    	_chequera,	   
			_comision,
			a_periodo,	   	   
			_nombre,	   
			_cod_agente   
		 );	
  
	LET _monto_banco = _comision;

	-- Encabezado del Cheque

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
  --user_added,
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
	_periodo,
	--a_usuario,
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


{
	let _renglon = 0;

	FOREACH
	 SELECT comision,
			cod_ramo
	   INTO _comision2,
			_cod_ramo
	   FROM tmp_ramo
	  WHERE cod_agente = _cod_agente

		SELECT monto
		  INTO _saldo
		  FROM agtsalra
		 WHERE cod_agente = _cod_agente
		   AND cod_ramo   = _cod_ramo;

		IF _saldo IS NULL THEN
			LET _saldo = 0;
		END IF
		
		LET _comision2 = _comision2 + _saldo;
	
		INSERT INTO chqchagt(
		no_requis,
		cod_ramo,
		monto
		)
		VALUES(
		_no_requis,
		_cod_ramo,
		_comision2
		);
			
	END FOREACH
}
	-- Blanquea los Acumulados del Saldo de Agentes
{
	INSERT INTO agtschi(
	cod_agente,
	cod_ramo,
	monto,
	fecha_al,
	fecha_desde,
	fecha_hasta
	)
	SELECT cod_agente,
	       cod_ramo,
		   monto,
		   a_fecha_hasta,
		   _fecha_ult_comis_orig,
		   a_fecha_hasta
	  FROM agtsalra
	 WHERE cod_agente = _cod_agente;

	UPDATE agtsalra
	   SET monto      = 0
	 WHERE cod_agente = _cod_agente;

	UPDATE chqcomis
	   SET no_requis   = _no_requis
	 WHERE cod_agente  = _cod_agente
	   AND fecha_desde >= _fecha_ult_comis_orig
	   AND fecha_hasta <= a_fecha_hasta
	   AND no_requis is null;
}
-- Registros Contables de Cheques de Comisiones

--	call sp_par205(_no_requis) returning _error, _error_desc;

--	if _error <> 0 then
--		return _error;
--	end if

END FOREACH 
DROP TABLE tmp_sobrecom;

-- COMMIT WORK;
-- RETURN _comision,
-- _cant_sobrecomis, 'El proceso se completo con Exito.';

RETURN 0, 'Fin del proceso de las Sobre Comisiones...';

END PROCEDURE;






 
