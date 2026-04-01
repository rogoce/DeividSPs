-- Procedimiento que Genera la Remesa de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob184bk;

CREATE PROCEDURE "informix".sp_cob184bk(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _flag,_flag2	    INTEGER;
DEFINE _error_code      INTEGER;
DEFINE _renglon      	INTEGER;  
DEFINE _saldo        	DEC(16,2);
DEFINE _monto        	DEC(16,2);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18);
DEFINE _fecha			DATE;
DEFINE _periodo			CHAR(7);
DEFINE _tipo_mov        CHAR(1);
DEFINE _factor			DEC(16,2);
DEFINE _prima			DEC(16,2);
DEFINE _impuesto		DEC(16,2);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _nombre_cte   	CHAR(50);
DEFINE _nombre_agente 	CHAR(50);
DEFINE _descripcion   	CHAR(100);
DEFINE _cod_agente   	CHAR(10);
DEFINE _porc_partic		DEC(5,2);
DEFINE _porc_comis		DEC(5,2);
DEFINE _null            CHAR(1);
DEFINE _ano_char        CHAR(4);
DEFINE a_no_remesa      CHAR(10);
DEFINE a_no_recibo      CHAR(10);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _motivo_rechazo  CHAR(50);
DEFINE _cod_pagador     CHAR(10);
DEFINE _cod_cobrador    CHAR(3);
DEFINE _dia		      	INTEGER;  
define _banco           CHAR(3);
define _id_transaccion  integer;
define _id_usuario      integer;
define _id_turno        integer;
define _existe          integer;
define _id_detalle      integer;
define _id_det		    integer;
define _id_tipo_cuenta  integer;
define _id_tipo_cobro   integer;
define _id_banco        integer;
define _recibo          CHAR(10);
define _monto_total		DEC(16,2);
define _monto_trancobro DEC(16,2);
define _fecha_documento date;
define _num_doc 		varchar(30);
define _tipo_tarjeta    integer;
define _cod_banco       char(3);
define _secuencia       integer;
DEFINE _mensaje         CHAR(100);
define ld_fecha_hora	datetime year to fraction(5);
define _fecha_registro  datetime year to fraction(5);
define _id_cliente		char(30);
define ls_cod_cobrador  char(3);
define _dia_cobros1     smallint;
define _pago_fijo       smallint;
define _tipo_cliente    smallint;

--SET DEBUG FILE TO "sp_cob184bk.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar la Remesa de Cobros Moviles', '';
END EXCEPTION           

LET _tipo_mov   = 'P';
LET _null       = NULL;
LET a_no_remesa = '1';  
let _existe = 0;
let _fecha  = null;
let _periodo = '';
let _error_code = 0;

--Buscar el banco en parametros
SELECT valor_parametro
  INTO _banco
  FROM inspaag
 WHERE codigo_compania  = "001"
   AND codigo_agencia   = "001"
   AND aplicacion       = "COB"
   AND version          = "02"
   AND codigo_parametro = "banco_cdm";

FOREACH
	select id_usuario,
		   id_turno
	  into _id_usuario,
		   _id_turno
	  from cdmturno
	 order by 1,2

	select count(*)
	  into _existe
	  from cdmtransacciones
	 where id_usuario = _id_usuario
       and id_turno   = _id_turno;

    if _existe = 0 then
		continue foreach;
	end if

	 let _cod_cobrador = '0' || _id_usuario;

	{ let a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

	SELECT fecha
	  INTO _fecha
	  FROM cobremae
	 WHERE no_remesa = a_no_remesa;
	
	IF _fecha IS NOT NULL THEN
		RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...', '';
	END IF

	LET _fecha = TODAY;

	IF MONTH(_fecha) < 10 THEN
		LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
	ELSE
		LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
	END IF

	update cdmturno
	   set sincronizado = a_no_remesa
	 where id_usuario   = _id_usuario
	   and id_turno	    = _id_turno;

	-- Insertar el Maestro de Remesas

	INSERT INTO cobremae
	VALUES(
	a_no_remesa,
	a_compania,
	a_sucursal,
	_banco,
	_cod_cobrador,
	_null,
	'A',
	_fecha,
	0,
	3,
	0.00,
	0,
	_periodo,
	a_user,
	_fecha,
	a_user,
	_fecha
	);

	LET _renglon = 0;
    let _id_det  = 0;

	--Buscar la transacciones por cobrador por turno.
	FOREACH
		select id_transaccion,
			   nombre_cliente,
			   total,
			   secuencia
		  into _id_transaccion,
			   _nombre_cliente,
			   _monto_total,
			   _secuencia
		  from cdmtransacciones
		 where id_usuario = _id_usuario
	       and id_turno   = _id_turno
		   and id_motivo_abandono is null
		 order by id_transaccion

		-- Numero de Recibo
		let _recibo = sp_sis79(_secuencia);
		let a_no_recibo = _cod_cobrador || '-' || _recibo;

		--ultimo numero de renglon
		select max(renglon)
		  into _renglon
		  from cobredet
		 where no_remesa = a_no_remesa;

		if _renglon is null then
			let _renglon = 0;
		end if

		select count(*)
		  into _existe
		  from cdmtrandetalle
		 where id_usuario 	  = _id_usuario
	       and id_turno   	  = _id_turno
		   and id_transaccion = _id_transaccion;

		if _monto_total = 0 and _existe = 0 then	--Recibo Anulado

			let _no_documento = a_no_recibo;
			let _renglon      = _renglon + 1;

			INSERT INTO cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado,
			no_poliza
			)
			VALUES(
		    a_no_remesa,
		    _renglon,
		    a_compania,
		    a_sucursal,
		    a_no_recibo,
		    _no_documento,
		    "B",
		    0,
		    0,
		    0,
		    0,
		    0,
		    "",
		    0,
		    _periodo,
		    _fecha,
		    0,
			_null
			);

			continue foreach;
		end if

		let _flag2 = 0;		  --transaccion nueva

		foreach
			select id_detalle,
				   cuenta,
				   monto,
				   id_tipo_cuenta
			  into _id_detalle,
			  	   _no_documento,
				   _monto,
				   _id_tipo_cuenta
			  from cdmtrandetalle
			 where id_usuario 	  = _id_usuario
		       and id_turno   	  = _id_turno
			   and id_transaccion = _id_transaccion
			 order by id_detalle

		   --Crear registros en cobrepag, proveniente de cdmtrancobro

		   if _flag2 = 0 then
		       
			   foreach
				   select id_tipo_cobro,
						  id_banco,
						  fecha_documento,
						  num_documento,
						  monto
					 into _id_tipo_cobro,
					      _id_banco,
						  _fecha_documento,
						  _num_doc,
						  _monto_trancobro
					 from cdmtrancobro
					where id_usuario 	  = _id_usuario
				      and id_turno   	  = _id_turno
					  and id_transaccion  = _id_transaccion

				   if _id_banco < 10 then
				   		let _cod_banco = "00" || _id_banco;
				   elif _id_banco < 100 then
						let _cod_banco = "0" || _id_banco;
				   end if

				   let _tipo_tarjeta = null;
				   let _flag         = 0;
				   let _nombre_cte   = _nombre_cliente;

				   if _id_tipo_cobro = 4 then		 --Visa
						let _tipo_tarjeta = 1;
						let _flag         = 1;
				   elif _id_tipo_cobro = 5 then	 --MasterCard
				   		let _id_tipo_cobro = 4;
						let _tipo_tarjeta = 2;
						let _flag         = 1;
				   elif _id_tipo_cobro = 6 then	 --DinersClub
						let _id_tipo_cobro = 4;
						let _tipo_tarjeta = 3;
						let _flag         = 1;
				   elif _id_tipo_cobro = 7 then	 --AmericanExpress
						let _id_tipo_cobro = 4;
						let _tipo_tarjeta = 4;
						let _flag         = 1;
				   elif _id_tipo_cobro = 1 then      --Efectivo
						let _cod_banco       = null;			 }
			   {		let _tipo_tarjeta    = null;
						let _fecha_documento = null;
						let _num_doc         = null;
						let	_nombre_cte      = null;
				   end if

				   if _flag = 1 and _id_banco = 0 then
						RETURN 1, 'Cobro con Tarjeta de Credito sin Banco, Por Favor Verifique. '||'Cobrador:'||_cod_cobrador||' Turno:'||_id_turno||' Trans.:'||_id_transaccion||' Detalle:'||_id_detalle,'';
				   end if

	 		       let _id_det = _id_det + 1;

				   INSERT INTO cobrepag(
				   no_remesa,
				   renglon,
				   tipo_pago,
				   tipo_tarjeta,
				   cod_banco,
				   fecha,
				   no_cheque,
				   girado_por,
				   a_favor_de,
				   importe
				   )
				   VALUES(
				   a_no_remesa,
				   _id_det,
				   _id_tipo_cobro,
				   _tipo_tarjeta,
				   _cod_banco,
				   _fecha_documento,
				   _num_doc,
				   _nombre_cte,
				   "",
				   _monto_trancobro
				   );
				   let _flag2 = 1;
			  end foreach
		   end if

		  let _renglon  = _renglon + 1;

		  select abreviatura
		    into _tipo_mov
		    from cdmtipocuenta
		   where id_usuario     = _id_usuario
		     and id_tipo_cuenta = _id_tipo_cuenta;

		  let _saldo    = 0;
		  let _prima    = 0;
		  let _impuesto = 0;

		  if _tipo_mov = "P" then		--Pago de Prima

				LET _no_poliza = sp_sis21(_no_documento);

				if _no_poliza is null then

					LET _tipo_mov   = 'E';  --Crear prima en suspenso
					LET _nombre_agente  = " ";
				else
					SELECT SUM(saldo)
					  INTO _saldo
					  FROM emipomae
					 WHERE no_documento = _no_documento
					   AND actualizado  = 1;

					IF _saldo IS NULL THEN
						LET _saldo = 0;
					END IF

					-- Impuestos de la Poliza

					SELECT SUM(i.factor_impuesto)
					  INTO _factor
					  FROM prdimpue i, emipolim p
					 WHERE i.cod_impuesto = p.cod_impuesto
					   AND p.no_poliza    = _no_poliza;

					IF _factor IS NULL THEN
						LET _factor = 0;
					END IF

					LET _factor   = 1 + _factor / 100;
					LET _prima    = _monto / _factor;
					LET _impuesto = _monto - _prima;

					-- Descripcion de la Remesa
						
					LET _nombre_agente = " ";

					FOREACH
					 SELECT cod_agente
					   INTO _cod_agente
					   FROM emipoagt
					  WHERE no_poliza = _no_poliza

						SELECT nombre
						  INTO _nombre_agente
						  FROM agtagent
						 WHERE cod_agente = _cod_agente;

						EXIT FOREACH;

					END FOREACH
				end if
		  end if

		  if _tipo_mov = "E" then		--Crear Prima Suspenso

			   LET _nombre_agente  = "-";
			   LET _no_poliza      = null;
			   LET _no_documento   = a_no_recibo;

			   INSERT INTO cobsuspe(
			   doc_suspenso,
			   cod_compania,
			   cod_sucursal,
			   monto,
			   fecha,
			   coaseguro,
			   asegurado,
			   poliza,
			   ramo,
			   actualizado,
			   user_added,
			   date_added
			   )
			   VALUES(
			   _no_documento,
			   a_compania,
			   a_sucursal,
			   _monto,
			   _fecha,
			   "",
			   _nombre_cliente,
			   _no_documento,
			   _null,
			   0,
			   a_user,
			   _fecha
			   );
		  end if

		  LET _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);
		 
		  -- Detalle de la Remesa

		  INSERT INTO cobredet(
		   no_remesa,
		   renglon,
		   cod_compania,
		   cod_sucursal,
		   no_recibo,
		   doc_remesa,
		   tipo_mov,
		   monto,
		   prima_neta,
		   impuesto,
		   monto_descontado,
		   comis_desc,
		   desc_remesa,
		   saldo,
		   periodo,
		   fecha,
		   actualizado,
		   no_poliza
		   )
		   VALUES(
		   a_no_remesa,
		   _renglon,
		   a_compania,
		   a_sucursal,
		   a_no_recibo,
		   _no_documento,
		   _tipo_mov,
		   _monto,
		   _prima,
		   _impuesto,
		   0,
		   0,
		   _descripcion,
		   _saldo,
		   _periodo,
		   _fecha,
		   0,
		   _no_poliza
		   );
		   
		   foreach
			 SELECT	cod_agente,
					porc_partic_agt,
					porc_comis_agt
			   INTO	_cod_agente,
					_porc_partic,
					_porc_comis
			   FROM	emipoagt
			  WHERE no_poliza = _no_poliza

				INSERT INTO cobreagt	   }
	 {			VALUES(
				a_no_remesa,
				_renglon,
				_cod_agente,
				0,
				0,
				_porc_comis,
				_porc_partic
				);  
		   end foreach
		end foreach
	end foreach

	SELECT SUM(monto)
	  INTO _saldo
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa;

	UPDATE cobremae
	   SET monto_chequeo = _saldo
	 WHERE no_remesa     = a_no_remesa;

	--Actualizacion de Remesa

	{call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

	if _error_code <> 0 then
		return _error_code, _mensaje, a_no_remesa;
	end if }

	call sp_sis40() returning ld_fecha_hora;

	--Procesar los registros cobrados en cobruter1 y cobruter2 y actualizar historia .
	foreach
		select id_cliente
		  into _id_cliente
		  from cdmtransacciones
		 where id_usuario = _id_usuario
	       and id_turno   = _id_turno
		   and id_motivo_abandono is null

		let _id_cliente = trim(_id_cliente);

		select cod_cobrador,
			   fecha,
			   dia_cobros1
		  into ls_cod_cobrador,
		  	   _fecha_registro,
			   _dia_cobros1
		  from cobruter3
		 where cod_pagador = _id_cliente
		   and tipo_labor  = 0;

		select pago_fijo
		  into _pago_fijo
		  from cascliente
		 where cod_cliente = _id_cliente;

		select tipocliente
		  into _tipo_cliente
		  from cdmclientes
		 where id_cliente = _id_cliente;
		
		--Se completa registro de historia
		update cobruhisbk
		   set fecha_posteo = ld_fecha_hora,
		       user_posteo  = a_user,
			   cod_motiv    = _null
		 where cod_cobrador = ls_cod_cobrador
		   and dia_cobros1  = _dia_cobros1
		   and fecha        = _fecha_registro;

		--Pago Fijo
		LET ld_fecha_hora = ld_fecha_hora + 10 UNITS SECOND;

		if _pago_fijo = 1 then

			call sp_cob159bk(_id_cliente, _cod_cobrador, _dia_cobros1, _fecha_registro, ld_fecha_hora) returning _error_code;

			if _error_code <> 0 then
				return _error_code, 'Rutina de los Pagos Fijos, verifique...', '';
			end if

		else

			--Borrar de Cobruter1 y Cobruter2
			if _tipo_cliente = 0 then			    --Cte Normal
				delete from cobruter4
				 where cod_pagador = _id_cliente 
				   and tipo_labor  = 0;
			 
				delete from cobruter3
				 where cod_pagador = _id_cliente
				   and tipo_labor  = 0;	 
			Else									--Es corredor
				delete from cobruter3
				 where cod_agente = _id_cliente;
			End If
		end if
	end foreach

END FOREACH

RETURN 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

END 

END PROCEDURE;
