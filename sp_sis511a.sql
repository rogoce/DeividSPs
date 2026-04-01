-- Procedimiento de validación de actualización de datos de Clientes
-- Creado: 10/08/2022 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis511a;
create procedure sp_sis511a(a_cod_contratante char(10)) 
returning smallint		as actualizar;

define _contratante			varchar(100);
define _error_desc			varchar(50);
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

return 0;


update cliclien
   set e_mail = e_mail,
	   celular = celular
 where cod_cliente = a_cod_contratante;

return 0;

end procedure;