-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 26/09/2000 - Autor: Marquelda Valdelamar
-- Modificado: 21/03/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob25b;
create procedure sp_cob25b(
a_compania 		char(3), 
a_sucursal 		char(3),
a_no_documento  char(20))
returning	date,  	   -- fecha
			char(20),  -- referencia
			char(20),  -- no. documento
			dec(16,2), -- monto
			dec(16,2), -- prima neta
			dec(16,2), -- saldo
			char(7),   -- periodo
			char(10),  -- poliza
			char(30),  -- tipo factura
			char(10);  -- no_remesa

define v_referencia		char(20);
define v_documento		char(20);
define _tipo_fac		char(30);
define _no_remesa		char(10);
define _no_poliza		char(10);
define _no_requis		char(10);
define v_periodo		char(7);
define v_cod_endomov	char(3);
define v_cod_tipocan	char(3);
define _cod_tipoprod	char(3);
define _cod_banco		char(3);
define _nueva_renov		char(1);
define _tipo_remesa		char(1);
define _tipo_mov		char(1);
define v_monto			dec(16,2);
define v_prima			dec(16,2);
define v_saldo			dec(16,2);	
define _anulado			smallint;
define _pagado			smallint;
define _orden			smallint;
define _fecha_anulado	date;
define v_fecha			date;

set isolation to dirty read;

--drop table tmp_saldo;


--SET DEBUG FILE TO "sp_sis83.trc";
--TRACE ON;


--drop table if exists tmp_saldo;
create temp table tmp_saldo(
fecha			date,
referencia		char(20),
no_documento	char(20),
monto			dec(16,2),
prima_neta		dec(16,2),
periodo			char(7),
no_poliza		char(10),
tipo_fac		char(30),
no_remesa		char(10),
orden			smallint) with no log; 

let a_no_documento = trim(a_no_documento);
let _orden = 1;

foreach
	select no_poliza,
		   nueva_renov
	  into _no_poliza,
		  _nueva_renov
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado  = 1

	let v_referencia = 'FACTURA';

	foreach
		select fecha_emision,
			   no_factura,
			   prima_bruta,
			   prima_neta,
			   periodo,
			   cod_endomov, 
			   cod_tipocan
		  into v_fecha,
			   v_documento,
			   v_monto,
			   v_prima,
			   v_periodo,
			   v_cod_endomov,
			   v_cod_tipocan
		  from endedmae
		 where no_poliza   = _no_poliza
		   and actualizado = 1
		   and activa = 1

			-- Tipo de Factura
		let _tipo_fac = "";

		if v_cod_endomov = '011' then
			if _nueva_renov = 'N' then
			   let _tipo_fac = 'NUEVA';
			else
			   let _tipo_fac = 'RENOVACION';
			end if
		elif v_cod_endomov = '002' then
			select nombre
			  into _tipo_fac
			  from endtican
			 where cod_tipocan = v_cod_tipocan;
		else
			select nombre
			  into _tipo_fac 
			  from endtimov
			 where cod_endomov = v_cod_endomov;
		end if

		insert into tmp_saldo(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza,
				tipo_fac,
				orden)
		values(	v_fecha,
				v_referencia,	
				v_documento,
				v_monto,
				v_prima, 
				v_periodo,
				_no_poliza,
				_tipo_fac,
				_orden);
	end foreach;

	let _orden = 2;

	foreach
		select no_recibo,
			   monto,
			   prima_neta,
			   no_remesa,
			   tipo_mov
		  into v_documento,
			   v_monto,
			   v_prima,
			   _no_remesa,
			   _tipo_mov
		  from cobredet
		 where no_poliza   = _no_poliza
		   and actualizado = 1
		   and tipo_mov in ('P', 'N', 'X')

		let v_monto = v_monto * -1;
		let v_prima = v_prima * -1;

		select fecha,
		       tipo_remesa,
			   periodo
		  into v_fecha,	
			   _tipo_remesa,
			   v_periodo
		  from cobremae
		 where no_remesa = _no_remesa;

	    if _tipo_remesa = 'C' then
			let v_referencia = 'COMPROBANTE';
		else
			if _tipo_mov = 'X' then
				let v_referencia = 'AJUSTE';
			else
				let v_referencia = 'RECIBO';
			end if
	    end if

		let _tipo_fac = 'REMESA ' || _no_remesa;

		insert into tmp_saldo(
				fecha,
				referencia,
				no_documento,
				monto,
				prima_neta,
				periodo,
				no_poliza,
				tipo_fac,
				no_remesa,
				orden)
		values(	v_fecha,
				v_referencia,
				v_documento,
				v_monto,
				v_prima, 
				v_periodo, 
				_no_poliza,
				_tipo_fac,
				_no_remesa,
				_orden);
	end foreach

	foreach
		select monto,
			   prima_neta,
			   no_requis
		  into v_monto,
			   v_prima,
			   _no_requis
		  from chqchpol
		 where no_poliza = _no_poliza

		select fecha_impresion,
		       no_cheque,
			   periodo,
			   pagado,
			   cod_banco,
			   anulado,
			   fecha_anulado
		  into v_fecha,	
			   v_documento, 
			   v_periodo,
			   _pagado,
			   _cod_banco,
			   _anulado,
			   _fecha_anulado
		  from chqchmae
		 where no_requis = _no_requis;

        select nombre
		  into _tipo_fac
		  from chqbanco
		 where cod_banco = _cod_banco;

		if _pagado  = 1 then
			let v_referencia = 'CHEQUE PAGADO';
			let _orden       = 3;

			insert into tmp_saldo(
					fecha,
					referencia,
					no_documento,
					monto,
					prima_neta,
					periodo,
					no_poliza,
					tipo_fac,
					orden)
			values(	v_fecha,
					v_referencia,	
					v_documento,
					v_monto,
					v_prima, 
					v_periodo, 
					_no_poliza,
					_tipo_fac,
					_orden);
		end if
	
		if _anulado = 1 then
			let v_monto      = v_monto * -1;
			let v_prima      = v_prima * -1;
			let v_periodo    = sp_sis39(_fecha_anulado);
			let v_referencia = 'CHEQUE ANULADO';
			let _orden       = 4;

			insert into tmp_saldo(
					fecha,
					referencia,
					no_documento,
					monto,
					prima_neta,
					periodo,
					no_poliza,
					tipo_fac,
					orden)
			values(	_fecha_anulado,
					v_referencia,	
					v_documento,
					v_monto,
					v_prima, 
					v_periodo, 
					_no_poliza,
					_tipo_fac,
					_orden);
		end if
	end foreach
end foreach

let v_saldo = 0;

foreach
	select fecha,
		   referencia,
		   no_documento,
		   monto,
		   prima_neta,
		   periodo,
		   no_poliza,
		   tipo_fac,
		   no_remesa,
		   orden
	  into v_fecha,
		   v_referencia,
		   v_documento,
		   v_monto, 
		   v_prima, 
		   v_periodo,
		   _no_poliza,
		   _tipo_fac,
		   _no_remesa,
		   _orden
	  from tmp_saldo
	 order by periodo, fecha, orden, referencia, no_documento
	 
	let v_saldo = v_saldo + v_monto;
 
	return v_fecha,
		   v_referencia, 
		   v_documento,
		   v_monto,
		   v_prima,
		   v_saldo,
		   v_periodo,
		   _no_poliza,
		   _tipo_fac,
		   _no_remesa
    	   with resume;
end foreach;
drop table tmp_saldo;
end procedure;