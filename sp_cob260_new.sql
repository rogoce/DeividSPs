-- insercion de los correos para los estados de cuenta de manera masiva en parmailsend
-- creado por :    roman gordon	05/01/2011
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob260_new;

create procedure "informix".sp_cob260_new()
returning	integer,
            char(50);				

define _email				char(384);
define _email_climail		char(50);
define _error_desc			char(50);
define _no_documento		char(21);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_formapag		char(3);
define _saldo60_mas_ac		dec(16,2);
define _saldo60_mas			dec(16,2);
define _len_email			smallint;
define _cnt_polizas			smallint;
define _len_climail			smallint;
define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
define _mail_secuencia		integer;
define _error_isam			integer;
define _secuencia			integer;
define _count_cor			integer;
define _mail_err			integer;
define _error				integer;
define _count				integer;

set isolation to dirty read;
--set debug file to "sp_cob260.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select par_periodo_ant 
  into _periodo
  from parparam;
  
foreach
	select cod_cliente,
		   e_mail
	  into _cod_cliente,
		   _email
	  from cliclien
	
	select count(*)
	  into _cnt_polizas
	  from emipomae 
	 where cod_formapag in ('083','089','056','004','003','006','008','084')
	   and actualizado = 1
	
	if _cnt_polizas < 1 then
		continue foreach;
	end if
	
	foreach
		select distinct no_documento
		  into _no_documento
		  from emipomae 
		 where cod_formapag in ('083','089','056','004','003','006','008','084')
		   and actualizado = 1
		
		call sp_sis21(_no_documento) returning _no_poliza;		
	end foreach
end foreach