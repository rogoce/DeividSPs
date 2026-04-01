--------------------------------------------
--Procedure que Cambia los contratos de reaseguro de Auto, Auto Flota y Soda 
--execute procedure sp_rea40()
--25/03/2017 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea40;
create procedure sp_rea40()
returning	smallint		as code_error,
			varchar(150)	as error_desc;

define _error_desc			varchar(100);
define _no_poliza			char(10);
define _error_isam			integer;
define _error				integer;

--set debug file to 'sp_rea40.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    return	_error,_error_desc;
end exception  

set isolation to dirty read;


foreach
	select distinct e.no_poliza
	  into _no_poliza
	  from emipomae p, endedmae e, emifacon r, reacomae c
	 where p.no_poliza = e.no_poliza
	   and e.no_poliza = r.no_poliza
	   and e.no_endoso = r.no_endoso
	   and c.cod_contrato = r.cod_contrato
	   and p.cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
	   and p.vigencia_inic between '01/01/2017' and '31/12/2017'
	   and c.serie <> 2017

	call sp_rea39a(_no_poliza) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc with resume;
	end if
end foreach
end
end procedure