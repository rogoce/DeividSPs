-- Creacion de las letras de pago de las polizas por nueva ley de seguros
-- Creado    : 08/01/2015 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro525g;

create procedure sp_pro525g()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _estatus_poliza	smallint;
define _cnt_credito		smallint;
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
	{select no_poliza
	  into _no_poliza	
	  from emipomae
	 where no_poliza in (select distinct no_poliza from emiletra where vigencia_inic >= '01/01/2013')
	   --and cod_ramo <> '018'
	   and actualizado = 1
	   --and estatus_poliza = 1}

	select distinct no_poliza
	  into _no_poliza
	  from emiletra
	 where vigencia_inic >='01/01/2013'
	   and pagada = 1
	   and fecha_pago is null

	begin work;
	
	{select count(*)
	  into _cnt
	  from emiletra
	 where no_poliza = _no_poliza;
	
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
		commit work;
		continue foreach;
	end if}
	
	select no_documento,
		   estatus_poliza
	  into _no_documento,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza = 2 then
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
	
	call sp_pro525f(_no_poliza) returning _error,_error_desc;
	
	if _error <> 0 then
		rollback work;
		return _error,_error_desc;
	end if
	
	select count(*)
	  into _cnt_credito
	  from emiletra
	 where no_documento = _no_documento
	   and monto_pen < 0;

	if _cnt_credito is null then
		let _cnt_credito = 0;
	end if

	if _cnt_credito > 0 then
		call sp_cob346a(_no_documento) returning _error,_error_desc;
	end if
	
	commit work;
end foreach


end

return 0, "Actualizacion Exitosa";
end procedure
