-- Procedimiento email por ramo 
-- Creado: 20/07/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro413('018;')

drop procedure sp_pro413;
create procedure sp_pro413( a_ramo char(255) default "*")
returning	varchar(50)	as email;

define _nombre		varchar(100);
define _e_mail2		varchar(50);          
define _e_mail		varchar(50);          
define _cod_cliente	char(10);
define _telefono1	char(10);
define _telefono2	char(10);
define _telefono3	char(10);
define _celular		char(10);



define v_filtros     char(255);
define _tipo         char(1);

--set debug file to "sp_pro412.trc";
--trace on;

set isolation to dirty read;

drop table if exists tmp_codigos;
drop table if exists tmp_ramo;

let v_filtros = '';

CREATE TEMP TABLE tmp_ramo(
		cod_ramo  CHAR(3)   NOT NULL,
		PRIMARY KEY (cod_ramo)
		) WITH NO LOG;
		
if a_ramo <> "*" then

	let v_filtros = trim(v_filtros) || " Ramo: " ||  trim(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos  

	if _tipo <> "E" then -- (I) Incluir los Registros
		BEGIN
		ON EXCEPTION IN(-239)			
		END EXCEPTION
			INSERT INTO tmp_ramo(
			cod_ramo)
			select cod_ramo from prdramo
			 where cod_ramo in (select codigo from tmp_codigos);
		 END
		 
	else		        -- (E) Excluir estos Registros
		BEGIN
		ON EXCEPTION IN(-239)			
		END EXCEPTION
			INSERT INTO tmp_ramo(
			cod_ramo)
			select cod_ramo from prdramo
			 where cod_ramo not in (select codigo from tmp_codigos);
		 END
		
	end if
	drop table tmp_codigos;
else
BEGIN
		ON EXCEPTION IN(-239)			
		END EXCEPTION
			INSERT INTO tmp_ramo(
			cod_ramo)
			select cod_ramo from prdramo;
		 END	
end if

foreach with hold	   
	select distinct trim(lower(c.e_mail))
	  into _e_mail
	 from cliclien c, emipoliza e
	where c.cod_cliente = e.cod_pagador
	  and (e.cod_status = 1 ) --or (e.cod_status = 3 and e.vigencia_fin >= a_fecha))
	  and e.cod_ramo in (select t.cod_ramo from tmp_ramo t)
	  and c.e_mail is not null
	  and e_mail not like '%/%'
	  and e_mail <> ''
	  and e_mail like '%@%'
	  and e_mail like '%.%'
	  and e_mail not like '@%'
	  and e_mail not like '% %'
	  and e_mail not like '%,%' 
	  and c.e_mail not in (select e_mail from insuser where (status = 'A' or (status = 'I' and fvac_out is not null)) and e_mail is not null and trim(e_mail) <> '')
    order by 1

	if trim(_e_mail) is null or trim(_e_mail) = '' then		--se excluye nulos
		continue foreach;
	end if

	return _e_mail with resume;	
end foreach
--drop table tmp_codigos;
drop table tmp_ramo;
end procedure;