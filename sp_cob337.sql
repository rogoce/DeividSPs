-- Procedimiento que Realiza el proceso de Rehabilitación de pólizas en cobros legal .
-- Creado    : 03/02/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob337;
create procedure "informix".sp_cob337(
a_no_documento	char(20),
a_decision		smallint,
a_usuario		char(8))
returning		integer,	--1._error
				char(250),	--2._error_desc
				char(5);	--3._no_endoso

define _error_desc			char(250);
define _comentario			char(250);
define _no_factura_rehab	char(10);
define _no_factura_canc		char(10);
define _no_poliza			char(10);
define _no_endoso_rehab		char(5);
define _no_endoso_canc		char(5);
define _no_endoso2			char(5);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_abogado			char(3);
define _cod_tipocan			char(3);
define _prima_b_rehab		dec(16,2);
define _monto_endoso		dec(16,2);
define _prima_b_canc		dec(16,2);
define _cnt_coboutleg		smallint;
define _no_endoso_int		smallint;
define _cnt_endoso			smallint;
define _recupero			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_hoy			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error, _error_desc,'00000';
end exception

--set debug file to "sp_cob337.trc";
--trace on;

let _cod_formapag = '082';
let _cod_compania = '001';
let _cod_tipocan = '001'; --'004'; Decisión de la Compañia, se cambia a Falta de Pago sol. de cobros impl. 21/01/2015 
let _fecha_hoy = today;

select count(*)
  into _cnt_coboutleg
  from coboutleg
 where no_documento = a_no_documento;

if _cnt_coboutleg is null then
	let _cnt_coboutleg = 0;
end if

if _cnt_coboutleg = 0 then
	return 1,'No se encuentra la Póliza en el proceso de Cobros Legal.','00000';
end if

select cod_abogado,
	   no_factura,
	   prima,
	   recupero,
	   no_poliza,
	   comentario
  into _cod_abogado,
	   _no_factura_canc,
	   _monto_endoso,
	   _recupero,
	   _no_poliza,
	   _comentario
  from coboutleg
 where no_documento = a_no_documento;

if _recupero = 1 then	
	select no_endoso_rehab,
		   prima,
		   no_poliza
	  into _no_endoso_rehab,
		   _monto_endoso,
		   _no_poliza
	  from coboutlegh
	 where no_documento = a_no_documento;
end if

select cod_sucursal
  into _cod_sucursal
  from emipomae
 where no_poliza = _no_poliza;
--let _no_poliza = sp_sis21(a_no_documento);

if a_decision = 1 then
	if _recupero = 0 then

		select no_endoso--prima_bruta
		  into _no_endoso_int
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_factura = _no_factura_canc;
		   
		let _cnt_endoso = 0;
		
		while _cnt_endoso = 0
			let _no_endoso_int = _no_endoso_int - 1;
			let _no_endoso2    = sp_set_codigo(5, _no_endoso_int);
			
			select count(*)
			  into _cnt_endoso
			  from endedmae
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso2
			   and cod_endomov = '002'
			   and cod_tipocan = '001'
			   and cod_tipocalc = '001';
			
			if _cnt_endoso is null then
				let _cnt_endoso = 0;
			end if
			
			if _cnt_endoso = 0 then
				select count(*)
				  into _cnt_endoso
				  from endedmae
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso2
				   and cod_endomov = '002';
				
				if _cnt_endoso is null then
					let _cnt_endoso = 0;
				end if
				
				if _cnt_endoso = 0 then
					return 1,'No se encuentra el Endoso de Cancelación por Falta de Pago..','00000';
				end if
			end if
		end while 
		
		let _prima_b_canc = 0.00;
		
		select prima_bruta
		  into _prima_b_canc
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso2;
		
		let _prima_b_canc = abs(_prima_b_canc);
		let _monto_endoso = _monto_endoso + _prima_b_canc;

		--Procedure de Rehab. de Póliza
		call sp_par192(_no_poliza,a_usuario,_monto_endoso) returning _error, _error_desc, _no_endoso;

		if _error <> 0 then
			return _error,_error_desc,_no_endoso;
		end if

		--Insertar un registro Historico
		insert into coboutlegh(
				no_documento,
				fecha,
				no_factura,
				no_poliza,
				prima,
				pagos,
				saldo,
				gen_endcan,
				cod_abogado,
				fecha_in,
				fecha_out,
				gasto_legal,
				comentario,
				recupero,
				no_endoso_rehab,
				decision)
		select no_documento,
			   fecha,
			   no_factura,
			   no_poliza,
			   prima,
			   pagos,
			   saldo,
			   gen_endcan,
			   cod_abogado,
			   fecha_in,
			   fecha_out,
			   gasto_legal,
			   comentario,
			   a_decision,
			   _no_endoso,
			   a_decision
		  from coboutleg
		 where no_documento = a_no_documento;
	elif _recupero = 1 then --Se Acepta el Endoso de Rehabilitación de la Póliza		

		call sp_pro43(_no_poliza, _no_endoso_rehab) returning _error, _error_desc;

		if _error <> 0 then
			return _error, _error_desc || ' Endoso: ' || _no_endoso_rehab,_no_endoso_rehab;
		end if
		
		select no_factura
		  into _no_factura_rehab
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso_rehab;
		
		update coboutlegh
		   set no_factura_rehab = _no_factura_rehab,
		       decision			= a_decision,
			   comentario		= _comentario
		 where no_documento = a_no_documento;

		--Insertando cambio de plan de pago ANC.
		call sp_pro519(_no_poliza,a_usuario,_monto_endoso,_cod_compania,_cod_sucursal,'006') returning _error,_error_desc;

		if _error <> 0 then
			return _error, _error_desc,_no_endoso_rehab;
		end if

		delete from coboutleg
		 where no_documento = a_no_documento;
		
		let _no_endoso = _no_endoso_rehab;
	end if
elif a_decision = 2 then	--No es recupero o no se acepta el Endoso de Rehabilitación de la Póliza
	-- Insertando cambio de plan de pago Cuentas Malas.
	call sp_pro519(_no_poliza,a_usuario,_monto_endoso,_cod_compania,_cod_sucursal,_cod_formapag) returning _error,_error_desc;

	if _error <> 0 then
		return _error, _error_desc,'00000';
	end if

	delete from coboutlegh
	 where no_documento = a_no_documento;

	update coboutleg
	   set recupero = 2
	 where no_documento = a_no_documento;

	let _no_endoso = '00000';
elif a_decision = 3 then --Se Acepta el Endoso de Rehabilitación de la Póliza para aceptar el pago, pero se mantiene Cancelada la Póliza

	call sp_pro379(_no_poliza,_no_endoso_rehab) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc || ' Endoso: ' || _no_endoso_rehab,_no_endoso_rehab;
	end if
	let _no_endoso_rehab = '00000';

	if _monto_endoso <> 0 then
		--Procedure de Rehab. de Póliza
		call sp_par192(_no_poliza,a_usuario,_monto_endoso) returning _error, _error_desc, _no_endoso_rehab;

		if _error <> 0 then
			return _error, _error_desc || ' Endoso: ' || _no_endoso_rehab,_no_endoso_rehab;
		end if

		call sp_pro43(_no_poliza, _no_endoso_rehab) returning _error, _error_desc;

		if _error <> 0 then
			return _error, _error_desc || ' Endoso: ' || _no_endoso_rehab,_no_endoso_rehab;
		end if

		select no_factura
		  into _no_factura_rehab
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso_rehab;

		update coboutlegh
		   set no_factura_rehab = _no_factura_rehab,
		       decision			= a_decision,
			   comentario		= _comentario
		 where no_documento = a_no_documento;
	end if

	--Endoso de Cancelación por Decisión de la Compañia
	call sp_par342(_no_poliza,a_usuario,0,_cod_sucursal,_cod_tipocan,_fecha_hoy) returning _error, _error_desc, _no_endoso;

	if _error <> 0 then
		return _error, _error_desc,_no_endoso;
	end if

	--Insertando cambio de plan de pago ANC.
	call sp_pro519(_no_poliza,a_usuario,_monto_endoso,_cod_compania,_cod_sucursal,'006') returning _error,_error_desc;

	if _error <> 0 then
		return _error, _error_desc,_no_endoso_rehab;
	end if
	
	delete from coboutleg
	 where no_documento = a_no_documento;
end if

return 0,'Actualización Exitosa',_no_endoso;
end
end procedure 