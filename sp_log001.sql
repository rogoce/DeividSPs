-- Procedimiento que retorna el numero de instancia a imprimir en los documentos internos

-- Creado    : 31/08/2011 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_log001;

create procedure sp_log001(
a_no_hoja char(10) default "*"
) returning char(20);

define _origen		smallint;
define _instancia	char(10);
define _imp_num		char(20);

let _imp_num = null;

--return _imp_num;

select texto_imp
  into _imp_num
  from dighoja
 where no_hoja = a_no_hoja;

return _imp_num;

end procedure
