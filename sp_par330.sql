-- Procedimiento que divide los corredores entre los que participan en el adelanto de comisiones y los que no.
-- Creado    : 13/11/2012 - Autor: Roman Gordon

-- SIS v.2.0 - d_para_agentes - DEIVID, S.A.

drop procedure sp_par330;

create procedure "informix".sp_par330(a_cod_agente char(255))
returning	varchar(255),
 			varchar(255);

define _cod_agente_si	varchar(255);
define _cod_agente_no	varchar(255);
define _cod_agente		char(5);
define _tipo			char(1);
define _adelanto_comis	smallint;
define _cnt_existe		smallint;

let _cod_agente_si = '';
let _cod_agente_no = '';

if a_cod_agente = "*" then
	select count(*)
	  into _cnt_existe
	  from agtagent
	 where adelanto_comis = 1;

	if _cnt_existe > 0 then
		foreach
			select cod_agente
			  into _cod_agente
			  from agtagent
			 where adelanto_comis = 1
			 order by cod_agente
			
			if _cod_agente_si = '' or _cod_agente_si is null then
				let _cod_agente_si = _cod_agente_si || trim(_cod_agente);
			else
				let _cod_agente_si = _cod_agente_si || ',' || trim(_cod_agente);
			end if
		end foreach

		let _cod_agente_no = _cod_agente_si || ';E';
		let _cod_agente_si = _cod_agente_si || ';';
	else
		let _cod_agente_si = '';
		let _cod_agente_no = '*'; 
	end if
else
		
	let _tipo = sp_sis04(a_cod_agente);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros
		foreach
			select cod_agente,
				   adelanto_comis	
			  into _cod_agente,
				   _adelanto_comis	
			  from agtagent
			 where cod_agente in (select codigo from tmp_codigos)
			 order by cod_agente

			if _adelanto_comis = 1 then
				if _cod_agente_si = '' or _cod_agente_si is null then
					let _cod_agente_si = _cod_agente_si || trim(_cod_agente);
				else
					let _cod_agente_si = _cod_agente_si || ',' || trim(_cod_agente);
				end if	
			else
				if _cod_agente_no = '' or _cod_agente_no is null then
					let _cod_agente_no = _cod_agente_no || trim(_cod_agente);
				else
					let _cod_agente_no = _cod_agente_no || ',' || trim(_cod_agente);
				end if
			end if
		end foreach
	else		        -- excluir estos registros
		foreach
			select cod_agente,
				   adelanto_comis	
			  into _cod_agente,
				   _adelanto_comis	
			  from agtagent
			 where cod_agente in (select codigo from tmp_codigos)
			   and adelanto_comis = 1
			 order by cod_agente

			if _cod_agente_si = '' or _cod_agente_si is null then
				let _cod_agente_si = _cod_agente_si || trim(_cod_agente);
			else
				let _cod_agente_si = _cod_agente_si || ',' || trim(_cod_agente);
			end if	
		end foreach
		
		foreach
			select cod_agente
			  into _cod_agente
			  from agtagent
			 where cod_agente in (select codigo from tmp_codigos)
			   and adelanto_comis = 0

			if _cod_agente_no = '' or _cod_agente_no is null then
				let _cod_agente_no = _cod_agente_no || trim(_cod_agente);
			else
				let _cod_agente_no = _cod_agente_no || ',' || trim(_cod_agente);
			end if
		end foreach
	end if
	drop table tmp_codigos;

	if _cod_agente_si is not null and _cod_agente_si <> '' then
		let _cod_agente_si = _cod_agente_si || ';';
		if _tipo = 'E' then
			let _cod_agente_si = _cod_agente_si || 'E';
		end if
	end if

	if _cod_agente_no is not null and _cod_agente_no <> '' then
		let _cod_agente_no = _cod_agente_no || ';';
		if _tipo = 'E' then
			let _cod_agente_no = _cod_agente_no || 'E';
		end if

	end if
end if

return _cod_agente_no,
	   _cod_agente_si;
end procedure	
		


