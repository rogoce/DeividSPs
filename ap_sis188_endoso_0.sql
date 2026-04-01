

drop procedure ap_sis188_endoso_0;
create procedure ap_sis188_endoso_0(a_no_poliza char(10))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_tipoprod        char(3);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define _cod_cober_reas,_cod_no_renov char(3);
define _porc_cober_reas		dec(9,6);
define _porc_proporcion		dec(9,6);
define _dif_proporcion		dec(9,6);
define _proporcion			dec(10,6);
define _prima_cober_reas	dec(16,2);
define _prima_total			dec(16,2);
define _contador_ret		smallint;
define _ramo_sis			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _cnt                 integer;
define _porc_coas_ancon		dec(5,2);

set isolation to dirty read;

{if a_no_poliza = '1409115' then
	SET DEBUG FILE TO "sp_sis188.trc";
	trace on;
end if}
--set debug file to "sp_sis188.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
 	return _error,_mensaje;
end exception

--drop table if exists tmp_dist_rea;
create temp table tmp_dist_rea(
	no_poliza		char(10),
	cod_cober_reas	char(3),
	porc_cober_reas	dec(10,6)) with no log;

-- Lectura de la DistribuciÃ³n de Reaseguro de la PÃ³liza
select a.no_documento,
	   a.cod_ramo,
	   a.cod_no_renov,
	   b.cod_tipoprod
  into _no_documento,
	   _cod_ramo,
	   _cod_no_renov,
	   _cod_tipoprod
  from emipomae a, endedmae b
 where a.no_poliza = b.no_poliza
   and b.no_poliza = a_no_poliza
   and b.no_endoso = '00000';
 
 if _cod_tipoprod = '001' then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = a_no_poliza
		   and cod_coasegur = "036";    --ancon
else
	let _porc_coas_ancon = 100;
end if

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
 
let _flag = 0;
let _prima_total = 0;

select sum(prima_neta)
  into _prima_total
  from endedcob
 where no_poliza = a_no_poliza
   and no_endoso = '00000';
 
let _prima_total = (_porc_coas_ancon * _prima_total) / 100; 

let _cod_cober_reas = null;
   
foreach
	select p.cod_cober_reas,
		   sum(e.prima_neta)
	  into _cod_cober_reas,
		   _prima_cober_reas
	  from endedcob e, prdcober p
	 where e.no_poliza = a_no_poliza
	   and p.cod_cobertura = e.cod_cobertura
       and e.no_endoso = '00000'
	 group by p.cod_cober_reas
	
	let _proporcion = 0.00;
	if _prima_total is null then
		let _prima_total = 0.00;
	end if			
	
	let _prima_cober_reas = (_porc_coas_ancon * _prima_cober_reas) / 100;
	
	if _prima_total <> 0 then
		let _proporcion = (_prima_cober_reas/_prima_total) * 100;
	else
		select sum(e.prima_neta)
		  into _prima_total
		  from endedcob e, endedmae t
		 where e.no_poliza = t.no_poliza
		   and e.no_endoso = t.no_endoso
		   and t.no_poliza = a_no_poliza
           and t.no_endoso = '00000'
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
               and t.no_endoso = '00000'
		     group by p.cod_cober_reas;

			let _proporcion = (_prima_cober_reas/_prima_total) * 100;
			if _cod_cober_reas = '031' and _proporcion = 0 then
				let _proporcion = 100;
			end if
			let _prima_total = 0;
		else
			let _proporcion = 100;
		end if
	end if
	if _cod_cober_reas = '021' and _proporcion = 0 then
		let _proporcion = 100;
	end if
	if abs(_proporcion) > 100 or _proporcion < 0 then
		let _proporcion = 100;
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
		if abs(_proporcion) > 100 or _proporcion < 0 then
			let _proporcion = 100;
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

select nvl(sum(porc_cober_reas),0.00)
  into _porc_proporcion
  from tmp_dist_rea
 where no_poliza = a_no_poliza;

--Ajuste de la proporcion por redondeos
let _dif_proporcion = 100 - _porc_proporcion;

if abs(_dif_proporcion) < 1 then
	foreach
		select cod_cober_reas,
			   sum(porc_cober_reas)		   
		  into _cod_cober_reas,
			   _porc_cober_reas		   
		  from tmp_dist_rea
		 where no_poliza = a_no_poliza
		 group by cod_cober_reas
		having sum(porc_cober_reas) <>  0
		 order by 1 desc

		update tmp_dist_rea
		   set porc_cober_reas = porc_cober_reas + _dif_proporcion
		 where no_poliza = a_no_poliza
		   and cod_cober_reas = _cod_cober_reas;

		exit foreach;
	end foreach
end if
if _cod_no_renov = '039' then
	update tmp_dist_rea
	   set porc_cober_reas    = 100
	 where no_poliza    = a_no_poliza
	   and cod_cober_reas in ('002','033');

	delete from tmp_dist_rea
	 where cod_cober_reas not in ('002','033');
end if
{
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
end if}

{if _porc_cober_reas <> 100 then
	let _mensaje = 'La Proporcion de la DistribuciÃ³n de Reaseguro no es igual a 100. Resultado de la ProporciÃ³n: ' || trim(cast(_porc_cober_reas as char(6))) || ' , Por Favor Verifique';
	return 1, _mensaje;
end if}

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end
end procedure 
                                                                                                                                                       
