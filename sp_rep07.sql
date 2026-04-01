-- Procedimiento que genera preliminar con pólizas  que tienen 16 dias sin pagos filtrado por agentes
-- Creado    : 02/06/2015 -- Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rep07;

create procedure "informix".sp_rep07()
returning varchar(10),
		  varchar(250),
		  varchar(50);

-- Actualizar Polizas Nuevas

define _error_desc	    	varchar(100);
define _nombre_forma_pag    varchar(30);
define _no_poliza       	varchar(10);
define _no_documento    	varchar(20);
define _cod_agente          varchar(100);
define _email_cobros		varchar(250);
define _email_agtmail		varchar(50);
define _email               varchar(50);
define _nombre_agente       varchar(50);

define _cnt                 integer;
define _cantidad            integer;
define _error		    	integer;

set isolation to dirty read;

--set debug file to "sp_repo06.trc";
--trace on;

drop table if exists tmp_codigos;
create temp table tmp_codigos(
codigo	char(25)  not null,
primary key (codigo)) with no log;

select count(*)
  into _cantidad
  from tmp_caspoliza;

if _cantidad > 0 then	  
	foreach
		select no_documento
		  into _no_documento   
		  from tmp_caspoliza
		 order by no_documento asc
		 
		let _no_poliza = sp_sis21(_no_documento);
		
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
				select count(*)
				  into _cnt
				  from tmp_codigos
				 where codigo = _cod_agente;
					if _cnt = 0 then
						insert into tmp_codigos(codigo)
						values(_cod_agente);
					end if
		end foreach
	end foreach		
end if
foreach
	select trim(codigo)
	  into _cod_agente
	  from tmp_codigos

		select nombre, 
			   email_cobros
		  into _nombre_agente,
			   _email
		  from agtagent
		 where cod_agente = _cod_agente
		   and e_mail is not null
		   and e_mail <> " ";

		if _email is null or trim(_email) = "" then
			continue foreach;
		end if

		let _email_cobros = trim(_email) || ';'; 

		foreach
			Select email
			  into _email_agtmail
			  from agtmail
			 where cod_agente = _cod_agente
			   and tipo_correo = 'COB'
			
				if trim(_email_agtmail) = '' or _email_agtmail is null then
					continue foreach;
				end if
			 	if _email_agtmail = _email then
			 		continue foreach;
			 	else
					let _email_cobros = trim(_email_cobros) || trim(_email_agtmail) || ';';
				end if
		end foreach
		return _cod_agente,
			   _email_cobros,
		       _nombre_agente
			   WITH RESUME;
end foreach
end procedure;