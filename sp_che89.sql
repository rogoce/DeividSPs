-- Impresion del Cheque	*** nuevo formato de cheques contables ***
--
-- Creado    : 09/07/2008 - Igual al sp_che01 - Autor: Lic. Amado Perez
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 17/01/2007 - Autor: Demetrio Hurtadi Almanza
               -- Se hizo una rutina aparte para los registros contables.
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_che89;

CREATE PROCEDURE "informix".sp_che89(a_compania CHAR(3), a_agencia CHAR(3), a_usuario CHAR(8), a_cod_banco CHAR(3), a_cod_chequera CHAR(3), a_no_requis CHAR(10)) 
RETURNING   DATE,
			CHAR(100),
		    DECIMAL(16,2), 
			CHAR(250),
		    DATE,
			INTEGER,
			CHAR(3),
			CHAR(3),
			CHAR(8),
			CHAR(3),
			CHAR(3),
			CHAR(10),
			CHAR(8),
			CHAR(8),
			DATE,
			DATE,
			DATE,
			CHAR(35),
			CHAR(35),
			CHAR(50);

DEFINE v_a_nombre_de  CHAR(50);     
DEFINE v_monto        DECIMAL(16,2);
DEFINE v_monto_letras CHAR(250);    
DEFINE _no_requis     CHAR(10);
DEFINE _no_cheque	  INTEGER;
DEFINE _origen_cheque CHAR(1);
DEFINE _transaccion	  CHAR(10);
DEFINE _cod_origen    CHAR(3);
DEFINE _enlace_cta    CHAR(20);
DEFINE _renglon		  SMALLINT;
DEFINE _cuenta		  CHAR(25);
define _periodo		  char(7);
define _mes_char      CHAR(2);
define _ano_char	  CHAR(4);
define _user_added    CHAR(8);
define _aut_workflow_user    CHAR(8);
define _fecha_captura date;
define _aut_workflow_fecha date;
define v_telefono     char(35);
define v_telefono3    char(35);
define v_corredor     char(50);
DEFINE _cod_tipopago  char(3);
define _cod_cliente   char(10);
define _cod_proveedor char(10);
define _tel_pag1	  char(10);
define _tel_pag2	  char(10);
define _cel_pag		  char(10);
define _no_reclamo	  char(10);	
define _cod_agente	  char(5);
define v_telefono1	  char(10);
define v_telefono2	  char(10);
define _no_poliza     char(10);
define _cta_chequera  smallint;
define _monto_disponible DECIMAL(16,2);
define _monto_asignado   DECIMAL(16,2);
define _ctrl_flujo     smallint;

define _error		    integer;
define _error_desc	    char(50);

--SET DEBUG FILE TO "sp_che01.trc";
--TRACE ON;

-- Lectura del Numero de Cheque
set isolation to dirty read;

IF  MONTH(today) < 10 THEN
	LET _mes_char = '0'|| MONTH(today);
ELSE
	LET _mes_char = MONTH(today);
END IF

LET _ano_char = YEAR(today);
LET _periodo  = _ano_char || "-" || _mes_char;

let v_corredor   = null;
let v_telefono   = null;
let v_telefono3  = null;
let _ctrl_flujo   = 0;

SELECT cont_no_cheque,
	   monto_disponible,
	   monto_asignado,
	   control_flujo
  INTO _no_cheque,
	   _monto_disponible,
	   _monto_asignado,
	   _ctrl_flujo
  FROM chqchequ
 WHERE cod_banco    = a_cod_banco
   AND cod_chequera = a_cod_chequera;

IF _no_cheque IS NULL THEN
	LET _no_cheque = 0;
END IF

-- Lectura del Origen del Banco para el Enlace de Cuentas
  	
SELECT cod_origen,
	   cta_chequera
  INTO _cod_origen,
	   _cta_chequera
  FROM chqbanco
 WHERE cod_banco = a_cod_banco;

-- Inicio de la Impresion de Cheques

 SELECT a_nombre_de,
		monto,
		no_requis,
		origen_cheque,
		user_added,
		aut_workflow_user,
		fecha_captura,
		aut_workflow_fecha
   INTO v_a_nombre_de,
		v_monto,
		_no_requis,
		_origen_cheque,
		_user_added,
		_aut_workflow_user,
		_fecha_captura,
		_aut_workflow_fecha
   FROM chqchmae
  WHERE cod_compania   = a_compania
	AND autorizado     = 1
	AND pagado         = 0
	AND autorizado_por = a_usuario
	AND cod_banco      = a_cod_banco
	AND cod_chequera   = a_cod_chequera
	AND tipo_requis    = "C"
	AND no_requis      = a_no_requis;

	-- Actualizacion del Maestro de Cheques

	UPDATE chqchmae
	   SET fecha_impresion = TODAY,
		   pagado          = 1,	
		   no_cheque       = _no_cheque,
		   periodo         = _periodo
	 WHERE no_requis       = _no_requis;

	let v_telefono  = null;
	let	v_telefono3 = null;
	let	v_corredor	= null;

	-- Registros Contables

	call sp_par276(a_no_requis, _origen_cheque) returning _error, _error_desc;

	-- Actualizacion de los Cheques de Devolucion de Primas
	
	IF _origen_cheque = '6' THEN

		BEGIN

		DEFINE _no_poliza		CHAR(10);
		DEFINE _prima_neta      DEC(16,2);
		DEFINE _doc_poliza		CHAR(20);

		FOREACH
		 SELECT	no_poliza,
				monto,
				no_documento
		   INTO	_no_poliza,
				_prima_neta,
				_doc_poliza
		   FROM	chqchpol
		  WHERE	no_requis = _no_requis

			UPDATE emipomae
			   SET saldo     = saldo + _prima_neta
			 WHERE no_poliza = _no_poliza;

		END FOREACH

		END

	END IF

	-- Actualizacion para los Cheques de Reclamos

	IF _origen_cheque = '3' THEN

		BEGIN

		DEFINE _fecha_transac DATE;
		DEFINE _fecha_param   DATE;
		DEFINE _monto_transac DEC(16,2);
		DEFINE _debito        DEC(16,2);
		DEFINE _credito       DEC(16,2);

		let _monto_transac = 0.00;

		SELECT sum(monto)
		  INTO _monto_transac
		  FROM chqchrec
		 WHERE no_requis = _no_requis;

		if _monto_transac <> v_monto then

			let v_monto = _monto_transac;

			update chqchmae
			   set monto     = v_monto
			 where no_requis = _no_requis;

		end if

		END 

		--******** tel de asegurado, tel y  nombre de corredor, tel de provvedor.

		FOREACH
		 SELECT transaccion
		   INTO _transaccion
		   FROM chqchrec
		  WHERE no_requis = _no_requis

		 EXIT FOREACH;

		END FOREACH

		FOREACH
		 SELECT cod_tipopago,
		        cod_cliente,
				cod_proveedor,
				no_reclamo
		   INTO _cod_tipopago,
				_cod_cliente,
				_cod_proveedor,
				_no_reclamo
		   FROM rectrmae
		  WHERE transaccion = _transaccion
		    AND actualizado = 1

		 EXIT FOREACH;

		END FOREACH

		if _cod_tipopago = '001' then	--pago proveedor

			  SELECT telefono1,
					 telefono2,
					 celular
			    INTO _tel_pag1,
				     _tel_pag2,
				     _cel_pag
			    FROM cliclien
			   WHERE cod_cliente = _cod_cliente;

			  if _tel_pag1 is null and _tel_pag2 is null and _cel_pag is null then
				  let v_telefono = "";
			  elif _tel_pag2 is null and _cel_pag is null then
				  let v_telefono = _tel_pag1;
			  elif _tel_pag2 is null and _tel_pag1 is null then
				  let v_telefono = _cel_pag;
			  elif _tel_pag1 is null and _cel_pag is null then
				  let v_telefono = _tel_pag2;
			  elif _tel_pag1 is null then
				  let v_telefono = _tel_pag2 || " / " || _cel_pag;
			  elif _tel_pag2 is null then
				  let v_telefono = _tel_pag1 || " / " || _cel_pag;
			  elif _cel_pag is null then
				  let v_telefono =_tel_pag1 || " / " || _tel_pag2;
			  else
				  let v_telefono  = _tel_pag1 || " / " || _tel_pag2 || " / " || _cel_pag;
			  end if

			  let v_telefono  = trim(v_telefono);
			  let v_corredor  = "";
			  let v_telefono3 = "";

		end if

		if _cod_tipopago = '003'then	--pago asegurado

			if _cod_cliente is not null then

				SELECT telefono1,
					   telefono2,
					   celular
			   	  INTO _tel_pag1,
				       _tel_pag2,
				       _cel_pag
			   	  FROM cliclien
			  	 WHERE cod_cliente = _cod_cliente;

				  if _tel_pag1 is null and _tel_pag2 is null and _cel_pag is null then
					  let v_telefono = "";
				  elif _tel_pag2 is null and _cel_pag is null then
					  let v_telefono = _tel_pag1;
				  elif _tel_pag2 is null and _tel_pag1 is null then
					  let v_telefono = _cel_pag;
				  elif _tel_pag1 is null and _cel_pag is null then
					  let v_telefono = _tel_pag2;
				  elif _tel_pag1 is null then
					  let v_telefono = _tel_pag2 || " / " || _cel_pag;
				  elif _tel_pag2 is null then
					  let v_telefono = _tel_pag1 || " / " || _cel_pag;
				  elif _cel_pag is null then
					  let v_telefono =_tel_pag1 || " / " || _tel_pag2;
				  else
					  let v_telefono  = _tel_pag1 || " / " || _tel_pag2 || " / " || _cel_pag;
				  end if

				  let v_telefono  = trim(v_telefono);
			end if

			SELECT no_poliza
			  INTO _no_poliza
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo
 			   and actualizado = 1;

			FOREACH
			 SELECT cod_agente
			   INTO _cod_agente
			   FROM emipoagt
			  WHERE no_poliza = _no_poliza

			 EXIT FOREACH;

			END FOREACH

			SELECT nombre,
				   telefono1,
				   telefono2	
			  INTO v_corredor,
				   v_telefono1,
				   v_telefono2
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			  if v_telefono1 is null and v_telefono2 is null then
				  let v_telefono3 = "";
			  elif v_telefono2 is null then
				  let v_telefono3 = v_telefono1;
			  elif v_telefono1 is null then
				  let v_telefono3 = v_telefono2;
			  else
				  let v_telefono3  = v_telefono1 || " / " || v_telefono1;
			  end if

		  let v_telefono3  = trim(v_telefono3);

		end if

	END IF

	{if _ctrl_flujo = 1 then								--control de flujo
		update chqchequ
		   set monto_disponible = monto_disponible + v_monto
		 where cod_banco 	= a_cod_banco
		   and cod_chequera = a_cod_chequera;
	end if}

	-- Datos del Cheque
	if v_corredor is null then
		let v_corredor = "";
	end if
	if v_telefono is null then
		let v_telefono = "";
	end if
	if v_telefono3 is null then
		let v_telefono3 = "";
	end if

	LET v_monto_letras = sp_sis11(v_monto);

	RETURN  TODAY, 
			v_a_nombre_de,
			v_monto, 
			v_monto_letras,      
			TODAY,
			_no_cheque,
			a_compania, 
			a_agencia, 
			a_usuario, 
			a_cod_banco, 
			a_cod_chequera, 
			_no_requis,
			_user_added,
			_aut_workflow_user,
			_fecha_captura,
			_aut_workflow_fecha,
			TODAY,
			v_telefono,
			v_telefono3,
			v_corredor;

{END FOREACH

-- Actualizacion del Ultimo Numero de Cheque
if _no_cheque2 IS NULL or _no_cheque2 = 0 then
	UPDATE chqchequ
	   SET cont_no_cheque = _no_cheque
	 WHERE cod_banco      = a_cod_banco
	   AND cod_chequera   = a_cod_chequera;
end if}

END PROCEDURE;
