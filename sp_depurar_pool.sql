-- Procedimiento que depura el Pool de Impresión
--
-- creado    : 01/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_depurar_pool;
create procedure "informix".sp_depurar_pool(a_cod_sucursal char(3),a_fecha_desde date)
returning   integer,
			char(100);   -- _error

define _error_desc		char(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _suc_origen		char(3);
define _cod_sucursal	char(3);
define _suc_prom		char(3);
define _cod_ramo		char(3);
define _error_isam		smallint;
define _cnt_acr			smallint;
define _error			smallint;

begin
on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

set isolation to dirty read;

foreach
	select no_poliza,
           cod_sucursal,
		   no_documento
	  into _no_poliza, 
           _cod_sucursal,
		   _no_documento
      from emirepo  
     where estatus   in (5,9)
	   and fecha_selec < a_fecha_desde

	select sucursal_origen
	  into _suc_origen
	  from emipomae
	 where no_poliza = _no_poliza;

	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = _suc_origen
	   and codigo_compania = '001';
	
	if _suc_prom not in (a_cod_sucursal) then 
		continue foreach;
	end if
	
	{select count(*)
	  into _cnt_acr
	  from emipoacr
	 where no_poliza = _no_poliza;
	
	if _cnt_acr is null then
		let _cnt_acr = 0;
	end if
	
	if _cnt_acr < 1 then
		continue foreach;
	end if}
	
	insert into emireimp
			(no_documento,
			no_poliza,
			fecha_impresion,
			user_imprimio
			)
	values	(_no_documento,
			_no_poliza,
			today,
			'informix'
			);
			
	delete from emirepo
	where no_poliza = _no_poliza;
	return 0,_no_poliza with resume;
end foreach
end
end procedure