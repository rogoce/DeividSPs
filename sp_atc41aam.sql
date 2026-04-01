-- procedimiento evalua quitar caracteres solicitados de la cadena
-- creado    : 04/10/2023 - autor: henry giron

drop procedure sp_atc41aam; 
create procedure sp_atc41aam( a_buscar varchar(250))
       returning varchar(250),integer;

define _valor    varchar(255);
define _valor2   varchar(255);
define _quitar   varchar(100);
define _i        integer;
define _cnt      integer;
define _caracter integer;
define _remplaza char(1);

set isolation to dirty read;
--set debug file to "sp_atc41aam.trc";
--trace on;
let _valor = a_buscar;
let _i = 1;
let _cnt = length( _valor);
let _remplaza = '';

while  _i <= _cnt
	let _quitar   = substring(_valor from _i for 1);	
	let _caracter = ascii(_quitar) ;	
	if( not (ascii(substring( _valor from _i for 1)) between 48 and 57 ) -- 0-9
	and not (ascii(substring( _valor from _i for 1)) between 65 and 90 ) -- A-Z
	and not (ascii(substring( _valor from _i for 1)) between 32 and 32 ) -- espacio
	)then
				
		if (not (ascii(substring( _valor from _i for 1)) between 192 and 241)     
		)then  
			let  _valor = replace( _valor,  _quitar, '#'); 
		else  --ÀÁÂÃÄÅÆ	ÈÉÊË	ÌÍÎÏ	ÒÓÔÕÖ×Ø	ÙÚÛÜ	Ññ	Ý
			let _remplaza = '';
			if ascii(_quitar) in (209,241) then
				let _remplaza = 'N';
				let  _valor = replace( _valor,  _quitar, _remplaza); 						
			else				
				if ascii(_quitar) between 192 and 198  or ascii(_quitar) between 224 and 230 then
					let _remplaza = 'A';
				end if								
				if ascii(_quitar) between 200 and 203  or ascii(_quitar) between 232 and 235 then
					let _remplaza = 'E';
				end if	
				if ascii(_quitar) between 204 and 207  or ascii(_quitar) between 236 and 239 or ascii(_quitar) = 221 then
					let _remplaza = 'I';
				end if	
				if ascii(_quitar) between 210 and 216  or ascii(_quitar) between 242 and 246 then
					let _remplaza = 'O';
				end if							
				if ascii(_quitar) between 217 and 220  or ascii(_quitar) between 249 and 252 then
					let _remplaza = 'U';
				end if	
				let  _valor = replace( _valor,  _quitar, _remplaza); 						
			end if									
		end if
	end if			
	let  _i =  _i + 1;
end while
let _valor2 = replace(replace(_valor,"#",""),"  "," ");
let _valor = rtrim(_valor2);	
let _valor = ltrim(_valor);	  
return  _valor,_caracter;


end procedure 
                                            
