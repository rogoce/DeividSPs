

DROP PROCEDURE sp_rec272;
CREATE PROCEDURE sp_rec272(a_no_remesa char(10), a_renglon smallint, a_usuario char(8))
returning smallint, varchar(100);

define _mensaje				varchar(100);
define _valor_parametro2	char(20);
define _valor_parametro		char(20);
define _numrecla			char(18);
define _no_tranrec_char		char(10);
define _no_tran_char		char(10);
define _cod_cliente			char(10);
define _no_reclamo			char(10); 
define _periodo_rec			char(7);
define _rec_periodo			char(7);
define _cod_cobertura		char(5);  
define _cod_sucursal		char(3);
define _cod_compania		char(3);
define _cod_tipotran		char(3);
define _cod_tipopago		char(3);
define _version				char(2);
define _tipo_mov			char(1);  
define _saldo_recup			dec(16,2);
define _monto_arreglo		dec(16,2);
define _mto_rec				dec(16,2);
define _salvamento			dec(16,2);
define _deducible			dec(16,2);
define _recupero			dec(16,2);
define _monto				dec(16,2);
define _error				smallint; 
define _renglon				smallint; 
define _fecha_no_server		date;
define _fecha_tran			date;

let _rec_periodo = '2017-01';
let _cod_compania = '001';
let _cod_sucursal = '001';

select version
  into _version
  from insapli
 where aplicacion = 'REC';

select valor_parametro
  into _valor_parametro
  from inspaag
 where codigo_compania  = _cod_compania
   and aplicacion       = 'REC'
   and version          = _version
   and codigo_parametro	= 'fecha_recl_default';

if trim(_valor_parametro) = '1' then   --toma la fecha del servidor
	if month(current) < 10 then
		let _periodo_rec = year(current) || "-0" || month(current);
	else
		let _periodo_rec = year(current) || "-" || month(current);
	end if
else								   --toma la fecha de un parametro establecido por computo.
	select valor_parametro			  
	  into _valor_parametro2
	  from inspaag
	 where codigo_compania  = _cod_compania
	   and aplicacion       = 'REC'
	   and version          = _version
	   and codigo_parametro	= 'fecha_recl_valor';

	   let _fecha_no_server = date(_valor_parametro2);				

	if month(_fecha_no_server) < 10 then
		let _periodo_rec = year(_fecha_no_server) || "-0" || month(_fecha_no_server);
	else
		let _periodo_rec = year(_fecha_no_server) || "-" || month(_fecha_no_server);
	end if
end if

let _periodo_rec = '2017-01';

foreach	
	select no_reclamo, 
		   cod_cobertura, 
		   tipo_mov, 
		   renglon, 
		   monto,
		   cod_recibi_de,
		   fecha
	  into _no_reclamo, 
		   _cod_cobertura, 
		   _tipo_mov, 
		   _renglon, 
		   _monto,
		   _cod_cliente,
		   _fecha_tran
	  from cobredet
	 where no_remesa = a_no_remesa
	   and renglon = a_renglon
	   and tipo_mov  in ('D', 'S', 'R')
   
	let _salvamento = 0;
	let _recupero   = 0;
	let _deducible  = 0;
	
	if _periodo_rec < _rec_periodo then
		let _mensaje = "No Puede Actualizar para un periodo de Reclamos ya Cerrado, Por favor Verifique.";
		return 1, _mensaje;
	end if

	if _tipo_mov = 'S' THEN   -- Salvamento

		select cod_tipotran
		  into _cod_tipotran
		  from rectitra
		 where tipo_transaccion = 5;    
		
		let _cod_tipopago = '004';
		let _salvamento   = _monto * -1;

	elif _tipo_mov = 'R' then	-- recupero

		select cod_tipotran
		  into _cod_tipotran
		  from rectitra
		 where tipo_transaccion = 6;    

		let _cod_tipopago = '004';
		let _recupero     = _monto * -1;
		
		select sum(rectrmae.monto) * -1
		  into _mto_rec
		  from rectrmae, rectitra  
		 where rectitra.cod_tipotran = rectrmae.cod_tipotran 
		   and rectrmae.no_reclamo = _no_reclamo 
		   and rectrmae.actualizado = 1
		   and rectitra.tipo_transaccion = 6;
		   
		select sum(monto_arreglo)
		  into _monto_arreglo
		  from recrecup
		 where no_reclamo = _no_reclamo;
		 
		let _saldo_recup = 0;
		let  _saldo_recup = abs(_monto_arreglo) - abs(_mto_rec + _monto);
		 
		if _saldo_recup <= 0 then
			update recrecup
			   set estatus_recobro = 7
			 where no_reclamo = _no_reclamo;
		end if			
	else -- deducible

		select cod_tipotran
		  into _cod_tipotran
		  from rectitra
		 where tipo_transaccion = 7;    

		let _cod_tipopago = '003';
		let _deducible    = _monto * -1;
	end if

	-- Asignacion del Numero Interno y Externo de Transacciones
	let _no_tran_char    = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);
	let _no_tranrec_char = sp_sis13(_cod_compania, 'REC', '02', 'par_tran_genera');

	-- Lectura de la Tabla de Reclamos
	select numrecla
	  into _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	-- Insercion de las Transacciones de Salvamentos, Recuperos, Deducibles
	let _monto = _monto * -1;

	if trim(_valor_parametro) = '1' THEN

		insert into rectrmae(
				no_tranrec,
				cod_compania,
				cod_sucursal,
				no_reclamo,
				cod_cliente,
				cod_tipotran,
				cod_tipopago,
				no_requis,
				no_remesa,
				renglon,
				numrecla,
				fecha,
				impreso,
				transaccion,
				perd_total,
				cerrar_rec,
				no_impresion,
				periodo,
				pagado,
				monto,
				variacion,
				generar_cheque,
				actualizado,
				user_added)
		values(	_no_tranrec_char,
				_cod_compania,
				_cod_sucursal,
				_no_reclamo,
				_cod_cliente,
				_cod_tipotran,
				_cod_tipopago,
				NULL,
				a_no_remesa,
				_renglon,
				_numrecla,
				_fecha_tran,
				0,
				_no_tran_char,
				0,
				0,
				0,
				_periodo_rec,
				1,
				_monto,
				0,
				0,
				1,
				a_usuario);
	else
		insert into rectrmae(
				no_tranrec,
				cod_compania,
				cod_sucursal,
				no_reclamo,
				cod_cliente,
				cod_tipotran,
				cod_tipopago,
				no_requis,
				no_remesa,
				renglon,
				numrecla,
				fecha,
				impreso,
				transaccion,
				perd_total,
				cerrar_rec,
				no_impresion,
				periodo,
				pagado,
				monto,
				variacion,
				generar_cheque,
				actualizado,
				user_added)
		values(	_no_tranrec_char,
				_cod_compania,
				_cod_sucursal,
				_no_reclamo,
				_cod_cliente,
				_cod_tipotran,
				_cod_tipopago,
				NULL,
				a_no_remesa,
				_renglon,
				_numrecla,
				_fecha_no_server,
				0,
				_no_tran_char,
				0,
				0,
				0,
				_periodo_rec,
				1,
				_monto,
				0,
				0,
				1,
				a_usuario);
	end if

	-- Insercion de las Coberturas (Transacciones)
	insert into rectrcob(
			no_tranrec,
			cod_cobertura,
			monto,
			variacion)
	values(	_no_tranrec_char,
			_cod_cobertura,
			_monto,
			0);

	-- Actualizacion de los Valores Acumulados de las Coberturas
	update recrccob
	   set salvamento       = salvamento       + _salvamento,
		   recupero         = recupero         + _recupero,
		   deducible_pagado = deducible_pagado + _deducible
	 where no_reclamo       = _no_reclamo
	   and cod_cobertura    = _cod_cobertura;

	-- Actualizacion en la Remesa del Numero de Transaccion Generado
	update cobredet
	   set no_tranrec = _no_tranrec_char
	 where no_remesa  = a_no_remesa
	   and renglon    = _renglon;

	-- Reaseguro a Nivel de Transaccion
	call sp_sis58(_no_tranrec_char) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

	-- Reaseguro de Reclamos (Nueva Estructura de Asientos)
	call sp_rea008(3, _no_tranrec_char) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if
end foreach

return 0,'Actualizacion Exitosa';

end procedure