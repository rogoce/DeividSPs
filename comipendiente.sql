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
-- 					  
-- Modificado: 25/02/2008 - Autor: Amado Perez
--             Se modifica la 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE comipend;

CREATE PROCEDURE comipend() RETURNING INTEGER; 

DEFINE _comision 		DEC(16,2);
DEFINE _comision2 		DEC(16,2);
DEFINE _monto_banco		DEC(16,2);
DEFINE _no_requis, _no_requis_c		CHAR(10);
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
DEFINE a_compania      	CHAR(3);
DEFINE a_sucursal      	CHAR(3);
DEFINE a_generar_cheque	SMALLINT;
DEFINE a_usuario       	CHAR(8);
define a_banco         	CHAR(3);
define a_chequera      	CHAR(3);
define a_fecha_desde   	DATE;
define a_fecha_hasta   	DATE;
DEFINE a_cod_agente		CHAR(5);
DEFINE _no_poliza       CHAR(10);


define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _fecha_ult_comis_orig date;
define _fecha_ult_comis      date;

-- SET DEBUG FILE TO "comipend.trc"; 
-- TRACE ON;                                                                

--BEGIN WORK;

let _cod_origen  = "001";
let a_compania       = "001";
let a_sucursal       = "001";
let a_generar_cheque = 1;
let a_usuario        = "ZULEYKA";
let a_banco          = "001";
let a_chequera       = "001";
let a_fecha_desde    = "26/02/2009";
let a_fecha_hasta    = "04/03/2009";

begin work;
begin
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error;
end exception

FOREACH	WITH HOLD

SELECT cod_agente, SUM(comision)
  INTO a_cod_agente, _comision
  FROM chqcomipend
group by cod_agente


SELECT che_banco_ach
  INTO _banco_ach
  FROM parparam
 WHERE cod_compania = a_compania;											 

select cod_origen
  into _origen_banc
  from chqbanco
 where cod_banco = a_banco;

--SELECT fecha_ult_comis
--  INTO _fecha_ult_comis_orig
--  FROM agtagent
-- WHERE cod_agente = a_cod_agente;

let _fecha_ult_comis_orig = "26/02/2009";
LET _fecha_ult_comis = _fecha_ult_comis_orig;

IF a_generar_cheque = 1 THEN


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

		LET _descripcion = 'PAGO DE HONORARIOS DE LA SEMANA DEL ' || a_fecha_desde || ' AL ' || a_fecha_hasta;

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

	--LET _comision    = _comision + _saldo;
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
	"05/03/2009",
	"05/03/2009",
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
			no_poliza
	   INTO _comision2,
			_no_poliza
	   FROM chqcomipend
	  WHERE cod_agente = a_cod_agente

    IF _no_poliza = "00000" THEN
	    LET _cod_ramo = "002";
	ELSE
		SELECT cod_ramo
		  INTO _cod_ramo
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
	END IF

{		SELECT monto
		  INTO _saldo
		  FROM agtsalra
		 WHERE cod_agente = a_cod_agente
		   AND cod_ramo   = _cod_ramo;

		IF _saldo IS NULL THEN
			LET _saldo = 0;
		END IF
		
		LET _comision2 = _comision2 + _saldo;
 }	

 		BEGIN                                         
                                                      
 			ON EXCEPTION IN(-239,-268)                     
 			                                          
 				UPDATE chqchagt                       
 				   SET monto      = _comision2 
 				 WHERE no_requis  = _no_requis      
 				   AND cod_ramo   = _cod_ramo;        
                                                      
                                                      
 			END EXCEPTION                             

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

		end
			
	END FOREACH

	-- Blanquea los Acumulados del Saldo de Agentes

	IF _fecha_ult_comis IS NOT NULL THEN
		UPDATE chqcomis
		   SET no_requis   = _no_requis
		 WHERE cod_agente  = a_cod_agente
		   AND fecha_desde >= _fecha_ult_comis_orig
 		   AND fecha_hasta <= a_fecha_hasta
		   AND no_requis is null;
   	ELSE
   		UPDATE chqcomis
   		   SET no_requis   = _no_requis
   		 WHERE cod_agente  = a_cod_agente
   		   AND no_requis is null;
	END IF

  --	   AND fecha_desde >= _fecha_ult_comis_orig;

	-- Actualizando chqcomis de cheques anulados dentro del periodo de pago

    FOREACH
		 select no_requis
		   into _no_requis_c
		   from chqchmae
		  where cod_agente = a_cod_agente
		    and origen_cheque in (2, 7)
			and anulado = 1
			and no_requis is not null
			and no_requis <> _no_requis
			and fecha_anulado <= a_fecha_hasta
			and fecha_anulado >= "01/03/2007"

		 If _no_requis_c is not null And Trim(_no_requis_c) <> "" Then
			 update chqcomis
			    set no_requis = _no_requis
			  where no_requis = _no_requis_c;
		 End If
    END FOREACH

	-- Registros Contables de Cheques de Comisiones

	call sp_par205(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if


ELSE

 	UPDATE agtagent                                   
 	   SET saldo      = _comision             
 	 WHERE cod_agente = a_cod_agente;                 
-- 	   SET saldo      = saldo + _comision             
                                                      
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
 				   SET monto      = _comision 
 				 WHERE cod_agente = a_cod_agente      
 				   AND cod_ramo   = _cod_ramo;        
 --				   SET monto      = monto + _comision 
                                                      
                                                      
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

END FOREACH
--COMMIT WORK;
end
commit work;

RETURN 0;

END PROCEDURE;