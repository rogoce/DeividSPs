-- Impresion del Cheque	(Chequera de Firma electronica)
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_che52;

CREATE PROCEDURE "informix".sp_che52(
a_compania		CHAR(3), 
a_agencia 		CHAR(3), 
a_usuario 		CHAR(8), 
a_cod_banco 	CHAR(3), 
a_cod_chequera	CHAR(3), 
a_no_requis 	CHAR(10) DEFAULT '*'
) RETURNING DATE,
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
			CHAR(50),
			CHAR(8),
			CHAR(8),
			CHAR(30),
			CHAR(30),
			smallint,
			smallint,
			datetime year to fraction(5),
			datetime year to fraction(5),
			datetime year to fraction(5),
			CHAR(10);

DEFINE v_a_nombre_de  CHAR(50);     
DEFINE v_monto        DECIMAL(16,2);
DEFINE v_monto_letras CHAR(250);    
DEFINE _no_requis     CHAR(10);
DEFINE _no_cheque,_no_cheque2     INTEGER;
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
define _cod_cliente2  char(10);
define _cod_proveedor char(10);
define _tel_pag1	  char(10);
define _tel_pag2	  char(10);
define _cel_pag		  char(10);
define _no_reclamo	  char(10);	
define _cod_agente	  char(5);
define v_telefono1	  char(10);
define v_telefono2	  char(10);
define _firma1		  char(8);
define _firma2		  char(8);
define _no_poliza     char(10);
define _cta_chequera  smallint;
define _monto_disponible DECIMAL(16,2);
define _monto_asignado   DECIMAL(16,2);
define ld_lim_max	   DECIMAL(16,2);
define _ctrl_flujo     smallint;
define _nombre1        char(30);
define _nombre2        char(30);
define _firma1_sale     smallint;
define _firma2_sale     smallint;
define _fecha_firma1     datetime year to fraction(5);
define _fecha_firma2     datetime year to fraction(5);
define _fecha_paso_firma datetime year to fraction(5);
define _tipo_firma       char(1);

--SET DEBUG FILE TO "sp_che52.trc";
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

let _no_cheque2  = null;
let v_corredor   = null;
let v_telefono   = null;
let v_telefono3  = null;
let _ctrl_flujo  = 0;

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

{if _no_cheque = 28881 then
	let _no_cheque = 28882;
end if }

-- Lectura del Origen del Banco para el Enlace de Cuentas
  	
SELECT cod_origen,
	   cta_chequera
  INTO _cod_origen,
	   _cta_chequera
  FROM chqbanco
 WHERE cod_banco = a_cod_banco;

select valor_parametro
  into ld_lim_max
  from inspaag
 where codigo_compania  = '001'
   and codigo_agencia   = '001'
   and aplicacion       = 'CHE'
   and inspaag.version  = '02'
   and codigo_parametro = "lim_max_firma";

-- Inicio de la Impresion de Cheques

--FOREACH 
	 SELECT a_nombre_de,
			monto,
			no_requis,
			origen_cheque,
			user_added,
			aut_workflow_user,
			fecha_captura,
			aut_workflow_fecha,
			firma1,
			firma2,
	        fecha_firma1,
			fecha_firma2,
			fecha_paso_firma,
			cod_cliente
	   INTO v_a_nombre_de,
			v_monto,
			_no_requis,
			_origen_cheque,
			_user_added,
			_aut_workflow_user,
			_fecha_captura,
			_aut_workflow_fecha,
			_firma1,
			_firma2,
			_fecha_firma1,
			_fecha_firma2,
			_fecha_paso_firma,
			_cod_cliente2
	   FROM chqchmae
	  WHERE cod_compania   = a_compania
		AND autorizado     = 1
		AND pagado         = 0
		AND cod_banco      = a_cod_banco
		AND cod_chequera   = a_cod_chequera
		AND tipo_requis    = "C"
		AND en_firma       = 2
		AND no_requis      = a_no_requis;

--	  ORDER BY firma2,a_nombre_de;

	 let _firma1_sale  = 0;
	 let _firma2_sale  = 0;

	 --se pone esto temporalmente hasta segunda orden
   {	select tipo_firma -----------> Se quita a partir de hoy 19/09/2008 A.P.M.
	  into _tipo_firma
	  from wf_firmas
	 where usuario = _firma1;

    if _tipo_firma is null then
		let _tipo_firma = "";
	end if

	if _tipo_firma = "A" then
		LET _firma1_sale = 1;
	end if

	select tipo_firma
	  into _tipo_firma
	  from wf_firmas
	 where usuario = _firma2;

    if _tipo_firma is null then
		let _tipo_firma = "";
	end if

	if _tipo_firma = "A" then
		LET _firma2_sale = 1;
	end if
	} -----------------------------------
	--if trim(_firma1) = "CARLOS" then
	--	LET _firma1_sale = 1;
	--end if

	--if trim(_firma2) = "CARLOS" then
	--	LET _firma2_sale = 1;
	--end if	

	--se quita temporalmente hasta segunda orden

	{if v_monto > ld_lim_max then	--15000
		LET _firma_sale = 1;
	end if}
	
--	LET _no_cheque = _no_cheque + 1;

	LET v_monto_letras = sp_sis11(v_monto);
	
	-- Actualizacion del Maestro de Cheques

	UPDATE chqchmae
	   SET fecha_impresion = TODAY,
		   pagado          = 1,	
		   no_cheque       = _no_cheque,
		   periodo         = _periodo
	 WHERE no_requis       = _no_requis;

	-- Renglon de los Registros Contables
	
	SELECT MAX(renglon)
	  INTO _renglon	
	  FROM chqchcta
	 WHERE no_requis = _no_requis;

	IF _renglon IS NULL THEN
		LET _renglon = 0;
	END IF

	let v_telefono  = null;
	let	v_telefono3 = null;
	let	v_corredor	= null;

	-- Actualizacion para los Cheques de Reclamos

	IF _origen_cheque = '3' THEN

		BEGIN

		DEFINE _fecha_transac DATE;
		DEFINE _fecha_param   DATE;
		DEFINE _monto_transac DEC(16,2);
		DEFINE _debito        DEC(16,2);
		DEFINE _credito       DEC(16,2);

		DELETE FROM chqchcta
		 WHERE no_requis = _no_requis;

		SELECT rec_fecha_prov
		  INTO _fecha_param
		  FROM parparam
		 WHERE cod_compania = a_compania;

		FOREACH
		 SELECT transaccion,
				monto
		   INTO _transaccion,
				_monto_transac
		   FROM chqchrec
		  WHERE no_requis = _no_requis

			UPDATE rectrmae
			   SET pagado       = 1,
				   no_requis    = _no_requis,
				   fecha_pagado = TODAY
			 WHERE transaccion  = _transaccion
			   AND actualizado  = 1;

			SELECT fecha
			  INTO _fecha_transac
			  FROM rectrmae
			 WHERE transaccion = _transaccion
			   AND actualizado = 1;

			IF _fecha_transac > _fecha_param THEN
				LET  _cuenta  = sp_sis15('BCXPP'); 
			ELSE
				LET  _cuenta  = sp_sis15('BCXPPV'); 
			END IF

			IF _monto_transac > 0 THEN
				LET  _debito  = _monto_transac;
				LET  _credito = 0;
			ELSE
				LET  _debito  = 0;
				LET  _credito = _monto_transac * -1;
			END IF

			SELECT renglon
			  INTO _renglon
			  FROM chqchcta
			 WHERE no_requis = _no_requis
			   AND cuenta    = _cuenta;

			IF _renglon IS NULL THEN
				LET _renglon = 0;
			END IF

			IF _renglon = 0 THEN
				
				SELECT MAX(renglon)
				  INTO _renglon	
				  FROM chqchcta
				 WHERE no_requis = _no_requis;

				IF _renglon IS NULL THEN
					LET _renglon = 0;
				END IF

				LET _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito
				)
				VALUES(
				_no_requis,
				_renglon,
				_cuenta,
				_debito,
				_credito
				);
			
			ELSE

				UPDATE chqchcta
				   SET debito    = debito  + _debito,
				       credito   = credito + _credito
				 WHERE no_requis = _no_requis
				   AND renglon   = _renglon;

			END IF

		END FOREACH

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

			LET v_monto_letras = sp_sis11(v_monto);
		end if

		END 
		--******** tel de asegurado, tel y  nombre de corredor, tel de provvedor.
		FOREACH
			 SELECT transaccion
			   INTO _transaccion
			   FROM chqchrec
			  WHERE no_requis = _no_requis
				AND monto     > 0

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

	-- Registros Contables del Banco
	
	SELECT MAX(renglon)
	  INTO _renglon	
	  FROM chqchcta
	 WHERE no_requis = _no_requis;

	IF _renglon IS NULL THEN
		LET _renglon = 0;
	END IF

	LET _renglon = _renglon + 1;

	IF _cod_origen = '001' THEN
		if _cta_chequera = 1 then
			LET _enlace_cta = 'BACHEQL'; -- Chequera Bancos Locales
			LET _cuenta = sp_sis15(_enlace_cta, '02', a_cod_banco, a_cod_chequera);
		else
			LET _enlace_cta = 'BACHEBL'; -- Chequera Bancos Locales
			LET _cuenta = sp_sis15(_enlace_cta, '02', a_cod_banco);
		end if
	ELSE
		LET _enlace_cta = 'BACHEBE'; -- Chequera Bancos Extranjeros
		LET _cuenta = sp_sis15(_enlace_cta, '02', a_cod_banco);
	END IF

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito
	)
	VALUES(
	_no_requis,
	_renglon,
	_cuenta,
	0,
	v_monto
	);

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

	select descripcion
	  into _nombre1
	  from insuser
	 where usuario = _firma1;

	if _firma2 is null then
		let _nombre2 = "";
	else
		select descripcion
		  into _nombre2
		  from insuser
		 where usuario = _firma2;
	end if

	if _cod_cliente2 is null then
		let _cod_cliente2 = "";
	end if

	--***Insertar en BITACHE***
		INSERT INTO bitache(
		no_requis,
		no_cheque
		)
		VALUES(
		a_no_requis,
		_no_cheque
		);

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
			v_corredor,
			_firma1,
			_firma2,
			_nombre1,
			_nombre2,
			_firma1_sale,
			_firma2_sale,
			_fecha_firma1,
			_fecha_firma2,
			_fecha_paso_firma,
			_cod_cliente2;


--END FOREACH

-- Actualizacion del Ultimo Numero de Cheque

{	UPDATE chqchequ
	   SET cont_no_cheque = _no_cheque
	 WHERE cod_banco      = a_cod_banco
	   AND cod_chequera   = a_cod_chequera;}

END PROCEDURE;
