-- procedimiento que trae todos los correos de un corredor.
-- creado    : 27/12/2011 - Autor: Roman Gordon

drop procedure sp_ajusta_contr_carta;

create procedure "informix".sp_ajusta_contr_carta()
returning	char(384) as mails;

define _error_desc		varchar(100);
define _contratante		varchar(150);
define _email_agtmail	char(50);
define _no_documento	char(20);
define _cod_contratante	char(10);
define _len_climail		smallint;
define _max_length		smallint;
define _len_email		smallint;
define _len_final		smallint;
define _cantidad		smallint;
define _error			integer;
define _error_isam		integer;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error_desc;
end exception


set isolation to dirty read;
--set debug file to "sp_par310.trc"; 
--trace on;

foreach
	select emi.cod_contratante,cli.nombre,tmp.poliza
	  into _cod_contratante,_contratante,_no_documento
	  from deivid_tmp:carta84 tmp
	 inner join emipomae emi on emi.no_documento = tmp.poliza
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 where emi.cod_contratante <> tmp.codasegurado

	update deivid_tmp:carta84
	   set codcontratante = _cod_contratante,
	       contratante = _contratante
	 where poliza = _no_documento;

end foreach	

return 0;
end procedure;