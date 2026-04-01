-- Procedimiento que Genera el Cheque para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 

-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 19/01/2006 - Autor: Amado Perez 
--             cuando se genere la comision, en el detalle debe aparecer 
--             desde la ultima fecha de comision si esta es menor que la
--             fecha desde se este generando la comision 

-- Modificado: 17/03/2006 - Autor: Demetrio Hurtado Almanza
--             Se separa la creacion de los registros contables y se incluyo en una rutina aparte que es la
--             sp_par205, que es la crea los registros contables de cheques de comisiones					  

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che06;

CREATE PROCEDURE sp_che06(
a_compania       CHAR(3),
a_sucursal       CHAR(3),
a_cod_agente     CHAR(5),
a_generar_cheque SMALLINT,
a_usuario        CHAR(8),
a_banco			 CHAR(3),
a_chequera		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta	 DATE
) RETURNING INTEGER; 

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

-- SET DEBUG FILE TO "sp_che06.trc"; 
-- TRACE ON;                                                                

--BEGIN WORK;

let _cod_origen  = "001";

SELECT SUM(comision)
  INTO _comision
  FROM tmp_ramo
 WHERE cod_agente = a_cod_agente;

SELECT che_banco_ach
  INTO _banco_ach
  FROM parparam
 WHERE cod_compania = a_compania;											 

select cod_origen
  into _origen_banc
  from chqbanco
 where cod_banco = a_banco;

SELECT fecha_ult_comis
  INTO _fecha_ult_comis_orig
  FROM agtagent
 WHERE cod_agente = a_cod_agente;

IF _fecha_ult_comis_orig IS NOT NULL THEN
	LET _fecha_ult_comis_orig = _fecha_ult_comis_orig +	1 UNITS DAY;
ELSE
	LET _fecha_ult_comis_orig = a_fecha_desde;
END IF

IF a_generar_cheque = 1 THEN

	UPDATE agtagent
	   SET fecha_ult_comis = a_fecha_hasta
	 WHERE cod_agente      = a_cod_agente;

	-- Numero Interno de Requisicion

	LET _no_requis = sp_sis13(a_compania, 'CHE', '02', 'par_cheque');

	SELECT nombre,
		   saldo,
		   tipo_agente,
		   tipo_pago,
		   alias	
	  INTO _nombre,
		   _saldo,
		   _tipo_agente,
		   _tipo_pago,
		   _alias
	  FROM agtagent
	 WHERE cod_agente = a_cod_agente;

	IF _tipo_agente = "E" THEN -- Agentes Especiales

	    IF DAY(a_fecha_desde) < 15 THEN
			LET _quincena = '1ra';
		ELSE
			LET _quincena = '2da';
		END IF

		LET _fecha_letra = sp_sac18(MONTH(a_fecha_desde));

		LET _ano = YEAR(a_fecha_desde);

		LET _descripcion = 'PAGO DE HONORARIOS DE LA ' || _quincena || ' QUINCENA DEL MES DE ' || _fecha_letra || ' DE ' || _ano;

        LET _origen_cheque = '7';

		IF TRIM(_nombre[1,7]) = "DIRECTO" THEN
			LET _nombre = _alias;
		END IF

	else -- Agentes Normales

		IF _fecha_ult_comis_orig < a_fecha_desde THEN
			LET _descripcion = 'PAGO DE COMISION DEL ' || _fecha_ult_comis_orig || ' AL ' || a_fecha_hasta;
		ELSE
			LET _descripcion = 'PAGO DE COMISION DEL ' || a_fecha_desde || ' AL ' || a_fecha_hasta;
		END IF

        LET _origen_cheque = '2';

	END IF

    IF _tipo_pago = 1 THEN -- Pago por ACH

		LET _tipo_requis = "A";

		LET _banco = _banco_ach;

        SELECT cod_chequera
		  INTO _chequera
		  FROM chqchequ
		 WHERE cod_banco = _banco_ach
		   AND cod_chequera <> "006";

		LET _autorizado     = 1; 	
		LET _autorizado_por	= a_usuario;

	else -- Pago por Cheque

		LET _tipo_requis    = "C";
		LET _banco          = a_banco;
		LET _chequera       = a_chequera;
		LET _autorizado     = 0; 	
		LET _autorizado_por	= NULL;

	END IF

	IF MONTH(CURRENT) < 10 THEN
		LET _periodo = YEAR(CURRENT) || '-0' || MONTH(CURRENT);
	ELSE
		LET _periodo = YEAR(CURRENT) || '-' || MONTH(CURRENT);
	END IF

	LET _comision    = _comision + _saldo;
	LET _monto_banco = _comision;
	-- + _saldo;

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
	user_added,
	autorizado_por,
	tipo_requis
	)
	VALUES(
	_no_requis,
	NULL,
	a_cod_agente,
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

	let _renglon = 0;

	FOREACH
	 SELECT comision,
			cod_ramo
	   INTO _comision2,
			_cod_ramo
	   FROM tmp_ramo
	  WHERE cod_agente = a_cod_agente

		SELECT monto
		  INTO _saldo
		  FROM agtsalra
		 WHERE cod_agente = a_cod_agente
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

	-- Blanquea los Acumulados del Saldo de Agentes

	UPDATE agtagent
	   SET saldo      = 0
	 WHERE cod_agente = a_cod_agente;

	INSERT INTO agtsalhi(
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
	 WHERE cod_agente = a_cod_agente;

	UPDATE agtsalra
	   SET monto      = 0
	 WHERE cod_agente = a_cod_agente;

	UPDATE chqcomis
	   SET no_requis   = _no_requis
	 WHERE cod_agente  = a_cod_agente
	   AND fecha_desde >= _fecha_ult_comis_orig
	   AND fecha_hasta <= a_fecha_hasta
	   AND no_requis is null;

	-- Registros Contables de Cheques de Comisiones

	call sp_par205(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if


ELSE

 	UPDATE agtagent                                   
 	   SET saldo      = saldo + _comision             
 	 WHERE cod_agente = a_cod_agente;                 
                                                      
 	FOREACH                                           
 	 SELECT comision,                                 
 			cod_ramo                                  
 	   INTO _comision,                                
 			_cod_ramo                                 
 	   FROM tmp_ramo                                  
 	  WHERE cod_agente = a_cod_agente                 
                                                      
 		BEGIN                                         
                                                      
 			ON EXCEPTION IN(-239,-268)                     
 			                                          
 				UPDATE agtsalra                       
 				   SET monto      = monto + _comision 
 				 WHERE cod_agente = a_cod_agente      
 				   AND cod_ramo   = _cod_ramo;        
                                                      
                                                      
 			END EXCEPTION                             
                                                      
 			INSERT INTO agtsalra(                     
 			cod_agente,                               
 			cod_ramo,                                 
 			monto                                     
 			)                                         
 			VALUES(                                   
 			a_cod_agente,                             
 			_cod_ramo,                                
 			_comision                                 
 			);                                        
 			                                          
 		END                                           
                                                      
 	END FOREACH                                       
 
END IF

--COMMIT WORK;

RETURN 0;

END PROCEDURE;