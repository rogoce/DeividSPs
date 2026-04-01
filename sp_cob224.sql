-- Procedure que Retorna la caja para comprobantes

-- Creado    : 25/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob224;

create procedure sp_cob224()
returning char(3), 
          char(3);

define _caja_caja	char(3);
define _caja_comp	char(3);

set isolation to dirty read;

SELECT valor_parametro
  INTO _caja_caja
  FROM inspaag
 WHERE codigo_compania  = "001"
   AND codigo_agencia   = "001"
   AND aplicacion       = "COB"
   AND version          = "02"
   AND codigo_parametro = "caja_caja";

SELECT valor_parametro
  INTO _caja_comp
  FROM inspaag
 WHERE codigo_compania  = "001"
   AND codigo_agencia   = "001"
   AND aplicacion       = "COB"
   AND version          = "02"
   AND codigo_parametro = "caja_comp";

return _caja_caja, _caja_comp;

end procedure