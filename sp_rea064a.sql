-- Procedimiento que disminuye la reserva del reclamo y la aumenta al monto original pero con la nueva distribución de Reaseguro
-- Creado    : 13/02/2017 - Autor: Román Gordón
--execute procedure sp_rea064a(a_numrecla char(18), 'DEIVID')

drop procedure sp_rea064a;
create procedure sp_rea064a(a_numrecla char(18), a_usuario char(8))
returning	integer,
            varchar(250);

define _error_desc			varchar(250);
define _valor_parametro2	char(20);
define _valor_parametro 	char(20);
define _no_tranrec_char2    char(10);
define _no_tranrec_char 	char(10); 
define _no_tran_char    	char(10); 
define _no_reclamo			char(10); 
define _cod_cliente     	char(10); 
define _no_poliza           char(10);
define _periodo_rec     	char(7);
define _cod_cobertura   	char(5);
define _cod_sucursal		char(3);
define _cod_compania		char(3);
define _aplicacion	    	char(3);
define _cod_ramo            char(3);
define _version		    	char(2);
define _porc_partic_cont	dec(9,6);
define _porc_partic_ret		dec(9,6);
define _reserva_contrato	dec(16,2);
define _reserva_actual      dec(16,2);
define _reserva_neta		dec(16,2);
define _reserva_cob			dec(16,2);
define _reserva_var			dec(16,2);
define _error_isam			integer;
define _error				integer;
define _fecha_no_server  	date;

set isolation to dirty read;

--set debug file to 'sp_rea064a.trc';
--trace on;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _aplicacion = 'REC';
let _version = '02';
let _reserva_actual = 0;
let _reserva_neta   = 0;
let _reserva_cob    = 0;
let _reserva_var    = 0;

select cod_compania,
       cod_sucursal,
	   cod_asegurado,
	   no_poliza,
	   no_reclamo
  into _cod_compania,
       _cod_sucursal,
	   _cod_cliente,
	   _no_poliza,
	   _no_reclamo
  from recrcmae
 where numrecla = a_numrecla;

select reserva_bruta,
	   reserva_act_ret,
	   reserva_act_cont
  into _reserva_actual,
	   _reserva_neta,
	   _reserva_contrato
  from deivid_tmp:recpentra
 where numrecla = a_numrecla
   and serie = 2015;

if _reserva_actual = 0 then
	if _reserva_neta < 0 then
		let _reserva_actual = _reserva_contrato;
		let _reserva_neta = _reserva_contrato;
		let _reserva_contrato = 0.00;
	else
		let _reserva_actual = _reserva_neta;
		let _reserva_contrato = _reserva_neta;
		let _reserva_neta = 0.00;
	end if
end if

-- Asignacion del Numero Interno y Externo de Transacciones
let _no_tran_char    = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);
let _no_tranrec_char = sp_sis13('001', _aplicacion, _version, 'par_tran_genera');

let _fecha_no_server = '02/06/2018';
let _periodo_rec     = '2018-06';

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
		'003',
		null,
		null,
		null,
		null,
		a_numrecla,
		_fecha_no_server,
		0,
		_no_tran_char,
		0,
		0,
		0,
		_periodo_rec,
		0,
		_reserva_actual,
		_reserva_actual * -1,
		0,
		1,
		a_usuario);

-- Insercion de las Coberturas (Transacciones)
foreach
	select sum(r.variacion),
		   r.cod_cobertura
	  into _reserva_cob,
		   _cod_cobertura		  
	  from rectrcob r, rectrmae t
	 where r.no_tranrec = t.no_tranrec
	   and t.no_reclamo = _no_reclamo
	   and t.actualizado = 1
	   and t.periodo <= '2018-05'
	 group by r.cod_cobertura
	having sum(r.variacion) <> 0
		
	insert into rectrcob(
			no_tranrec,
			cod_cobertura,
			monto,
			variacion)
	values(	_no_tranrec_char,
			_cod_cobertura,
			_reserva_cob,
			_reserva_cob * -1);
end foreach
        
-- Reaseguro a Nivel de Transaccion
call sp_sis58(_no_tranrec_char) returning _error, _error_desc;

let _porc_partic_ret = (_reserva_neta / _reserva_actual) * 100;
let _porc_partic_cont = (_reserva_contrato / _reserva_actual) * 100;

update rectrrea
   set porc_partic_prima = _porc_partic_ret,
	   porc_partic_suma = _porc_partic_ret
 where no_tranrec = _no_tranrec_char
   and tipo_contrato = 1;

update rectrrea
   set porc_partic_prima = _porc_partic_cont,
	   porc_partic_suma = _porc_partic_cont
 where no_tranrec = _no_tranrec_char
   and tipo_contrato = 5;

delete from rectrrea
 where no_tranrec = _no_tranrec_char
   and porc_partic_prima = 0.00;

update deivid_tmp:recpentra
   set transaccion_dism = _no_tran_char
 where numrecla = a_numrecla;

--Realizar Transaccion de Aumento de reserva
let _no_tranrec_char2 = _no_tranrec_char;
let _no_tran_char     = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);
let _no_tranrec_char  = sp_sis13(_cod_compania, _aplicacion, _version, 'par_tran_genera');

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
		'002',
		null,
		null,
		null,
		null,
		a_numrecla,
		_fecha_no_server,
		0,
		_no_tran_char,
		0,
		1,
		0,
		_periodo_rec,
		1,
		_reserva_actual,
		_reserva_actual,
		0,
		1,
		a_usuario);

foreach
	select cod_cobertura,
		   monto,
		   variacion * -1
	  into _cod_cobertura,
		   _reserva_cob,
		   _reserva_var
	  from rectrcob
	 where no_tranrec = _no_tranrec_char2

	insert into rectrcob(
			no_tranrec,
			cod_cobertura,
			monto,
			variacion)
	values(	_no_tranrec_char,
			_cod_cobertura,
			_reserva_cob,
			_reserva_var);
end foreach

      
--Cambiar recreaco
call sp_rea065(_no_reclamo) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if		

-- Reaseguro a Nivel de Transaccion
call sp_sis58(_no_tranrec_char) returning _error, _error_desc;

update deivid_tmp:recpentra
   set transaccion_aum = _no_tran_char
 where numrecla = a_numrecla;

end
return 0, 'Actualizacion Exitosa';

end procedure;