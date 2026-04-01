-- Proceso que verifica excepciones en la carga de planilla y totaliza la cantida de empleados,cheques,ach y el monto de la cuenta del banco.
-- Creado: 17/07/2012	- Autor: Roman Gordon
 													   
drop procedure sp_rrh03;

create procedure sp_rrh03(a_num_planilla char(10))
returning integer,
		  integer,
          char(100);

define _cedula_emp		varchar(30);
define _num_ach			varchar(10);
define _error_desc		char(250);
define _nombre_empleado	char(50);
define _cta_banco		char(15);
define _cuenta			char(15);
define _no_requis		char(10);
define _chequera		char(3);
define _banco			char(3);
define _origen_cheque	char(1);
define _tipo_requis		char(1);
define _cta_recibe		char(1);
define _tot_cta_bco_chq	dec(16,2);
define _tot_cta_bco_ach dec(16,2);
define _tot_cta_banco	dec(16,2);
define _monto			dec(16,2);
define _error_excep		smallint;
define _cnt_cheque		smallint;
define _error_isam		smallint;
define _excepcion		smallint;
define _coltype			smallint;
define _cnt_ach			smallint;
define _cnt_chq			smallint;
define _cnt_emp			smallint;
define _error			smallint;
define _no_cheque		integer;
define _renglon			integer;
define _tot_reg			integer;
						
--set debug file to "sp_rrh03.trc";
--trace on;

begin
on exception set _error_excep,_error_isam,_error_desc
	return _error_excep,_error_isam,"Error al verificar las Excepciones de la carga. " || _error_desc;
end exception

let _nombre_empleado	= '';
let _error_desc			= '';
let _cedula_emp			= '';
let _num_ach			= '';
let _cuenta				= '';
let _renglon			= 0;
let _error				= 0;
let _no_cheque			= 0;
let _excepcion			= 0;
let _monto				= 0.00;
let	_tot_cta_bco_chq	= 0.00;
let	_tot_cta_bco_ach	= 0.00;
let _tot_cta_banco		= 0.00;
let _origen_cheque		= "P";
let _tipo_requis		= 'C';
let _chequera			= "013";
let _banco				= "001";

-------------Verificacion de Excepciones en la carga----------------

select count(*)
  into _tot_reg
  from chqpaydet
 where num_planilla = a_num_planilla;
																								  
foreach
	select nombre_empleado, 
		   cedula_emp,
		   num_ach,
		   cuenta,
		   renglon,
		   no_cheque,
		   monto				
	  into _nombre_empleado,
		   _cedula_emp,
		   _num_ach,
		   _cuenta,
		   _renglon,
		   _no_cheque,
		   _monto				
	  from chqpaydet
	 where num_planilla = a_num_planilla
	 
	if (_no_cheque is null or _no_cheque = '') and (_num_ach is null or _num_ach = '') then
		let _error_desc = 'Falta No. Cheque o No. ACH';
		let _error = 1;
		let _excepcion = 1;
	else
		select count(*)
		  into _cnt_cheque
		  from chqchmae
		 where cod_banco	= _banco
		   and cod_chequera	= _chequera
		   and tipo_requis	= _tipo_requis
		   and no_cheque	= _no_cheque;

		if _cnt_cheque > 0 then
			foreach
				select no_requis
				  into _no_requis
				  from chqchmae
				 where cod_banco	= _banco
				   and cod_chequera	= _chequera
				   and tipo_requis	= _tipo_requis
		   		   and no_cheque	= _no_cheque
				exit foreach;
			end foreach

			let _error_desc = 'El Cheque #' || _no_cheque || ' ya fue utilizado en la requisión #' || _no_requis;
			let _error = 1;
			let _excepcion	= 1;
		end if
	end if

	if _nombre_empleado is null or _nombre_empleado = '' then
		if _error = 0 then
			let _error_desc = 'Falta capturar el nombre del empleado';
			let _error = 1;
		else
			let _error_desc = trim(_error_desc) || ', falta capturar el nombre del empleado';
		end if
		let _excepcion = 1;
	end if
	
	--if _cedula_emp = '9-130-974' then
	--else
		if _monto = 0.00 then
			if _error = 0 then
				let _error_desc = 'El monto del movimiento no puede ser cero (0)';
				let _error = 1;
			else
				let _error_desc = trim(_error_desc) || ', el monto del movimiento no puede ser cero (0)';
			end if
			let _excepcion = 1;
		end if
	--end if
	
	if _cuenta is null or _cuenta = '' then
		if _error = 0 then
			let _error_desc = 'Falta capturar la cuenta a afectar';
			let _error = 1;
		else
			let _error_desc = trim(_error_desc) || ', falta capturar la cuenta a afectar';
		end if
		let _excepcion = 1;
	else
		select cta_recibe
		  into _cta_recibe
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cta_recibe = 'N' then
			if _error = 0 then
				let _error_desc = 'La Cuenta #' || trim(_cuenta) || ' no recibe movimientos';
				let _error = 1;
			else
				let _error_desc = trim(_error_desc) || ', La Cuenta #' || trim(_cuenta) || ' no recibe movimientos';
			end if
			let _excepcion = 1;	
		end if
	end if

	if _cedula_emp is null or _cedula_emp = '' then
		if _error = 0 then
			let _error_desc = 'Falta capturar la cédula del empleado';
			let _error = 1;
		else
			let _error_desc = trim(_error_desc) || ', falta capturar la cédula del del empleado';
		end if
		let _excepcion = 1;
	end if
	
	if _error <> 0 then 
		update chqpaydet
		   set error		= _error,
		   	   error_desc	= _error_desc
		 where num_planilla	= a_num_planilla
		   and renglon		= _renglon;
	end if

	let _error = 0;
	let _error_desc = '';

	return 1,_tot_reg,'' with resume;

end foreach

if _excepcion = 1 then
	update chqpayasien
	   set error = 1
	 where num_planilla = a_num_planilla;
end if	

-------------Totalizacion de la carga----------------

select cta_banco
  into _cta_banco
  from chqpayasien
 where num_planilla = a_num_planilla;

select count(distinct cod_empleado)
  into _cnt_emp
  from chqpaydet
 where num_planilla = a_num_planilla;

select sum(abs(monto))
  into _tot_cta_banco													 
  from chqpaydet														 
 where num_planilla = a_num_planilla									 
   and cuenta		= _cta_banco;

select count(distinct cod_empleado)
  into _cnt_chq
  from chqpaydet
 where num_planilla = a_num_planilla
   and no_cheque <> 0 
   and no_cheque is not null;

select count(distinct cod_empleado)
  into _cnt_ach
  from chqpaydet
 where num_planilla = a_num_planilla
   and num_ach <> '' 
   and num_ach is not null;

select sum(abs(monto))
  into _tot_cta_bco_ach
  from chqpaydet
 where num_planilla = a_num_planilla
   and num_ach		<> '' 
   and num_ach 		is not null
   and cuenta		= _cta_banco;

select sum(abs(monto))
  into _tot_cta_bco_chq
  from chqpaydet
 where num_planilla = a_num_planilla
   and no_cheque 	<> 0 
   and no_cheque 	is not null
   and cuenta		= _cta_banco;

update chqpayasien
   set cant_emp			= _cnt_emp,
	   cant_cheq		= _cnt_chq,
	   cant_ach			= _cnt_ach,
	   tot_cta_bco		= _tot_cta_banco,
	   tot_cta_bco_chq	= _tot_cta_bco_chq,
	   tot_cta_bco_ach	= _tot_cta_bco_ach
 where num_planilla = a_num_planilla;

return 0,_tot_reg,'Verificacion de Exepciones exitosa';
end
end procedure


	