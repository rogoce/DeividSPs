-- Procedure que elimina la 0 de la cedula
-- 
-- Creado    : 04/02/2013 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis400b;

create procedure "informix".sp_sis400b(a_cedula varchar(30))
returning	varchar(30);

define _cedula		varchar(30);
define _resultado	varchar(30);
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

let _cedula = trim(a_cedula) || ';';
{create temp table tmp_cedula(
campo		char(10),
valor		char(5)
) with no log;}

let _provincia	= '0000';
let _inicial	= '0000';
let _asiento 	= '00000';
let _folio	   	= '00000';
let _tomo	   	= '00000';
let _flag		= 1;
let _valor		= '';
let _resultado	= '';

for i = 1 to 30
	let _char	= _cedula[1,1];
	let _cedula	= _cedula[2,20];
	
	if _char = ';' then
		exit for;
	elif _char = '-' then
		let _flag = 1;
		let _resultado = trim(_resultado) || _char;
	else
		if (_flag = 0 and _char = '0') or _char <> '0' then
			let _resultado = trim(_resultado) || _char;
			let _flag = 0;
		end if		
	end if
end for

return _resultado;
end
end procedure