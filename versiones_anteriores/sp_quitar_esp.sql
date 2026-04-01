-- procedimiento evalua quitar caracteres solicitados de la cadena
-- creado    : 04/10/2023 - autor: henry giron

drop procedure sp_quitar_esp; 

create procedure sp_quitar_esp ( v_inputstring varchar(250))
returning varchar(250);


define v_badstrings varchar(100);
define  v_increment integer;
define  v_len_increment integer;
define  v_inputstring2 varchar(255);
define li_badstrings integer;
define v_remplaza char(1);

set isolation to dirty read;
--set debug file to "sp_pro51.trc";
--trace on;
--foreach
-- select first 111 distinct trim(upper(contratante))
--   into v_inputstring
 --  from tmp_contratante
 -- group by 1
        let v_increment = 1;
        let v_len_increment = length( v_inputstring);
		let v_remplaza = '';

		while  v_increment <= v_len_increment
		    let v_increment = v_increment;
		    let v_len_increment = v_len_increment;
		    let v_inputstring2 = substring(v_inputstring from v_increment for 1);
			let v_badstrings   = substring(v_inputstring from v_increment for 1);	
			let li_badstrings = ascii(v_badstrings) ;
			
			if( not (ascii(substring( v_inputstring from v_increment for 1)) between 48 and 57 )  -- 0 to 9
			and not (ascii(substring( v_inputstring from v_increment for 1)) between 65 and 90 )  -- a to z
	        and not (ascii(substring( v_inputstring from v_increment for 1)) between 46 and 46 ) -- 46 punto
	        and not (ascii(substring( v_inputstring from v_increment for 1)) between 32 and 32 ) -- espacios
			)then
						
				if  (not (ascii(substring( v_inputstring from v_increment for 1)) between 192 and 241)    --  
				)then  
					let  v_inputstring = replace( v_inputstring,  v_badstrings, '#'); -- added # to explicit convert all char to # and then replace # with blank, this is to remove multiple special char if in same sequence	
				else
				    let v_remplaza = '';
					
					if ascii(v_badstrings) in (209,241) then
					    let v_remplaza = 'Ñ';
					else				
						if ascii(v_badstrings) between 192 and 198  or ascii(v_badstrings) between 224 and 230 then
							let v_remplaza = 'A';
						end if								
						if ascii(v_badstrings) between 200 and 203  or ascii(v_badstrings) between 232 and 235 then
							let v_remplaza = 'E';
						end if	
						if ascii(v_badstrings) between 204 and 207  or ascii(v_badstrings) between 236 and 239 or ascii(v_badstrings) = 221 then
							let v_remplaza = 'I';
						end if	
						if ascii(v_badstrings) between 210 and 216  or ascii(v_badstrings) between 242 and 246 then
							let v_remplaza = 'O';
						end if							
						if ascii(v_badstrings) between 217 and 220  or ascii(v_badstrings) between 249 and 252 then
							let v_remplaza = 'U';
						end if	
                        let  v_inputstring = replace( v_inputstring,  v_badstrings, v_remplaza); 						
					end if									
				end if
			end if			
			let  v_increment =  v_increment + 1;
		end while
        let v_inputstring2 = replace(v_inputstring,"#","");
        let v_inputstring2 = replace(v_inputstring,"  "," ");
		let v_inputstring = rtrim(v_inputstring2);	
		let v_inputstring = ltrim(v_inputstring2);	  

        return  v_inputstring; -- with resume;

--end foreach

--return v_inputstring;

end procedure 
                                            
