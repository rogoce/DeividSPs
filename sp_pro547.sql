-- Creacion de las letras de pago de las polizas por nueva ley de seguros
-- Creado    : 08/01/2015 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro547;
create procedure sp_pro547()
returning	int,
			char(50);

define _nom_ramo			varchar(50);
define _error_desc			char(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_ramo			char(3);
define _promedio_pagos		dec(16,2);
define _monto_letra			dec(16,2);
define _monto_pag			dec(16,2);
define _monto_pen			dec(16,2);
define _poliza_cancelada	smallint;
define _aviso_enviado		smallint;
define _estatus_pol			smallint;
define _pagada				smallint;
define _error_isam			integer;
define _dias_letra			integer;
define _dias_pago			integer;
define _cantidad			integer;
define _no_letra			integer;
define _error				integer;
define _fecha_vencimiento	date;
define _cancelar_poliza		date;
define _periodo_gracia		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_aviso			date;
set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

--set debug file to "sp_pro525b.trc";
--trace on;

foreach
	select no_poliza,
		   no_letra,
	  into _no_poliza,
		   _no_letra
	  from emiletra
	 where pagada = 1
	   and fecha_pago is null
	   and vigencia_inic >= '01/01/2013'

	select estatus_poliza,
	  into _estatus_pol
	  from emipomae
	 where no_poliza = _no_poliza;
end foreach

end
end procedure;