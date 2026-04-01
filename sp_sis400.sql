-- Procedure que separa la cedula en 
-- 
-- Creado    : 19/03/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis400;		

create procedure "informix".sp_sis400(a_cedula varchar(30))
returning	char(2),
			char(2),
			char(7),
			char(7);

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
define _length		smallint;
define _flag		smallint;
define i			smallint;

begin
on exception set _error, _error_isam, _error_desc
	let _error_char = cast(_error as char(7));
	return '','',_error, _error_desc;									   
end exception

set isolation to dirty read;

let _provincia	= '0000';
let _inicial	= '';
let _asiento 	= '0000000';
let _folio	   	= '0000000';
let _tomo	   	= '0000000';
let _flag		= 0;
let _valor		= '';

for i = 1 to 15
	let _char		= a_cedula[1,1];
	let a_cedula	= a_cedula[2,20];

	if _char = '-' then
		let _flag = _flag + 1;
		if _flag = 1 then
			let _provincia	= _valor;
			--let _inicial	= _valor;
		elif _flag = 2 then
			let _tomo = _valor;
		end if

		let _valor = '';
	else
		let _valor = trim(_valor) || _char;
	end if
end for

let _asiento = trim(_valor);

return _provincia,
	   _inicial,
	   _tomo,
	   _asiento;	
end
end procedure