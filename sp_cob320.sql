-- Registros de la Remesa 660575 de ajuste de centavos

-- Creado    : 07/02/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_cob320;

create procedure "informix".sp_cob320()
returning char(20), 
          dec(16,2);

define _no_documento	char(20);
define _saldo			dec(16,2);
define _periodo			char(7);

let _periodo = "2013-12";

foreach
 select doc_remesa
   into _no_documento
   from cobredet
  where no_remesa = "660575"

	let _saldo = sp_cob175(_no_documento, _periodo);

	if _saldo <> 0 then

		return _no_documento,
		       _saldo
			   with resume;

	end if

end foreach

return "",
       0;

end procedure
