-- Creacion de las letras de pago de las polizas por nueva ley de seguros
-- Creado    : 08/01/2015 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro525j;
create procedure sp_pro525j(a_vigencia_inic date, a_vigencia_final date)
returning	char(20)	as Poliza,				--_no_documento
			char(3)		as Cod_Ramo,			--_cod_ramo,
			varchar(50)	as Ramo,				--_nom_ramo,
			integer		as Letra,				--_no_letra,
			date		as Vigencia_Inic_Letra,	--_vigencia_inic
			date		as Fecha_Pago,			--_fecha_pago			
			integer		as Dias_Pago;			--_dias_pago,

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
define _pagada				smallint;
define _error_isam			integer;
define _dias_letra			integer;
define _dias_pago			integer;
define _cantidad			integer;
define _no_letra			integer;
define _error				integer;
define _fecha_vencimiento	date;
define _vigencia_inic		date;
define _fecha_pago			date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _no_documento,'',_error_desc,_error,_error_isam,0,0.00;
end exception

--set debug file to "sp_pro525j.trc";
--trace on;

foreach with hold
	select no_poliza,
		   no_documento,
		   no_letra,
		   vigencia_inic,
		   fecha_pago
	  into _no_poliza,
		   _no_documento,
		   _no_letra,
		   _vigencia_inic,
		   _fecha_pago
	  from emiletra
	 where vigencia_inic between a_vigencia_inic and a_vigencia_final
	 order by vigencia_inic

	begin work;

	if _fecha_pago is null or _fecha_pago = '' then
		commit work;
		continue foreach;
	end if
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _dias_pago = 0.00;
	let _dias_pago = _fecha_pago - _vigencia_inic;
	
	if _dias_pago < 0 then
		let _dias_pago = 0.00;
		commit work;
		continue foreach;
	end if
	
	{begin
	on exception in(-239)
		update tmp_ramos
		   set cantidad = cantidad + 1,
		       dias_pago = dias_pago + _dias_pago
		 where cod_ramo = _cod_ramo
		   and no_letra = _no_letra;
	end exception
		insert into tmp_ramos
		values(	_cod_ramo,
				_no_letra,
				_nom_ramo,
				_dias_pago,
				1);
	end}
	commit work;
	return _no_documento,
		   _cod_ramo,
		   _nom_ramo,
		   _no_letra,
		   _vigencia_inic,
		   _fecha_pago,
		   _dias_pago with resume;
end foreach

{foreach
	select cod_ramo,
		   nom_ramo,
		   no_letra,
		   cantidad,
		   sum(dias_pago)
	  into _cod_ramo,
		   _nom_ramo,
		   _no_letra,
		   _cantidad,
		   _dias_pago
	  from tmp_ramos
	 group by 1,2,3,4

	let _promedio_pagos = _dias_pago/_cantidad;

	return _cod_ramo,
		   _nom_ramo,
		   _no_letra,
		   _cantidad,
		   _dias_pago,
		   _promedio_pagos with resume;
end foreach

drop table tmp_ramos;}
end
end procedure;