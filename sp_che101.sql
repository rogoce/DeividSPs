-- Impresion del Cheque	*** nuevo formato de cheques contables ***
--
-- Creado    : 09/07/2008 - Igual al sp_che01 - Autor: Lic. Amado Perez
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 17/01/2007 - Autor: Demetrio Hurtadi Almanza
               -- Se hizo una rutina aparte para los registros contables.
--Modificado : 11/05/2011 retornar tel de cliente cuando es devolucion de prima proveniente de evaluacion. Armando Moreno.
--
-- SIS v.2.0 d_- DEIVID, S.A.

drop procedure sp_che101;

create procedure sp_che101(a_compania char(3), a_agencia char(3), a_usuario char(8), a_cod_banco char(3), a_cod_chequera char(3), a_no_requis char(10)) 
returning   date,
			varchar(100),
		    decimal(16,2), 
			char(250),
		    date,
			integer,
			char(3),
			char(3),
			char(8),
			char(3),
			char(3),
			char(10),
			char(8),
			char(8),
			date,
			date,
			date,
			char(35),
			char(35),
			char(50),
			varchar(20),
			varchar(20),
			char(30),
			char(30),
			datetime year to fraction(5),
			datetime year to fraction(5),
			datetime year to fraction(5),
			char(1);

define v_a_nombre_de		varchar(100);
define _firma1				varchar(20);
define _firma2				varchar(20);
define v_monto_letras		char(250);
define _error_desc			char(50);
define v_corredor			char(50);
define v_telefono3			char(35);
define v_telefono			char(35);
define _nombre1				char(30);
define _nombre2				char(30);
define _cuenta				char(25);
define _enlace_cta			char(20);
define _cod_cliente_dev		char(10);
define _cod_proveedor		char(10);
define _cod_cliente			char(10);
define _transaccion			char(10);
define _no_reclamo			char(10);
define v_telefono1			char(10);
define v_telefono2			char(10);
define _no_poliza			char(10);
define _no_requis			char(10);
define _tel_pag1			char(10);
define _tel_pag2			char(10);
define _cel_pag				char(10);
define _aut_workflow_user	char(8);
define _usuario_imp			char(8);
define _user_added			char(8);
define _periodo				char(7);
define _cod_agente			char(5);
define _ano_char			char(4);
define _cod_tipopago		char(3);
define _cod_origen			char(3);
define _mes_char			char(2);
define _origen_cheque		char(1);
define _monto_disponible	dec(16,2);
define _monto_asignado		dec(16,2);
define v_monto				dec(16,2);
define _cta_chequera		smallint;
define _ctrl_flujo			smallint;
define _enfirma				smallint;
define _renglon				smallint;
define _no_cheque			integer;
define _error				integer;
define _aut_workflow_fecha	date;
define _fecha_captura		date;
define _fecha_firma1		datetime year to fraction(5);
define _fecha_firma2		datetime year to fraction(5);
define _fecha_paso_firma	datetime year to fraction(5);
define _numrecla            char(20);

--define _hora_imp         datetime hour to fraction(5);

if a_no_requis = '773927' then
	SET DEBUG FILE TO "sp_che101.trc";
	TRACE ON;
end if

-- Lectura del Numero de Cheque
set isolation to dirty read;

if  month(today) < 10 then
	let _mes_char = '0'|| month(today);
else
	let _mes_char = month(today);
end if

let _ano_char = year(today);
let _periodo  = _ano_char || "-" || _mes_char;
let _cod_cliente_dev = null;
let _usuario_imp     = "";

let v_corredor   = null;
let v_telefono   = null;
let v_telefono3  = null;
let _ctrl_flujo   = 0;
let _error = 0;
let _no_cheque = 0;

select cont_no_cheque,
	   monto_disponible,
	   monto_asignado,
	   control_flujo
  into _no_cheque,
	   _monto_disponible,
	   _monto_asignado,
	   _ctrl_flujo
  from chqchequ
 where cod_banco    = a_cod_banco
   and cod_chequera = a_cod_chequera;

if _no_cheque is null then
	let _no_cheque = 0;
end if

-- Lectura del Origen del Banco para el Enlace de Cuentas 
  	
select cod_origen,
	   cta_chequera
  into _cod_origen,
	   _cta_chequera
  from chqbanco
 where cod_banco = a_cod_banco;

-- inicio de la impresion de cheques

 select en_firma
   into _enfirma
   from chqchmae
  where no_requis = a_no_requis;

let _usuario_imp = a_usuario;

if _enfirma = 2 then
	let a_usuario = "%"; --firmado
end if


select a_nombre_de,
	   monto,
	   no_requis,
	   origen_cheque,
	   user_added,
	   aut_workflow_user,
	   fecha_captura,
	   aut_workflow_fecha,
	   firma1,
	   firma2,
	   fecha_firma1,
	   fecha_firma2,
	   fecha_paso_firma,
	   cod_cliente
  into v_a_nombre_de,
	   v_monto,
	   _no_requis,
	   _origen_cheque,
	   _user_added,
	   _aut_workflow_user,
	   _fecha_captura,
	   _aut_workflow_fecha,
	   _firma1,
	   _firma2,
	   _fecha_firma1,
	   _fecha_firma2,
	   _fecha_paso_firma,
	   _cod_cliente_dev
  from chqchmae
 where cod_compania   = a_compania
   and autorizado     = 1
   and pagado         = 0
--   and autorizado_por like a_usuario
   and cod_banco      = a_cod_banco
   and cod_chequera   = a_cod_chequera
   and tipo_requis    = "C"
   and no_requis      = a_no_requis;

	-- actualizacion del maestro de cheques

if _enfirma = 2 then
	let a_usuario = _usuario_imp;
end if

update chqchmae
   set fecha_impresion = today,
	   pagado          = 1,	
	   no_cheque       = _no_cheque,
	   periodo         = _periodo,
	   hora_impresion  = current,
	   autorizado_por  = a_usuario
 where no_requis       = _no_requis;

let v_telefono  = null;
let	v_telefono3 = null;
let	v_corredor	= null;

-- registros contables

call sp_par276(a_no_requis, _origen_cheque) returning _error, _error_desc;

if _error <> 0 then
	if _error > 0 then
		let _error = -1;
	end if

	return  today,
			_error_desc,
			0,
			"",
			TODAY,
			_error,
			"",
			"",
			"",
			"", 		   
			"", 		   
			"",			   
			"",			   
			"",			   
			today,		   
			today,		   
			today,		   
			"",			   
			"",			   
			"",			   
			"",			   
			"",			   
			"",			   
			"",			   
			current,	   
			current,	   
			current,
			"";
end if

-- Actualizacion de los Cheques de Devolucion de Primas	
if _origen_cheque = '6' then
	begin
	define _doc_poliza		char(20);
	define _no_poliza		char(10);
	define _prima_neta      dec(16,2);

	foreach
		select no_poliza,
			   monto,
			   no_documento
		  into _no_poliza,
			   _prima_neta,
			   _doc_poliza
		  from chqchpol
		 where	no_requis = _no_requis

		update emipomae
		   set saldo     = saldo + _prima_neta
		 where no_poliza = _no_poliza;
	end foreach
	end
end if

if _origen_cheque = 'S' or _origen_cheque = 'K' then
	if _cod_cliente_dev is not null then
		select telefono1,
			   telefono2,
			   celular
		  into _tel_pag1,
			   _tel_pag2,
			   _cel_pag
		  from cliclien
		 where cod_cliente = _cod_cliente_dev;

		if _tel_pag1 is null and _tel_pag2 is null and _cel_pag is null then
			let v_telefono = "";
		elif _tel_pag2 is null and _cel_pag is null then
			let v_telefono = _tel_pag1;
		elif _tel_pag2 is null and _tel_pag1 is null then
			let v_telefono = _cel_pag;
		elif _tel_pag1 is null and _cel_pag is null then
			let v_telefono = _tel_pag2;
		elif _tel_pag1 is null then
			let v_telefono = _tel_pag2 || " / " || _cel_pag;
		elif _tel_pag2 is null then
			let v_telefono = _tel_pag1 || " / " || _cel_pag;
		elif _cel_pag is null then
			let v_telefono =_tel_pag1 || " / " || _tel_pag2;
		else
			let v_telefono = _tel_pag1 || " / " || _tel_pag2 || " / " || _cel_pag;
		end if

		let v_telefono  = trim(v_telefono);
	end if		
end if

-- Actualizacion para los Cheques de Reclamos
if _origen_cheque = '3' then
	begin
	define _fecha_transac date;
	define _fecha_param   date;
	define _monto_transac dec(16,2);
	define _debito        dec(16,2);
	define _credito       dec(16,2);

	let _monto_transac = 0.00;

	select sum(monto)
	  into _monto_transac
	  from chqchrec
	 where no_requis = _no_requis;

	if _monto_transac <> v_monto then
		let v_monto = _monto_transac;

		update chqchmae
		   set monto     = v_monto
		 where no_requis = _no_requis;

	end if
	end 

	--******** tel de asegurado, tel y  nombre de corredor, tel de provvedor.

	foreach
		select transaccion,
		       numrecla
		  into _transaccion,
		       _numrecla
		  from chqchrec
		 where no_requis = _no_requis
	 exit foreach;
	end foreach

	foreach
		select cod_tipopago,
			   cod_cliente,
			   cod_proveedor,
			   no_reclamo
		  into _cod_tipopago,
			   _cod_cliente,
			   _cod_proveedor,
			   _no_reclamo
		  from rectrmae
		 where transaccion = _transaccion
		   and actualizado = 1
		exit foreach;
	end foreach

	if _cod_tipopago = '001' then	--pago proveedor
		select telefono1,
			   telefono2,
			   celular
		  into _tel_pag1,
			   _tel_pag2,
			   _cel_pag
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _tel_pag1 is null and _tel_pag2 is null and _cel_pag is null then
			let v_telefono = "";
		elif _tel_pag2 is null and _cel_pag is null then
			let v_telefono = _tel_pag1;
		elif _tel_pag2 is null and _tel_pag1 is null then
			let v_telefono = _cel_pag;
		elif _tel_pag1 is null and _cel_pag is null then
			let v_telefono = _tel_pag2;
		elif _tel_pag1 is null then
			let v_telefono = _tel_pag2 || " / " || _cel_pag;
		elif _tel_pag2 is null then
			let v_telefono = _tel_pag1 || " / " || _cel_pag;
		elif _cel_pag is null then
			let v_telefono =_tel_pag1 || " / " || _tel_pag2;
		else
			let v_telefono  = _tel_pag1 || " / " || _tel_pag2 || " / " || _cel_pag;
		end if

		let v_telefono  = trim(v_telefono);
		let v_corredor  = "";
		let v_telefono3 = "";
	end if

	if _cod_tipopago = '003'then	--pago asegurado
		if _cod_cliente is not null then
			select telefono1,
				   telefono2,
				   celular
			  into _tel_pag1,
				   _tel_pag2,
				   _cel_pag
			  from cliclien
			 where cod_cliente = _cod_cliente;

			if _tel_pag1 is null and _tel_pag2 is null and _cel_pag is null then
				let v_telefono = "";
			elif _tel_pag2 is null and _cel_pag is null then
				let v_telefono = _tel_pag1;
			elif _tel_pag2 is null and _tel_pag1 is null then
				let v_telefono = _cel_pag;
			elif _tel_pag1 is null and _cel_pag is null then
				let v_telefono = _tel_pag2;
			elif _tel_pag1 is null then
				let v_telefono = _tel_pag2 || " / " || _cel_pag;
			elif _tel_pag2 is null then
				let v_telefono = _tel_pag1 || " / " || _cel_pag;
			elif _cel_pag is null then
				let v_telefono =_tel_pag1 || " / " || _tel_pag2;
			else
				let v_telefono  = _tel_pag1 || " / " || _tel_pag2 || " / " || _cel_pag;
			end if

			let v_telefono  = trim(v_telefono);
		end if

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1;

		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			exit foreach;
		end foreach

		select nombre,
			   telefono1,
			   telefono2	
		  into v_corredor,
			   v_telefono1,
			   v_telefono2
		  from agtagent
		 where cod_agente = _cod_agente;

		if v_telefono1 is null and v_telefono2 is null then
			let v_telefono3 = "";
		elif v_telefono2 is null then
			let v_telefono3 = v_telefono1;
		elif v_telefono1 is null then
			let v_telefono3 = v_telefono2;
		else
			let v_telefono3  = v_telefono1 || " / " || v_telefono1;
		end if
		let v_telefono3  = trim(v_telefono3);
	end if
	
	if _cod_tipopago = '004' then	--pago a tercero
		select telefono1,
			   telefono2,
			   celular
		  into _tel_pag1,
			   _tel_pag2,
			   _cel_pag
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _tel_pag1 is null and _tel_pag2 is null and _cel_pag is null then
			let v_telefono = "";
		elif _tel_pag2 is null and _cel_pag is null then
			let v_telefono = _tel_pag1;
		elif _tel_pag2 is null and _tel_pag1 is null then
			let v_telefono = _cel_pag;
		elif _tel_pag1 is null and _cel_pag is null then
			let v_telefono = _tel_pag2;
		elif _tel_pag1 is null then
			let v_telefono = _tel_pag2 || " / " || _cel_pag;
		elif _tel_pag2 is null then
			let v_telefono = _tel_pag1 || " / " || _cel_pag;
		elif _cel_pag is null then
			let v_telefono =_tel_pag1 || " / " || _tel_pag2;
		else
			let v_telefono  = _tel_pag1 || " / " || _tel_pag2 || " / " || _cel_pag;
		end if

		let v_telefono  = trim(v_telefono);
		let v_corredor  = "";
		let v_telefono3 = "";
	end if
	
	if _enfirma = 2 then
		if _numrecla[1,2] in ('02','20','23') then
			update cheprereq
			   set saldo_real = saldo_real - v_monto,
				   pagado_real = pagado_real + v_monto
			 where anio = year(today)
			   and mes = month(today)
			   and opc = 1;
		elif _numrecla[1,2] in ('04','16','18','19') then
			update cheprereq
			   set saldo_real = saldo_real - v_monto,
				   pagado_real = pagado_real + v_monto
			 where anio = year(today)
			   and mes = month(today)
			   and opc = 2;
		end if	
	end if
end if

{if _ctrl_flujo = 1 then								--control de flujo
	update chqchequ
	   set monto_disponible = monto_disponible + v_monto
	 where cod_banco 	= a_cod_banco
	   and cod_chequera = a_cod_chequera;
end if}

-- Datos del Cheque
if v_corredor is null then
	let v_corredor = "";
end if
if v_telefono is null then
	let v_telefono = "";
end if
if v_telefono3 is null then
	let v_telefono3 = "";
end if

select descripcion
  into _nombre1
  from insuser
 where upper(windows_user) = upper(_firma1);

if _firma2 is null then
	let _nombre2 = "";
else
	select descripcion
	  into _nombre2
	  from insuser
	 where upper(windows_user) = upper(_firma2);
end if

let v_monto_letras = sp_sis11(v_monto);

return  today, 
		v_a_nombre_de,
		v_monto, 
		v_monto_letras,      
		today,
		_no_cheque,
		a_compania, 
		a_agencia, 
		a_usuario, 
		a_cod_banco, 
		a_cod_chequera, 
		_no_requis,
		_user_added,
		_aut_workflow_user,
		_fecha_captura,
		_aut_workflow_fecha,
		today,
		v_telefono,
		v_telefono3,
		v_corredor,
		trim(_firma1),
		trim(_firma2),
		_nombre1,
		_nombre2,
		_fecha_firma1,
		_fecha_firma2,
		_fecha_paso_firma,
		_origen_cheque;

{END FOREACH

-- Actualizacion del Ultimo Numero de Cheque
if _no_cheque2 IS NULL or _no_cheque2 = 0 then
	UPDATE chqchequ
	   SET cont_no_cheque = _no_cheque
	 WHERE cod_banco      = a_cod_banco
	   AND cod_chequera   = a_cod_chequera;
end if}
end procedure;
