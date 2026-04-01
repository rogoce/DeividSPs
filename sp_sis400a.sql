-- Procedure que modifica la cedula para que cumpla con el formato ##-####-##### 
-- 
-- Creado    : 03/10/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis400a;		

create procedure "informix".sp_sis400a(a_cedula varchar(30))
returning	varchar(30);

define _cedula		varchar(30);
define _error_desc	char(100);
define _error_char	char(7);
define _asiento		char(7);
define _folio		char(7);
define _valor		char(7);
define _tomo		char(7);
define _provincia	char(4);
define _inicial		char(4);
define _char		char(1);
define _error_isam	integer;
define _error		integer;
define _len_valor	smallint;
define _length		smallint;
define _flag		smallint;
define _esp			smallint;
define i			smallint;

begin
on exception set _error, _error_isam, _error_desc
	let _error_char = cast(_error as char(7));
	return _error_char;
end exception

--set debug file to "sp_sis400a.trc"; 
--trace on;

set isolation to dirty read;

{create temp table tmp_cedula(
campo		char(10),
valor		char(5)
) with no log;}

let _provincia	= '0000';
let _inicial	= '0000';
let _asiento 	= '00000';
let _folio	   	= '00000';
let _tomo	   	= '00000';
let _flag		= 0;
let _valor		= '';

for i = 1 to 30
	let _char		= a_cedula[1,1];
	let a_cedula	= a_cedula[2,20];
	 
	if _char = '-' then
		let _flag = _flag + 1;

		if _flag = 1 then
		   let _provincia	= _valor;
		elif _flag = 2 then
			if _valor[1,1] not between "0" and "9" then
				let _provincia	= trim(_provincia) || _valor;
				let _esp		= 1;
			else
				let _asiento 	= _valor;
			end if

		elif _flag = 3 then
			if _esp = 1 then
				let _asiento	= _valor;
			end if
		end if
		let _valor = '';
	else
		let _valor = trim(_valor) || _char;
	end if
end for

let _tomo = _valor;

let _len_valor	= length(_provincia);
if _len_valor = 1 then
	let _provincia	= '0' || trim(_provincia);
end if

let _len_valor = length(_asiento);
if _len_valor = 1 then
	let _asiento = '000' || trim(_asiento);
elif _len_valor = 2 then
	let _asiento = '00' || trim(_asiento);
elif _len_valor = 3 then
	let _asiento = '0' || trim(_asiento);
end if

let _len_valor = length(_tomo);
if _len_valor = 1 then
	let _tomo = '0000' || trim(_tomo);
elif _len_valor = 2 then
	let _tomo = '000' || trim(_tomo);
elif _len_valor = 3 then
	let _tomo = '00' || trim(_tomo);
elif _len_valor = 4 then
	let _tomo = '0' || trim(_tomo);
end if

let _cedula = trim(_provincia) || '-' || trim(_asiento) || '-' || trim(_tomo);

return	_cedula;	
end
end procedure