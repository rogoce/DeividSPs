-- Procedimiento que segmenta  la información de los archivos de TCR y ACH
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob340;
create procedure "informix".sp_cob340(a_proceso char(3),a_tipo_info char(1), a_info varchar(200)) 
returning	varchar(50),	--1
			varchar(50),	--2
			varchar(50),	--3
			varchar(50),	--4
			varchar(50),	--5
			varchar(50),	--6
			varchar(50),	--7
			varchar(50),	--8
			varchar(50),	--9
			varchar(50),	--10
			varchar(50),	--11
			varchar(50),	--12
			varchar(50),	--13
			varchar(50),	--14
			varchar(50),	--15
			varchar(50);	--16

define _desc_rechazo		varchar(50);
define _nom_cliente			varchar(50);
define _desc_error			varchar(50);
define _no_afiliacion		varchar(20);
define _no_tarjeta			varchar(20);
define _monto_aprobado		varchar(15);
define _retrefno			varchar(12);
define _hora_aprobacion		varchar(10);
define _tipo_tarjeta		varchar(10);
define _invoice				varchar(10);
define _authid				varchar(10);
define _stan				varchar(10);
define _fecha_aprobacion	varchar(8);
define _cod_rechazo			varchar(5);
define _no_lote				varchar(5);
define _renglon				varchar(5);
define _fecha_exp			varchar(5);

set isolation to dirty read;

--set debug file to "sp_cob340.trc";
--trace on ;


let _fecha_aprobacion	= '';
let _hora_aprobacion	= '';
let _monto_aprobado		= '0';
let _no_afiliacion		= '';
let _tipo_tarjeta		= '';
let _desc_rechazo		= '';
let _cod_rechazo		= '';
let _desc_error			= '';
let _no_tarjeta			= '';
let _fecha_exp			= '';
let _retrefno			= '';
let _no_lote			= '';
let _renglon			= '';
let _invoice			= '';
let _authid				= '';
let _stan				= '';

if a_proceso = 'TCR' then
	if a_tipo_info = 'A' then	--Aprobadas

		let _no_afiliacion = a_info[1,15];
		let _tipo_tarjeta = a_info[16,25];
		let _no_tarjeta = a_info[26,44];
		let _retrefno = a_info[45,56];
		let _invoice = a_info[57,62];
		let _stan = a_info[63,68];
		let _fecha_aprobacion = a_info[69,76];
		let _hora_aprobacion = a_info[77,82];
		let _authid = a_info[83,88];
		let _monto_aprobado = a_info[89,102];
		let _no_lote = a_info[103,107];
		let _renglon = a_info[108,110];

	elif a_tipo_info = 'E' then	--Errores

		let _no_tarjeta = a_info[1,19];
		let _fecha_exp	= a_info[20,23];
		let _monto_aprobado = a_info[24,41];
		let _no_lote = a_info[42,46];
		let _renglon = a_info[47,59];
		let _desc_error = trim(a_info[60,200]);

	elif a_tipo_info = 'R' then	--Rechazos

		let _no_afiliacion = a_info[1,15];
		let _tipo_tarjeta = a_info[16,25];
		let _no_tarjeta = a_info[26,44];
		let _fecha_aprobacion = a_info[45,52];
		let _cod_rechazo = a_info[53,54];
		let _monto_aprobado = a_info[55,66];
		let _no_lote = a_info[67,71];
		let _renglon = a_info[72,84];
		let _desc_rechazo = trim(a_info[85,200]);
	elif a_tipo_info = 'N' then	--No Procesados
	elif a_tipo_info = 'B' then	--Archivo al Banco
		let _no_tarjeta = a_info[1,19];
		let _fecha_exp = a_info[20,23];
		let _monto_aprobado = a_info[24,41];
		let _no_lote = a_info[42,46];
		let _renglon = a_info[47,49];		
	end if
elif a_proceso = 'ACH' then
	let _invoice = a_info[1,1];
	
	if a_tipo_info = 'R' then		
		if _invoice = 'T' then
			let _no_tarjeta =trim(a_info[12,28]);
			let _monto_aprobado	=trim(a_info[29,44]);
			let _renglon =trim(a_info[45,50]);
			let _desc_rechazo =trim(a_info[60,85]);
		end if
	elif a_tipo_info = 'B' then		
		if _invoice = 'L' then
			let _renglon =trim(a_info[2,16]);
			let _desc_rechazo =trim(a_info[17,38]); 
			let _monto_aprobado	=trim(a_info[39,49]); 
			let _authid =trim(a_info[50,58]); 
			let _no_tarjeta =trim(a_info[59,75]); 
			let _cod_rechazo =trim(a_info[76,76]); 
			let _stan =trim(a_info[77,77]); 
		end if
	end if

	if _invoice = 'A' then
		let _desc_rechazo = a_info[1,40];
	end if
end if

return	_no_afiliacion,
		_tipo_tarjeta,
		_no_tarjeta,
		_retrefno,
		_invoice,
		_stan,
		_fecha_aprobacion,
		_hora_aprobacion,
		_authid,
		_monto_aprobado,
		_no_lote,
		_renglon,
		_fecha_exp,
		_cod_rechazo,
		_desc_rechazo,
		_desc_error;
end procedure 