-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro545_test;

create procedure sp_pro545_test(a_no_documento	char(20))
returning	int,
			char(50);

define _error_desc		char(50);
define _documento		char(10);
define _no_remesa		char(10);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_endomov		char(3);
define _tipo_doc		char(1);
define _cnt_credito		smallint;
define _renglon			smallint;
define _fecha_emision	date;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table if exists tmp_movimientos;
	drop table if exists tmp_emiletra;

	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_documento) || trim(_error_desc);
	return _error, _error_desc;
end exception

--set debug file to "sp_pro545.trc";
--trace on;
drop table if exists tmp_movimientos;

create temp table tmp_movimientos (
no_poliza	char(10),
documento	char(10),
renglon		smallint default 0,
fecha		date,
tipo		char(1)) with no log;

let _error_desc = '';
let _documento = '';
let _no_poliza = '';


{foreach with hold
	select distinct no_documento
	  into a_no_documento
	  from emipomae
	 where no_documento in (select distinct no_documento from endedmae where no_endoso = '00000' and activa = 0)
	begin work;}

foreach with hold
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_inic

	--begin work;
	drop table if exists tmp_emiletra;

	select *
	  from emiletra
	 where no_poliza = _no_poliza
	 into temp tmp_emiletra;
	 
	--call sp_pro525(_no_poliza) returning _error,_error_desc;
	call sp_pro525_test(_no_poliza) returning _error,_error_desc;

	if _error <> 0 then	
		drop table if exists tmp_movimientos;
		drop table if exists tmp_emiletra;
		return _error,_error_desc;
	end if
	
	insert into tmp_movimientos(no_poliza,documento,fecha,tipo)
	select p.no_poliza,
		   p.no_requis,
		   c.fecha_impresion,
		   'Q'
	  from chqchpol p, chqchmae c
	 where c.no_requis = p.no_requis
	   and p.no_poliza = _no_poliza
	   and c.anulado = 0
	  order by c.fecha_impresion;

	insert into tmp_movimientos(no_poliza,documento,fecha,tipo)
	select no_poliza,
		   no_endoso,
		   fecha_emision,
		   'E'
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso <> '00000'
	   and actualizado = 1
	   and activa = 1
	   and prima_bruta <> 0.00
	   and fecha_emision < '08/10/2019'
	 order by fecha_emision;

	insert into tmp_movimientos(no_poliza,documento,renglon,fecha,tipo)
	select d.no_poliza,
		   d.no_remesa,
		   d.renglon,
		   m.date_posteo,
		   'C'
	  from cobremae m, cobredet d
	 where m.no_remesa = d.no_remesa
	   and d.no_poliza = _no_poliza
	   and m.actualizado = 1
	   and m.tipo_remesa in ('A','M','C','J','H','T','B','F')
	   and d.tipo_mov in ('P','N','X')
	   and m.date_posteo < '08/10/2019'
	 order by date_posteo;
	
	foreach
		select documento,
			   renglon,
			   fecha,
			   tipo
		  into _documento,
			   _renglon,
			   _fecha_emision,
			   _tipo_doc
		  from tmp_movimientos
		 where no_poliza = _no_poliza
		 order by fecha,tipo desc

		if _tipo_doc = 'E' then --Endosos

			select cod_endomov
			  into _cod_endomov
			  from endedmae
			 where no_poliza = _no_poliza
			   and no_endoso = _documento;

			if _cod_endomov = '014' then --Endoso de Facturación Mensual de Salud
				call sp_pro541b(_no_poliza,_documento) returning _error,_error_desc;
				
				if _error <> 0 then
					--rollback work;
					return _error, _error_desc;
				end if
			else 				
				call sp_pro541(_no_poliza,_documento) returning _error,_error_desc;
				
				if _error <> 0 then
					--rollback work;
					return _error, _error_desc;
				end if
			end if

		elif _tipo_doc = 'C' then --Cobros
			call sp_cob343a(_documento,_renglon) returning _error,_error_desc;

			if _error <> 0 then	
				--rollback work;
				return _error, _error_desc;
			end if

		elif _tipo_doc = 'Q' then --Cheques de Devolución de Prima
			call sp_che161(_no_poliza,_documento) returning _error,_error_desc;
				
			if _error <> 0 then
				--rollback work;
				return _error, _error_desc;
			end if
		end if
	end foreach

	--commit work;
	drop table if exists tmp_emiletra;
end foreach
{
let _cnt_credito = 0;
select count(*)
  into _cnt_credito
  from emiletra
 where no_documento = a_no_documento
   and monto_pen < 0;

if _cnt_credito is null then
	let _cnt_credito = 0;
end if

if _cnt_credito > 0 then
	--call sp_cob346a(a_no_documento) returning _error,_error_desc;
end if

delete from tmp_movimientos;
--end foreach}
drop table if exists tmp_movimientos;

return 0, "Actualizacion Exitosa";
end
end procedure;