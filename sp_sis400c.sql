-- Procedure que modifica la cedula  y el ruc para que cumpla con el formato del grupo rey
-- 
-- Creado    : 07/04/2015 - Autor: Federico Coronado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis400c;		

create procedure "informix".sp_sis400c(a_cedula varchar(30))
returning	varchar(7),
			char(7),
			char(7);

define _cedula		varchar(30);
define _error_desc	char(100);
define _error_char	char(7);
define _asiento		char(7);
define _folio		char(7);
define _valor		char(7);
define _tomo		char(7);
define _provincia	char(7);
define _inicial		char(4);
define _char		char(1);
define _error_isam	integer;
define _error		integer;
define _len_valor	smallint;
define _length		smallint;
define _flag		smallint;
define _esp			smallint;
define i			smallint;
define _esp1		smallint;

begin
on exception set _error, _error_isam, _error_desc
	let _error_char = cast(_error as char(7));
	return "","",_error_char;
end exception

--set debug file to "sp_wun04.trc"; 
--trace on;

set isolation to dirty read;

let _provincia	= '0000';
let _inicial	= '0000';
let _asiento 	= '00000';
let _folio	   	= '00000';
let _tomo	   	= '00000';
let _flag		= 0;
let _valor		= '';
let _esp        = 0;
let _esp1		= 0;

	 -- Ruc persona Juridica
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

		 return trim(_provincia),
		        trim(_asiento),
				trim(_tomo);
	
end
end procedure