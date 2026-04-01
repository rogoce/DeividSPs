-- Procedimiento para buscar el tipo de produccion
-- 
-- Creado    :06/10/2015 - Autor: Armando Moreno M.
--

drop procedure sp_sis437;
create procedure "informix".sp_sis437(a_no_poliza char(10))
 returning smallint;


define _tipo_prod	        smallint;
define _cod_tipoprod		char(3);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_sis437.trc";
--trace on;

select cod_tipoprod
  into _cod_tipoprod
  from emipomae
 where no_poliza = a_no_poliza;

select tipo_produccion
  into _tipo_prod
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

return _tipo_prod;

end procedure








