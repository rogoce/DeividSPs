-- Generacion de los Lotes de las Tarjetas de Credito

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob203;

create procedure "informix".sp_cob203(
a_compania		char(3),
a_sucursal		char(3),
a_fecha			date,
a_user			char(8)
) returning smallint,
            char(100);

define _error_desc		char(100);
define _nombre			char(100);
define _mensaje			char(50);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _no_poliza		char(10);
define _fecha_exp		char(7);
define v_periodo        char(7);
define _no_lote_char	char(5);
define _cod_ramo		char(3);
define _codigo          char(2);
define _periodo2        char(1);
define _periodo         char(1);
define _monto_a_cobrar	dec(16,2);
define v_por_vencer		dec(16,2);
define v_corriente		dec(16,2);
define _prima_neta		dec(16,2);
define v_exigible		dec(16,2);
define v_monto_30		dec(16,2);
define v_monto_60		dec(16,2);
define v_monto_90		dec(16,2);
define _ult_pago        dec(16,2);
define _impuesto		dec(16,2);
define _factor			dec(16,2);
define v_saldo			dec(16,2);
define _cargo			dec(16,2);
define _monto			dec(16,2);
define _saldo           dec(16,2);
define _dif             dec(16,2);
define _tiene_impuesto	smallint;
define _dia_especial	smallint;
define _cnt_dia_esp		smallint;
define _pronto_pago		smallint;
define _error_code      smallint;
define _rechazada		smallint;
define _cnt_dia2		smallint;
define _ramo_sis		smallint;
define _procesar        smallint;
define _cnt_dia			smallint;
define _valor			smallint;
define _dia				smallint;
define _max_por_lote	integer;
define _max_por_tran	integer;
define _cant_tran		integer;
define _cant_lote       integer;
define _error			integer;
define _fecha_inicio	date;
define _fecha_hasta     date;
define _fecha_hoy		date;
define v_fecha          date;
define _fecha_proceso	date;


--set debug file to "sp_cob203.trc"; 
--trace on;                                                                

let _max_por_lote = 99;
let _max_por_tran = 9999; --se cambio de 499 a 9999 16/05/2018

--let _max_por_tran = 499;      --se cambio 15/07/2014

let _fecha_hoy    = today;
let _mensaje      = "";
let _codigo       = '40';
let _dif          = 0.00;

begin
on exception set _error_code 
	drop table tmp_dias_proceso;

 	return _error_code, 'Error al Actualizar los Lotes';         
end exception

let v_fecha       = today;

select max(fecha)
  into _fecha_proceso
  from cobfectar
 where procesado = 2;

if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 

call sp_cob338('TCR',_fecha_proceso) returning _error,_error_desc;

if _error <> 0 then
	return _error,_error_desc;
end if

select count(*)
  into _cant_tran
  from cobtacre c, cobtahab h
 where c.no_tarjeta = h.no_tarjeta
   and c.procesar   = 1
   and h.tipo_tarjeta <> "4";

if _cant_tran is null then
	let _cant_tran = 0; 
end if

if _cant_tran = 0 then
	return 1, 'No Existen Tarjetas para los días a Procesar ... '; 
end if

if _cant_tran > (_max_por_lote * _max_por_tran) then
	return 1, 'Cantidad de Transacciones Excede el Maximo Permitido por el Banco ...'; 
end if

delete from cobtatra;
delete from cobtalot;

let _cant_lote = 0;
let _cant_tran = 0;

let _cant_lote    = _cant_lote + 1;
let _no_lote_char = sp_set_codigo(5, _cant_lote);

-- crea el lote inicial
insert into cobtalot
		(no_lote,
		fecha,
		total_transac,
		total_monto,
		id_operador,
		id_terminal,
		id_oficina,
		procesar,
		fecha_remesa)
values(	_no_lote_char,
		a_fecha,
		0,
		0,
		a_user,
		'',
		a_sucursal,
		1,
		a_fecha);	

let _fecha_hasta = null;

-- procesa todas las tarjetas de credito

foreach
	select h.no_tarjeta,
		   c.monto,
		   c.cargo_especial,
		   c.fecha_hasta,
		   h.fecha_exp,
		   c.fecha_inicio,
		   c.no_documento,
		   h.nombre,
		   c.dia,
		   c.dia_especial,
		   c.rechazada
	  into _no_tarjeta,
		   _monto,
		   _cargo,
		   _fecha_hasta,
		   _fecha_exp,
		   _fecha_inicio,
		   _no_documento,
		   _nombre,
		   _dia,
		   _dia_especial,
		   _rechazada
	  from cobtacre c, cobtahab h
	 where c.no_tarjeta = h.no_tarjeta
	   and c.procesar   = 1
	   and h.tipo_tarjeta <> "4"	--no debe tomar en cuanta las american express.
	 order by h.nombre

	call sp_cob33('001', '001', _no_documento, v_periodo, v_fecha)
	returning   v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_60,
				v_monto_90,
				v_saldo;

	if _monto < v_exigible then
		let _dif = 0;
		let _dif = v_exigible - _monto;
		if _dif <= 1.00 then
			let _monto = v_exigible;
		end if

	end if
	
	{if _fecha_hasta is not null then
		if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
			if _fecha_inicio <= _fecha_hoy then --ok
				
				select count(*)
				  into _cnt_dia_esp
				  from tmp_dias_proceso
				  where dia = _dia;
				
				if _cnt_dia_esp is null then
					let _cnt_dia_esp = 0;
				end if
				
				if _rechazada = 1 then
					let _cnt_dia_esp = 1;
				end if
				
				if _cnt_dia_esp <> 0 then    -- se debe sumar el cargo al monto
					let _monto = _monto + _cargo;
				else
					let _monto = _cargo;
				end if
			end if
		end if
	end if}
	
	select count(*)
	  into _cnt_dia
	  from tmp_dias_proceso
	  where dia = _dia;

	if _cnt_dia is null then
		let _cnt_dia = 0;
	end if

	if _rechazada = 1 then
		let _cnt_dia = 1;
	end if

	if _cnt_dia = 0 then
		if _dia_especial is null then	--Esto es para el cargo adicional.
			let _dia_especial = 0;
		end if

		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok

					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;

					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if
					
					if _cnt_dia_esp > 0 then   -- se debe sumar el cargo al monto
						if _cargo > 0 then
							let _monto = _cargo;
						else
							continue foreach;
						end if
					else
						continue foreach;
					end if
				else
					continue foreach;
				end if
			else
				continue foreach;	
			end if
		else
			continue foreach;
		end if
	else
		--Esto es para el cargo adicional.
		if _dia_especial is null then
			let _dia_especial = 0;
		end if

		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok

					select count(*)
					  into _cnt_dia_esp
					  from tmp_dias_proceso
					  where dia = _dia_especial;

					if _cnt_dia_esp is null then
						let _cnt_dia_esp = 0;
					end if

					if _cnt_dia_esp <> 0 then    -- se debe sumar el cargo al monto
						let _monto = _monto + _cargo;
					end if
				end if
			end if
		end if
	end if

	call sp_sis21(_no_documento) returning _no_poliza;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	{if _ramo_sis = 5 then
		--let _monto = v_saldo;
		--if v_exigible <> 0 then
		--	let _monto = v_exigible;
		--end if-- - v_corriente;
		
		let _cnt_dia2 = 0;
		
		select count(*)
		  into _cnt_dia2
		  from tmp_dias_proceso
		  where dia = _dia;
		
		if _cnt_dia2 is null then
			let _cnt_dia2 = 0;
		end if
		
		if _cnt_dia2 > 0 then
			let _monto = v_saldo;
		end if
		
		if _rechazada = 1 then
			select monto_a_cobrar
			  into _monto_a_cobrar
			  from cobtacre
			 where no_tarjeta = _no_tarjeta
			   and no_documento = _no_documento;
			
			if _monto_a_cobrar is null then
				let _monto_a_cobrar = 0.00;
			end if
			
			if _monto_a_cobrar <> 0 then
				let _monto = _monto_a_cobrar;
			end if
		end if
	end if}

 	select sum(saldo)                   
 	  into _saldo                       
 	  from emipomae                     
 	 where no_documento = _no_documento 
 	   and actualizado  = 1;            

	if _saldo is null then
		let _saldo = 0;
	end if

	let _procesar = 1;              
	let _cant_tran = _cant_tran + 1;

	if _cant_tran > _max_por_tran then
		let _cant_tran    = 1;
		let _cant_lote    = _cant_lote + 1;
		let _no_lote_char = sp_set_codigo(5, _cant_lote);

		insert into cobtalot
				(no_lote,
				fecha,
				total_transac,
				total_monto,
				id_operador,
				id_terminal,
				id_oficina,
				procesar,
				fecha_remesa)
		values(	_no_lote_char,
				a_fecha,
				0,
				0,
				a_user,
				'               ',
				a_sucursal,
				1,
				a_fecha);
	end if

	let _ult_pago    = 0;
	let _pronto_pago = 0;
	call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;

	if _valor = 0 then
		let _pronto_pago = 1;
		let _monto       = _ult_pago;
	else
		let _pronto_pago = 0;		
	end if
	
	-- Impuestos de la poliza 16/08/2016
	let _tiene_impuesto = 0;

	select tiene_impuesto
	  into _tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza;

	if _tiene_impuesto = 1 then
		select sum(i.factor_impuesto)
		  into _factor
		  from prdimpue i, emipolim p
		 where i.cod_impuesto = p.cod_impuesto
		   and p.no_poliza = _no_poliza;

		if _factor is null then
			let _factor = 0;
		end if

		let _factor = 1 + _factor / 100;
		let _prima_neta = _monto / _factor;
		let _impuesto = _monto - _prima_neta;
	else
		let _prima_neta = _monto;
		let _impuesto = 0.00;
	end if

	insert into cobtatra(
			no_lote,
			renglon,
			no_tarjeta,
			codigo,
			monto,
			fecha_exp,
			no_documento,
			nombre,
			saldo,
			procesar,
			motivo_rechazo,
			pronto_pago,
			prima_neta,
			impuesto)
	values(	_no_lote_char,
			_cant_tran,
			_no_tarjeta,
			_codigo,
			_monto,
			_fecha_exp,
			_no_documento,
			_nombre,
			_saldo,
			_procesar,
			'',
			_pronto_pago,
			_monto, --_prima_neta,
			0.00);
end foreach

--set debug file to "sp_cob203.trc"; 
--trace on;   
foreach
	select count(*),
		   sum(monto),
		   no_lote
	  into _cant_tran,
		   _monto,
		   _no_lote_char
	  from cobtatra
	 group by no_lote

	update cobtalot
	   set total_transac = _cant_tran,
	       total_monto   = _monto
     where no_lote       = _no_lote_char;
end foreach

drop table tmp_dias_proceso;

--Procedure que Carga la Tabla Cobtaban para generar el archivo al banco
call sp_cob293(a_compania,a_sucursal,a_user) returning _error_code, _error_desc;

if _error_code <> 0 then
	return _error_code, _error_desc;
end if

return 0, 'Actualizacion Exitosa ...';

end
end procedure;