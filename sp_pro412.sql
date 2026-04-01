-- Procedimiento verificar email en cliclien
-- Creado: 22/06/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro412('01/01/2018')

drop procedure sp_pro412;
create procedure sp_pro412(a_fecha date)
returning	char(10)	as cliente,
			char(100)	as nombre,
			varchar(50)	as email,
			char(10)	as telefono,
			char(10)	as celular,
			date		as fecha_modifica;

define _nombre		varchar(100);
define _e_mail2		varchar(50);          
define _e_mail		varchar(50);          
define _cod_cliente	char(10);
define _telefono1	char(10);
define _telefono2	char(10);
define _telefono3	char(10);
define _celular		char(10);
define _fecha_modif	date;
define _fecha_limite	date;

--set debug file to "sp_pro412.trc";
--trace on;

set isolation to dirty read;

let _fecha_limite = today - 2 units year;

foreach with hold
	select distinct trim(c.cod_cliente),
		   trim(c.nombre),
		   trim(c.e_mail),
		   trim(c.telefono1),
		   trim(c.telefono2),
		   trim(c.telefono3),
		   trim(c.celular)
	  into _cod_cliente,
		   _nombre,
		   _e_mail,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _celular
	  from cliclien c, emipoliza e
	 where c.cod_cliente = e.cod_pagador
       and (e.cod_status = 1 or (e.cod_status = 3 and e.vigencia_fin >= a_fecha))
       and trim(c.e_mail) is not null
       and c.e_mail not in (select e_mail from insuser where (status = 'A' or (status = 'I' and fvac_out is not null)) and e_mail is not null and trim(e_mail) <> '')
	   
 {  and c.cod_cliente not in (select distinct c.cod_cliente
                         from cliclien c, emipoliza e
                        where c.cod_cliente = e.cod_pagador
                          and (e.cod_status = 1 or (e.cod_status = 3 and e.vigencia_fin >= a_fecha))
                          and c.e_mail is not null
                          and e_mail not like '%/%'
                          and e_mail <> ''
                          and e_mail like '%@%'
                          and e_mail like '%.%'
                          and e_mail not like '@%'
                          and e_mail not like '% %'
                          and e_mail not like '%,%') }
    --order by 3,2 --e_mail,nombre

	if trim(_e_mail) is null or trim(_e_mail) = '' then		--se excluye nulos
		continue foreach;
	end if
	
	let _fecha_modif = null;	

	select max(date(fecha_modif))
	  into _fecha_modif
	  from clibitacora
	 where cod_cliente = _cod_cliente 
	   --and date_changed >= _fecha_limite
	   and e_mail <> _e_mail;

	return _cod_cliente,_nombre,_e_mail,_telefono1,_celular,_fecha_modif with resume;	
end foreach
end procedure;