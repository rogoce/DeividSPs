-- procedimiento tilde.
-- Autor: Hgiron

drop procedure sp_tilde_carta021;

create procedure "informix".sp_tilde_carta021()
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
define _llave		integer;
DEFINE _Contratantew      VARCHAR(250);
DEFINE _Contratantewf      VARCHAR(250);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error_desc;
end exception


set isolation to dirty read;
--set debug file to "sp_par310.trc"; 
--trace on;
	 
foreach
select distinct  tmp.cod_asegurado, upper(cli.nombre),tmp.poliza ,tmp.llave
	  into _cod_contratante,_contratante,_no_documento, _llave
	  from deivid_tmp:carta_021_all tmp
	 inner join emipomae emi on emi.no_documento = tmp.poliza
  	 inner join emipouni uni on uni.no_poliza = emi.no_poliza and uni.cod_producto = tmp.cod_producto 
	 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
	 where  uni.cod_asegurado = tmp.cod_asegurado
  and upper(nombre) like ('%Ñ%')
  
  	if _contratante is null then
	    continue foreach;
	end if
  
	let _contratantewf = '';
	let _Contratantew = rtrim(_contratante);	
	let _Contratantew = ltrim(_contratante);				
	call sp_web_carta021(_contratante) returning _contratantewf;			
	if _Contratantewf is null or trim(_Contratantewf) = '' then
		continue foreach;
	end if			  
  
	update deivid_tmp:carta_021_all2
	   set n_asegurado_cesp = _contratante,
	   n_asegurado_web = _Contratantewf
	 where poliza = _no_documento
	 and llave = _llave;

end foreach	

return 0;
end procedure;