-- Procedimiento para retorna los valores para la carta al cliente
-- por la no facturacion de las polizas de salud.
--
-- Creado    : 21/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob272;

create procedure "informix".sp_cob272(a_mail_secuencia integer)
returning char(100),
          char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(100);

define _cod_pagador		char(10);
define _nombre_pagador	char(100);
define _no_documento  	char(20);
define _saldo			dec(16,2);
define _saldo61			dec(16,2);
define _prima_mensual	dec(16,2);
define _asegurado		char(100);

define _no_poliza		char(10);

set isolation to dirty read;

select no_remesa,
       no_documento,
	   asegurado,
	   saldo,
	   saldo61,
	   prima_mensual
  into _no_poliza,
       _no_documento,
	   _asegurado,
	   _saldo,
	   _saldo61,
	   _prima_mensual
  from parmailcomp
 where mail_secuencia = a_mail_secuencia;
   
select cod_pagador
  into _cod_pagador
  from emipomae
 where no_poliza = _no_poliza;

select nombre
  into _nombre_pagador
  from cliclien
 where cod_cliente = _cod_pagador;

return _nombre_pagador,
       _no_documento,
	   _saldo,
	   _saldo61,
	   _prima_mensual,
       _asegurado;

end procedure