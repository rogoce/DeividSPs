-- Procedimiento que da formato de una poliza dependiendo de la ultima poliza impresa en el sistema.
-- Creado    : 02/09/2011 - Autor: Roman Gordon

drop procedure sp_sis160;

create procedure "informix".sp_sis160(a_no_documento	char(20))
returning	char(20);

define _no_poliza_formato	char(20);
define _no_documento		char(20);
define _no_documento_form	char(20);
define _poliza_tmp			char(20);
define _no_poliza			char(20);
define _no_poliza2			char(10);
define _cod_ramo			char(3);
define _char1				char(1);
define _char_mirror			char(1);
define _len_no_documento	smallint;
define _len_documento		smallint;
define _no_poliza_int		smallint;
define _estatus_pol			smallint;
define _cnt_existe			smallint;
define _serie				smallint;
define _cont				smallint;
define i					smallint;
define _fecha_impresion		date;

--set debug file to "sp_sis160.trc"; 
--trace on;	  

let _no_poliza_formato	= a_no_documento;
let _poliza_tmp 		= '';
let _no_poliza			= '';
let _char1				= '';
let _cnt_existe			= 0;
let _serie				= 0;

select count(*)
  into _cnt_existe
  from emipomae
 where no_documento = a_no_documento;

if _cnt_existe > 0 then
	return a_no_documento;
end if

let _serie = a_no_documento[3,4];

if _serie > 90 then
	let _serie = _serie + 1900;
else
	let _serie = _serie + 2000;
end if

let _len_documento = length(trim(a_no_documento));
if _len_documento = 11 then
	let a_no_documento = a_no_documento[1,4] || '-' || a_no_documento[5,9] || '-' || a_no_documento[10,11];
	return a_no_documento;
elif _len_documento = 10 then
	let a_no_documento = a_no_documento[1,4] || '-' || a_no_documento[5,8] || '-' || a_no_documento[9,10];
	return a_no_documento;	
end if 

let _len_documento = _len_documento + 2; 

let _no_documento = '';
 
foreach 
	select no_documento,
		   fecha_impresion,
		   serie,
		   estatus_poliza	
	  into _no_documento,
		   _fecha_impresion,
		   _serie,
		   _estatus_pol
	  from emipomae
	 where serie		= _serie
	   and actualizado	= 1
	
	let _no_documento 		= trim(_no_documento);
	let _len_no_documento	= length(trim(_no_documento));
	
	if _len_documento <> _len_no_documento then
		continue foreach;
	end if
	 
	let _no_documento_form	= _len_documento;

	for i = 1 to _len_no_documento
		let _char_mirror = _no_documento[1,1];
		let _char1 		 = _no_documento_form[1,1];
		if _char_mirror in ('0','1','2','3','4','5','6','7','8','9') then
			let _poliza_tmp = trim(_poliza_tmp) || trim(_char1);		
			let _no_documento_form = _no_documento_form[2,15];
			let _no_documento  = _no_documento[2,15];
		else
			if _char1 = _char_mirror then
				let _poliza_tmp = trim(_poliza_tmp) || trim(_char1);
				let _no_documento_form = _no_documento_form[2,15];
				let _no_documento  = _no_documento[2,15];
			else	
				let _no_poliza = trim(_no_poliza) || trim(_poliza_tmp) || '-';
				let _poliza_tmp = '';
				let _no_documento  = _no_documento[2,15];
			end if
		end if	
	end for

	let _no_poliza = trim(_no_poliza) || trim(_poliza_tmp);

	call sp_sis21(_no_poliza) returning _no_poliza2;
	
	if _no_poliza2 is not null then
		exit foreach;
	else 
		let _poliza_tmp			= '';
		let _no_documento_form	= '';
		let _char1 				= '';
		let _len_no_documento	= 0;
		let _char_mirror		= '';
		let _no_poliza			= ''; 
	end if
end foreach


return _no_poliza;
end procedure