-- procedimiento que verifica si existe un endoso de perdida total
-- autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro533;

create procedure sp_pro533(a_no_tranrec char(10)) 
returning integer;

define v_cantidad			integer;
define v_no_poliza		    char(10);
define v_no_endoso		    char(5);
define v_no_documento		char(20);

--SET DEBUG FILE TO "sp_pro533.trc";
--TRACE ON;


set isolation to dirty read;
	
select b.no_poliza,
       b.no_documento
  into v_no_poliza,
       v_no_documento
  from rectrmae a inner join recrcmae b on
	   a.no_reclamo = b.no_reclamo
 where a.no_tranrec = a_no_tranrec
   and a.actualizado = 1;
		
	-- 008 cancelacion por perdida total
select count(*)
  into v_cantidad
  from endedmae
 where no_documento = v_no_documento
   and cod_tipocan  = '008'
   and actualizado  = 1;

RETURN v_cantidad;

end procedure