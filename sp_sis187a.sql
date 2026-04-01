-- Procedimiento que Trae los correos de los Clientes y Corredores para el envío de información Semanal
-- creado    : 24/06/2013 - Autor: Román Gordón
-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis187a;
create procedure "informix".sp_sis187a() 
returning	char(1),
			char(10),
			varchar(100);         

define _email			varchar(100);
define _cod_cliente		char(10);
define _tipo_codigo		char(1);
define _tiene_imp_orig	smallint;
define _cnt				smallint;

--set debug file to "sp_sis187.trc"; 
--trace on;    

--return '','','';

let _cnt = 0;

foreach
	select tipo_codigo,
		   cod_cliente,
		   email
	  into _tipo_codigo,
		   _cod_cliente,
		   _email
	  from tmp_correos
	 where enviado = 0
	
	let _email = trim(_email);

	return _tipo_codigo,
		   _cod_cliente,
		   _email
	with resume;
end foreach
--drop table tmp_correos;
end procedure


