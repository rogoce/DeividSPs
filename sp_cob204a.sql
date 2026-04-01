-- Generacion de los Lotes de las Tarjetas de Credito American

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/02/2007 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob204;

create procedure "informix".sp_cob204(
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
define v_por_vencer		dec(16,2);
define v_corriente		dec(16,2);
define v_exigible		dec(16,2);
define v_monto_30		dec(16,2);
define v_monto_60		dec(16,2);
define v_monto_90		dec(16,2);
define _ult_pago        dec(16,2);
define v_saldo			dec(16,2);
define _monto			dec(16,2);
define _saldo           dec(16,2);
define _cargo			dec(16,2);
define _dif             dec(16,2);
define _dia_especial	smallint;
define _pronto_pago		smallint;
define _cnt_dia_esp		smallint;
define _error_code      smallint;
define _procesar        smallint;
define _ramo_sis		smallint;
define _valor			smallint;
define _max_por_lote	integer;
define _max_por_tran	integer;
define _cant_tran		integer;
define _cant_lote       integer;
define _fecha_inicio	date;
define _fecha_hasta     date;
define _fecha_hoy		date;
define v_fecha          date;


--set debug file to "sp_cob204.trc";
--trace on ;

let _max_por_lote = 99;
let _max_por_tran = 998; --se cambio 14/06/2013 
--let _max_por_tran = 499; --se cambio 15/07/2014
let _codigo       = '40';
let _mensaje      = "";
let _periodo2     = null;

begin
on exception set _error_code 
 	return _error_code, 'error al actualizar los lotes';
end exception           

let v_fecha       = today;
if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 

select count(*)
  into _cant_tran
  from cobtacre
 where procesar = 1;

if _cant_tran is null then
	let _cant_tran = 0; 
end if

if _cant_tran = 0 then
	return 1, 'No Existen Tarjetas para Procesar en esta Quincena ... '; 
end if

if _cant_tran > (_max_por_lote * _max_por_tran) then
	return 1, 'Cantidad de Transacciones Excede el Maximo Permitido por el Banco ...'; 
end if

delete from cobtatra;
delete from cobtalot;

let _fecha_hoy    = today;

call sp_cob338('AME',_fecha_hoy) returning _error_code,_error_desc;

if _error_code <> 0 then
	return _error_code,_error_desc;
end if

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

-- Procesa Todas las Tarjetas de Credito
foreach
	select h.no_tarjeta,
		   c.monto,
		   c.cargo_especial,
		   h.fecha_exp,
		   c.no_documento,
		   h.nombre,
		   c.fecha_inicio,
		   c.fecha_hasta,
		   c.dia_especial
	  into _no_tarjeta,
		   _monto,
		   _cargo,
		   _fecha_exp,
		   _no_documento,
		   _nombre,
		   _fecha_inicio,
		   _fecha_hasta,
		   _dia_especial
	  from cobtacre c, cobtahab h
	 where c.no_tarjeta = h.no_tarjeta
	   and c.procesar   = 1
	   and h.tipo_tarjeta = "4"
	 order by h.nombre
	
	call sp_sis21(_no_documento) returning _no_poliza;
	
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

	--Esto es para el cargo adicional.
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
				else
					let _monto = _cargo;
				end if
			end if
		end if
	end if

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 5 then
		--let _monto = v_saldo;
		if v_exigible <> 0.00 then
			let _monto = v_exigible;
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
	_pronto_pago
	);
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

--Procedure que Carga la Tabla Cobtaban para generar el archivo al banco
call sp_cob294(a_compania,a_sucursal,a_user) returning _error_code, _error_desc;

if _error_code <> 0 then
	return _error_code, _error_desc;
end if

drop table tmp_dias_proceso;

return 0, 'Actualizacion Exitosa ...'; 

end
end procedure;