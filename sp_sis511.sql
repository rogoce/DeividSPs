-- Procedimiento de validación de actualización de datos de Clientes
-- Creado: 10/08/2022 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis511;
create procedure sp_sis511(a_no_documento char(20)) 
returning smallint		as actualizar,
		  char(10)		as cod_contratante,
		  varchar(100)	as contratante,
		  varchar(50)	as email,
		  char(10)		as celular,
		  integer		as dias,
		  varchar(50)	as cedula;

define _contratante			varchar(100);
define _error_desc			varchar(50);
define _cedula				varchar(50);
define _email				varchar(50);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _celular				char(10);
define _cod_tipoprod		char(3);
define _cobra_poliza		char(1);
define _cod_formapag		char(3);
define _cod_cobrador		char(3);
define _dias_act			integer;
define _error				integer;
define _error_isam			integer;
define _dias_control		smallint;
define _today	        	date;


set isolation to dirty read;

--set debug file to "sp_sis511.trc";
--trace on;

--if a_no_documento = '0221-01800-01' then
--else
--	return 0,'','','','',0,'';
--end if

let _today = current;
let _dias_control = 90;

--if a_no_documento = '0221-01800-01' then
	let _no_poliza = sp_sis21(a_no_documento);
	
	select emi.cod_contratante,
		   cli.cedula,
		   cli.nombre,
		   cli.e_mail,
		   cli.celular,
		   _today - cli.date_changed
	  into _cod_contratante,
		   _cedula,
		   _contratante,
		   _email,
		   _celular,
		   _dias_act
	  from emipomae emi
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 where emi.no_poliza = _no_poliza
	   and _today - cli.date_changed > _dias_control;		   

--end if
if _dias_act is null then
	let _dias_act = 0;
end if

if _dias_act > 0 then
	return 1,_cod_contratante,_contratante,_email,_celular,_dias_act,_cedula;
else
	return 0,'','','','',0,'';
end if
end procedure;