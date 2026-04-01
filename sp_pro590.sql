-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro590;

create procedure sp_pro590(a_no_poliza char(10))
returning	integer		as resultado,
			varchar(30)	as descripcion;
			
			
define _error_desc		char(50);
define _documento		char(10);
define _no_documento	char(20);
define _no_remesa		char(10);
define _no_poliza		char(10);
define _cod_agente			char(5);
define _no_endoso			char(5);
define _cod_ramo			char(3);
define _tipo_doc			char(1);
define _estatus_poliza		smallint;
define _valor		smallint;
define _no_vigencias		smallint;
define _clasificacion		smallint;
define _no_pagos			smallint;
define _cnt_cob			smallint;
define _vigencia_inic	date;
define _vigencia_final	date;
define _error_isam		integer;
define my_sessionid		integer;
define _error			integer;
define _porc_partic_agt		dec(9,6);
define _porc_comis_agt		dec(9,6);
define _prima_neta_cob		dec(16,2);
define _mto_comision		dec(16,2);
define _monto_cob		dec(16,2);
define _prima_neta		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_cedida		dec(16,2);
define _prima_bruta		dec(16,2);
define _monto2		dec(16,2);



set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc	
	return _error,		  
		   _error_desc;
end exception


--set debug file to "sp_pro590.trc";
--trace on;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo = '002' then

else
	select count(
end if

end
end procedure;