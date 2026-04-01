-- Creacion de las letras de pago de las polizas por nueva ley de seguros
-- Creado    : 21/06/2012 - Autor: Demetrio Hurtado Almanza 
-- modificado: 09/12/2013 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro525b;

create procedure sp_pro525b(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	int,
			char(50);

define _error_desc		char(50);
define _no_poliza		char(10);
define _cnt_endoso		smallint;
define _cnt				smallint;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

--set debug file to "sp_pro525b.trc";
--trace on;

foreach with hold
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where actualizado = 1
	   and periodo >= a_periodo_desde
	   and periodo <= a_periodo_hasta
	 order by periodo,no_poliza
	   --and estatus_poliza = 1

	begin work;
	
	select count(*)
	  into _cnt
	  from emiletra
	 where no_poliza = _no_poliza;
	
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
		commit work;
		continue foreach;
	end if
	
	select count(*)
	  into _cnt_endoso
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = '00000';
	
	if _cnt_endoso is null then
		let _cnt_endoso = 0;
	end if
	
	if _cnt_endoso = 0 then
		commit work;
		continue foreach;
	end if
	
	if _no_poliza in ('401346','80197','81610','89107','95130','109085') then
		commit work;
		continue foreach;
	end if
	
	call sp_pro525(_no_poliza) returning _error,_error_desc;
	
	if _error <> 0 then
		rollback work;
		return _error,_error_desc;
	end if
	
	commit work;
end foreach

end

return 0, "Actualizacion Exitosa";
end procedure
