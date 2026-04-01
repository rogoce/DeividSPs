-- Procedimiento que Determina el Reaseguro para una póliza
-- Creado    : 06/09/2013 - Autor: Román Gordon

drop procedure sp_sis188;
create procedure "informix".sp_sis188(a_no_poliza char(10))--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _porc_cober_reas		dec(9,7);
define _porc_proporcion		dec(9,7);
define _dif_proporcion		dec(9,7);
define _proporcion			dec(9,7);
define _prima_cober_reas	dec(16,2);
define _prima_total			dec(16,2);
define _contador_ret		smallint;
define _ramo_sis			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _cnt                 integer;

set isolation to dirty read;

--set debug file to "sp_sis188.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

drop table if exists tmp_dist_rea;
create temp table tmp_dist_rea(
	no_poliza		char(10),
	cod_cober_reas	char(3),
	porc_cober_reas	dec(10,6)) with no log;

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

--if _ramo_sis = 5 then
select sum(prima_neta)
  into _prima_total
  from emipocob
 where no_poliza = a_no_poliza;
{else
	select sum(prima_neta)
	  into _prima_total
	  from emipocob
	 where no_poliza = a_no_poliza;
end if}

let _cod_cober_reas = null;
   
foreach
	select p.cod_cober_reas,
		   sum(e.prima_neta)
	  into _cod_cober_reas,
		   _prima_cober_reas
	  from emipocob e, prdcober p
	 where e.no_poliza = a_no_poliza
	   and p.cod_cobertura = e.cod_cobertura
	 group by p.cod_cober_reas
	
	let _proporcion = 0.00;
	if _prima_total is null then
		let _prima_total = 0.00;
	end if			
	
	if _prima_total <> 0 then
		let _proporcion = (_prima_cober_reas/_prima_total) * 100;
	else
		select sum(e.prima_neta)
		  into _prima_total
		  from endedcob e, endedmae t
		 where e.no_poliza = t.no_poliza
		   and e.no_endoso = t.no_endoso
		   and t.no_poliza = a_no_poliza
		   and t.actualizado = 1;

		if _prima_total <> 0 then
			select sum(e.prima_neta)
			  into _prima_cober_reas
			  from endedcob e, prdcober p, endedmae t
			 where e.no_poliza = t.no_poliza
               and e.no_endoso = t.no_endoso
               and p.cod_cobertura = e.cod_cobertura
               and e.no_poliza = a_no_poliza
			   and p.cod_cober_reas = _cod_cober_reas
               and t.actualizado = 1
		     group by p.cod_cober_reas;

			let _proporcion = (_prima_cober_reas/_prima_total) * 100;
		end if
	end if
	
	insert into tmp_dist_rea(
			no_poliza,
			cod_cober_reas,
			porc_cober_reas)
	values	(a_no_poliza,
			_cod_cober_reas,
			_proporcion);			
end foreach

if _cod_cober_reas is null then
	foreach
		select p.cod_cober_reas,
			   sum(e.prima_neta)
		  into _cod_cober_reas,
			   _prima_cober_reas
		  from endedcob e, prdcober p
		 where e.no_poliza = a_no_poliza
		   and e.no_endoso = '00000'
		   and p.cod_cobertura = e.cod_cobertura
		 group by p.cod_cober_reas
		
		let _proporcion = 0.00;
		
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
end if

select sum(porc_cober_reas)
  into _porc_proporcion
  from tmp_dist_rea
 where no_poliza = a_no_poliza;

let _dif_proporcion = 100 - _porc_proporcion;

foreach
	select sum(porc_cober_reas),cod_cober_reas
	  into _porc_cober_reas,_cod_cober_reas
	  from tmp_dist_rea
	 where no_poliza = a_no_poliza
	 group by cod_cober_reas
    having sum(porc_cober_reas) = 0
	 
	if _porc_cober_reas = 0 then

		select sum(e.prima_neta)
		  into _prima_cober_reas
		  from endedcob e, prdcober p, endedmae t
		 where e.no_poliza = t.no_poliza
           and e.no_endoso = t.no_endoso
           and p.cod_cobertura  = e.cod_cobertura
           and t.actualizado    = 1
           and e.no_poliza      = a_no_poliza
		   and p.cod_cober_reas = _cod_cober_reas
	     group by p.cod_cober_reas;

		if _prima_cober_reas = 0 then
			update tmp_dist_rea
			   set porc_cober_reas = 100
			 where no_poliza       = a_no_poliza
			   and cod_cober_reas  = _cod_cober_reas;
		end if
	end if
end foreach

if _cod_ramo in ('001','003') then
	if _porc_proporcion <> 100 or a_no_poliza = '960042' then
		update tmp_dist_rea
		   set porc_cober_reas    = 70
		 where no_poliza    = a_no_poliza
		   and cod_cober_reas in ('001','003');

		update tmp_dist_rea
		   set porc_cober_reas    = 30
		 where no_poliza    = a_no_poliza
		   and cod_cober_reas in ('021','022');
	end if
end if

{if _porc_cober_reas <> 100 then
	let _mensaje = 'La Proporcion de la Distribución de Reaseguro no es igual a 100. Resultado de la Proporción: ' || trim(cast(_porc_cober_reas as char(6))) || ' , Por Favor Verifique';
	return 1, _mensaje;
end if}

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end
end procedure;
