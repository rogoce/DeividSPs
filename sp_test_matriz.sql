drop procedure sp_test_matriz;

create procedure "informix".sp_test_matriz() 
returning int, 
		  varchar(100);   										   
																											   																											   


define v_test               integer;									 
define _arr1                integer;    
define _arr2                integer; 



set isolation to dirty read;

_arr1 = 1
_arr2 = 1
foreach 
    
    select prima_suscrita,
           prima_bruta
      into v_test[_arr1],
           v_test[_arr2]
      from emipomae
end foreach

return 0, "Actualizacion Exitosa";

end procedure;
