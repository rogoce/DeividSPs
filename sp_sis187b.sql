-- Procedimiento que Trae los correos de los Clientes y Corredores para el envío de información Semanal
-- creado    : 24/06/2013 - Autor: Román Gordón
-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis187b;
create procedure "informix".sp_sis187b(a_tipo_envio char(1)) 
returning	integer,
			varchar(255);

define _error_desc		varchar(255);
define _email			varchar(100);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _cod_subramo		char(3);
define _cod_ramo		char(3);
define _tipo_codigo		char(1);
define _cnt_tmp_correo	smallint;
define _status_pol		smallint;
define _cnt_poliza		smallint;
define _cnt_cober		smallint;
define _es_salud		smallint;
define _es_cinta		smallint;
define _ramo_sis		smallint;
define _es_auto			smallint;
define _cnt				smallint;
define _flag			smallint;
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_sis187.trc"; 
--trace on;    


let _cnt = 0;
let _es_salud = 1;
let _es_auto = 0;
let _es_cinta = 1;
{create table tmp_correos(
		cod_cliente	char(10)  not null,
		tipo_codigo	char(1),
		email		varchar(100),
		enviado		smallint,
		primary key (tipo_codigo,cod_cliente)
		);
create index idx_tmp_correos on tmp_correos(enviado);	}

{insert into tmp_correos values ('00000','A','rgordon@asegurancon.com',0);
return 0,'Carga de Correos Exitosa';}


begin
on exception set _error, _error_isam, _error_desc 
 	return _error, _error_desc; 
end exception

--return 0,'';

delete from tmp_correos where enviado = 0;

--Se le Envia a Cliente 
if a_tipo_envio in ('C','B') then
	foreach
		select distinct trim(e_mail)
		  into _email
		  from cliclien
		 where e_mail is not null
		   and e_mail not like '%/%'
		   and e_mail <> ''
		   and e_mail like '%@%'
		   and e_mail not like '@%'
		   and e_mail not like '% %'
		   and e_mail not like '%,%'

		let _flag = 0;

		select count(*)
		  into _cnt_tmp_correo
		  from tmp_correos
		 where trim(email) = _email;

		if _cnt_tmp_correo is null then
			let _cnt_tmp_correo = 0;
		end if
		
		if _cnt_tmp_correo > 0 then
			continue foreach;
		end if

		foreach
			select cod_cliente
			  into _cod_cliente
			  from cliclien
			 where e_mail = _email

			select count(*)
			  into _cnt_poliza
			  from emipomae
			 where (cod_pagador	= _cod_cliente
				or cod_contratante	= _cod_cliente)
			   and estatus_poliza = 1
			   and actualizado  = 1;

			if _cnt_poliza  = 0 then
				foreach
					select no_poliza
					  into _no_poliza
					  from emipouni
					 where cod_asegurado = _cod_cliente
					   and activo = 1

					select cod_ramo,
						   estatus_poliza,
						   cod_subramo
					  into _cod_ramo,
						   _status_pol,
						   _cod_subramo
					  from emipomae
					 where no_poliza = _no_poliza;

					select ramo_sis
					  into _ramo_sis
					  from prdramo
					 where cod_ramo = _cod_ramo;

					if _es_salud = 1 then
						if _cod_ramo <> '018' then
							continue foreach;
						end if
						
						if _es_cinta = 1 then
							if _cod_subramo not in ('008','007','009','018','012','014','011') then
								continue foreach;
							elif _cod_subramo = '012' then
								let _cnt_cober = 0;

								select count(*)
								  into _cnt_cober
								  from emipocob
								 where no_poliza = _no_poliza
								   and cod_cobertura = '00929';

								if _cnt_cober is null then
									let _cnt_cober = 0;
								end if
								
								if _cnt_cober = 0 then
									continue foreach;
								end if
							end if
						end if 
					end if
					
					if _es_auto = 1 then
						if _ramo_sis <> 1 then
							continue foreach;
						end if
					end if

					if _status_pol = 1 then
						let _flag = 1;
						exit foreach;
					end if
				end foreach;
			else
				foreach
					select no_poliza,
						   cod_ramo,
						   cod_subramo
					  into _no_poliza,
						   _cod_ramo,
						   _cod_subramo
					  from emipomae
					 where (cod_pagador	= _cod_cliente
						or cod_contratante	= _cod_cliente)
					   and estatus_poliza = 1
					   and actualizado  = 1

					if _es_salud = 1 then
						if _cod_ramo <> '018' then
							continue foreach;
						end if
						
						if _es_cinta = 1 then
							if _cod_subramo not in ('008','007','009','018','012','014','011') then
								continue foreach;
							elif _cod_subramo = '012' then
								let _cnt_cober = 0;

								select count(*)
								  into _cnt_cober
								  from emipocob
								 where no_poliza = _no_poliza
								   and cod_cobertura = '00929';

								if _cnt_cober is null then
									let _cnt_cober = 0;
								end if
								
								if _cnt_cober = 0 then
									continue foreach;
								end if
							end if
						end if 
					end if
					
					select ramo_sis
					  into _ramo_sis
					  from prdramo
					 where cod_ramo = _cod_ramo;
					 
					if _es_auto = 1 then
						if _ramo_sis <> 1 then
							continue foreach;
						end if
					end if
					
					let _flag = 1;
					exit foreach;
				end foreach
			end if

			if _flag = 1 then
				insert into tmp_correos
				values (_cod_cliente,'C',_email,0);
				exit foreach;
			end if
		end foreach
	end foreach
end if

--Se le envia a Corredores
if a_tipo_envio in ('A','B') then
	foreach
		select distinct e_mail,
			   cod_agente
		  into _email,
			   _cod_cliente
		  from agtagent
		 where estatus_licencia = 'A'
		   and email_reclamo is not null
		   and email_reclamo <> ''
		   and email_reclamo like '%@%'

		let _cnt = 0;
		
		select count(*)
		  into _cnt
		  from tmp_correos
		 where email = _email;

		if _cnt = 0 then
			insert into tmp_correos
			values (_cod_cliente,'A',_email,0);
		end if
	end foreach
end if

return 0,'Carga de Correos Exitosa';
{foreach
	select tipo_codigo,
		   cod_cliente,
		   email
	  into _tipo_codigo,
		   _cod_cliente,
		   _email
	  from tmp_correos

	let _email = trim(_email);

	return _tipo_codigo,
		   _cod_cliente,
		   _email
	with resume;
end foreach}


--drop table tmp_correos;
end
end procedure


