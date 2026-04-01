-- Proceso que descompone cobtaban para la generación del archivo para el proceso de AMEX
-- creado    : 17/08/2000 - autor: demetrio hurtado almanza 
-- modificado: 17/08/2000 - autor: demetrio hurtado almanza
--
-- sis v.2.0 - - deivid, s.a.

drop procedure sp_cob378;

create procedure "informix".sp_cob378(a_no_lote char(5)) 
returning char(1);

define _campo		varchar(64);
define _filename	varchar(50);      
define _codigo		varchar(50);      
define _contador	integer;    
define _mes_char	char(2);      
define _ano_char	char(2);      
define _char_1		char(1);      
define _tipo		char(1);
define _len_codigo	integer;
define _flag_filtro	smallint;
define _fecha_hoy	date;

--set debug file to "sp_cas105.trc";
--trace on;

let _fecha_hoy = sp_sis40();

--Formato del mes con 2 caracteres
let _mes_char = lpad(month(_fecha_hoy),2,'0');

--Extraer los 2 últimos valores del año
let _ano_char = substr(year(_fecha_hoy),-2);

let _filename = 'AM' || _mes_char || _ano_char || '01.csv';

--unload to _filename
--select * from cobtaban;
--drop table if exists ext_cobtaban;
--CREATE EXTERNAL TABLE if not exists ext_cobtaban SAMEAS cobtaban USING (DATAFILES ('DISK:AM01.dat'),DELIMITER "");

--INSERT INTO ext_cobtaban 
--SELECT * FROM cobtaban;

foreach
	select campo
	  into _campo
	  from cobtaban

	let _campo = _campo || ';';
	let _codigo   = "";
	let _len_codigo = length(_campo);

	for _contador = 1 to _len_codigo

		let _char_1   = _campo[1, 1];
		let _campo  = _campo[2, 64];

		if _char_1 = ";" then

			if _codigo <> a_no_lote then
				let _flag_filtro = 1;
			end if
			
			exit for;

		else

			if _char_1 = "," then

				insert into tmp_codigos(
					codigo
					)
					values(
					_codigo
					);
				let _codigo = "";
			elif _char_1 = ' ' then
				
				let _codigo = _codigo || _char_1;	
			else
				let _codigo = _codigo || trim(_char_1);
			end if
		end if
	end for
	
	if _flag_filtro = 1 then
		continue foreach;
	end if

	return _char_1;
end foreach}


end procedure;