-- Lista de Chequeras
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_cob755;
create procedure sp_cob755() 
returning char(3), char(50),char(3);

define _cod_chequera 	char(3);
define _nombre      	char(50);
define _cod_banco	 	char(3);

set isolation to dirty read;

foreach
 select cod_chequera, nombre , cod_banco
   into	_cod_chequera, _nombre , _cod_banco
   from chqchequ
  where cod_chequera in ("017","019","021","014","028")
  order by cod_chequera

	return _cod_chequera, 
		   _nombre , 
		   _cod_banco
		   with resume;

end foreach
end procedure