-- insercion de los correos para los estados de cuenta de manera masiva en parmailsend
-- creado por :    roman gordon	05/01/2011
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob260b;

create procedure "informix".sp_cob260b()
returning	char(20),
            dec(16,2),
			char(10);				

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
define _flag				smallint;
define _len_email			smallint;
define _len_climail			smallint;
define _cnt_asegurado		smallint;
define _cnt_existe			smallint;
define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
define _mail_secuencia		integer;
define _secuencia_ase		integer;
define _error_isam			integer;
define _secuencia			integer;
define _count_cor			integer;
define _mail_err			integer;
define _error				integer;
define _count				integer;
define _contador            smallint;

set isolation to dirty read;
--set debug file to "sp_cob260b.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _no_documento;
end exception

let _flag = 0;
let _saldo60_mas = 0.00;
let _saldo60_mas_ac = 0.00;
let _contador = 0;

select par_periodo_ant 
  into _periodo
  from parparam;
	
foreach	
	select distinct no_documento
	  into _no_documento
	  from emipomae 
	 where cod_formapag <> '084'
	   and actualizado = 1
	   and vigencia_final > today 
	   and fecha_suscripcion < today
	   --and no_documento = '0100-00003-03'
	    
		call sp_sis21(_no_documento) returning _no_poliza;
		
		select cod_pagador
		  into _cod_cliente
		  from emipomae
		 where no_poliza = _no_poliza;

--		select count(*)
--		  into _count
--		  from emipoliza
--		 where cod_pagador = _cod_cliente;

--		if _count = 1 then
			select (monto_60 + monto_90 + monto_120 + monto_150 + monto_180),
				   cod_formapag
			  into _saldo60_mas,
				   _cod_formapag
			  from emipoliza
			 where no_documento = _no_documento
			   and cod_formapag <> '084';
			 
			if _saldo60_mas is null then
				let _saldo60_mas = 0.00;
			end if

			if _saldo60_mas < 4.99 then
				continue foreach;
			end if

--		else
	{		select count(*)
			  into _count_cor
			  from emipomae
			 where cod_pagador = _cod_cliente
			   and cod_formapag = '008'
			   and vigencia_final > today 
			   and fecha_suscripcion < today;

			if _count_cor = _count then
			    let _saldo60_mas_ac = 0.00;
				
				foreach
					select (monto_60 + monto_90 + monto_120 + monto_150 + monto_180)
					  into _saldo60_mas
					  from emipoliza
					 where cod_pagador = _cod_cliente
			           and cod_formapag <> '084'
					 
					if _saldo60_mas is null then
						let _saldo60_mas = 0.00;
					end if					 
					
					let _saldo60_mas_ac = _saldo60_mas_ac + _saldo60_mas;					
				end foreach
				if _saldo60_mas_ac < 4.99 then
					continue foreach;
				end if
			end if
}			
--		end if
		
		let _email = '';
		select e_mail
		  into _email
		  from cliclien
		 where cod_cliente = _cod_cliente;
		
		let _email = trim(_email);

		foreach
			select email
			  into _email_climail
			  from climail
			 where cod_cliente = _cod_cliente
			let _len_email = length(_email); 
			let _len_climail = length(_email_climail);
			let _email = trim(_email) || ';' || trim(_email_climail);
		end foreach

		select count(*)
		  into _mail_err
		  from parmailerr
		 where email = _email;
		
		if _email is null or _email = '' or _mail_err > 0 then
			continue foreach;
		end if
		
		if _contador = 100 then
			exit foreach;
		end if
		
		let _contador = _contador + 1;
		
{		select count(*)
		  into _cnt_existe
		  from parmailsend
		 where cod_tipo = '00015'
		   and email = _email
		   and enviado = 0;
		   
		if _cnt_existe > 0 then
			foreach
				select secuencia
				  into _secuencia_ase
				  from parmailsend
				 where cod_tipo = '00015'
				   and email = _email
				   and enviado = 0
				   
				select count(*)
				  into _cnt_asegurado
				  from parmailcomp
				 where mail_secuencia = _secuencia_ase
				   and asegurado = _cod_cliente;
				
				if _cnt_asegurado > 0 then
					let _flag = 1;
					exit foreach;
				end if
			end foreach
			
			if _flag = 1 then
				let _flag = 0;
				continue foreach;
			end if
		end if
}		
	return _no_documento,_saldo60_mas, _cod_cliente with resume;	
end foreach

--return 0,'insercion correcta en parmailsend';

end
end procedure