--drop procedure sp_sis09;

create procedure "informix".sp_sis09(a_user char(8),a_agencia char(3))
returning smallint;

begin

define _cnt             smallint;

--SET DEBUG FILE TO "sp_cob248.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;


let _cnt = 0;

SELECT count(*)
  INTO _cnt
  FROM insauca
 WHERE (insauca.codigo_compania     = '001')     AND
         (insauca.codigo_agencia    = a_agencia) AND
         (insauca.usuario           = a_user)    AND
         (insauca.aplicacion        = 'PRO')     AND
         (insauca.version           = '02')      AND
         (insauca.tipo_autorizacion = '17');


return _cnt;
end
end procedure;
