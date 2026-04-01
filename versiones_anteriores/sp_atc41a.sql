-- procedimiento evalua quitar caracteres solicitados de la cadena
-- creado    : 04/10/2023 - autor: henry giron

drop procedure sp_atc41a; 

create procedure sp_atc41a( a_buscar varchar(250))
       returning varchar(250);

define _valor    varchar(255);
define _valor2   varchar(255);
define _quitar   varchar(100);
define _i        integer;
define _cnt      integer;
define _caracter integer;
define _remplaza char(1);

set isolation to dirty read;
--set debug file to "sp_pro51.trc";
--trace on;
--foreach
-- select first 111 distinct trim(upper(contratante))
--   into _valor
 --  from tmp_contratante
 -- group by 1
        let _valor = a_buscar;
        let _i = 1;
        let _cnt = length( _valor);
		let _remplaza = '';

		while  _i <= _cnt
		    let _i = _i;
		    let _cnt = _cnt;
		    let _valor2 = substring(_valor from _i for 1);
			let _quitar   = substring(_valor from _i for 1);	
			let _caracter = ascii(_quitar) ;
			
			if( not (ascii(substring( _valor from _i for 1)) between 48 and 57 )  -- 0 to 9
			and not (ascii(substring( _valor from _i for 1)) between 65 and 90 )  -- a to z
	        and not (ascii(substring( _valor from _i for 1)) between 46 and 46 ) -- 46 punto
	        and not (ascii(substring( _valor from _i for 1)) between 32 and 32 ) -- espacios
			)then
						
				if  (not (ascii(substring( _valor from _i for 1)) between 192 and 241)     
				)then  
					let  _valor = replace( _valor,  _quitar, '#'); 
				else
				    let _remplaza = '';
					
					if ascii(_quitar) in (209,241) then
					    let _remplaza = 'Ñ';
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
        let _valor2 = replace(_valor,"#","");
        let _valor2 = replace(_valor,"  "," ");
		let _valor = rtrim(_valor2);	
		let _valor = ltrim(_valor2);	  

        return  _valor; -- with resume;

--end foreach

--return _valor;

end procedure 
                                            
