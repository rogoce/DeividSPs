-- Verificación de emireaco
-- Creado : 13/01/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis438;		

create procedure "informix".sp_sis438()
returning	integer		as error,
			char(255)	as error_desc;

define _cantidad		integer;

define _error_desc		varchar(255);
define _no_documento	varchar(21);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _saldo_cobmoros	dec(16,2);
define _cnt_contrato	smallint;
define _no_cambio		smallint;
define _error			integer;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al Generar el Reaseguro de la Transaccion";
end exception

drop table if exists tmp_excepcion;
create temp table tmp_excepcion(
no_documento	char(21),
no_poliza		char(10),
no_unidad		char(5)) with no log;

foreach with hold
	select no_documento,
		   no_poliza
	  into _no_documento,
		   _no_poliza
	  from emipomae
	 where cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)

	begin work;

	--let _no_poliza = sp_sis21(_no_documento);

	select saldo_pxc
	  into _saldo_cobmoros
	  from deivid_cob:cobmoros2
	 where periodo = '2016-08'
	   and no_documento = _no_documento;

	if abs(_saldo_cobmoros) < 5.00 then
		commit work;
		continue foreach;
	end if

	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		select count(*)
		  into _cnt_contrato
		  from emireaco e, reacomae c
		 where e.cod_contrato = c.cod_contrato
		   and e.no_poliza = _no_poliza
		   and e.no_unidad = _no_unidad
		   and e.no_cambio = _no_cambio
		   and c.tipo_contrato <> 3
		   and e.cod_contrato not in ('00647','00648','00649');

		if _cnt_contrato is null then
			let _cnt_contrato = 0;
		end if

		if _cnt_contrato > 0 then
			insert into tmp_excepcion
			values(_no_documento,_no_poliza,_no_unidad);
		end if
	end foreach

	commit work;
end foreach
end
end procedure;