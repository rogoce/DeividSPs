-- Procedimiento que Determina el Reaseguro para un Cheque de Devolución de Prima
-- 
-- Creado    : 06/09/2013 - Autor: Román Gordon


drop procedure sp_sis188c;

create procedure "informix".sp_sis188c(a_no_poliza char(10),a_no_endoso char(5))--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _porc_cober_reas		dec(9,6);
define _proporcion			dec(9,6);
define _prima_cober_reas	dec(16,2);
define _prima_total			dec(16,2);
define _contador_ret		smallint;
define _ramo_sis			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _cnt                 smallint;

set isolation to dirty read;

--set debug file to "sp_sis188.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

create temp table tmp_dist_rea(
	no_poliza		char(10),
	cod_cober_reas	char(3),
	porc_cober_reas	dec(9,6)) with no log;

-- Lectura de la Distribución de Reaseguro de la Póliza

select no_documento,
	   cod_ramo
  into _no_documento,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
 
let _flag = 0;
let _prima_total = 0;

{foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso

		select sum(prima_neta)
		  into _prima_total
		  from endedcob
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;

		if _prima_total <> 0 then
			let _flag = 1;
			exit foreach;
		end if
end foreach	}

		select sum(prima_neta)
		  into _prima_total
		  from endedcob
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

let _cod_cober_reas = null;
   
foreach
	select c.cod_cober_reas,
		   sum(e.prima_neta)
	  into _cod_cober_reas,
		   _prima_cober_reas
	  from endedcob e, prdcober c
	 where e.no_poliza = a_no_poliza
--	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	 group by c.cod_cober_reas
		
	let _proporcion = 0.00;

	if _prima_cober_reas = 0 then
	   let _prima_cober_reas = _prima_total;
	end if
	if _prima_total <> 0 then
		let _proporcion = (_prima_cober_reas/_prima_total) * 100;
	end if
		
	insert into tmp_dist_rea(
			no_poliza,
			cod_cober_reas,
			porc_cober_reas)
	values	(a_no_poliza,
			_cod_cober_reas,
			_proporcion);			
end foreach

select count(*)
  into _cnt
  from tmp_dist_rea
 where no_poliza = a_no_poliza;

select sum(porc_cober_reas)
  into _porc_cober_reas
  from tmp_dist_rea
 where no_poliza = a_no_poliza;

if _cnt = 1 and _porc_cober_reas = 0 then

	update tmp_dist_rea
	   set porc_cober_reas = 100
	 where no_poliza = a_no_poliza;

end if

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end
end procedure;
