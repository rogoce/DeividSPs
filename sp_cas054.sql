
drop procedure sp_cas054;

create procedure sp_cas054()

define _cod_pagador	char(10);

foreach
 select cod_pagador
   into _cod_pagador
   from cobcatmp3
   
	update cascliente
	   set set cod_cobrador = 	
	
	   
end foreach  

end procedure