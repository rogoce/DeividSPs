-- Procedimiento que Genera la Remesa de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob184;

create procedure "informix".sp_cob184(
a_compania		char(3),
a_sucursal		char(3),
a_user			char(8),
a_turno			integer,
a_id_usuario    integer
) returning smallint,
            char(100),
            char(10);

define _num_doc				varchar(30);
define _descripcion			char(100);
define _mensaje				char(100);
define _motivo_rechazo		char(50);
define _nombre_cliente		char(50);
define _nombre_agente		char(50);
define _nombre_cte			char(50);
define _error_desc			char(50);
define _id_cliente			char(30);
define _no_tarjeta			char(19);
define _no_documento		char(18);
define _cod_pagador			char(10);
define _cod_agente			char(10);
define a_no_remesa			char(10);
define a_no_recibo			char(10);
define _no_poliza			char(10);
define _recibo				char(10);
define _periodo				char(7);
define _ano_char			char(4);
define ls_cod_cobrador		char(3);
define _cod_cobrador		char(3);
define _cod_chequera		char(3);
define _cod_sucursal		char(3);
define _cod_banco			char(3);
define _banco				char(3);
define _tipo_mov			char(1);
define _null				char(1);
define _sum_transacciones	dec(16,2);
define _monto_trancobro		dec(16,2);
define _sum_trandetalle		dec(16,2);
define _sum_trancobro		dec(16,2);
define _monto_total			dec(16,2);
define _sum_turno			dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _prima				dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _porc_partic			dec(5,2);
define _porc_comis			dec(5,2);
define _verif_recibo		smallint;
define _tipo_cliente		smallint;
define _dia_cobros1			smallint;
define _cant_suspe			smallint;
define _pago_fijo			smallint;
define _id_transaccion		integer;
define _id_tipo_cuenta		integer;
define _id_tipo_cobro		integer;
define _tipo_tarjeta		integer;
define _id_usuario			integer;
define _id_detalle			integer;
define _error_code			integer;
define _error_isam			integer;
define _secuencia			integer;
define _id_banco			integer;
define _id_turno			integer;
define _renglon				integer;  
define _existe				integer;
define _id_det				integer;
define _flag2				integer;
define _flag				integer;
define _cnt					integer;
define _dia					integer;
define _fecha_documento		date;
define _fecha				date;
define _fecha_registro		datetime year to fraction(5);
define ld_fecha_hora		datetime year to fraction(5);
define _aplica              smallint;
define _mensaje2             varchar(30);
define _monto_linea			dec(16,2);

--define _resultado    char(30);
--define i,_valor      integer; 
--define _char_1       char(1);

set isolation to dirty read;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, _error_desc;
end exception           

--SET DEBUG FILE TO "sp_cob184.trc"; 
--trace on;

let _tipo_cliente	= 0;
let _error_code		= 0;
let _existe			= 0;
let a_no_remesa		= '1';  
let _tipo_mov		= 'P';
let _periodo		= '';
let _fecha			= null;
let _null			= null;
let _monto_linea    = 0;


--Buscar el banco en parametros
select valor_parametro
  into _banco
  from inspaag
 where codigo_compania  = "001"
   and codigo_agencia   = "001"
   and aplicacion       = "COB"
   and version          = "02"
   and codigo_parametro = "banco_cdm";


select count(*)
  into _cnt
  from cdmtransacciones
 where id_usuario = a_id_usuario
   and id_turno   = a_turno
   and id_motivo_abandono is null;

if _cnt = 0 then
	return 0, '','00000'; 	
end if

-- Verificacion del monto cobrado	
select total_cobrado
  into _sum_turno
  from cdmturno
 where id_usuario	= a_id_usuario
   and id_turno		= a_turno;

select sum(total)
  into _sum_transacciones
  from cdmtransacciones
 where id_usuario	= a_id_usuario
   and id_turno		= a_turno;

if _sum_transacciones <> _sum_turno then
	return 1,'El monto total de la tabla cdmtransacciones no coincide con el total del monto cobrado','' ;
end if

select sum(monto)
  into _sum_trancobro
  from cdmtrancobro
 where id_usuario	= a_id_usuario
   and id_turno		= a_turno;

if _sum_trancobro <> _sum_turno then
	return 1,'El monto total de la tabla cdmtrancobro no coincide con el total del monto cobrado','' ;
end if

select sum(monto)
  into _sum_trandetalle
  from cdmtrandetalle
 where id_usuario	= a_id_usuario
   and id_turno		= a_turno;
	
if _sum_trandetalle <> _sum_turno then
	return 1,'El monto total de la tabla cdmtrandetalle no coincide con el total del monto cobrado','' ;
end if
	 
-- Verificacion de un recibo del turno para ver si existe en cobredet Roman Gordon 04/03/2011
foreach
	select id_transaccion,
		   nombre_cliente,
		   total,
		   secuencia
	  into _id_transaccion,
		   _nombre_cliente,
		   _monto_total,
		   _secuencia
	  from cdmtransacciones
	 where id_usuario = a_id_usuario
	   and id_turno   = a_turno
	   and id_motivo_abandono is null
	 order by id_transaccion
	exit foreach;
end foreach

-- Numero de Recibo
let _cod_cobrador = '0' || a_id_usuario;
let _recibo       = sp_sis79(_secuencia);
let a_no_recibo   = _cod_cobrador || '-' || _recibo;

Select count(*),
	   no_remesa
  into _verif_recibo,
	   a_no_remesa
  from cobredet
 where no_recibo = a_no_recibo
 group by no_remesa;

if _verif_recibo > 0 then
	return 1, 'Turno Duplicado, Por favor Verifique Remesa # ...',a_no_remesa; 	
end if

 select id_usuario,
  	    id_turno
   into _id_usuario,
	    _id_turno
   from cdmturno
  where id_usuario = a_id_usuario
    and id_turno   = a_turno;

 select count(*)
   into _existe
   from cdmtransacciones
  where id_usuario = _id_usuario
    and id_turno   = _id_turno;

	if _existe = 0 then
		return 1, 'No Existen Transacciones para este Usuario en este Turno, Verifique ...','';
	end if

	if _id_usuario < 100 then
		let _cod_cobrador = '0' || _id_usuario;
	else
		let _cod_cobrador = _id_usuario;
	end if

	let a_no_remesa = sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

	select cod_sucursal,
		   cod_banco,
		   cod_chequera
	  into _cod_sucursal,
		   _banco,
		   _cod_chequera
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	if _banco is null theN
		return 1, 'Se debe colocar el banco caja en Mantenimiento de Cobradores', '';
	end if

	if _cod_chequera is null then
		return 1, 'Se debe colocar la Chequera del banco caja en Mantenimiento de Cobradores', '';
	end if

   {	select banco_caja,
	       cod_chequera
	  into _banco,
	       _cod_chequera
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';}

   	select fecha
   	  into _fecha
   	  from cobremae
   	 where no_remesa = a_no_remesa;
	
   	if _fecha is not null theN
		return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
	end if

	--Sacar la fecha del turno para la remesa
    select fecha_fin
	  into _fecha
   	  from cdmturno
	 where id_usuario = _id_usuario
       and id_turno   = _id_turno;

	if month(_fecha) < 10 then
		let _periodo = year(_fecha) || '-0' || month(_fecha);
	else
		let _periodo = year(_fecha) || '-' || month(_fecha);
	end if

	update cdmturno
	   set sincronizado = a_no_remesa
	 where id_usuario   = _id_usuario
	   and id_turno	    = _id_turno;

	-- Insertar el Maestro de Remesas

   	insert into cobremae(
			no_remesa,
			cod_compania,
			cod_sucursal,
			cod_banco,
			cod_cobrador,
			recibi_de,
			tipo_remesa,
			fecha,
			comis_desc,
			contar_recibos,
			monto_chequeo,
			actualizado,
			periodo,
			user_added,
			date_added,
			user_posteo,
			date_posteo,
			cod_chequera)
   	values(	a_no_remesa,
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
			_fecha,
			_cod_chequera);

   	let _renglon = 0;
    let _id_det  = 0;

   	--buscar la transacciones por cobrador por turno.
   	foreach
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

		{select count(*)
		  into _existe
		  from cdmtrandetalle
		 where id_usuario 	  = _id_usuario
	       and id_turno   	  = _id_turno
		   and id_transaccion = _id_transaccion;}

		if _monto_total = 0 then	--Recibo Anulado

			let _no_documento = a_no_recibo;
			let _renglon      = _renglon + 1;

		   	insert into cobredet(
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
					no_poliza)
			values(	a_no_remesa,
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
					_null);

			insert into cobrepag(
					no_remesa,
					renglon,
					tipo_pago,
					tipo_tarjeta,
					cod_banco,
					fecha,
					no_cheque,
					girado_por,
					a_favor_de,
					importe,
					tipo_cheque)
			values(	a_no_remesa,
					_renglon,
					1,
					null,
					null,
					null,
					null,
					null,
					null,
					0.00,
					0);
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
					 where id_usuario     = _id_usuario
					   and id_turno       = _id_turno
					   and id_transaccion = _id_transaccion

					let _num_doc = trim(_num_doc);
				   --	let _valor   = length(_num_doc);

				   {	 for i = 1 to _valor

						LET _char_1  = _num_doc[1, 1];
						LET _num_doc = _num_doc[2, 30];

						if _char_1 = "-" or _char_1 = "." or _char_1 = " " or _char_1 = "/" or _char_1 = "*" or _char_1 = "+" or _char_1 = "!" or _char_1 = "#" or _char_1 = "$" or _char_1 = '?' or
						   _char_1 = ":" or _char_1 = "," or _char_1 = ";" then
						else	
							let _resultado = trim(_resultado) || trim(_char_1);
						end if

					    if i = _valor then
							EXIT FOR;
						end if

					 end for}

					{ let _num_doc   = trim(_resultado);
				   	 let _resultado = "";
				     let _char_1    = "";}

				   if _id_banco < 10 then
				   		let _cod_banco = "00" || _id_banco;
				   elif _id_banco < 100 then
						let _cod_banco = "0" || _id_banco;
				   else
				   		let _cod_banco = _id_banco;	
				   end if

				   let _tipo_tarjeta = null;
				   let _flag         = 0;
				   let _nombre_cte   = _nombre_cliente;

				   if _id_tipo_cobro = 4 then		-- Visa
						let _tipo_tarjeta  = 1;
						let _flag          = 1;
						let _num_doc       = null;
				   elif _id_tipo_cobro = 5 then	    -- MasterCard
				   		let _id_tipo_cobro = 4;
						let _tipo_tarjeta  = 2;
						let _flag          = 1;
						let _num_doc       = null;
				   elif _id_tipo_cobro = 6 then	    -- DinersClub
						let _id_tipo_cobro = 4;
						let _tipo_tarjeta  = 3;
						let _flag          = 1;
						let _num_doc       = null;
				   elif _id_tipo_cobro = 7 then	    -- AmericanExpress
						let _id_tipo_cobro = 4;
						let _tipo_tarjeta  = 4;
						let _flag          = 1;
						let _num_doc       = null;
				   elif _id_tipo_cobro = 1 then     -- Efectivo
						let _cod_banco     	 = null;
			   			let _tipo_tarjeta    = null;
						let _fecha_documento = null;
						let _num_doc         = null;
						let	_nombre_cte      = null;
				   end if

				   if _flag = 1 and _id_banco = 0 then
						return 1, 'Cobro con Tarjeta de Credito sin Banco, Por Favor Verifique. '||'Cobrador:'||_cod_cobrador||' Turno:'||_id_turno||' Trans.:'||_id_transaccion||' Detalle:'||_id_detalle,'';
				   end if

					if _id_det >= _renglon then
						let _id_det = _id_det + 1;
					else
						let _id_det = _renglon + 1;
					end if

				   insert into cobrepag(
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
				   values(
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

		   	let _no_poliza = sp_sis21(_no_documento);

			if _no_poliza is null then

		   		let _tipo_mov   = 'E';  --Crear prima en suspenso
		   		let _nombre_agente  = " ";
		
			else
		
				{SELECT SUM(saldo)
				  INTO _saldo
				  FROM emipomae
				 WHERE no_documento = _no_documento
				   AND actualizado  = 1;}

			    call sp_cob115b(a_compania,a_sucursal,_no_documento,"") returning _saldo;

			   	if _saldo is null theN
			   		let _saldo = 0;
			   	end iF

				-- Impuestos de la Poliza

			   	select sum(i.factor_impuesto)
			   	  into _factor
			   	  from prdimpue i, emipolim p
			   	 where i.cod_impuesto = p.cod_impuesto
			   	   and p.no_poliza    = _no_poliza;

			   	if _factor is null theN
			   		let _factor = 0;
			   	end iF

			   	let _factor   = 1 + _factor / 100;
			   	let _prima    = _monto / _factor;
			   	let _impuesto = _monto - _prima;
				let _saldo    = _saldo - _monto;
			   	-- descripcion de la remesa
					
			   	let _nombre_agente = " ";

			   	foreacH
			   	 select cod_agente
			   	   into _cod_agente
			   	   from emipoagt
			   	  where no_poliza = _no_poliza

			   		select nombre
			   		  into _nombre_agente
			   		  from agtagent
			   		 where cod_agente = _cod_agente;

			   		exit foreach;

			   	end foreacH

			end if

		  end if

		  if _tipo_mov in ("D", "S", "R") then
		  	let _tipo_mov = "E";
		  end if

		  if _tipo_mov = "E" then -- Crear Prima Suspenso

		   	let _nombre_agente  = "-";
		   	let _no_poliza      = null;
		   	let _no_documento   = a_no_recibo;
		
			select count(*)
			  into _cant_suspe
			  from cobsuspe
			 where doc_suspenso = _no_documento;
			 
			 if _cant_suspe <> 0 then

				update cobsuspe
				   set monto        = monto + _monto				  					
				 where doc_suspenso = _no_documento;

			 else

				insert into cobsuspe(
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
				values(
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

		  end if

		  let _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);
		 
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

				INSERT INTO cobreagt(
                no_remesa,
				renglon,
				cod_agente,
				monto_calc,
				monto_man,
				porc_comis_agt,
				porc_partic_agt)
	 			VALUES(
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
		
	if _saldo is null then
		let _saldo = 0.00;
	end if

	UPDATE cobremae
	   SET monto_chequeo = _saldo
	 WHERE no_remesa     = a_no_remesa;

--------------------------------------------
let _cnt = 0;

foreach

	SELECT no_poliza,monto,doc_remesa
	  INTO _no_poliza,_monto_linea,_no_documento
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  = 'P'

	select count(*)
	  into _cnt
	  from coboutleg
	 where no_documento = _no_documento;

	if _cnt = 0 then
		call sp_pro863(_no_poliza,_monto_linea,a_user,a_no_remesa) returning _aplica, _mensaje2;
	end if

end foreach
	-------------------------
	--Actualizacion de Remesa

	call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

	if _error_code <> 0 then
		return _error_code, _mensaje, a_no_remesa;
	end if

	call sp_sis40() returning ld_fecha_hora;

    --********************************************************************************
	--Procesar los registros cobrados en cobruter1 y cobruter2 y actualizar historia .
	--********************************************************************************

	foreach
		select id_cliente,
			   id_transaccion
		  into _id_cliente,
			   _id_transaccion
		  from cdmtransacciones
		 where id_usuario = _id_usuario
	       and id_turno   = _id_turno
		   and total      <> 0
		   and id_motivo_abandono is null

		if _id_cliente is null then
			continue foreach;
		end if

		let _id_cliente = trim(_id_cliente);

		select cod_cobrador,
			   fecha,
			   dia_cobros1
		  into ls_cod_cobrador,
		  	   _fecha_registro,
			   _dia_cobros1
		  from cobruter1
		 where cod_pagador  = _id_cliente
		   and cod_cobrador = _cod_cobrador
		   and tipo_labor   = 0;

	    let _pago_fijo = 0;

	    foreach
			select pago_fijo
			  into _pago_fijo
			  from cascliente
			 where cod_cliente = _id_cliente
			exit foreach;
	    end foreach

	    if _pago_fijo is null then
			let _pago_fijo = 0;
	    end if

		select tipocliente
		  into _tipo_cliente
		  from cdmclientes
		 where id_cliente = _id_cliente;
		
		--Se completa registro de historia
		update cobruhis
		   set fecha_posteo = ld_fecha_hora,
		       user_posteo  = a_user,
			   cod_motiv    = _null
		 where cod_cobrador = ls_cod_cobrador
		   and dia_cobros1  = _dia_cobros1
		   and fecha        = _fecha_registro;

		call sp_sis40() returning ld_fecha_hora;

		--Pago Fijo
		LET ld_fecha_hora = ld_fecha_hora + 10 UNITS SECOND;

		if _pago_fijo = 1 then			
			if _dia_cobros1 is not null then
				call sp_cob159(_id_cliente, _cod_cobrador, _dia_cobros1, _fecha_registro, ld_fecha_hora) returning _error_code, _error_desc;

				if _error_code <> 0 then
					return _error_code, _error_desc, '';
				end if
			end if
		else
			--Borrar de Cobruter1 y Cobruter2
			if _tipo_cliente = 0 then			    --cte normal
				delete from cobruter2
				 where cod_pagador = _id_cliente 
				   and tipo_labor  = 0;
			 
				delete from cobruter1
				 where cod_pagador = _id_cliente
				   and tipo_labor  = 0;
			else									--es corredor
				delete from cobruter1
				 where cod_agente = _id_cliente;
			end if
		end if
	end foreach
return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 
end 
end procedure;