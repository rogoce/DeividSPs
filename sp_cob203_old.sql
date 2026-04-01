-- Generacion de los Lotes de las Tarjetas de Credito

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob203;

create procedure "informix".sp_cob203(
a_compania		char(3),
a_sucursal		char(3),
a_fecha			date,
a_periodo		char(1),
a_user			char(8)
) returning smallint,
            char(100);

define _error_desc		char(100);
define _nombre			char(100);
define _mensaje			char(50);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _fecha_exp		char(7);
define _no_lote_char	char(5);
define _codigo          char(2);
define _periodo2        char(1);
define _periodo         char(1);
define _ult_pago        dec(16,2);
define _cargo			dec(16,2);
define _monto			dec(16,2);
define _saldo           dec(16,2);
define _pronto_pago		smallint;
define _error_code      smallint;
define _procesar        smallint;
define _valor			smallint;
define _cnt_dia_esp		smallint;
define _max_por_lote	integer;
define _max_por_tran	integer;
define _cant_tran		integer;
define _cant_lote       integer;
define _error			integer;
define _dia_especial	smallint;
define _rechazada		smallint;
define _dia				smallint;
define _fecha_inicio	date;
define _fecha_hasta     date;
define _fecha_hoy		date;
define v_fecha          date;
define v_periodo        char(7);
define _dif             decimal(16,2);
define v_por_vencer		decimal(16,2);
define v_exigible		decimal(16,2);
define v_corriente		decimal(16,2);
define v_monto_30		decimal(16,2);
define v_monto_60		decimal(16,2);
define v_monto_90		decimal(16,2);
define v_saldo			decimal(16,2);


--set debug file to "sp_cob203.trc"; 
--trace on;                                                                

let _max_por_lote = 99;
--let _max_por_tran = 998;    --500;se cambio 14/06/2013

let _max_por_tran = 499;      --se cambio 15/07/2014

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
if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 

call sp_cob338('TCR',_fecha_hoy) returning _error,_error_desc;

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
values(
_no_lote_char,
a_fecha,
0,
0,
a_user,
'',
a_sucursal,
1,null,0.00,today      
);	

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

	--esto es para el cargo adicional.
	{if _periodo2 is null then
		let _periodo2 = "0";
	end if}

	{if _fecha_hasta is not null then
		if _fecha_hasta > _fecha_hoy then  -- tiene cargo adicional
			if _periodo = _periodo2 then   -- se debe sumar el cargo al monto
				let _monto = _monto + _cargo;
			else
				if a_periodo = _periodo2 then
					if _cargo > 0 then
						let _monto = _cargo;
					end if
				end if
			end if
		end if
	end if}
	
	if _fecha_hasta is not null then
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
	end if

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
		values(
		_no_lote_char,
		a_fecha,
		0,
		0,
		a_user,
		'               ',
		a_sucursal,
		1,null,0.00,today     
		);
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

	insert into cobtatra
	values(
	_no_lote_char,
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
	_pronto_pago);
end foreach

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

return 0, 'Actualizacion Exitosa ...'; 

end
end procedure;