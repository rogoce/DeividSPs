-- procedimiento que verifica si existe un endoso de perdida total
-- autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec264;

create procedure sp_rec264(a_no_requis char(10)) 
returning CHAR(3), smallint;

define v_no_poliza		    char(10);
define _cod_ramo            char(3);
define _no_tranrec          char(10);
define _tipo_finiquito      smallint;
--SET DEBUG FILE TO "sp_pro533.trc";
--TRACE ON;


set isolation to dirty read;

FOREACH	
	select b.no_poliza,
           a.no_tranrec	
	  into v_no_poliza,	
           _no_tranrec	  
	  from rectrmae a inner join recrcmae b on
		   a.no_reclamo = b.no_reclamo
	 where a.no_requis = a_no_requis
	   and a.actualizado = 1
   EXIT FOREACH;
END FOREACH	   
	-- 008 cancelacion por perdida total
select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = v_no_poliza;
 
let _tipo_finiquito = 0; 
select tipo_finiquito
  into _tipo_finiquito
  from rectrfini1
 where no_tranrec = _no_tranrec;

RETURN _cod_ramo, _tipo_finiquito;

end procedure