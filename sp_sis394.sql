-- Procedimiento que retorna el nombre del ramo dando el no_documento
-- Se usa para los casos en que la poliza no se ha creado pero ya se tiene el numero de documento

-- Creado    : 28/10/2011 - Autor: Demetrio Hurtado Almanza

-- sis v.2.0 - deivid, s.a.

--drop procedure sp_sis394;

create procedure "informix".sp_sis394(a_no_documento char(20))
returning char (50);

define _cod_ramo	char(3);
define _nombre_ramo	char(50);

let _nombre_ramo = null;
let _cod_ramo    = "0" || a_no_documento[1,2];

select nombre
  into _nombre_ramo
  from prdramo
 where cod_ramo = _cod_ramo;

return _nombre_ramo;

end procedure
