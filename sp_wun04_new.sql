-- Procedure que modifica la cedula  y el ruc para que cumpla con el formato del grupo rey
-- 
-- Creado    : 07/04/2015 - Autor: Federico Coronado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_wun04_new;		

create procedure "informix".sp_wun04_new(a_cedula varchar(30), a_tipo_cliente char(1), a_pasaporte smallint)
returning	varchar(30);

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
	return _error_char;
end exception

--set debug file to "sp_wun04.trc"; 
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
let _esp        = 0;
let _esp1		= 0;

	if a_tipo_cliente = 'N' and a_pasaporte = 0 then
	-- Cedula persona natural
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
		if  _len_valor = 1 then
			if _provincia = 'E' or _provincia = 'N' then
				let _provincia	= '00' || trim(_provincia);
			else
				let _provincia	= '0' || trim(_provincia);
			end if
		elif _len_valor = 2 then
			if _provincia = 'PE' then
				let _provincia	= '00' || trim(_provincia);
			elif _provincia = 'EE' then
				let _provincia	= '00' || trim(_provincia);
			else
				let _provincia	= trim(_provincia);
			end if
		elif _len_valor = 3 then
			if _provincia[2,3] = 'PI' then
				let _provincia	= '0' || trim(_provincia[1,1])|| trim(_provincia[2,3]);
				let _esp1 = 1;
			elif _provincia[2,3] = 'AV' then
				let _provincia	= '0' || trim(_provincia[1,1])|| trim(_provincia[2,3]);
				let _esp1 = 1;
			end if
		elif _len_valor = 4 then
			if _provincia[3,4] = 'PI' then
				let _provincia	=  trim(_provincia[1,2])|| trim(_provincia[3,4]);
				let _esp1 = 1;
			elif _provincia[3,4] = 'AV' then
				let _provincia	= trim(_provincia[1,2])|| trim(_provincia[3,4]);
				let _esp1 = 1;
			end if
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
			let _tomo = '00000' || trim(_tomo);
		elif _len_valor = 2 then
			let _tomo = '0000' || trim(_tomo);
		elif _len_valor = 3 then
			let _tomo = '000' || trim(_tomo);
		elif _len_valor = 4 then
			let _tomo = '00' || trim(_tomo);
		elif _len_valor = 5 then
			let _tomo = '0' || trim(_tomo);
		end if

		if _provincia = '00E' or _provincia = '00N' then
			let _cedula = trim(_provincia) || ' ' || trim(_asiento) || trim(_tomo);
		elif _provincia = '00PE' then 
			let _cedula = trim(_provincia) || trim(_asiento) || trim(_tomo);
		elif _provincia = '00EE' then 
			let _cedula = trim(_provincia) || trim(_asiento) || trim(_tomo);
		elif _esp1 = 1 then 
			let _cedula = trim(_provincia) || trim(_asiento) || trim(_tomo);
		--elif _provincia = '04AV' then 
			--let _cedula = trim(_provincia) || trim(_asiento) || trim(_tomo);
		else
			let _cedula = trim(_provincia) || '  ' ||trim(_asiento) || trim(_tomo);
		end if
		

		return _cedula;
		
		
	elif a_tipo_cliente = 'N' and a_pasaporte = 1 then
	-- Cedula persona natural
/*	
			let _provincia		= a_cedula[1,2];
			let a_cedula	= a_cedula[3,20];
			
		let _len_valor = length(a_cedula);
		if _len_valor = 1 then
			let a_cedula = '00000000' || trim(a_cedula);
		elif _len_valor = 2 then
			let a_cedula = '0000000' || trim(a_cedula);
		elif _len_valor = 3 then
			let a_cedula = '000000' || trim(a_cedula);
		elif _len_valor = 4 then
			let a_cedula = '00000' || trim(a_cedula);
		elif _len_valor = 5 then
			let a_cedula = '0000' || trim(a_cedula);
		elif _len_valor = 6 then
			let a_cedula = '000' || trim(a_cedula);
		elif _len_valor = 7 then
			let a_cedula = '00' || trim(a_cedula);
		elif _len_valor = 8 then
			let a_cedula = '0' || trim(a_cedula);
		else
			let a_cedula = trim(a_cedula);
		end if


		let _cedula = trim(_provincia) || '  ' ||trim(a_cedula);
*/		
		let _cedula = trim(a_cedula);
		return _cedula;	
		
	else
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
		let _len_valor	= length(_provincia);
		if  _len_valor = 1 then
				let _provincia	= '000000' || trim(_provincia);
		elif _len_valor = 2 then
				let _provincia	= '00000' || trim(_provincia);
		elif _len_valor = 3 then
				if _provincia[2,3] = 'NT' then
					let _provincia	= '0' || trim(_provincia[1,1])|| trim(_provincia[2,3]);
					let _esp1 = 1;
				else
					let _provincia	= '0000' || trim(_provincia);
				end if
		elif _len_valor = 4 then
				if _provincia[3,4] = 'NT' then
					let _provincia	= trim(_provincia[1,2])|| trim(_provincia[3,4]);
					let _esp1 = 1;
				else
					let _provincia	= '000' || trim(_provincia);
				end if
		elif _len_valor = 5 then
				let _provincia	= '00' || trim(_provincia);
		elif _len_valor = 6 then
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
		
		if _esp1 = 1 then
			if _len_valor = 1 then
				let _tomo = '0000' || trim(_tomo);
			elif _len_valor = 2 then
				let _tomo = '000' || trim(_tomo);
			elif _len_valor = 3 then
				let _tomo = '00' || trim(_tomo);
			elif _len_valor = 4 then
				let _tomo = '0' || trim(_tomo);
			end if
		else
			if _len_valor = 1 then
				let _tomo = '00000' || trim(_tomo);
			elif _len_valor = 2 then
				let _tomo = '0000' || trim(_tomo);
			elif _len_valor = 3 then
				let _tomo = '000' || trim(_tomo);
			elif _len_valor = 4 then
				let _tomo = '00' || trim(_tomo);
			elif _len_valor = 5 then
				let _tomo = '0' || trim(_tomo);
			end if
		end if
		
		let _cedula = trim(_provincia) || trim(_asiento) || trim(_tomo);

		return	_cedula;
	
	end if
	
end
end procedure